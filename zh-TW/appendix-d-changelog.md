---
title: "附錄 D：變更紀錄"
description: "PIF AI 白皮書版本變更紀錄"
appendix: D
lang: zh-TW
authors:
  - "Vincent Lin"
last_updated: 2026-04-19
last_modified_at: '2026-04-21T15:50:45Z'
---




# 附錄 D：變更紀錄

> 本附錄為白皮書之完整版本歷史。格式遵循 [Keep a Changelog](https://keepachangelog.com/) 慣例。

## v0.1 — 2026-04-19

### 新增

- **首次公開草稿**，採 `baiyuan-tech/geo-whitepaper` 相容格式
- **12 章正文**：
  - Ch.01 摘要與核心命題
  - Ch.02 台灣化粧品 PIF 法規背景
  - Ch.03 PIF 16 項深度解析
  - Ch.04 系統全局架構
  - Ch.05 前端技術棧
  - Ch.06 後端技術棧
  - Ch.07 AI 引擎（含 Claude Code 協同實踐）
  - Ch.08 資料庫與多租戶隔離
  - Ch.09 毒理資料 Pipeline
  - Ch.10 中心 RAG 整合架構（方案 C+，含 L1 Wiki + L2 向量 RAG）
  - Ch.11 安全模型
  - Ch.12 路線圖、部署與開源策略
- **4 個附錄**：
  - 附錄 A 縮寫與術語對照（50+ 條）
  - 附錄 B API 端點完整清單
  - 附錄 C 參考文獻
  - 附錄 D 變更紀錄（本檔）
- **Mermaid 圖表 15+ 張**：跨 ER、flowchart、sequence、state、gantt、pie
- **AI-friendly 結構化資料**：每章 YAML frontmatter + 每 README 嵌入 Schema.org `TechArticle` JSON-LD
- **英文版**（en/）同步提供全部章節對應翻譯（Phase 2 完成）

### CI 與工具

- `.github/workflows/build-pdf.yml`：Pandoc + XeLaTeX + Noto CJK 雙語 PDF 建置（matrix strategy: zh-TW, en）
- `.github/workflows/lint.yml`：markdownlint + lychee 連結檢查
- `.markdownlint.jsonc`：linting 規則對齊 geo-whitepaper
- `assets/pdf/concat.sh`：章節合併腳本（剝掉 frontmatter、JSON-LD、nav footer）
- `CITATION.cff`：GitHub 自動辨識引用資訊

### 授權

- 白皮書採 **CC BY-NC 4.0**
- 底層軟體（PIF AI code）採 **AGPL-3.0**

### 已知限制

- PIF AI 部分效能指標仍標示為「**目標值**」，等待 Phase 1 GA 後之正式 benchmark（見 §1.4.1）
- 英文章節為機器輔助翻譯 + 人工校對，法規術語可能仍需當地律師審閱（尤其 §2.5 國際比較）
- 圖表部分於 PDF 建置時 Mermaid 會被剝除並替換為「[See online version]」提示，因 XeLaTeX 不原生支援 Mermaid

### 對應 Commits（於 `baiyuan-tech/pif` 與 `baiyuan-tech/pif-whitepaper` 兩 repo）

- `f33392e` — feat(i18n): extend locales to Japanese, Korean, French with language dropdown
- （RAG 整合 commit，待 push）— feat(rag): central RAG integration (Scheme C+) backend
- （白皮書 commit，待 push）— docs: initial whitepaper v0.1 draft with 12 chapters + 4 appendices

## 未來計畫

### v0.2（預計 2026-09）

- Phase 1 GA 後之實測 benchmark 數據置換「目標值」
- SA 電子簽章章節擴充
- 新增章節：「法規變更監測與通知機制」（配合 Phase 3）
- 新增多國語版翻譯校對（ja, ko, fr 原為 i18n UI 完成，白皮書本體尚未譯）

### v1.0（預計 2026-12）

- 配合 Phase 2 GA 上線時發布
- 包含首批客戶案例研究（匿名化）
- 與學術界合作的正式同儕審查版本

---

**導覽** [← 附錄 C：參考文獻](appendix-c-references.md) · [返回 zh-TW README →](README.md)
