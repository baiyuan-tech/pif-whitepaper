<!-- AI-friendly structured data
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "TechArticle",
  "headline": "PIF AI 技術白皮書 (繁體中文版)",
  "inLanguage": "zh-TW",
  "datePublished": "2026-04-19",
  "dateModified": "2026-04-30",
  "author": {"@type": "Person", "name": "Vincent Lin", "affiliation": "Baiyuan Tech"},
  "license": "https://creativecommons.org/licenses/by-nc/4.0/",
  "isPartOf": {"@type": "CreativeWorkSeries", "name": "Baiyuan Tech Whitepapers"},
  "url": "https://github.com/baiyuan-tech/pif-whitepaper/tree/master/zh-TW"
}
</script>
-->

# PIF AI 技術白皮書（繁體中文版）

*多租戶 AI 輔助化粧品 PIF 建檔平台*

**版本**：v0.2 · **日期**：2026-04-30 · **作者**：Vincent Lin（Baiyuan Tech）
**License**：白皮書本體採 [CC BY-NC 4.0](../LICENSE)；PIF AI 底層軟體採 AGPL-3.0

> [!NOTE]
> 本文件為學術暨技術白皮書。凡涉及效能、使用者數、營收等數字，若未實測或實際查詢，一律以「**目標值**」或「**預期值**」標示，以符合《開發憲法》中「不可模擬數據、完整測試後才回報」之規範。
>
> 本專案（含程式碼與本白皮書）以 [Anthropic Claude Code](https://docs.claude.com/en/docs/claude-code/overview) 輔助完成開發與撰寫，是 LLM 輔助工程於法規合規領域的開源案例研究。

---

## 🧭 目錄

### 導論 Part I

| § | 章節 | 主題 |
|:--:|------|------|
| [01](ch01-abstract.md) | **摘要與核心命題** | TL;DR、四大設計命題、系統總覽圖 |
| [02](ch02-regulatory-background.md) | **台灣化粧品 PIF 法規背景** | 化粧品衛安法第 8 條、2026-07 強制日、罰則 |
| [03](ch03-pif-16-items.md) | **PIF 16 項深度解析** | 每項資料來源、AI 處理方式、DB 關聯 |

### 系統架構 Part II

| § | 章節 | 主題 |
|:--:|------|------|
| [04](ch04-system-architecture.md) | **系統全局架構** | 五層架構圖、模組邊界、資料流 |
| [05](ch05-frontend-stack.md) | **前端技術棧** | Next.js 15 App Router、RSC、shadcn/ui |
| [06](ch06-backend-stack.md) | **後端技術棧** | FastAPI、SQLAlchemy async、Alembic vs inline migration |

### AI 與資料 Part III

| § | 章節 | 主題 |
|:--:|------|------|
| [07](ch07-ai-engine.md) | **AI 引擎** | Claude Tool Use、Claude Code 開發實踐、信心度評分 |
| [08](ch08-multi-tenancy.md) | **資料庫與多租戶隔離** | Schema、Row-Level Security、`current_setting` 模式 |
| [09](ch09-toxicology-pipeline.md) | **毒理資料 Pipeline** | PubChem / TFDA / ECHA / OECD 交叉查詢 |
| [10](ch10-central-rag.md) | **中心 RAG 整合架構** | 方案 C+ 隔離、兩 header 認證、fail-soft |

### 安全與合規流程 Part IV

| § | 章節 | 主題 |
|:--:|------|------|
| [11](ch11-security-model.md) | **安全模型** | AES-256、JWT、TOTP、稽核、威脅模型、i18n 5 語系 |
| [12](ch12-roadmap-deployment-opensource.md) | **路線圖、部署與開源策略** | Docker → K8s、AGPL 選擇、Phase 1-3、社群貢獻 |
| [13](ch13-compliance-engine.md) | **PIF 合規引擎深度解析（Phase 22-23）** | 生命週期 5 階段、業者責任矩陣、14 條跨 Item lint、V0-V3 快照、罰則對照、合規 PDF 14 頁產出 |

### 附錄 Appendices

| § | 章節 | 主題 |
|:--:|------|------|
| [A](appendix-a-glossary.md) | **縮寫與術語對照** | PIF、SA、TFDA、INCI 等 50+ 條 |
| [B](appendix-b-api-endpoints.md) | **API 端點完整清單** | 前端 BFF + 後端 FastAPI 所有端點 |
| [C](appendix-c-references.md) | **參考文獻** | 法規條文、標準、RFC、學術論文 |
| [D](appendix-d-changelog.md) | **變更紀錄** | 白皮書修訂歷史 |

---

## 📖 閱讀建議

**循序閱讀**：學術研究或法規專業人士建議由 §1 開始，逐章至 §13，再閱讀附錄。

**快速上手**（開源貢獻者）：
1. 先讀 [§1 摘要](ch01-abstract.md) 建立整體印象
2. 跳到 [§4 系統架構](ch04-system-architecture.md) 了解模組邊界
3. 依您想貢獻的區塊進入對應章節（前端→§5、後端→§6、AI→§7、RAG→§10）
4. 完成後看 [§12 路線圖](ch12-roadmap-deployment-opensource.md)
5. 到母專案閱讀 [CONTRIBUTING.md](https://github.com/baiyuan-tech/pif/blob/master/CONTRIBUTING.md) 開工

**法規合規**：§2 → §3 → §9 → §13（§11 節中 SA 流程段落）→ 附錄 C。

**資安審閱**：§10 → §11 + 母專案 [SECURITY.md](https://github.com/baiyuan-tech/pif/blob/master/SECURITY.md)。

---

## 📊 白皮書規模

| 指標 | 目標 | 目前狀態 |
|---|---|---|
| 章節 | 13 章 + 4 附錄 | v0.2 完成 |
| 繁中字數 | 30,000+ 字 | v0.2 ≈ 33,800 字 |
| 圖表 | 15+ Mermaid 圖 | v0.2 ≈ 16 張 |
| 程式碼引用 | 40+ 條（格式 `file:line`） | v0.2 完成 |
| 參考文獻 | 30+ 條 | v0.2 完成 |

> [!NOTE]
> 本 README 為目錄頁。完整 PDF 可於 [GitHub Releases](https://github.com/baiyuan-tech/pif-whitepaper/releases) 下載。
> PDF 發佈路徑慣例：`releases/download/<version>/whitepaper-zh-TW.pdf`。

---

## 🔗 跨語版本

- 🇹🇼 [繁體中文版](../zh-TW/)（您正在閱讀）
- 🇺🇸 [English version](../en/)

---

**導覽** [← 返回 repo 根目錄](../README.md) · [格式規範 →](../FORMAT.md)
