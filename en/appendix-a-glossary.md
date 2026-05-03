---
title: "Appendix A: Glossary and Acronyms"
description: "Common terms, acronyms, and Chinese-English mappings used throughout the PIF AI whitepaper"
appendix: A
lang: en
authors:
  - "Vincent Lin"
last_updated: 2026-04-19
last_modified_at: '2026-05-03T11:34:22+08:00'
---






# Appendix A: Glossary and Acronyms

> This appendix lists terms and acronyms used throughout the whitepaper, alphabetically.

## A

| Term / Acronym | Full name | Note |
|---|---|---|
| **ACL** | Access Control List | Enforced at FastAPI layer with `org_id` filtering |
| **AGPL-3.0** | GNU Affero General Public License v3 | This project's code license; requires SaaS modifications to be open-sourced |
| **AES-256** | Advanced Encryption Standard, 256-bit | PIF AI's application-layer formulation encryption algorithm |
| **API** | Application Programming Interface | — |
| **ARIA** | Accessible Rich Internet Applications | Used in the LanguageToggle |

## B

| Term | Full name | Note |
|---|---|---|
| **BDFL** | Benevolent Dictator For Life | Open-source governance model |
| **BFF** | Backend-for-Frontend | PIF AI implements via Next.js tRPC |

## C

| Term | Full name | Note |
|---|---|---|
| **CAS Number** | Chemical Abstracts Service Number | Chemical substance unique ID, format NNN-NN-N |
| **CC BY-NC 4.0** | Creative Commons Attribution-NonCommercial 4.0 | This whitepaper's license |
| **CPNP** | Cosmetic Products Notification Portal | EU cosmetic notification portal |
| **CPR** | Cosmetic Products Regulation (EC No 1223/2009) | EU cosmetic regulation |
| **CSR / CPSR** | Cosmetic Product Safety Report | EU-required safety assessment report |
| **Claude Code** | — | Anthropic's official CLI; main dev tool for this project |

## D

| Term | Full name | Note |
|---|---|---|
| **DDD** | Domain-Driven Design | — |

## E

| Term | Full name | Note |
|---|---|---|
| **ECHA** | European Chemicals Agency | Provides C&L Inventory |

## F

| Term | Full name | Note |
|---|---|---|
| **Fail-soft** | — | Failures do not block the workflow; a PIF AI design principle |
| **FDA** | U.S. Food and Drug Administration | — |

## G

| Term | Full name | Note |
|---|---|---|
| **GHS** | Globally Harmonized System of Classification and Labelling of Chemicals | — |
| **GMP** | Good Manufacturing Practice | PIF Item 5 |

## H

| Term | Full name | Note |
|---|---|---|
| **HSTS** | HTTP Strict Transport Security | — |

## I

| Term | Full name | Note |
|---|---|---|
| **i18n** | Internationalization | PIF AI supports 5 locales |
| **INCI** | International Nomenclature of Cosmetic Ingredients | — |
| **ISO 22716** | ISO 22716:2007 Cosmetics — GMP | International GMP standard |

## J

| Term | Full name | Note |
|---|---|---|
| **JWT** | JSON Web Token | Used for authentication |

## K

| Term | Full name | Note |
|---|---|---|
| **KB** | Knowledge Base | 1 per product in central RAG |
| **KMS** | Key Management Service | AWS/GCP KMS |

## L

| Term | Full name | Note |
|---|---|---|
| **L1 Wiki / L2 RAG** | — | Central RAG's dual-layer retrieval: L1 compiled, L2 vector |
| **LD50** | Lethal Dose, 50% | Acute toxicity indicator |
| **LLM** | Large Language Model | — |

## M

| Term | Full name | Note |
|---|---|---|
| **MCP** | Model Context Protocol | Anthropic-led tool integration standard |
| **MoCRA** | Modernization of Cosmetics Regulation Act of 2022 | US cosmetics law |

## O

| Term | Full name | Note |
|---|---|---|
| **OECD** | Organisation for Economic Co-operation and Development | — |
| **OWASP** | Open Web Application Security Project | — |

## P

| Term | Full name | Note |
|---|---|---|
| **PIF** | Product Information File | The core of this project |
| **PubChem** | — | NIH public chemical database |
| **PWA** | Progressive Web App | — |

## R

| Term | Full name | Note |
|---|---|---|
| **RAG** | Retrieval-Augmented Generation | — |
| **RBAC** | Role-Based Access Control | — |
| **RFC** | Request For Comments | — |
| **RLS** | Row-Level Security | PostgreSQL feature; core of PIF multi-tenancy |
| **RSC** | React Server Components | — |

## S

| Term | Full name | Note |
|---|---|---|
| **SA** | Safety Assessor | Required signatory of PIF Item 16 |
| **SaaS** | Software as a Service | — |
| **SCCS** | Scientific Committee on Consumer Safety | EU committee |
| **SKU** | Stock Keeping Unit | — |
| **SSE** | Server-Side Encryption | S3 feature |
| **SSR** | Server-Side Rendering | — |
| **STRIDE** | Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege | Microsoft threat modeling |

## T

| Term | Full name | Note |
|---|---|---|
| **TCIIA** | Taiwan Cosmetic Industry Association | — |
| **TFDA** | Taiwan Food and Drug Administration | — |
| **TLS** | Transport Layer Security | — |
| **Tool Use** | — | Anthropic Claude's structured tool-invocation capability |
| **TOTP** | Time-based One-Time Password | Used for 2FA |
| **tRPC** | TypeScript Remote Procedure Call | End-to-end typed API framework |

## U

| Term | Full name | Note |
|---|---|---|
| **UV Filter** | Ultraviolet Filter | A cosmetic category |

## W

| Term | Full name | Note |
|---|---|---|
| **WORM** | Write Once Read Many | Used for audit-log archival |

## Z

| Term | Full name | Note |
|---|---|---|
| **zod** | — | TypeScript schema validation library used in PIF frontend forms |

---

**Nav** [← Chapter 13: Compliance Engine Deep Dive](ch13-compliance-engine.md) · [Appendix B: API Endpoint List →](appendix-b-api-endpoints.md)
