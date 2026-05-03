---
title: "附錄 B：API 端點完整清單"
description: "PIF AI 所有 API 端點 — 前端 BFF、後端 FastAPI v1、中心 RAG 串接端點"
appendix: B
lang: zh-TW
authors:
  - "Vincent Lin"
last_updated: 2026-04-19
last_modified_at: '2026-05-03T03:56:28Z'
---








# 附錄 B：API 端點完整清單

> 本附錄列出 PIF AI 所有 API 端點。開發者可據此設計整合；審閱者可據此檢視覆蓋率。全部端點於程式碼中皆可驗證。

## B.1 後端 FastAPI (`/api/v1/*`)

### B.1.1 認證 `/auth`

| 方法 | 路徑 | 說明 | 認證 |
|:---:|------|------|:---:|
| POST | `/api/v1/auth/register` | 註冊新使用者 | 否 |
| POST | `/api/v1/auth/login` | Email + password 登入 | 否 |
| POST | `/api/v1/auth/google` | Google OAuth 登入 | 否 |
| POST | `/api/v1/auth/refresh` | 換發 access token | Refresh |
| POST | `/api/v1/auth/logout` | 登出 + 撤銷 refresh | JWT |
| POST | `/api/v1/auth/verify-email` | 驗證 email | 否 |
| POST | `/api/v1/auth/forgot-password` | 忘記密碼 | 否 |
| POST | `/api/v1/auth/reset-password` | 重設密碼 | Token |
| POST | `/api/v1/auth/setup-2fa` | 啟用 TOTP | JWT |
| POST | `/api/v1/auth/verify-2fa` | 驗證 TOTP | JWT |

### B.1.2 產品 `/products`

| 方法 | 路徑 | 說明 |
|:---:|------|------|
| POST | `/api/v1/products` | 建立產品（**同步觸發 RAG KB 建立 fail-soft**）|
| GET | `/api/v1/products` | 列表（分頁） |
| GET | `/api/v1/products/{id}` | 詳情 |
| PUT | `/api/v1/products/{id}` | 更新 |
| DELETE | `/api/v1/products/{id}` | 刪除（**同步觸發 RAG KB 刪除**） |

全部需 JWT + `require_plan_access`。

### B.1.3 PIF 建檔 `/products/{id}/pif`

| 方法 | 路徑 | 說明 |
|:---:|------|------|
| GET | `/api/v1/products/{id}/pif` | 取得 16 項狀態總覽 |
| POST | `/api/v1/products/{id}/pif/upload` | 上傳檔案（指定 `item_number`） |
| POST | `/api/v1/products/{id}/pif/analyze` | 觸發 AI 分析（非同步） |
| GET | `/api/v1/products/{id}/pif/{item}` | 特定項目詳情 |
| PUT | `/api/v1/products/{id}/pif/{item}` | 更新特定項目 |
| POST | `/api/v1/products/{id}/pif/generate` | 觸發完整 PIF PDF 生成 |
| GET | `/api/v1/products/{id}/pif/download` | 下載 PIF PDF |

### B.1.4 成分與毒理 `/ingredients`

| 方法 | 路徑 | 說明 |
|:---:|------|------|
| GET | `/api/v1/ingredients/search?q=` | 搜尋（INCI / CAS） |
| GET | `/api/v1/ingredients/{id}` | 詳情（含毒理） |
| POST | `/api/v1/ingredients/{id}/toxicology` | 觸發毒理更新 |
| POST | `/api/v1/ingredients/check-formula` | 批量檢查配方合規 |

### B.1.5 SA 審閱 `/sa`

| 方法 | 路徑 | 說明 | 角色 |
|:---:|------|------|:---:|
| GET | `/api/v1/sa/pending` | 待審案件清單 | SA |
| GET | `/api/v1/sa/reviews/{id}` | 審閱詳情 | SA |
| PUT | `/api/v1/sa/reviews/{id}` | 提交審閱意見 | SA + TOTP |
| POST | `/api/v1/sa/reviews/{id}/sign` | 電子簽署 | SA + TOTP |
| POST | `/api/v1/sa/reviews/{id}/revision` | 要求修正 | SA |

### B.1.6 組織設定 `/settings`

| 方法 | 路徑 | 說明 | 角色 |
|:---:|------|------|:---:|
| GET | `/api/v1/settings/org` | 組織設定 | any |
| PUT | `/api/v1/settings/org` | 更新組織 | admin |
| GET | `/api/v1/settings/api-keys` | API 金鑰列表 | admin |
| PUT | `/api/v1/settings/api-keys/{key}` | 設定外部 API 金鑰 | admin |
| POST | `/api/v1/settings/api-keys/{key}/test` | 測試連線 | admin |

### B.1.7 管理員 `/admin`

| 方法 | 路徑 | 說明 | 角色 |
|:---:|------|------|:---:|
| POST | `/api/v1/admin/bootstrap` | 初始化超管帳號 | SECRET |
| GET | `/api/v1/admin/organizations` | 所有組織 | super_admin |
| PUT | `/api/v1/admin/organizations/{id}/plan` | 方案升降 | super_admin |
| POST | `/api/v1/admin/organizations/{id}/exempt` | 封測豁免 | super_admin |
| GET | `/api/v1/admin/audit-logs` | 稽核日誌 | super_admin |

### B.1.8 化學資料同步 `/chemical-sync`

| 方法 | 路徑 | 說明 | 角色 |
|:---:|------|------|:---:|
| POST | `/api/v1/chemical-sync/tfda` | 同步 TFDA 清冊 | super_admin |
| POST | `/api/v1/chemical-sync/echa` | 同步 ECHA C&L | super_admin |
| GET | `/api/v1/chemical-sync/status` | 同步狀態 | super_admin |

### B.1.9 PIF 合規引擎（Phase 22–23）

> 詳見第 13 章。涵蓋業者類型責任矩陣、7 步驟工作流、V0–V3 版本快照、變更偵測、跨 Item lint、合規 PDF 產出。全部需 JWT + `require_plan_access`。

#### 責任歸屬矩陣（Phase 22A）

| 方法 | 路徑 | 說明 |
|:---:|------|------|
| GET | `/api/v1/pif/responsibility-matrix?org_type=brand\|oem\|importer\|consultant` | 通用責任矩陣（4 業者類型 × 16 項，64 格） |
| GET | `/api/v1/products/{id}/pif-responsibilities` | 自動依 `product.org.type` 帶出對應業者類型之 16 項責任配置 |

#### 7 步驟工作流與委外（Phase 22B）

| 方法 | 路徑 | 說明 |
|:---:|------|------|
| GET | `/api/v1/products/{id}/pif-workflow` | 7 步驟工作流自動推導（含 outsourcing_suggestions） |
| GET | `/api/v1/products/{id}/outsourcings` | 列出已登錄之委外項目 |
| POST | `/api/v1/products/{id}/outsourcings` | 新增委外（`item_number` + `vendor` + `note`） |
| DELETE | `/api/v1/products/{id}/outsourcings/{id}` | 移除委外 |

#### V0–V3 版本快照（Phase 22C / 22E / 23C）

| 方法 | 路徑 | 說明 |
|:---:|------|------|
| POST | `/api/v1/products/{id}/pif-versions/snapshot` | 建立當下 16 項狀態之快照（V0/V1/V2/V3） |
| GET | `/api/v1/products/{id}/pif-versions` | 列出所有歷史快照 |
| GET | `/api/v1/products/{id}/pif-versions/expiring` | 文件時效聚合（GMP / 試驗報告 / §12 通報倒數） |
| GET | `/api/v1/products/{id}/pif-versions/change-detection` | 比對 fingerprints；回傳 `needs_resign` + `suggested_next_version` |
| POST | `/api/v1/products/{id}/pif-versions/auto-draft` | 一鍵建立 V2/V3 草案（unsigned） |

#### 跨 Item lint（Phase 22D / 23A / 23B）

| 方法 | 路徑 | 說明 |
|:---:|------|------|
| GET | `/api/v1/products/{id}/cross-item-lint` | 執行 14 條規則（R1–R14），回傳 alerts + 罰則對照（§22–§25 罰鍰範圍） |

#### 合規 PIF PDF（Phase 23E）

| 方法 | 路徑 | 說明 |
|:---:|------|------|
| GET | `/api/v1/products/{id}/pif-versions/regulatory-pdf` | 產出當下 PIF 14 頁合規 PDF（即時計算 lint） |
| GET | `/api/v1/products/{id}/pif-versions/{snapshot_id}/regulatory-pdf` | 產出指定 V0/V1/V2/V3 快照之 PDF（從 `items_snapshot` 還原） |

回應 `Content-Disposition` 採 RFC 5987 雙標頭支援中文檔名。

## B.2 前端 BFF (Next.js API Routes, `/api/*`)

| 方法 | 路徑 | 說明 |
|:---:|------|------|
| POST | `/api/auth/session` | NextAuth session endpoint |
| POST | `/api/auth/callback/google` | Google OAuth callback |
| POST | `/api/files/presign` | 產生 S3 pre-signed URL |
| POST | `/api/files/finalize` | 完成檔案上傳登記 |
| GET | `/api/dashboard` | Dashboard 聚合資料 |
| GET | `/api/plan-status` | 當前方案狀態（用於 UI 顯示） |

## B.3 中心 RAG（PIF backend 出站）

PIF backend 呼叫 `rag.baiyuan.io`（認證：`X-RAG-API-Key` + `X-Tenant-ID`）：

| 方法 | 路徑 | PIF 使用時機 |
|:---:|------|------|
| POST | `/api/v1/knowledge-bases` | 建立產品對應 KB（`safe_create_kb`） |
| DELETE | `/api/v1/knowledge-bases/{id}` | 刪除 KB（`safe_delete_kb`） |
| POST | `/api/v1/ask` | 毒理 / 配方分析查詢（`RagClient.ask`） |
| POST | `/api/v1/documents/text` | 匯入業者提供的私有知識（Phase 2） |
| POST | `/api/v1/documents/url` | 匯入 URL（Phase 2） |
| POST | `/api/v1/documents/file` | 匯入檔案（Phase 2） |
| POST | `/api/v1/knowledge-bases/{id}/wiki/compile` | 觸發 L1 Wiki 編譯（Phase 2） |

## B.4 外部整合（PIF backend 出站）

| 服務 | 端點 | 認證 |
|------|------|------|
| PubChem | `https://pubchem.ncbi.nlm.nih.gov/rest/pug/*` | 無（有 rate limit） |
| PubChem View | `https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/*` | 無 |
| ECHA C&L | `https://echa.europa.eu/api/*` | API Key |
| OECD eChemPortal | `https://www.echemportal.org/echemportal/api/*` | 無（條款受限） |
| Anthropic | `https://api.anthropic.com/v1/messages` | `x-api-key` |
| Google OAuth | `https://oauth2.googleapis.com/token` | Client Secret |

## B.5 OpenAPI schema

FastAPI 自動產出 OpenAPI 3.1 schema：

- JSON：`https://pif.baiyuan.io/api/v1/openapi.json`
- Swagger UI：`https://pif.baiyuan.io/api/v1/docs`
- ReDoc：`https://pif.baiyuan.io/api/v1/redoc`

生產環境可能關閉 docs（僅於 `APP_ENV=development` 開啟）；完整 schema 永遠可由 OpenAPI JSON 取得。

---

**導覽** [← 附錄 A：縮寫與術語](appendix-a-glossary.md) · [附錄 C：參考文獻 →](appendix-c-references.md)
