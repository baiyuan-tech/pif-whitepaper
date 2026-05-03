---
title: "Appendix B: Full API Endpoint List"
description: "All PIF AI API endpoints — frontend BFF, backend FastAPI v1, and central RAG integration endpoints"
appendix: B
lang: en
authors:
  - "Vincent Lin"
last_updated: 2026-04-19
last_modified_at: '2026-05-03T04:09:11Z'
---









# Appendix B: Full API Endpoint List

> Every PIF AI API endpoint. Developers can use this for integration design; reviewers can check coverage. All endpoints are verifiable in the source code.

## B.1 Backend FastAPI (`/api/v1/*`)

### B.1.1 Auth `/auth`

| Method | Path | Description | Auth |
|:---:|------|------|:---:|
| POST | `/api/v1/auth/register` | Register new user | — |
| POST | `/api/v1/auth/login` | Email + password login | — |
| POST | `/api/v1/auth/google` | Google OAuth login | — |
| POST | `/api/v1/auth/refresh` | Renew access token | Refresh |
| POST | `/api/v1/auth/logout` | Logout + revoke refresh | JWT |
| POST | `/api/v1/auth/verify-email` | Verify email | — |
| POST | `/api/v1/auth/forgot-password` | Request password reset | — |
| POST | `/api/v1/auth/reset-password` | Reset password | Token |
| POST | `/api/v1/auth/setup-2fa` | Enable TOTP | JWT |
| POST | `/api/v1/auth/verify-2fa` | Verify TOTP | JWT |

### B.1.2 Products `/products`

| Method | Path | Description |
|:---:|------|------|
| POST | `/api/v1/products` | Create product (**triggers fail-soft RAG KB creation**) |
| GET | `/api/v1/products` | List (paginated) |
| GET | `/api/v1/products/{id}` | Detail |
| PUT | `/api/v1/products/{id}` | Update |
| DELETE | `/api/v1/products/{id}` | Delete (**triggers RAG KB deletion**) |

All require JWT + `require_plan_access`.

### B.1.3 PIF Build `/products/{id}/pif`

| Method | Path | Description |
|:---:|------|------|
| GET | `/api/v1/products/{id}/pif` | 16-item status overview |
| POST | `/api/v1/products/{id}/pif/upload` | Upload file (specify `item_number`) |
| POST | `/api/v1/products/{id}/pif/analyze` | Trigger AI analysis (async) |
| GET | `/api/v1/products/{id}/pif/{item}` | Item detail |
| PUT | `/api/v1/products/{id}/pif/{item}` | Update item |
| POST | `/api/v1/products/{id}/pif/generate` | Trigger full PIF PDF generation |
| GET | `/api/v1/products/{id}/pif/download` | Download PIF PDF |

### B.1.4 Ingredients & Toxicology `/ingredients`

| Method | Path | Description |
|:---:|------|------|
| GET | `/api/v1/ingredients/search?q=` | Search (INCI / CAS) |
| GET | `/api/v1/ingredients/{id}` | Detail (with toxicology) |
| POST | `/api/v1/ingredients/{id}/toxicology` | Trigger toxicology update |
| POST | `/api/v1/ingredients/check-formula` | Batch check formula compliance |

### B.1.5 SA Review `/sa`

| Method | Path | Description | Role |
|:---:|------|------|:---:|
| GET | `/api/v1/sa/pending` | Pending-review cases | SA |
| GET | `/api/v1/sa/reviews/{id}` | Review detail | SA |
| PUT | `/api/v1/sa/reviews/{id}` | Submit review comments | SA + TOTP |
| POST | `/api/v1/sa/reviews/{id}/sign` | Electronic signature | SA + TOTP |
| POST | `/api/v1/sa/reviews/{id}/revision` | Request revisions | SA |

### B.1.6 Organization Settings `/settings`

| Method | Path | Description | Role |
|:---:|------|------|:---:|
| GET | `/api/v1/settings/org` | Org settings | any |
| PUT | `/api/v1/settings/org` | Update org | admin |
| GET | `/api/v1/settings/api-keys` | API-key list | admin |
| PUT | `/api/v1/settings/api-keys/{key}` | Set external API key | admin |
| POST | `/api/v1/settings/api-keys/{key}/test` | Test connectivity | admin |

### B.1.7 Admin `/admin`

| Method | Path | Description | Role |
|:---:|------|------|:---:|
| POST | `/api/v1/admin/bootstrap` | Initialize super-admin | SECRET |
| GET | `/api/v1/admin/organizations` | All organizations | super_admin |
| PUT | `/api/v1/admin/organizations/{id}/plan` | Plan change | super_admin |
| POST | `/api/v1/admin/organizations/{id}/exempt` | Beta exemption | super_admin |
| GET | `/api/v1/admin/audit-logs` | Audit logs | super_admin |

### B.1.8 Chemical Sync `/chemical-sync`

| Method | Path | Description | Role |
|:---:|------|------|:---:|
| POST | `/api/v1/chemical-sync/tfda` | Sync TFDA lists | super_admin |
| POST | `/api/v1/chemical-sync/echa` | Sync ECHA C&L | super_admin |
| GET | `/api/v1/chemical-sync/status` | Sync status | super_admin |

### B.1.9 PIF Compliance Engine (Phase 22–23)

> See Chapter 13. Covers business-type responsibility matrix, 7-step workflow, V0–V3 version snapshots, change detection, cross-item lint, and regulatory PDF generation. All require JWT + `require_plan_access`.

#### Responsibility Matrix (Phase 22A)

| Method | Path | Description |
|:---:|------|------|
| GET | `/api/v1/pif/responsibility-matrix?org_type=brand\|oem\|importer\|consultant` | Generic responsibility matrix (4 business types × 16 items, 64 cells) |
| GET | `/api/v1/products/{id}/pif-responsibilities` | Auto-resolves to the row matching `product.org.type` |

#### 7-Step Workflow & Outsourcing (Phase 22B)

| Method | Path | Description |
|:---:|------|------|
| GET | `/api/v1/products/{id}/pif-workflow` | 7-step workflow auto-derivation (with `outsourcing_suggestions`) |
| GET | `/api/v1/products/{id}/outsourcings` | List registered outsourcing entries |
| POST | `/api/v1/products/{id}/outsourcings` | Add outsourcing (`item_number` + `vendor` + `note`) |
| DELETE | `/api/v1/products/{id}/outsourcings/{id}` | Remove outsourcing |

#### V0–V3 Version Snapshots (Phase 22C / 22E / 23C)

| Method | Path | Description |
|:---:|------|------|
| POST | `/api/v1/products/{id}/pif-versions/snapshot` | Create snapshot of current 16-item state (V0/V1/V2/V3) |
| GET | `/api/v1/products/{id}/pif-versions` | List all historical snapshots |
| GET | `/api/v1/products/{id}/pif-versions/expiring` | Document-expiry aggregation (GMP / test reports / §12 reporting countdown) |
| GET | `/api/v1/products/{id}/pif-versions/change-detection` | Compare fingerprints; returns `needs_resign` + `suggested_next_version` |
| POST | `/api/v1/products/{id}/pif-versions/auto-draft` | One-click create V2/V3 draft (unsigned) |

#### Cross-Item Lint (Phase 22D / 23A / 23B)

| Method | Path | Description |
|:---:|------|------|
| GET | `/api/v1/products/{id}/cross-item-lint` | Execute 14 rules (R1–R14); returns alerts + penalty mapping (§22–§25 fine ranges) |

#### Regulatory PIF PDF (Phase 23E)

| Method | Path | Description |
|:---:|------|------|
| GET | `/api/v1/products/{id}/pif-versions/regulatory-pdf` | Generate current 14-page compliance PDF (lint computed live) |
| GET | `/api/v1/products/{id}/pif-versions/{snapshot_id}/regulatory-pdf` | Generate PDF for the specified V0/V1/V2/V3 snapshot (restored from `items_snapshot`) |

Response `Content-Disposition` uses RFC 5987 dual headers to support Chinese filenames.

## B.2 Frontend BFF (Next.js API Routes, `/api/*`)

| Method | Path | Description |
|:---:|------|------|
| POST | `/api/auth/session` | NextAuth session endpoint |
| POST | `/api/auth/callback/google` | Google OAuth callback |
| POST | `/api/files/presign` | Generate S3 pre-signed URL |
| POST | `/api/files/finalize` | Finalize file upload record |
| GET | `/api/dashboard` | Dashboard aggregated data |
| GET | `/api/plan-status` | Current plan status (for UI) |

## B.3 Central RAG (PIF backend egress)

PIF backend calls `rag.baiyuan.io` (auth: `X-RAG-API-Key` + `X-Tenant-ID`):

| Method | Path | When PIF uses |
|:---:|------|------|
| POST | `/api/v1/knowledge-bases` | Create KB for product (`safe_create_kb`) |
| DELETE | `/api/v1/knowledge-bases/{id}` | Delete KB (`safe_delete_kb`) |
| POST | `/api/v1/ask` | Toxicology / formulation analysis query (`RagClient.ask`) |
| POST | `/api/v1/documents/text` | Import business-provided private knowledge (Phase 2) |
| POST | `/api/v1/documents/url` | Import URL (Phase 2) |
| POST | `/api/v1/documents/file` | Import file (Phase 2) |
| POST | `/api/v1/knowledge-bases/{id}/wiki/compile` | Trigger L1 Wiki compilation (Phase 2) |

## B.4 External Integrations (PIF backend egress)

| Service | Endpoint | Auth |
|------|------|------|
| PubChem | `https://pubchem.ncbi.nlm.nih.gov/rest/pug/*` | None (rate limit) |
| PubChem View | `https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/*` | None |
| ECHA C&L | `https://echa.europa.eu/api/*` | API Key |
| OECD eChemPortal | `https://www.echemportal.org/echemportal/api/*` | None (terms apply) |
| Anthropic | `https://api.anthropic.com/v1/messages` | `x-api-key` |
| Google OAuth | `https://oauth2.googleapis.com/token` | Client Secret |

## B.5 OpenAPI Schema

FastAPI auto-generates OpenAPI 3.1 schema:

- JSON: `https://pif.baiyuan.io/api/v1/openapi.json`
- Swagger UI: `https://pif.baiyuan.io/api/v1/docs`
- ReDoc: `https://pif.baiyuan.io/api/v1/redoc`

Production may disable the docs UI (only in `APP_ENV=development`); the full schema is always available via the OpenAPI JSON.

---

**Nav** [← Appendix A: Glossary](appendix-a-glossary.md) · [Appendix C: References →](appendix-c-references.md)
