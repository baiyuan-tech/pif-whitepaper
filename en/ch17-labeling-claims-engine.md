---
title: "Chapter 17: Labeling and Claims Compliance Engine"
description: "The full chain from a packaging photo to a regulatory verdict: Claude Vision extraction of statutory label elements and the full ingredient list, a 262-phrase corpus from the L0030099 determination rule, five-state verdicts with acknowledgement records, and six false negatives we actually hit."
chapter: 17
lang: en
authors:
  - "Vincent Lin"
keywords:
  - "labeling claims"
  - "L0030099"
  - "determination rule"
  - "Claude Vision"
  - "false negative"
  - "acknowledgement"
  - "certification marks"
word_count: approx 3400
last_updated: 2026-08-24
last_modified_at: '2026-08-26T02:25:46Z'
---




# Chapter 17: Labeling and Claims Compliance Engine

> The sixteen PIF items answer "is this product's documentation complete?" This chapter answers a different question: **"are the words printed on the box lawful?"** In Taiwan these fall under two separate legal bases — Article 7 statutory label elements and the Article 10 advertising determination rule — and the penalty ceiling for the latter is five times that of the former. This chapter records what we built between a packaging photograph and an acknowledgeable regulatory verdict, plus six false negatives we genuinely hit.

## 📌 Chapter Highlights

- **Two legal bases, handled separately.** Article 7 label elements ask "is it printed?" (omission → NT$10,000–1,000,000). The Article 10 determination rule asks "may you phrase it that way?" (medical-efficacy claims → NT$600,000–5,000,000, with possible revocation of registration). One photograph, two verdict paths.
- **An official corpus, not LLM recall.** Appendices I–IV yield **262 official phrases**, extracted from the source PDF into structured data with a `content_sha256`. The engine only matches; it **never lets the LLM author a regulatory conclusion** — Chapter 7's "structured compression, not free generation" principle applied to compliance.
- **Five states, not a binary.** `red` / `amber` / `pending_data` / `green` / `gray`. `pending_data` (Appendix III phrases are bound to ingredient concentrations that are not yet filed) and `gray` (nothing matched) are deliberately kept out of green — **"no match" is not "lawful."**
- **Advisory only, never blocking.** The engine emits `advisory_only: true` and blocks nothing. Responsibility transfers through an **acknowledgement record**: when a tenant clicks "acknowledged, not changing for now," we store the exact findings they saw and the rule version in force at that moment — rather than re-running the check later.
- **All six false negatives came from real comparisons.** Ideographic comma separators, `○○` placeholders, CJK compatibility ideographs, concentration limits split across lines, image-only certification marks, and `pending` items missing from the banner. Each returned a green light on genuinely non-compliant labels — far more dangerous than over-flagging.

## 17.1 Why Labeling and Claims Sit Outside the Sixteen Items

The acceptance criterion for the sixteen PIF items is **completeness**: is the formula sheet present, is the GMP certificate on file, was stability testing performed. That is document inventory.

But the first place a business actually gets fined is often not a missing document — it is one extra sentence on the packaging. Taiwan's Cosmetic Hygiene and Safety Act regulates these separately:

| | Art. 7 statutory label elements | Art. 10 advertising determination rule |
|---|---|---|
| Question | Is the required content printed? | May it be phrased that way? |
| Basis | MOHW Order 1081603869 | L0030099 rule + four appendices |
| Penalty | NT$10,000–1,000,000 | Exaggeration NT$40,000–200,000; **medical efficacy NT$600,000–5,000,000, registration may be revoked** |
| Verdict | Field presence | Phrase matching + substantiation conditions + ingredient linkage |

The second column's ceiling is five times the first, and the determination is far harder — it is not "present or absent" but "does this word, in this context, count?" Article 2 of the rule requires **holistic judgement of the overall presentation**, so any automated verdict can only be advisory; the competent authority makes the determination. That boundary shapes every design decision in this chapter.

## 17.2 From Packaging Image to Structured Fields

The entry point is a packaging photo or PDF. `app/services/label_parser.py` uses Claude Vision with **tool use** to force structured output — the same pattern as formula extraction in Chapter 7: the LLM sees and aligns; it does not conclude.

A single call extracts three groups:

1. **Article 7 statutory elements** — product name (Chinese/English), intended use, directions, storage, net content, precautions, the manufacturer/importer triplet (name/address/phone), country of origin, manufacture date, expiry, batch number, licence number: 21 fields, with `confidence` and `missing_elements`.
2. **The full ingredient list** — legally mandatory, and **the original order on the label must be preserved**. Order carries regulatory meaning (descending concentration, with exceptions for ≤1% and colour cosmetics pigments); reordering destroys the basis for any later ordering check.
3. **Claims and symbols** — a `detected_claims` array, SPF/PA values, warning phrases, and `certification_marks` including **image-only marks with no text** such as USDA Organic, ECOCERT and COSMOS, flagged with `text_visible: false`.

### 17.2.1 A Category of Bug: Tool Schema Must Match the Response Model

`certification_marks` had always been in the tool schema — its description explicitly listed those image-only marks, and the model returned them. But Pydantic's `LabelDetectedSymbols` had no such field, so validation **silently discarded it**. We paid for AI recognition of the marks, received the result, and threw it away, with no error anywhere. The downstream mark matcher therefore never received anything.

This is not one bug but a class of bug: **any field the tool schema requests and the response model omits disappears silently**. Beyond the fix, we added a field-parity test comparing the tool schema's top-level properties against the Pydantic model's fields. Failures of the form "tokens spent, result discarded" have no outward symptom and can only be caught structurally.

## 17.3 The L0030099 Corpus: 262 Official Phrases

The basis for adjudication is not the LLM's memory of the law but a structured corpus, `l0030099_claims.json`, extracted phrase by phrase from the official PDF:

| Appendix | Content | Structure | Phrases |
|---|---|---|---:|
| I | Exaggeration examples | Flat list | 34 |
| II | Permitted phrasings | 15 categories | 184 |
| III | Ingredient-linked claims | 8 groups | 24 |
| IV | Medical-efficacy examples | Flat list | 20 |
| | | **Total** | **262** |

Each phrase carries its appendix, governing article, penalty band, and substantiation notes (`*1`–`*5`). Note `*2` in particular: it points directly at the Cosmetic Product Information File Regulations, meaning **the duty to substantiate a claim loops back to requiring a complete PIF**. The two regimes meet here.

The corpus carries a `content_sha256`, and every verdict snapshot records the `rule_version` in force (pcode, promulgated 2019-06-04, effective 2019-07-01, content hash). Any past verdict can therefore answer "which version of the law was this based on?"

### 17.3.1 Two Traps in Corpus Extraction

**CJK compatibility ideographs.** The official PDF mixes in Unicode CJK Compatibility Ideographs — 亮 U+F977, 復 U+F966, 麗 U+F988 and others, 65 occurrences in total. These are **visually identical to the common forms** but occupy different code points, so naive matching misses every one. We normalise the U+F900–FAFF range only, and deliberately **do not apply NFKC** — that would also rewrite official punctuation and distort the statutory text.

**Line and page breaks.** Concentration limits are frequently split across lines (for example "triclosan 0.3" on one line, "%" on the next). The extractor needs continuation rules for these patterns; otherwise the limit is lost and a conditional claim becomes unconditionally permitted.

## 17.4 Five-State Verdicts

The result is not a compliant/non-compliant binary but five states:

| State | Meaning | Basis |
|---|---|---|
| `red` | Medical efficacy, or clear exaggeration | Appendix I / IV |
| `amber` | Permitted, but substantiation required | Appendix II `*1`–`*5` |
| `pending_data` | Phrase bound to ingredient concentration, ingredients not yet filed | Appendix III |
| `green` | Matched Appendix II with no attached condition | Appendix II |
| `gray` | Nothing in the official corpus matched | — |

`pending_data` and `gray` exist deliberately. Tenants commonly upload the Chinese label and packaging photos first and file ingredients later — at that moment Appendix III can only return `pending_data`, not a fabricated green light. Likewise `gray` must read in the UI as **"no match this run," never "lawful"**: the 262 phrases are official *examples*, not an exhaustive list, and a non-match may simply mean the wording was rephrased.

Display precedence is `red > amber > pending_data > green > gray` — one red sentence turns the whole report red.

## 17.5 Source Monitoring and a Fingerprint Trap

Regulations change, and a corpus goes stale. We periodically fingerprint the official law page and treat a basis as stable only after two consecutive identical readings.

Our first implementation hashed the whole HTML page — and **every fetch differed**. The page is ASP.NET, and its `__VIEWSTATE` hidden field changes on every response. The "two consecutive matches" condition could therefore never hold: monitoring appeared to run while being **completely blind to real amendments**.

The fix is `stable_rule_signature()`: hash only the revision-history section and the article body, skipping all dynamic fields. This failure mode — monitoring that runs but is permanently false — belongs to the same family as the silent discard in §17.2.1: **failures with no error message**, findable only by distrusting the mechanism itself.

## 17.6 Advisory Only: How Responsibility Transfers

Every verdict carries `advisory_only: true` and blocks no save or generation flow. This is a product decision anchored by the operator: **the platform warns, the business decides, the business bears the consequence.**

But "we warned you" needs evidence. When a tenant clicks "acknowledged, not changing for now" on a verdict, the system writes an acknowledgement: timestamp, subject, **the complete findings as displayed at that moment**, and the rule version then in force. One design choice is deliberate — **acknowledgement does not re-run the check**. A re-run could yield different results (ingredients may have been filed in the interim, turning `pending_data` into `red`), and that would no longer be what the tenant confirmed. We store what they saw, not what is true now.

## 17.7 Six False Negatives

Each of the following once returned a green light on a genuinely non-compliant label. False negatives are far more dangerous than over-flagging: over-flagging is noise, a false negative sends a non-compliant product to market.

| # | Trap | Consequence |
|---|---|---|
| 1 | Compound phrases separated by ideographic commas not split | Matching fails when only one item is used |
| 2 | `○○` placeholders not converted to wildcards | The official text uses `○○` for substitutable body parts; literal matching never fires |
| 3 | CJK compatibility ideographs (§17.3.1) | Visually identical, different code points, whole phrase missed |
| 4 | Concentration limits split across lines | Conditional claims misread as unconditional |
| 5 | Image-only marks never reaching the matcher (§17.2.1) | Packaging covered in organic seals raises no flag at all |
| 6 | `pending_data` absent from the alert banner | Items awaiting verification effectively vanish from the UI |

Item 5 bears repeating: it was not a missing feature. The feature existed, the AI recognised the marks, and the result was discarded at the type layer. **Built-but-unwired is externally indistinguishable from never-built** — and harder to spot, because the code is right there.

## 17.8 Observations and Limitations

- **262 phrases are examples, not an enumeration.** Article 2 requires holistic judgement, which is another way of saying that a rephrasing can evade any phrase matcher. This engine reliably catches **verbatim reuse of official examples** and is powerless against creative rewording.
- **The competent authority decides.** No automated output constitutes a compliance guarantee; both the UI copy and the API response state `advisory_only`.
- **Appendix III needs ingredient data.** Without filed ingredients the engine can only return `pending_data`; for a tenant who never files ingredients, that path effectively does not exist.
- **Image-mark recognition is bounded by the vision model.** Whether a `text_visible: false` mark is recognised is a model-capability question, not an engineering one, and no coverage rate should be promised externally.

The design core of the labeling and claims engine matches the rest of this book: **turn regulation into matchable structured data, let the LLM do the alignment and extraction it is good at, and leave conclusions to rules and to people.** What differs here is that the error asymmetry is extreme — better to warn once too often than to miss a single medical-efficacy claim.

## 📚 References

[^1]: Ministry of Health and Welfare. *Regulations for Determining False, Exaggerated or Medical-Efficacy Cosmetic Labeling, Promotion or Advertising* (L0030099), promulgated 2019-06-04, effective 2019-07-01, with Appendices I–IV. <https://law.moj.gov.tw>
[^2]: Taiwan FDA. *Cosmetic Labeling Requirements*, MOHW Order 1081603869, effective 2021-07-01.
[^3]: Ministry of Health and Welfare. *Cosmetic Hygiene and Safety Act*, Articles 7, 10, 20 and 22.
[^4]: Ministry of Health and Welfare. *Regulations Governing Cosmetic Product Information Files* — the regulation referenced by the Appendix II `*2` substantiation note.
[^5]: Unicode Consortium. *CJK Compatibility Ideographs (U+F900–U+FAFF)*. <https://www.unicode.org/charts/PDF/UF900.pdf>

## 📝 Revision History

| Version | Date | Summary |
|:---:|:---:|---|
| v0.4 | 2026-08-24 | Initial draft. Covers the Art. 7 / Art. 10 split, Claude Vision label extraction (21 fields + full ingredient list + certification marks), the tool-schema/response-model parity trap, construction of the 262-phrase L0030099 corpus (CJK compatibility ideographs, limits split across lines), five-state verdicts, the VIEWSTATE fingerprint trap in source monitoring, acknowledgement records, and six false negatives. |

---

© 2026 Baiyuan Tech. Licensed under CC BY-NC 4.0.

**Nav** [← Chapter 16: Self-Driving Evolution](ch16-self-driving-evolution.md) · [Appendix A: Glossary →](appendix-a-glossary.md)
