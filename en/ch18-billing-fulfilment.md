---
title: "Chapter 18: Billing Model and Service Fulfilment"
description: "Turning knowledge work into a sellable unit: report credits with entitlement that follows the balance, a ratchet on product slots, anti-arbitrage tiered refunds, and the fulfilment layer that dispatches 'a human must sign' and 'physics must wait' to partner vendors."
chapter: 18
lang: en
authors:
  - "Vincent Lin"
keywords:
  - "report credits"
  - "entitlement"
  - "tiered refund"
  - "fulfilment"
  - "ratchet"
word_count: approx 2900
last_updated: 2026-08-24
last_modified_at: '2026-08-26T02:16:54Z'
---



# Chapter 18: Billing Model and Service Fulfilment

> The previous seventeen chapters cover automating regulatory knowledge work. This chapter covers something equally engineered and rarely written into technical whitepapers: **how to turn it into units that can be sold, refunded and dispatched**. Errors in this layer produce no incorrect toxicological conclusions — they produce incorrect amounts of money, and monetary error has no fail-safe direction.

## 📌 Chapter Highlights

- **The unit of sale is output, not seats.** The smallest purchasable unit is one credit for one safety assessment report, not a monthly seat. Small brands that file a handful of products a year need not pay a subscription.
- **Entitlement follows the balance, not the history.** `org_is_paid` does not ask "did they ever pay" but "**do they still have credits**." A zero balance returns the account to trial limits; buying again restores it. The old "any successful order grants permanent paid status" clause left zero-balance accounts holding paid features forever, and was removed.
- **Product slots ratchet; credits do not.** The two carry deliberately different semantics — slots are granted on **lifetime cumulative purchases** and never shrink with consumption (so a customer's existing products are never locked by running out of credits); feature entitlement follows the **current balance**.
- **Refunds resist arbitrage.** Refund = amount paid − units consumed × **the unit price of the tier matching consumption**. Use less, pay more per unit — eliminating "buy the big pack, use three, refund the rest." A pure function with no database access, fully unit-testable.
- **Fulfilment is its own layer.** Once the platform finishes the knowledge work, "a human must sign" (SA signature) and "physics must wait" (laboratory testing) are dispatched to partner vendors, with cost and sale prices recorded for monthly settlement.

## 18.1 Why Not Subscription Seats

PIF filing is **event-driven** demand: a brand may launch three products in a year and then do nothing for six months. Under a per-seat monthly model such a customer pays for the months they do not use — precisely the strongest objection small brands raise against compliance tooling.

So the smallest unit of pricing is **output**: one safety assessment report equals one credit. Plans (Pro / Enterprise) still exist, but what they sell is bundled quota and peripheral capability (product slots, PDF export, unlimited toxicology lookups) rather than access itself.

The engineering consequence is that **"is this account paid" is not a boolean column but a state that must be computed on demand**.

## 18.2 Entitlement Follows the Balance, Not the History

`org_is_paid()` in `app/services/feature_access.py` checks four conditions in order; any one grants paid status:

1. Beta exemption (`plan_exempt`) — partners and internal accounts
2. Billing exemption (`billing_exempt`)
3. Plan is `pro` or `enterprise`
4. **Report credit balance > 0**

Condition 4 replaced an earlier "any successful payment order → permanently paid" rule. The problem with the old rule was concrete: a user who bought a single report and spent it would **permanently retain** paid features such as AI formula extraction — the platform kept paying for their AI vision costs while they no longer paid anything. Keying on the current balance means a zero balance returns the account to trial limits, and buying again restores it.

### 18.2.1 A Deliberate Asymmetry: Product Slots Ratchet

The credit balance governs **feature entitlement** but not the **product slot ceiling**. Slots are granted from `lifetime_purchased` (cumulative reports ever bought) and never shrink with consumption.

The reason is data accessibility. If slots also followed the balance, a customer who exhausted their credits would find **products they had already created** exceeding the ceiling and locked — using the billing mechanism to impound the customer's own compliance data. Features may be withdrawn; delivered data may not.

## 18.3 Refunds: Use Less, Pay More Per Unit

Credits are sold in packs, with larger packs carrying lower unit prices. This creates an obvious arbitrage path: buy the largest pack at the lowest unit price, use a few, request a refund on the remainder, and effectively obtain retail volume at bulk pricing.

The rule in `app/services/refund_calc.py` closes it:

```text
refund = amount paid − units consumed × (unit price of the tier matching units consumed)
```

The second term deliberately uses the tier matching **actual consumption**, not the tier at **purchase time**. Buy 50 units, use 3, and those 3 are priced at the 3-unit retail tier. Consumption is attributed FIFO.

The module is deliberately written as a **pure function with no database access and no outbound calls** — a refund amount is the last computation that should carry hidden state. The actual card refund, credit note, credit clawback and order marking are executed by the payments layer using the amount this module returns.

## 18.4 Fulfilment: Dispatch Is Not Outsourced Support

What the platform can automate is knowledge work. But two classes of work in the PIF process **cannot be automated in principle**:

| Type | Why it cannot be automated | Dispatched to |
|---|---|---|
| SA signature | Regulation requires a qualified natural person to sign and take responsibility | Partner safety assessors |
| Laboratory testing | Physically requires waiting (stability, microbiology, heavy metals) | Partner testing laboratories |

Three modules — `service_vendors`, `service_orders`, `service_admin` — form this layer: the tenant places an order, the platform dispatches to a vendor, progress is reported back, and settlement occurs monthly. The system records both **cost price and sale price**, because that is the actual basis for reconciliation between platform and vendor.

One design constraint is worth recording: **an SA signature must be bound to a specific report** — platform-generated or customer-supplied, but never a vague "sign off on this product." The assessor signs that version of that report, which extends the same principle as the signature metadata in Chapter 13 (content hash plus version binding).

Outsourced services sit behind a platform-level switch that defaults to off. The reasoning is recorded in the code: open it on the vendor and service pricing page only after fulfilment is confirmed possible. **Advertising a service that cannot be fulfilled once purchased is worse than not offering it.**

## 18.5 Observations and Limitations

- **Credits do not suit high-volume customers.** For contract manufacturers filing dozens of products a year, plan-based pricing has a lower marginal cost. Pro and Enterprise cover this today, but the crossover point has not been calibrated against sufficient real data.
- **The refund tier table and the pack definitions must stay in sync.** The tiers in `refund_calc` are a floor table aligned with `DEFAULT_PACKAGES`; if packaging is adjusted without updating the tiers, refunds will be computed off-target. This is a two-source risk **not yet locked by a test**.
- **Vendor settlement is monthly reconciliation, not real time.** Cost and sale prices are recorded, but automated reconciliation reporting is not yet built.
- **Prices never appear in front-end copy.** Amounts come from `payment_settings.packages` and can be overridden from the admin console; a "page shows the old price while the database holds the new one" misstatement has occurred before, so pricing is always rendered dynamically.

The engineering principle in the billing layer differs from the rest of this book — there is no fail-safe direction here. A toxicological verdict can prefer false positives over false negatives; an amount cannot: overcharging and undercharging are both wrong. Hence this layer's preferences are **pure functions, unit-testable, single-sourced**, keeping uncertainty out of the computation.

## 📚 References

[^1]: PAYUNi. *Integrated Payment API Documentation*. <https://www.payuni.com.tw>
[^2]: Ministry of Health and Welfare. *Regulations Governing Cosmetic Product Information Files* — safety assessor (SA) qualifications and responsibilities.
[^3]: Ministry of Health and Welfare. *Cosmetic Hygiene and Safety Act*, Article 4 (safety assessment) and Article 8 (product information file).

## 📝 Revision History

| Version | Date | Summary |
|:---:|:---:|---|
| v0.4 | 2026-08-24 | Initial draft. Covers the rationale for report credits, entitlement following the balance (replacing the permanent-paid clause), the product-slot ratchet asymmetry, anti-arbitrage tiered refunds, and the fulfilment layer with its SA-bound-to-report constraint. |

---

© 2026 Baiyuan Tech. Licensed under CC BY-NC 4.0.

**Nav** [← Chapter 17: Labeling and Claims Compliance Engine](ch17-labeling-claims-engine.md) · [Chapter 19: Operational Observability and Edge Topology →](ch19-observability-edge-topology.md)
