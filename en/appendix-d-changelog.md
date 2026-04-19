---
title: "Appendix D: Changelog"
description: "Revision history of the PIF AI Whitepaper"
appendix: D
lang: en
authors:
  - "Vincent Lin"
last_updated: 2026-04-19
---

# Appendix D: Changelog

> Complete version history. Format follows [Keep a Changelog](https://keepachangelog.com/).

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
