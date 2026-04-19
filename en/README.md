<!-- AI-friendly structured data
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "TechArticle",
  "headline": "PIF AI Whitepaper (English edition)",
  "inLanguage": "en",
  "datePublished": "2026-04-19",
  "dateModified": "2026-04-19",
  "author": {"@type": "Person", "name": "Vincent Lin", "affiliation": "Baiyuan Tech"},
  "license": "https://creativecommons.org/licenses/by-nc/4.0/",
  "isPartOf": {"@type": "CreativeWorkSeries", "name": "Baiyuan Tech Whitepapers"},
  "url": "https://github.com/baiyuan-tech/pif-whitepaper/tree/master/en"
}
</script>
-->

# PIF AI Whitepaper (English edition)

*A Multi-Tenant AI-Assisted Platform for Cosmetic Product Information File Documentation*

**Version**: v0.1 · **Date**: 2026-04-19 · **Author**: Vincent Lin (Baiyuan Tech)
**License**: Whitepaper licensed under [CC BY-NC 4.0](../LICENSE); the underlying PIF AI software is AGPL-3.0.

> [!NOTE]
> This document is an academic-technical whitepaper. Any numbers related to performance, user counts, or revenue are labeled as **target** or **expected** values unless supported by measurement or live query — consistent with the project's *Development Constitution*: no mock data, no hard-coded numbers, full testing before reporting.
>
> The entire project (code and whitepaper) was developed with the assistance of [Anthropic Claude Code](https://docs.claude.com/en/docs/claude-code/overview), serving as an open-source case study of LLM-assisted engineering applied to regulatory-compliance domains.

---

## 🧭 Table of Contents

### Part I — Introduction

| § | Chapter | Topic |
|:--:|---------|-------|
| [01](ch01-abstract.md) | **Abstract** | TL;DR, four design propositions, system overview diagram |
| [02](ch02-regulatory-background.md) | **Regulatory Background** | Taiwan Cosmetic Hygiene & Safety Act Article 8, July 2026 deadline, penalties |
| [03](ch03-pif-16-items.md) | **The 16 PIF Items** | Per-item data source, AI handling, database mapping |

### Part II — System Architecture

| § | Chapter | Topic |
|:--:|---------|-------|
| [04](ch04-system-architecture.md) | **System Architecture** | Five-layer architecture, module boundaries, data flow |
| [05](ch05-frontend-stack.md) | **Frontend Stack** | Next.js 15 App Router, RSC, shadcn/ui |
| [06](ch06-backend-stack.md) | **Backend Stack** | FastAPI, SQLAlchemy async, Alembic vs inline migration |

### Part III — AI & Data

| § | Chapter | Topic |
|:--:|---------|-------|
| [07](ch07-ai-engine.md) | **AI Engine** | Claude Tool Use, Claude Code engineering practice, confidence scoring |
| [08](ch08-multi-tenancy.md) | **Database & Multi-Tenancy** | Schema, Row-Level Security, `current_setting` pattern |
| [09](ch09-toxicology-pipeline.md) | **Toxicology Pipeline** | PubChem / TFDA / ECHA / OECD cross-query |
| [10](ch10-central-rag.md) | **Central RAG Integration** | Scheme C+ isolation, dual-header auth, fail-soft |

### Part IV — Security & Process

| § | Chapter | Topic |
|:--:|---------|-------|
| [11](ch11-security-model.md) | **Security Model** | AES-256, JWT, TOTP, audit, threat model, 5-locale i18n |
| [12](ch12-roadmap-deployment-opensource.md) | **Roadmap, Deployment & Open-Source Strategy** | Docker → K8s, AGPL rationale, Phase 1–3, contribution model |

### Appendices

| § | Chapter | Topic |
|:--:|---------|-------|
| [A](appendix-a-glossary.md) | **Glossary** | PIF, SA, TFDA, INCI, 50+ entries |
| [B](appendix-b-api-endpoints.md) | **API Endpoint Reference** | All frontend BFF + backend FastAPI endpoints |
| [C](appendix-c-references.md) | **References** | Statutes, standards, RFCs, academic papers |
| [D](appendix-d-changelog.md) | **Changelog** | Whitepaper revision history |

---

## 📖 How to Read

**Linear reading**: Academic or regulatory readers should start at §1 and proceed through §12, then the appendices.

**Quick start** (open-source contributors):

1. Read [§1 Abstract](ch01-abstract.md) for the big picture.
2. Jump to [§4 System Architecture](ch04-system-architecture.md) for module boundaries.
3. Enter your area of interest (frontend → §5, backend → §6, AI → §7, RAG → §10).
4. Read [§12 Roadmap](ch12-roadmap-deployment-opensource.md).
5. Head to the code repo's [CONTRIBUTING.md](https://github.com/baiyuan-tech/pif/blob/master/CONTRIBUTING.md) to start coding.

**Regulatory compliance**: §2 → §3 → §9 → §11 (SA workflow) → Appendix C.

**Security review**: §10 → §11 + [SECURITY.md](https://github.com/baiyuan-tech/pif/blob/master/SECURITY.md).

---

## 📊 Whitepaper Scale

| Metric | Target | Current |
|---|---|---|
| Chapters | 12 chapters + 4 appendices | In drafting |
| English word count | 28,000+ words | In drafting |
| Figures | 15+ Mermaid diagrams | In drafting |
| Code citations | 40+ (format `file:line`) | In drafting |
| References | 30+ entries | In drafting |

> [!NOTE]
> This README is a ToC. The complete PDF is available on [GitHub Releases](https://github.com/baiyuan-tech/pif-whitepaper/releases).
> PDF convention: `releases/download/<version>/whitepaper-en.pdf`.

---

## 🔗 Language versions

- 🇹🇼 [繁體中文版 (Traditional Chinese)](../zh-TW/)
- 🇺🇸 [English edition](../en/) (you are here)

---

**Nav** [← Back to repo root](../README.md) · [Format spec →](../FORMAT.md)
