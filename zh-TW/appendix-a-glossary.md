---
title: "附錄 A：縮寫與術語對照"
description: "PIF AI 白皮書常用專有名詞、縮寫、中英對照（50+ 條）"
appendix: A
lang: zh-TW
authors:
  - "Vincent Lin"
last_updated: 2026-04-19
last_modified_at: '2026-04-19T21:19:43+08:00'
---


# 附錄 A：縮寫與術語對照

> 本附錄為全書使用之專有名詞、縮寫、術語中英對照。依字母順序排列。

## A

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **ACL** | Access Control List | 存取控制清單；PIF AI 於 FastAPI 層強制過濾 `org_id` |
| **AGPL-3.0** | GNU Affero General Public License v3 | 本專案程式碼採用之開源授權；要求 SaaS 改動需同步公開 |
| **AES-256** | Advanced Encryption Standard, 256-bit | 本專案配方檔案應用層加密所用演算法 |
| **API** | Application Programming Interface | 應用程式介面 |
| **ARIA** | Accessible Rich Internet Applications | 無障礙網頁規範；LanguageToggle 使用 |

## B

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **BDFL** | Benevolent Dictator For Life | 善意終身獨裁者；開源專案治理模式 |
| **BFF** | Backend-for-Frontend | 為前端量身訂做的 API 聚合層；PIF AI 由 Next.js tRPC 實作 |

## C

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **CAS Number** | Chemical Abstracts Service Number | 化學物質專屬編號，格式 NNN-NN-N |
| **CC BY-NC 4.0** | Creative Commons Attribution-NonCommercial 4.0 | 本白皮書採用之授權（禁商用） |
| **CPNP** | Cosmetic Products Notification Portal | 歐盟化粧品通報平台 |
| **CPR** | Cosmetic Products Regulation (EC No 1223/2009) | 歐盟化粧品法規 |
| **CSR / CPSR** | Cosmetic Product Safety Report | 歐盟要求之化粧品安全評估報告 |
| **Claude Code** | — | Anthropic 官方 CLI 代理；本專案開發主要工具 |

## D

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **DDD** | Domain-Driven Design | 領域驅動設計 |

## E

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **ECHA** | European Chemicals Agency | 歐洲化學品管理局；提供 C&L Inventory |

## F

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **Fail-soft** | — | 失敗不阻斷流程；PIF AI 設計原則之一 |
| **FDA** | U.S. Food and Drug Administration | 美國食藥署 |

## G

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **GHS** | Globally Harmonized System of Classification and Labelling of Chemicals | 全球統一分類與標示制度 |
| **GMP** | Good Manufacturing Practice | 優良製造規範；PIF 第 5 項 |

## H

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **HSTS** | HTTP Strict Transport Security | HTTP 嚴格傳輸安全 |

## I

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **i18n** | Internationalization | 國際化；PIF AI 支援 5 語系 |
| **INCI** | International Nomenclature of Cosmetic Ingredients | 國際化粧品成分命名 |
| **ISO 22716** | ISO 22716:2007 Cosmetics — GMP | 國際 GMP 標準 |

## J

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **JWT** | JSON Web Token | JSON 網路權杖；認證使用 |

## K

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **KB** | Knowledge Base | 知識庫；中心 RAG 每產品建立一個 |
| **KMS** | Key Management Service | 金鑰管理服務（AWS / GCP 皆有） |

## L

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **L1 Wiki / L2 RAG** | — | 中心 RAG 雙層檢索：L1 編譯型知識、L2 向量 RAG |
| **LD50** | Lethal Dose, 50% | 半數致死劑量；急性毒性指標 |
| **LLM** | Large Language Model | 大型語言模型 |

## M

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **MCP** | Model Context Protocol | 模型上下文協定；Anthropic 主導的工具整合標準 |
| **MoCRA** | Modernization of Cosmetics Regulation Act of 2022 | 美國化粧品現代化法 |

## O

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **OECD** | Organisation for Economic Co-operation and Development | 經濟合作暨發展組織 |
| **OWASP** | Open Web Application Security Project | 開放式網頁應用程式安全計畫 |

## P

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **PIF** | Product Information File | 產品資訊檔案；本專案核心 |
| **PubChem** | — | NIH 化學物質公開資料庫 |
| **PWA** | Progressive Web App | 漸進式網頁應用程式 |

## R

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **RAG** | Retrieval-Augmented Generation | 檢索增強生成 |
| **RBAC** | Role-Based Access Control | 角色基底存取控制 |
| **RFC** | Request For Comments | 徵求意見書 |
| **RLS** | Row-Level Security | 列層級安全；PostgreSQL 特性，PIF 多租戶核心 |
| **RSC** | React Server Components | React 伺服器元件 |

## S

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **SA** | Safety Assessor | 安全評估者；PIF 第 16 項必要簽署者 |
| **SaaS** | Software as a Service | 軟體即服務 |
| **SCCS** | Scientific Committee on Consumer Safety | 歐盟消費者安全科學委員會 |
| **SKU** | Stock Keeping Unit | 單品編碼 |
| **SSE** | Server-Side Encryption | 伺服端加密（S3 特性） |
| **SSR** | Server-Side Rendering | 伺服端渲染 |
| **STRIDE** | Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege | Microsoft 威脅建模法 |

## T

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **TCIIA** | Taiwan Cosmetic Industry Association | 台灣化粧品工業同業公會 |
| **TFDA** | Taiwan Food and Drug Administration | 衛福部食品藥物管理署 |
| **TLS** | Transport Layer Security | 傳輸層安全協定 |
| **Tool Use** | — | Anthropic Claude 的結構化工具呼叫能力 |
| **TOTP** | Time-based One-Time Password | 基於時間的一次性密碼；2FA 使用 |
| **tRPC** | TypeScript Remote Procedure Call | TypeScript 端對端型別安全 API 框架 |

## U

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **UV Filter** | Ultraviolet Filter | 紫外線濾劑；化粧品類別之一 |

## W

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **WORM** | Write Once Read Many | 一次寫入多次讀取；稽核日誌儲存用 |

## Z

| 縮寫／術語 | 英文全稱 | 中文說明 |
|---|---|---|
| **zod** | — | TypeScript schema 驗證庫；PIF 前端表單使用 |

---

**導覽** [← 第 12 章：路線圖](ch12-roadmap-deployment-opensource.md) · [附錄 B：API 端點清單 →](appendix-b-api-endpoints.md)
