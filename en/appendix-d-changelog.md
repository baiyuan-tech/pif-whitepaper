---
title: "Appendix D: Changelog"
description: "Revision history of the PIF AI Whitepaper"
appendix: D
lang: en
authors:
  - "Vincent Lin"
last_updated: 2026-04-19
last_modified_at: '2026-05-03T04:09:11Z'
---









# Appendix D: Changelog

> Complete version history. Format follows [Keep a Changelog](https://keepachangelog.com/).

## v0.2 — 2026-04-30

### Added

- **Chapter 13 "Compliance Engine Deep Dive (Phase 22–23)"** (zh-TW + en, both languages) — covers compliance capabilities accumulated across 11 sub-phases:
  - §13.1 Lifecycle 5-stage reorganization (pre_launch / development / manufacturing / post_launch / signing)
  - §13.1.2 Business-type × 16-item responsibility matrix (4 × 16 = 64 cells)
  - §13.1.3 Auto-derived 7-step workflow + outsourcing recommendations
  - §13.2 PIF version management V0/V1/V2/V3 snapshots
  - §13.2.2 Change detection (formula / process / packaging fingerprints, SHA-256)
  - §13.2.3 One-click V2/V3 drafting
  - §13.2.4 Document expiry auto-tracking (GMP / test reports / §12 reporting countdown)
  - §13.3 Cross-item lint engine — 14 rules R1–R14 (including R1 advanced filtering)
  - §13.4 Penalty mapping table (§22–§25 fine ranges, NT$30K to NT$5M)
  - §13.5 SA signature metadata (method / hash / ip / cert ref)
  - §13.6 14-page regulatory PIF PDF one-click generation (WeasyPrint A4 + Noto Sans CJK)
  - §13.6.6 E2E real-data dual-path validation (by item number / by stage)

- **Appendix B new §B.1.9 PIF Compliance Engine endpoints** (14 new endpoints):
  - Responsibility matrix: 2
  - Workflow & outsourcing: 4
  - V0–V3 version snapshots: 5
  - Cross-item lint: 1
  - Regulatory PDF: 2

### Changed

- Chapter 12 footer "Nav" link from "Appendix A" → "Chapter 13"
- Appendix A header "Nav" link from "Chapter 12" → "Chapter 13"
- README TOC adds Chapter 13
- CITATION.cff version bumped from `0.1` to `0.2`; date-released updated to 2026-04-30

### Corresponding Commits

- Parent repo `VincentLinB/pif`: Phase 22.0 → Phase 23E (commits ac44591, 7618936, 8755f8d, 43d649e, 91190a2, ...)
- Whitepaper repo: this v0.2 commit

### Known Limitations

- Performance numbers cited in Chapter 13 (PDF 14 pages in 2-3 sec, PDF size 640-690 KB) are measured; latency of other Phase 22-23 endpoints has not been benchmarked
- Cross-item lint R1–R14 rule table is PIF AI's interpretation of ITRI curriculum; other SAs may interpret slightly differently — discussion welcome via GitHub issues

## v0.1 — 2026-04-19

### Added

- **First public draft**, structurally compatible with `baiyuan-tech/geo-whitepaper`
- **12 main chapters**:
  - Ch.01 Abstract and Core Propositions
  - Ch.02 Regulatory Background (Taiwan Cosmetic PIF)
  - Ch.03 The 16 PIF Items (deep analysis)
  - Ch.04 System Architecture
  - Ch.05 Frontend Stack
  - Ch.06 Backend Stack
  - Ch.07 AI Engine (including Claude Code co-development practice)
  - Ch.08 Database and Multi-Tenant Isolation
  - Ch.09 Toxicology Data Pipeline
  - Ch.10 Central RAG Integration (Scheme C+, with L1 Wiki + L2 Vector RAG)
  - Ch.11 Security Model
  - Ch.12 Roadmap, Deployment, and Open-Source Strategy
- **4 appendices**:
  - Appendix A — Glossary and Acronyms (50+ entries)
  - Appendix B — Full API Endpoint List
  - Appendix C — References
  - Appendix D — Changelog (this file)
- **15+ Mermaid diagrams**: ER, flowchart, sequence, state, gantt, pie
- **AI-friendly structured data**: YAML frontmatter per chapter + Schema.org `TechArticle` JSON-LD per README
- **Chinese edition** (zh-TW/) available in parallel with full chapter correspondence

### CI and Tooling

- `.github/workflows/build-pdf.yml`: Pandoc + XeLaTeX + Noto CJK bilingual PDF build (matrix: zh-TW, en)
- `.github/workflows/lint.yml`: markdownlint + lychee link check
- `.markdownlint.jsonc`: linting rules aligned with geo-whitepaper
- `assets/pdf/concat.sh`: chapter concatenation script (strips frontmatter, JSON-LD, nav footer)
- `CITATION.cff`: GitHub auto-recognized citation info

### Licensing

- Whitepaper: **CC BY-NC 4.0**
- Underlying software (PIF AI code): **AGPL-3.0**

### Known Limitations

- Some PIF AI performance metrics remain marked as "**target values**"; formal Phase 1 GA benchmarks pending (§1.4.1)
- English chapters are human-reviewed machine-assisted translation; regulatory terms may still require local legal review (especially §2.5 international comparison)
- Mermaid diagrams are stripped in PDF build and replaced with "[See online version]" placeholders because XeLaTeX does not natively render Mermaid

### Corresponding Commits (in `baiyuan-tech/pif` and `baiyuan-tech/pif-whitepaper`)

- `f33392e` — feat(i18n): extend locales to Japanese, Korean, French with language dropdown
- (RAG integration commit, pending) — feat(rag): central RAG integration (Scheme C+) backend
- (whitepaper commit, pending) — docs: initial whitepaper v0.1 draft with 12 chapters + 4 appendices

## Future Plans

### v0.2 (expected 2026-09)

- Replace "target values" with actual Phase 1 GA benchmark data
- Extended SA electronic-signature chapter
- New chapter: "Regulatory-Change Monitoring and Notification Mechanism" (aligned with Phase 3)
- Additional multilingual review for ja, ko, fr translations (originally UI-only; whitepaper body not yet translated)

### v1.0 (expected 2026-12)

- Released alongside Phase 2 GA
- Includes first-batch anonymized customer case studies
- Formally peer-reviewed edition in partnership with academia

---

**Nav** [← Appendix C: References](appendix-c-references.md) · [Back to en README →](README.md)
