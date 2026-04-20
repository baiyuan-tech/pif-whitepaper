---
title: "第 11 章：安全模型"
description: "威脅模型、AES-256 加密、JWT+TOTP、稽核日誌、i18n 5 語系安全考量，以及與 OWASP Top 10 的對應"
chapter: 11
lang: zh-TW
authors:
  - "Vincent Lin"
keywords:
  - "security"
  - "threat model"
  - "AES-256"
  - "JWT"
  - "TOTP"
  - "OWASP"
  - "audit"
word_count: approx 2500
last_updated: 2026-04-19
last_modified_at: '2026-04-19T21:19:43+08:00'
---


# 第 11 章：安全模型

> 本章是審計員、資安研究者、企業資安長的主要閱讀章。我們以 STRIDE 威脅模型逐項盤點 PIF AI 的攻擊面，對每項威脅給出緩解措施，並對應到 OWASP Top 10（2021）。最後說明 i18n 5 語系於資安上的特殊考量（super-admin 不套用）。

## 📌 本章重點

- 採用 **STRIDE** 威脅建模；對應 OWASP Top 10 逐項檢查
- 加密雙層：配方 AES-256 應用層 + S3 SSE-KMS 儲存層
- 認證雙因子：JWT access token（15 分鐘）+ Refresh token；SA 操作需 TOTP 二次驗證
- 稽核日誌不可篡改（DB user 無 UPDATE/DELETE 權），歸檔至 WORM S3
- Super-admin 介面不套用 i18n 是**安全設計**，避免翻譯錯誤引發誤操作

## 11.1 威脅模型（STRIDE）

STRIDE[^1]（Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege）為 PIF AI 採用的威脅分類法。

### 11.1.1 資產盤點

優先保護資產：

| 資產 | 機敏性 | 影響 |
|------|--------|------|
| 配方（INCI + 濃度） | **極高** | 商業機密外洩 → 法律訴訟 |
| SA 簽章 | **極高** | 偽造 → 法規責任 + 刑事偽造文書 |
| 使用者憑證 | 高 | 身份竊取 → 全面資料洩漏 |
| 毒理摘要 | 中 | 僅公開資料庫整理，影響有限 |
| 系統組態 | 高 | 影響所有租戶可用性 |

### 11.1.2 威脅矩陣

| 威脅類型 | 代表攻擊 | 緩解 |
|------|---------|------|
| **Spoofing** | 冒充其他使用者 | JWT 短效 + Refresh + 裝置指紋（規劃） |
| **Tampering** | 篡改請求 / 稽核 | HTTPS 全站 + audit log 不可篡改 |
| **Repudiation** | 否認 SA 簽章 | SA 需 TOTP + 電子簽章記錄 + IP + UA 於 audit |
| **Information disclosure** | 配方外洩 | 四層隔離（§10）+ AES-256 + 稽核觸發警報 |
| **Denial of service** | 密集 AI 呼叫 | Rate limit + Cloudflare + fail-soft 降級 |
| **Elevation of privilege** | 一般使用者成 super admin | DB CHECK constraint on `role` + super-admin 需另建 user record（非升級） |

## 11.2 認證與授權

### 11.2.1 身份驗證

PIF AI 採雙重機制：

1. **Email + password**（加 bcrypt 12 rounds）
2. **Google OAuth**（Turnstile 反機器人）
3. **Passkey**（WebAuthn，規劃中）

### 11.2.2 JWT 設計

| Token | 存活期 | 存放 | 用途 |
|------|---------|------|------|
| Access Token | 15 分鐘 | Memory（不入 localStorage） | API 授權 |
| Refresh Token | 7 天 | HttpOnly Cookie | 換發 Access |
| Session cookie（NextAuth） | 24 小時 | HttpOnly + Secure | 前端 Session |

Access token 短效使被盜用時間窗口縮短；refresh token 設於 HttpOnly Cookie 避免 XSS 竊取。

### 11.2.3 TOTP 二次驗證

SA 為高敏感角色。任何 `sa_review.*` 端點呼叫前皆需通過 TOTP（Google Authenticator / Authy 皆相容），實作：

```python
# app/core/security.py (概念)
def verify_totp(user: User, code: str) -> bool:
    if not user.totp_enabled:
        return True  # 尚未啟用 TOTP 的使用者（非 SA）
    totp = pyotp.TOTP(user.totp_secret)
    return totp.verify(code, valid_window=1)
```

DB 欄位 `users.totp_secret` 以 application-level encryption 存儲，即使 DB 被 dump 也不易還原。

### 11.2.4 超級管理員隔離

Super admin（Baiyuan Tech 內部維運）是 PIF 最高權限。設計上隔離：

- 獨立登入 URL：`/super-admin/login`
- 使用獨立 DB user（`pifai_superadmin`）取得 BYPASSRLS 權限
- 所有操作強制二次驗證
- **Super-admin UI 不套用 i18n**（見 §11.5）

## 11.3 加密

### 11.3.1 傳輸加密

- 全站強制 HTTPS（**TLS 1.3** only）
- HSTS `max-age=31536000; includeSubDomains; preload`
- Certificate 由 Let's Encrypt 自動更新（cert-manager on K8s / certbot on Docker）

### 11.3.2 配方檔案雙層加密

如 §8.5 所述，配方檔案採**應用層 AES-256-GCM** + **S3 SSE-KMS**：

```python
# app/services/encryption.py (概念)
def encrypt_formula(plaintext: bytes, key: bytes) -> EncryptedPayload:
    nonce = os.urandom(12)
    aes = Cipher(algorithms.AES(key), modes.GCM(nonce)).encryptor()
    ciphertext = aes.update(plaintext) + aes.finalize()
    return EncryptedPayload(
        nonce=nonce,
        ciphertext=ciphertext,
        tag=aes.tag,
    )
```

金鑰 `FILE_ENCRYPTION_KEY` 長 256-bit，由 Secret Manager（AWS Secrets Manager / HashiCorp Vault）管理，**不進 git、不進 env file 明文**（透過 IAM role 或 service token 動態載入）。

### 11.3.3 DB 欄位加密

敏感欄位於 application 層加密後才寫入：

| 欄位 | 加密方式 | 理由 |
|------|----------|------|
| `users.totp_secret` | Fernet（對稱） | 2FA 種子 |
| `users.sa_certificate_url` | Fernet | SA 資格證明連結 |
| `organizations.api_keys` | Fernet | 第三方服務金鑰（如 ECHA） |

## 11.4 稽核

### 11.4.1 記錄範圍

詳見 §8.4。對安全關鍵操作補充：

| 事件 | 觸發位置 |
|------|----------|
| `auth.login_success` / `auth.login_failed` | `app/api/v1/auth.py` |
| `auth.totp_failed` | TOTP 驗證錯誤 |
| `org.data_export` | 組織資料下載 |
| `admin.bypass_rls` | Super admin 使用 BYPASSRLS |
| `security.suspicious_login` | 異常 IP 或失敗次數過多 |

### 11.4.2 不可篡改

- 應用層 DB user 僅有 INSERT 權
- 每日 cron 將當日 audit_logs 輸出至 WORM S3 bucket（Object Lock compliance mode, 10 年保留）
- 每筆 log 含前一筆的 SHA-256 hash（hash chain，類似 blockchain 概念）

### 11.4.3 即時警報

以下事件觸發即時通知（Slack / PagerDuty）：

- `auth.login_failed` 連續 5 次（同 user 或 IP）
- `admin.bypass_rls` （任何時候）
- `rag_client` 連續 5 次失敗（外部服務異常）
- DB connection pool 耗盡

## 11.5 i18n 與安全

### 11.5.1 為何 super-admin 不套用 i18n

PIF AI 前端支援 5 語系（zh-TW / en / ja / ko / fr）。但 `/super-admin/*` 路徑**刻意不引入 `useI18n()`**。安全理由：

1. **維運操作嚴謹性**：「撤銷封測豁免」若翻譯為英文「revoke beta exemption」可能被誤解為「撤回此次請求」
2. **翻譯校對風險**：5 語系維運文字需 5 位母語審閱者；少一人即降低可靠性
3. **縮減攻擊面**：翻譯字串也是輸入；若有 XSS 風險，super-admin 只用一種語言就少 4 倍曝險
4. **內部共同語言**：Baiyuan Tech 內部維運者母語為中文，直接用中文溝通最清楚

此為**設計決策**，於 [CLAUDE.md](https://github.com/baiyuan-tech/pif/blob/master/CLAUDE.md) 與 [memory/project_pif_i18n.md](https://github.com/baiyuan-tech/pif/) 明確記錄。

### 11.5.2 一般使用者介面的翻譯安全

5 語系 JSON 的專業翻譯由 Claude Code 協同產出（非機翻），但仍有安全要求：

- 翻譯字串作為 React 屬性值時用 `{t("key")}` 而非直接 HTML，避免 XSS
- 特殊字元（< > & "）由 React 自動 escape
- 不使用 `dangerouslySetInnerHTML` 渲染翻譯

## 11.6 與 OWASP Top 10 (2021) 對應

| OWASP Risk | PIF AI 對應 |
|------|------|
| **A01 Broken Access Control** | 四層隔離（§10.3.3）|
| **A02 Cryptographic Failures** | AES-256 雙層 + TLS 1.3 + Fernet DB |
| **A03 Injection** | SQLAlchemy ORM + Pydantic 驗證 + zod 前端 |
| **A04 Insecure Design** | 威脅模型主導設計；fail-soft 為原則 |
| **A05 Security Misconfiguration** | Docker image 經 trivy scan；生產環境無 DEBUG |
| **A06 Vulnerable Components** | dependabot + renovate 自動更新 |
| **A07 ID & Auth Failures** | JWT 短效 + TOTP + rate limit |
| **A08 Software & Data Integrity** | audit log 不可篡改 + hash chain |
| **A09 Logging & Monitoring** | 結構化日誌 + 即時警報 |
| **A10 SSRF** | 外部 API 白名單（只 allow PubChem/ECHA/RAG）|

## 11.7 威脅狩獵（future）

Phase 2+ 規劃：

- **Anomaly detection**：使用者行為 baseline + 偏離警示
- **SIEM 整合**：audit logs → ELK / Datadog
- **Bug bounty**：公開 vulnerability disclosure program（見母專案 SECURITY.md）

## 📚 參考資料

[^1]: Microsoft. *The STRIDE Threat Model*. <https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats>
[^2]: OWASP. *OWASP Top 10 (2021)*. <https://owasp.org/Top10/>
[^3]: NIST. *SP 800-63B Digital Identity Guidelines*. 2017 (revised).
[^4]: RFC 6238. *TOTP: Time-Based One-Time Password Algorithm*.

## 📝 修訂記錄

| 版本 | 日期 | 摘要 |
|:---:|:---:|---|
| v0.1 | 2026-04-19 | 首次撰寫。涵蓋 STRIDE、認證、加密、稽核、i18n 安全、OWASP 對應 |

---

© 2026 Baiyuan Tech. Licensed under CC BY-NC 4.0.

**導覽** [← 第 10 章：中心 RAG](ch10-central-rag.md) · [第 12 章：路線圖、部署與開源策略 →](ch12-roadmap-deployment-opensource.md)
