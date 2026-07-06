---
title: "Chapter 16: Self-Driving Evolution and Computation-Basis Documentation"
description: "The SA feedback learning loop, the agreement_rate KPI, active re-grounding to expand NOAELs from authoritative sources, the computation-basis documentation SSOT, and an honest boundary: what real autonomous growth actually is when there is no signing feature."
chapter: 16
lang: en
authors:
  - "Vincent Lin"
keywords:
  - "self-driving evolution"
  - "agreement_rate"
  - "re-grounding"
  - "computation basis"
  - "tox_reference"
  - "adversarial red team"
  - "asymmetric learning"
word_count: approx 3300
last_updated: 2026-07-06
---

# Chapter 16: Self-Driving Evolution and Computation-Basis Documentation

> "We are already an AI — can't we evolve ourselves every time?" This user-anchored line opened the design of a self-learning system. But what this chapter records is not only how it works, but also an honest boundary — **under the current premise that the platform has no safety-assessor signing feature, "learning from signed cases" has no autonomous fuel**. Real growth that does not rely on humans comes from three other blocks: the deterministic engine, the resolved-cache, and active re-grounding. Being clear about this matters more than claiming a pretty but idling loop.

## 📌 Chapter Highlights

- **The definition of "100% success rate"**: not "100% pass" (that would be unsafe), but `agreement_rate → 1.0` — every AI verdict is ultimately consistent with the SA, zero false negatives, zero numbers without provenance.
- **Asymmetric learning**: false-safe (an AI miss intercepted by the SA) → can auto-tighten (safe direction); over-flag (false alarm) → can only produce a calibration proposal, requiring a human toxicologist's verification before relaxing.
- **Honest boundary**: the platform's `sa_reviews.signed_at` is currently all 0 — there is no real signing. So the ground truth for "learning from signing" is all hand-curated (uploaded SA-signed PDFs + official sample PIFs), **not something the platform grew itself**.
- **Real autonomous growth (already live)**: ① the deterministic engine (curated read-across + structural similarity + Cramer/TTC), where new ingredients are automatically resolved from structure; ② the resolved-cache, which sediments anchors from the cited values of already-analyzed ingredients; ③ active re-grounding, which proactively queries EPA ToxValDB for cited NOAELs of data_gap ingredients.
- **Computation-basis documentation SSOT**: every computation constant (TTC / exposure / DAp / SED / MoS / NOAEL) is anchored to authoritative literature, recording the adopted value + alternative value + why the strictest was chosen, output together in the report appendix.

## 16.1 "100% Success Rate" Is Not "100% Pass"

The first design decision for the self-driving system was to define the goal clearly. The user anchored "achieve a 100% success rate", but this phrase has a dangerous misreading — if understood as "100% of formulas pass", that turns safety assessment into a rubber stamp, entirely violating the fail-safe constitution.

The correct definition is `agreement_rate → 1.0`:

> Every AI safety verdict is consistent with the final human SA decision — zero false negatives, zero numbers without provenance, and the SA feedback loop progressively converges false alarms toward 0.

In other words, success is not "letting more formulas pass" but "the AI's judgment getting closer and closer to that of a rigorous toxicologist". This metric has zero tolerance for false negatives (letting a hazard through = immediate failure), while false positives (conservative mis-flags) are counted as over-flags pending calibration.

## 16.2 Asymmetric Learning

The core of the learning loop is an asymmetric rule that maps directly to Chapter 14's fail-safe philosophy:

| Error type | Meaning | Learning action |
|---|---|---|
| **false-safe** | AI judged safe, SA intercepted (a miss) | Auto-tighten — a safe-direction adjustment may be auto-adopted by the engine |
| **over-flag** | AI judged review, SA considered it actually safe (false alarm) | Can only produce a **calibration proposal**, requiring a human toxicologist's verification before relaxing |

The directionality is clear: **tightening may be automatic, relaxing must be human-reviewed**. This ensures that even if the self-driving system learns wrong, the wrong direction is "more conservative" rather than "more lenient" — a system that always drifts toward the safe side is far more trustworthy than one that might relax its own thresholds.

## 16.3 The Honest Boundary: No Signing, So Where Does Signing-Learning Come From

The self-driving system designed a "learn from SA signed cases" loop (`tox_self_learning.rebuild_learned_anchors` learns structural anchors from ground truth with `sa_decision='acceptable'`). But PROD evidence exposed an assumption:

> `sa_reviews.signed_at IS NOT NULL` → **0**. The platform currently has no truly completed signings.

This means that learning loop **has no autonomous fuel**. The ground truth it learns from (a dozen or so entries) is all **hand-curated**: SA-signed PDFs manually uploaded by the user, official sample PIFs, red-team boundary cases. These are fed in by humans, not grown from the platform's own signings.

This point must be recorded honestly, otherwise it would mislead the reader into thinking the system has a self-reinforcing flywheel. **Without a signing feature, the "learn from signing" path moves only when someone manually adds ground truth.** Stating this clearly is part of engineering honesty — a pretty but idling loop should not be advertised as autonomous evolution.

So what is real autonomous growth that does not rely on humans? The next three sections.

## 16.4 The Three Truly Autonomous Blocks (Already Live)

### 16.4.1 The Deterministic Engine

Chapter 14's fallback cascade is itself autonomous: curated read-across rules, the RDKit structural-similarity engine, Cramer/TTC — **when a new ingredient comes in, the engine gives a verdict directly by structural resolution, with no learning loop needed**. This is the most reliable block, because its behavior is fully deterministic, traceable, and independent of how much historical data exists.

### 16.4.2 Resolved-Cache Sedimentation

`rebuild_resolved_anchors_from_history` automatically sediments the parsing results with a cited NOAEL from `ingredient_tox_cache` (the cache of already-analyzed ingredients) into anchors. This **requires no signing** — as long as an ingredient has once been resolved by an authoritative value, it can serve as an analogue for future read-across. The limitation is a low yield: most cosmetic ingredients are botanical extracts / have no cited NOAEL, and no anchor can be sedimented from them.

### 16.4.3 Active Re-Grounding

This is the correct answer to "autonomous even without signing". For ingredients with "no NOAEL found", the system **proactively** queries an authoritative source (EPA ToxValDB) to fetch more cited NOAELs, expanding from the source rather than passively waiting to be fed by humans.

`tox_regrounding.py` (the harvester) runs in `skip_ai=True` mode — **EPA ToxValDB is the only non-AI numeric source** (OECD/ECHA return only existence; CIR/SCCS go into the AI queue). A daily cron scans data_gap → enqueues → processes → sediments regrounded anchors. PROD evidence (with AI offline) did fetch cited NOAELs: Phenoxyethanol 80, Salicylic Acid 100, ZnO 31.25 — all from EPA ToxValDB, with zero ground-truth contradictions.

One pitfall stepped on three times is worth recording: early re-grounding tried to sediment results into a **structural anchor** (which needs a SMILES), but the raw return of `skip_ai=True` does not carry a canonical SMILES → sedimentation failed. The correct answer is not to force a SMILES, but to **store the regrounded NOAEL back into the resolver as a cited Tier, keyed by CAS** — the next time the same CAS appears, use it directly without going through structure. A data_gap can be retried after a 7-day cooldown (re-fetched whenever the authoritative source updates).

## 16.5 The Computation-Basis Documentation SSOT

For the self-driving system to be trustworthy, every computation constant it uses must be traceable to authoritative literature, not a magic number an engineer filled in casually. `tox_reference.py` is an SSOT of computation bases: every basis (TTC, exposure, DAp, SED, MoS, NOAEL assessment factor) is anchored to an authoritative source and records three things — **the adopted value, the alternative value, and why the strictest was chosen**.

| Basis | Authoritative source | Design principle |
|---|---|---|
| TTC threshold | Munro 1996 / Kroes 2004 / Cramer 1978 | With a structural alert, take the strictest 0.15 µg/day |
| Exposure E | SCCS/1647/22 Table 3A/3B | Use only if the authority lists it; if not, fall to conservative whole-body |
| DAp | SCCS/1647/22 §4-5 + Bos & Meinardi | Fixed oils 5%; essential oils / small molecules not applied |
| MoS threshold | SCCS convention | ≥ 100 (10× interspecies × 10× inter-individual) |

`verify_live_constants()` self-checks whether the live constants are consistent with the documented literature — if someone changed a constant in the code without updating its literature basis, the self-check catches it. The safety-assessment report's appendix (§8) outputs this basis together via `render_basis_appendix()`, letting the SA and the regulator see "where each number comes from".

**Iron rule**: a safety threshold must not be naively "aligned to the literature" and relaxed. TTC deliberately takes the strictest — the literature gives a range, and the system takes the conservative end. Before changing any safety constant, one must first read that constant's literature-basis annotation and understand why this value was chosen in the first place.

## 16.6 Adversarial Red-Teaming

Validating the self-driving system cannot only run "normal formulas"; it must proactively attack itself. Every round of deepening runs an adversarial red-team to confirm fail-safe has no breach:

- **Ultra-low-concentration genotoxic / CMR**: Estradiol, even with an MoS as high as a million (because the concentration is 0.0001%), is still blocked as prohibited — proving the hard gate overrides MoS.
- **Over-limit carcinogen**: Titanium Dioxide at 30% / 40% / 100% is all blocked.
- **Pathological input**: a dozen malformed inputs (empty ingredient, garbled text, extreme values), zero crash, zero bare blank.
- **Heavy-metal salts**: ultra-low-concentration mercuric chloride and other salts, all prohibited after the §15.5 hole-fill.

The red-team's pass criterion is "zero false-safe breach" — if even one hazardous input is released as safe, it is a failure. After multiple red-team rounds, the false-safe dimension was judged truly converged (rather than merely not-yet-caught), at which point it is advisable to stop deep-mining that dimension and turn to other backlog (such as dedicated gates for inhalation dosage forms, or an SED model for hair-dye / perm products).

## 16.7 Observations and Limitations

- **The self-driving fuel is still limited**: the deterministic engine and re-grounding are truly autonomous, but the learning loop lacks signing fuel. To make "learning from decisions" truly run, the lightest substitute is a user "adopt this report" one-click (not the full signing workflow) → convert to ground truth.
- **Re-grounding yield is limited by authoritative-source coverage**: EPA ToxValDB covers repeated-dose oral NOAELs fairly well, but for botanical extracts, surfactants, etc., it still often finds nothing, and such ingredients ultimately fall to TTC or data_gap.
- **Over-flag calibration is ongoing work**: some conservative false positives (whole-body exposure fallback) are on the safe side and are not a breach, but neither can they be auto-relaxed — because the authority has no corresponding exposure value. Relaxation is always a human-review threshold.
- **Do not claim what cannot be done**: this chapter deliberately distinguishes "already-live autonomy" from "fuel-lacking loop". Engineering honesty requires that we not package an idling signing-learning loop as a self-evolving flywheel.

The core value of self-driving evolution lies not in any single machine-learning technique, but in honest engineering under constraint: **use the deterministic engine and active re-grounding to achieve real growth that does not rely on humans, use asymmetric learning to ensure any automatic adjustment drifts to the safe side, and clearly mark which loops currently still lack fuel — letting the system's degree of autonomy honestly correspond to the data it actually possesses.**

## 📚 References

[^1]: Munro, I. C., et al. (1996). *Correlation of structural class with no-observed-effect levels: a proposal for establishing a threshold of concern*. Food and Chemical Toxicology, 34(9), 829–867.
[^2]: Kroes, R., et al. (2004). *Structure-based thresholds of toxicological concern (TTC)*. Food and Chemical Toxicology, 42(1), 65–83.
[^3]: SCCS. *The SCCS Notes of Guidance, 12th Revision (SCCS/1647/22)*. Table 3A/3B (exposure), §4-5 (dermal absorption). <https://health.ec.europa.eu>
[^4]: US EPA. *CompTox Chemicals Dashboard — ToxValDB*. <https://comptox.epa.gov/dashboard>
[^5]: EFSA Scientific Committee (2019). *Guidance on the use of the Threshold of Toxicological Concern approach in food safety assessment*. EFSA Journal, 17(6):5708.

## 📝 Revision History

| Version | Date | Summary |
|:---:|:---:|---|
| v0.3 | 2026-07-06 | First written. Covers the agreement_rate definition, asymmetric learning, the honest boundary of having no signing feature, the three truly-autonomous blocks (deterministic engine / resolved-cache / active re-grounding), the computation-basis documentation SSOT, and adversarial red-teaming. |

---

© 2026 Baiyuan Tech. Licensed under CC BY-NC 4.0.

**Navigation** [← Chapter 15: Regulatory Correctness](ch15-regulatory-correctness.md) · [Appendix A: Glossary →](appendix-a-glossary.md)
