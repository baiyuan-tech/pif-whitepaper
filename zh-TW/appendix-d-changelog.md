---
title: "附錄 D：變更紀錄"
description: "PIF AI 白皮書版本變更紀錄"
appendix: D
lang: zh-TW
authors:
  - "Vincent Lin"
last_updated: 2026-04-19
last_modified_at: '2026-05-03T04:14:20Z'
---










# 附錄 D：變更紀錄

> 本附錄為白皮書之完整版本歷史。格式遵循 [Keep a Changelog](https://keepachangelog.com/) 慣例。

## v0.2 — 2026-04-30

### 新增

- **第 13 章「PIF 合規引擎深度解析（Phase 22–23）」**（zh-TW + en 雙語）— 覆蓋 11 個 sub-phase 累積之合規能力：
  - §13.1 生命週期 5 階段重組（pre_launch / development / manufacturing / post_launch / signing）
  - §13.1.2 業者類型 × 16 項責任歸屬矩陣（4 × 16 = 64 格）
  - §13.1.3 7 步驟工作流自動推導 + 委外建議
  - §13.2 PIF 版本管理 V0/V1/V2/V3 快照
  - §13.2.2 變更偵測（formula / process / packaging fingerprints, SHA-256）
  - §13.2.3 一鍵 V2/V3 草案
  - §13.2.4 文件時效自動追蹤（GMP / 試驗報告 / §12 通報倒數）
  - §13.3 跨 Item lint 引擎 14 條規則 R1–R14（含 R1 進階過濾）
  - §13.4 罰則對照表（§22–§25 罰鍰範圍 NT$3 萬至 NT$500 萬）
  - §13.5 SA 簽章 metadata（method / hash / ip / cert ref）
  - §13.6 合規 PIF PDF 14 頁一鍵產出（WeasyPrint A4 + Noto Sans CJK）
  - §13.6.6 e2e 真實數據雙路徑驗證（依編號 / 依階段）

- **附錄 B 新增 §B.1.9 PIF 合規引擎端點**（共 14 條新端點）：
  - 責任矩陣 2 條
  - 工作流與委外 4 條
  - V0–V3 版本快照 5 條
  - 跨 Item lint 1 條
  - 合規 PDF 2 條

### 變更

- 第 12 章末段「導覽」連結由「附錄 A」改為「第 13 章」
- 附錄 A 起始「導覽」連結由「第 12 章」改為「第 13 章」
- README TOC 加入第 13 章
- CITATION.cff version 由 `0.1` 升至 `0.2`，date-released 更新為 2026-04-30

### 對應 Commits

- 母 repo `VincentLinB/pif`：Phase 22.0 → Phase 23E（commits ac44591, 7618936, 8755f8d, 43d649e, 91190a2 等）
- 白皮書 repo：本次 v0.2 commit

### 已知限制

- 第 13 章引用之效能數據（PDF 14 頁 2-3 秒、PDF 大小 640-690 KB）為實測值；其他 Phase 22-23 端點之延遲尚未 benchmark
- 跨 Item lint R1–R14 規則表為 PIF AI 對 ITRI 講義之解讀；其他 SA 解讀可能略有差異，歡迎透過 GitHub issue 討論

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
