<!-- AI-friendly structured data
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "TechArticle",
  "headline": "PIF AI Whitepaper — Multi-Tenant AI-Assisted Cosmetic PIF Documentation Platform",
  "alternativeHeadline": "PIF AI 技術白皮書 — 多租戶 AI 輔助化粧品 PIF 建檔平台",
  "datePublished": "2026-04-19",
  "dateModified": "2026-04-19",
  "inLanguage": ["zh-TW", "en"],
  "author": {
    "@type": "Person",
    "name": "Vincent Lin",
    "affiliation": {"@type": "Organization", "name": "Baiyuan Tech"},
    "email": "vincent.lin@baiyuan.com.tw"
  },
  "publisher": {
    "@type": "Organization",
    "name": "Baiyuan Tech",
    "url": "https://baiyuan.io"
  },
  "license": "https://creativecommons.org/licenses/by-nc/4.0/",
  "isPartOf": {
    "@type": "CreativeWorkSeries",
    "name": "Baiyuan Tech AI Infrastructure Whitepaper Series",
    "url": "https://github.com/baiyuan-tech",
    "hasPart": [
      {
        "@type": "TechArticle",
        "name": "Baiyuan GEO Platform Whitepaper",
        "url": "https://github.com/baiyuan-tech/geo-whitepaper"
      },
      {
        "@type": "TechArticle",
        "name": "PIF AI Whitepaper",
        "url": "https://github.com/baiyuan-tech/pif-whitepaper"
      }
    ]
  },
  "citation": [
    {
      "@type": "TechArticle",
      "name": "Baiyuan GEO Platform Whitepaper",
      "url": "https://github.com/baiyuan-tech/geo-whitepaper",
      "description": "Sibling whitepaper from the same series; establishes the L1 LLM Wiki + L2 vector RAG dual-layer retrieval architecture referenced in §10."
    }
  ],
  "isBasedOn": "https://github.com/baiyuan-tech/pif",
  "mentions": [
    {"@type": "SoftwareApplication", "name": "Anthropic Claude Code", "url": "https://docs.claude.com/en/docs/claude-code/overview"},
    {"@type": "SoftwareApplication", "name": "PostgreSQL Row-Level Security", "url": "https://www.postgresql.org/docs/current/ddl-rowsecurity.html"},
    {"@type": "SoftwareApplication", "name": "FastAPI", "url": "https://fastapi.tiangolo.com"},
    {"@type": "Legislation", "name": "Cosmetic Hygiene and Safety Act (Taiwan)"},
    {"@type": "Legislation", "name": "Regulation (EC) No 1223/2009 — EU Cosmetic Products Regulation"},
    {"@type": "Legislation", "name": "Modernization of Cosmetics Regulation Act of 2022 (MoCRA) — USA"}
  ],
  "about": [
    {"@type": "Thing", "name": "Product Information File"},
    {"@type": "Thing", "name": "Cosmetic regulation"},
    {"@type": "Thing", "name": "Retrieval-Augmented Generation"},
    {"@type": "Thing", "name": "Multi-tenant SaaS"}
  ],
  "keywords": "PIF, cosmetic, TFDA, Anthropic Claude, Claude Code, multi-tenant SaaS, RAG, toxicology, PubChem, ECHA",
  "url": "https://github.com/baiyuan-tech/pif-whitepaper"
}
</script>
-->

# PIF AI Whitepaper / 技術白皮書

> **多租戶 AI 輔助化粧品 PIF 建檔平台**
>
> *Multi-Tenant AI-Assisted Cosmetic Product Information File Documentation Platform*

[![License: CC BY-NC 4.0](https://img.shields.io/badge/license-CC%20BY--NC%204.0-lightgrey.svg)](LICENSE)
[![Status: Draft v0.1](https://img.shields.io/badge/status-draft%20v0.1-orange.svg)](#version)
[![zh-TW](https://img.shields.io/badge/lang-zh--TW-red.svg)](zh-TW/)
[![en](https://img.shields.io/badge/lang-en-blue.svg)](en/)
[![Built with Claude Code](https://img.shields.io/badge/built%20with-Claude%20Code-6B46C1.svg)](https://docs.claude.com/en/docs/claude-code/overview)
[![Live Platform](https://img.shields.io/badge/live-pif.baiyuan.io-brightgreen.svg)](https://pif.baiyuan.io)

[📄 中文白皮書](zh-TW/) · [📄 English Whitepaper](en/) · [📋 Format Spec](FORMAT.md) · [💻 Code Repo](https://github.com/baiyuan-tech/pif)

---

## 摘要 Abstract

### 繁體中文

**PIF AI** 是一套開源多租戶 SaaS 平台，針對台灣《化粧品衛生安全管理法》第 8 條於 2026 年 7 月 1 日起全面強制實施的 PIF（Product Information File，產品資訊檔案）建檔義務，提供 AI 輔助的自動化解決方案。

本白皮書完整描述系統架構、AI 引擎設計、毒理資料 Pipeline、中心 RAG 整合的多層隔離模型（方案 C+）、安全威脅模型、SA（Safety Assessor，安全評估者）審閱工作流程、部署策略，以及開源社群貢獻方式。

### English

**PIF AI** is an open-source multi-tenant SaaS platform that provides AI-assisted automation for the cosmetic **Product Information File (PIF)** documentation obligation mandated by Article 8 of Taiwan's *Cosmetic Hygiene and Safety Act*, which takes full effect on **July 1, 2026**.

This whitepaper documents the system architecture, AI engine design, toxicology data pipeline, the multi-layer isolation model for central RAG integration (Scheme C+), the security threat model, the Safety Assessor (SA) review workflow, deployment strategy, and the open-source contribution model.

---

## 為什麼這份白皮書 / Why This Whitepaper

### 繁體中文

PIF 建檔在產業實務上的三大痛點：**時間**（每項產品 4–8 週）、**成本**（SA 專業費用高）、**不確定性**（16 項法規對照散落於多份文件）。

PIF AI 以下列四項設計命題處理這些痛點：

1. **結構化壓縮 ≠ 生成**：PIF 16 項多為結構化資訊的跨文件拼裝，正是 LLM Tool Use（工具使用）能力的強項。
2. **AI 草稿 + SA 定稿**：所有 AI 輸出一律標示為「參考草稿」，最終簽署由 SA 負責，符合法規要求與工程原則。
3. **三層資料隔離**：PostgreSQL Row-Level Security + SQLAlchemy ACL 閘門 + RAG KB per-product，任何單層破口皆不致於整體洩漏。
4. **Fail-soft 為預設**：任何外部相依（Claude API / PubChem / 中心 RAG）的短暫故障不得阻斷建檔流程。

### English

Three operational pain points of PIF compilation in the industry: **time** (4–8 weeks per product), **cost** (qualified SA fees), and **uncertainty** (16 regulatory items scattered across multiple documents).

PIF AI addresses these with four design propositions:

1. **Structured composition, not generation**: The 16 items are largely a cross-document assembly problem — precisely what LLM Tool Use excels at.
2. **AI draft + SA final**: Every AI output is marked as a "reference draft"; the SA is always the final signatory — aligning with both regulation and engineering principles.
3. **Three-layer data isolation**: PostgreSQL Row-Level Security + SQLAlchemy ACL gate + one KB per product in the central RAG — a breach of any single layer does not compromise the whole.
4. **Fail-soft by default**: Transient outages of external dependencies (Claude API, PubChem, central RAG) must never block the documentation flow.

---

## 為誰而寫 / Audience

| 讀者 Audience | 建議路徑 Reading Path |
|---|---|
| 🎓 學術研究者 · Academic researchers | 從 §1 循序閱讀至 §12；程式碼引用採 `file:line` 格式可驗證 |
| 🛠 開源貢獻者 · Open-source contributors | §4 架構 → §14 部署 → `CONTRIBUTING.md` of the [code repo](https://github.com/baiyuan-tech/pif) |
| ⚖️ 法規專業人士 · Regulatory professionals | §2 法規 → §3 PIF 16 項 → §9 毒理 → §13 SA 流程 |
| 🔒 資安審閱者 · Security reviewers | §10 RAG 隔離 + §11 威脅模型 + `SECURITY.md` |
| 💼 商務決策者 · Business stakeholders | §1 摘要 → §15 路線圖 |

---

## 開發聲明：本專案以 Claude Code 開發 / Development Note: Built with Claude Code

### 繁體中文

PIF AI 整個專案（前端、後端、AI 引擎、RAG 整合、部署設定、i18n 5 語系、本白皮書）皆由作者搭配 **[Anthropic Claude Code](https://docs.claude.com/en/docs/claude-code/overview)**（Anthropic 官方 CLI）完成開發與撰寫。本專案同時是：

- 一個 **產品**：服務台灣化粧品產業的 PIF 建檔 SaaS
- 一個 **參考實作**：示範如何以 Claude Code 從零打造一個具商業規模的多租戶 SaaS
- 一個 **案例研究**：LLM 輔助工程在法規合規領域的應用

關於 Claude Code 如何協助建構本專案的具體工程細節，詳見白皮書 §7（AI 引擎）與 §15（路線圖與開源策略）。

### English

The entire PIF AI project — frontend, backend, AI engine, RAG integration, deployment configuration, 5-locale i18n, and this whitepaper — was built and written by the author in collaboration with **[Anthropic Claude Code](https://docs.claude.com/en/docs/claude-code/overview)** (Anthropic's official CLI). This project is simultaneously:

- A **product**: a PIF documentation SaaS for Taiwan's cosmetic industry
- A **reference implementation**: demonstrating how to build a commercial-grade multi-tenant SaaS from scratch with Claude Code
- A **case study**: on the application of LLM-assisted engineering to regulatory-compliance domains

Engineering details on how Claude Code contributed appear in §7 (AI Engine) and §15 (Roadmap & Open-Source Strategy).

---

## 如何引用 / How to Cite

### APA 7

```
Lin, V. (2026). PIF AI: A multi-tenant AI-assisted platform for accelerating cosmetic
  product information file documentation under Taiwan Cosmetic Hygiene and Safety Act
  (Whitepaper v0.1). Baiyuan Tech.
  https://github.com/baiyuan-tech/pif-whitepaper
```

### BibTeX

```bibtex
@techreport{lin2026pifai,
  author      = {Lin, Vincent},
  title       = {PIF AI: A Multi-Tenant AI-Assisted Platform for Accelerating
                 Cosmetic Product Information File Documentation Under Taiwan
                 Cosmetic Hygiene and Safety Act},
  institution = {Baiyuan Tech},
  type        = {Whitepaper},
  number      = {v0.1},
  year        = {2026},
  month       = {apr},
  url         = {https://github.com/baiyuan-tech/pif-whitepaper}
}
```

See also [CITATION.cff](CITATION.cff) — GitHub's "Cite this repository" button reads this file directly.

---

## Related Work · Baiyuan Whitepaper Series / 百原白皮書系列

This whitepaper is part of an ongoing series documenting Baiyuan Technology's engineering practice in AI-native platforms. The three pillars share common design patterns — multi-tenant isolation, fail-soft external dependencies, Claude-assisted engineering — applied to different verticals:

本白皮書是百原科技 AI 原生平台工程實踐系列的一部分。三項支柱專案共用多租戶隔離、fail-soft 外部依賴、Claude 輔助工程等設計模式，只是應用於不同垂直領域：

| Whitepaper | Focus | Repo |
|:---|:---|:---|
| 📄 **This: PIF AI Whitepaper** | Cosmetic regulatory compliance automation (Taiwan) | `baiyuan-tech/pif-whitepaper` |
| 📄 [GEO Platform Whitepaper](https://github.com/baiyuan-tech/geo-whitepaper) | Generative-engine brand visibility (7-dim citation scoring, AXP, L1 Wiki + L2 RAG origin) | `baiyuan-tech/geo-whitepaper` |
| 🛠 [PIF AI Platform](https://github.com/baiyuan-tech/pif) | Underlying AGPL-3.0 code referenced in this document | `baiyuan-tech/pif` |

> **Cite both whitepapers together** for a fuller picture of Baiyuan's AI infrastructure approach — the GEO paper establishes the **L1 LLM Wiki + L2 vector RAG** dual-layer retrieval architecture, and this PIF paper shows how it is applied under strict multi-tenant regulatory-compliance constraints.
>
> 引用這兩份白皮書可獲得更完整的 Baiyuan AI 基礎設施視角：GEO 白皮書建立了 **L1 LLM Wiki + L2 向量 RAG** 雙層檢索架構，本 PIF 白皮書展示該架構如何應用於嚴格的多租戶法規合規場景。

## Awesome Lists · AI-Citable Resource Index / 相關 awesome 清單

This whitepaper is positioned at the intersection of several open-source ecosystems. If you maintain one of the awesome-lists below, the PR to add this whitepaper is welcome:

本白皮書位於多個開源生態的交集。若您維護以下 awesome-list 之一，歡迎將本白皮書納入：

- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) — engineering case studies built with Anthropic Claude Code
- [awesome-rag](https://github.com/frutik/awesome-rag) / [awesome-generative-ai-guide](https://github.com/aishwaryanr/awesome-generative-ai-guide) — RAG architecture pattern references
- [awesome-multi-tenant-saas](https://github.com/LCNetwork/awesome-multi-tenant-saas) — isolation design references (Scheme C+ contribution)
- [awesome-fastapi](https://github.com/mjhea0/awesome-fastapi) — FastAPI + SQLAlchemy async pattern
- [awesome-cosmetic-regulation](https://github.com/topics/cosmetic-regulation) — regulatory-tech references (niche, emerging)

> **Design-pattern references in this whitepaper** — for readers interested in the primary sources behind the design decisions:
>
> - **Tool Use / function calling** → Anthropic Claude docs ([Tool Use guide](https://docs.claude.com/en/docs/build-with-claude/tool-use)); OpenAI function calling reference
> - **Multi-tenant isolation** → PostgreSQL Row-Level Security docs; AWS SaaS Factory isolation patterns
> - **Fail-soft design** → Martin Fowler, *Circuit Breaker* (2014); AWS Well-Architected resilience pillar
> - **Regulatory translation to engineering** → EU CPR Annexes (mapped to structured schema in §3 of this paper)

---

## 授權 / Licensing

- **白皮書文字與圖表 · Whitepaper text & figures**: [CC BY-NC 4.0](LICENSE) — free for academic citation, translation, and non-commercial use. Commercial reproduction requires explicit permission from Baiyuan Tech.
- **底層軟體 · Underlying software**: **AGPL-3.0** — see the [PIF AI code repository](https://github.com/baiyuan-tech/pif).

「**AGPL-3.0** 的選擇理由」詳見白皮書 §14.2。

---

## 發行策略 / Publication Strategy

1. **主要發佈 Primary publishing**: 此 GitHub repository (`baiyuan-tech/pif-whitepaper`)
2. **PDF 附件 PDF attachment**: 每次 release 自動附加 `whitepaper-zh-TW.pdf` 與 `whitepaper-en.pdf`（由 `.github/workflows/build-pdf.yml` 編譯）
3. **學術平台 Academic platforms**: arXiv、SSRN（若受控）
4. **產業場域 Industry venues**: 台灣化粧品工業同業公會、衛福部食藥署開放論壇
5. **社群 Community**: Hacker News、r/MachineLearning、Twitter/X、LinkedIn
6. **多語系擴展 Multi-lingual expansion**: 日、韓、法譯本為 v1.0 之後的路線圖項目
7. **引用追蹤 Citation tracking**: Google Scholar、Semantic Scholar

---

## Repo 結構 / Repository Structure

```
pif-whitepaper/
├── README.md                    # ← 您目前閱讀的檔案
├── FORMAT.md                    # 白皮書格式規範
├── LICENSE                      # CC BY-NC 4.0
├── CITATION.cff                 # 引用資訊
├── .markdownlint.jsonc          # Markdown lint 規則
├── whitepaper-zh-TW.pdf         # (generated) 中文 PDF
├── whitepaper-en.pdf            # (generated) 英文 PDF
├── assets/
│   ├── figures/                 # Mermaid 原始檔
│   └── pdf/                     # Pandoc 建置腳本與 metadata
│       ├── concat.sh
│       ├── metadata-zh-TW.yaml
│       └── metadata-en.yaml
├── zh-TW/                       # 繁體中文 12 章 + 4 附錄
│   ├── README.md
│   ├── ch01-abstract.md
│   ├── ... ch02..ch12
│   └── appendix-a..d.md
├── en/                          # English 12 chapters + 4 appendices
│   └── (mirror of zh-TW)
└── .github/
    └── workflows/
        ├── build-pdf.yml         # Pandoc + XeLaTeX → PDF
        └── lint.yml              # markdownlint + link check
```

---

## 修訂記錄 / Revision History

| 版本 Version | 日期 Date | 摘要 Summary |
|:---:|:---:|---|
| v0.1 | 2026-04-19 | First public draft — covers MVP (Phase 1) and Phase 2 designs for Central RAG and SA e-signature |

---

## AI-friendly 結構 / AI-friendly Structure

本 repo 同時為人類讀者與 AI crawler 最佳化：

- **Schema.org `TechArticle`** JSON-LD 嵌入於 HTML 註解中（見原始 markdown 檔首）
- **YAML frontmatter** 於每章節提供機器可讀 metadata
- **對齊 ISO 8601 日期**、一致性術語、ASCII-only Mermaid node IDs
- **單一 `whitepaper.md`** 由 CI 產出，供整體語義分析 / LLM 訓練輸入

This repo is optimized for both human readers and AI crawlers: Schema.org `TechArticle` JSON-LD embedded in HTML comments, YAML frontmatter on every chapter, ISO 8601 dates, consistent terminology, and a single generated `whitepaper.md` for holistic semantic analysis / LLM training input.

---

## 貢獻 / Contributing

本白皮書歡迎勘誤、翻譯、章節補充。流程與規範請見 [FORMAT.md](FORMAT.md) 與母專案 [CONTRIBUTING.md](https://github.com/baiyuan-tech/pif/blob/master/CONTRIBUTING.md)。

Errata, translations, and chapter contributions are welcomed. See [FORMAT.md](FORMAT.md) and the code repo's [CONTRIBUTING.md](https://github.com/baiyuan-tech/pif/blob/master/CONTRIBUTING.md) for process and conventions.

---

---

**© 2026 Baiyuan Tech · Released under CC BY-NC 4.0**

[📄 Read in Chinese ›](zh-TW/) · [📄 Read in English ›](en/)
