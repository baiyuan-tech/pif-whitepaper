---
title: "Chapter 19: Operational Observability and Edge Topology"
description: "One IP-resolution mistake causing three different harms: telemetry rendered meaningless, per-IP brute-force protection collapsed into a global lock, and signature evidence made forgeable. Plus the tenant funnel built on top — reusing the existing audit table rather than adding a new one."
chapter: 19
lang: en
authors:
  - "Vincent Lin"
keywords:
  - "observability"
  - "conversion funnel"
  - "client IP"
  - "X-Forwarded-For"
  - "edge topology"
  - "retention"
  - "append-only"
word_count: approx 2800
last_updated: 2026-08-24
last_modified_at: '2026-08-26T02:16:54Z'
---



# Chapter 19: Operational Observability and Edge Topology

> This chapter begins with a concrete question: a tenant registered, created a product, and left the same day — where did they get stuck? The only trace was the container's `docker logs`, which is ephemeral. The investigation incidentally exposed something more serious: **the platform's determination of "where did this request come from" was wrong in three separate places**, with entirely different consequences in each.

## 📌 Chapter Highlights

- **Ephemeral evidence is no evidence.** Reconstructing a user journey after the fact from `docker logs` worked exactly once, and only by luck (the container happened not to have been rebuilt). Tenants already lost cannot be recovered.
- **No new table.** Tenant footprints reuse the existing `audit_logs`, distinguishing behavioural events from document CRUD by a `funnel.` prefix. That table is already append-only, already indexed, already isolated — a second table would only create a second source of truth.
- **The retention boundary lives in the database, not in the purge job.** The `audit_logs` trigger permits DELETE only for rows past retention, and blocks UPDATE unconditionally. If the purge job is miswritten or wrongly invoked, unexpired records still cannot be deleted.
- **One IP mistake, three harms**: telemetry recording `127.0.0.1` for everyone (a meaningless field), per-IP brute-force protection collapsing into a single global bucket (a handful of failures locks out the entire platform), and signature source IP becoming whatever the signer chooses (evidence inverted).
- **The root cause is edge topology, not code.** The two most common industry patterns — prefer `CF-Connecting-IP`, or take the first `X-Forwarded-For` segment — are **both wrong** under this platform's L4 routing architecture.

## 19.1 The Question: Why Did the Tenant Leave?

A tenant registered, uploaded a label three times, created a product, attempted to generate a toxicology report from it, viewed the pricing page, and left. We wanted to know which step stopped them.

All that was available was `docker logs` — 138 lines spanning two days, gone the moment the container is rebuilt. Finding it at all was luck: they acted that morning and the container happened not to have been recreated for days. Earlier tenants lost in the same way are simply unreachable.

The cause is worth recording, because it was not a bug. Taiwanese cosmetic labels must list the full ingredient set by law, and the AI read it every time — but the system prompt at the time explicitly stated that ingredients were not to be extracted. They uploaded a label three times; the system read the ingredients three times and discarded them, then asked them to retype the whole formula into an empty form. They did not, checked the pricing, and left.

**That conclusion could only be derived afterwards from the code, not from the data** — because the data was never kept.

## 19.2 Footprints: Reusing the Existing Audit Table

The fix was not a new analytics table but reuse of the existing `audit_logs`, for three reasons:

1. It is already **append-only** (a DB trigger blocks UPDATE/DELETE) — behavioural records should not be editable in the first place.
2. It already carries tenant isolation and indexing (Chapter 8).
3. A new table would create a **second source of truth**: the same event could disagree between two tables.

Behavioural events carry a `funnel.` prefix to separate them from existing document CRUD audit rows, covering registration, login, label parsing, ingredient analysis, report preview, report generation, pricing views, checkout entry, and the two most valuable **blocked** events: hitting the paywall and exhausting quota.

> The people who hit a wall are the people who wanted to use something and could not — the closest to converting, and entirely invisible before this change.

### 19.2.1 Telemetry Must Not Join the Caller's Transaction

One easily mis-implemented detail: the existing audit contract is "only `db.add()`; the caller's commit persists it" — correct for business audit, where the record should live and die with the change it describes.

Telemetry cannot follow that contract. If telemetry commits inside a POST endpoint, it commits **business changes that have not yet completed**; if it does not commit, events on GET endpoints never persist. The resolution is for telemetry to open its own session, never touching the caller's transaction, wrapped entirely in try/except — **failing to write a log is not a business error**.

### 19.2.2 Retention: The Database Is the Gatekeeper

Behavioural records contain email, IP and a complete activity trail, together forming a personal behavioural profile. Retention is therefore three years, readable only by platform administrators.

The implementation question that matters is **where the boundary lives**. `audit_logs` originally blocked DELETE unconditionally; it now permits DELETE only where `created_at` is past retention, while still blocking UPDATE always (immutability and retention are separate concerns). The purge job is merely an executor — if it is miswritten, wrongly invoked, or miscalculates its parameters, unexpired records remain undeletable at the database layer.

Purging runs in batches of a few thousand rows: this table is continuously written on the request path, and deleting everything at once would hold locks for a long time.

## 19.3 Three Harms, One Root Cause

The first verification after building the footprint feature showed every recorded IP was **`127.0.0.1`**. Tracing the root cause revealed that the same mistake produced a different kind of harm in three separate places.

### 19.3.1 The Edge Topology

The production request chain is:

```text
Cloudflare → nginx:443 (L4 stream, SNI-based routing) → 127.0.0.1:8443 (nginx http) → application container
```

The L4 layer does not alter HTTP headers, but the connection reaching port 8443 originates locally, so `$remote_addr` at that layer is always `127.0.0.1`. That layer's configuration, in order to prevent spoofing, overwrites `CF-Connecting-IP` with `$remote_addr` — turning **everyone into `127.0.0.1`**.

The real source remains in `X-Forwarded-For`. Access logs show the contrast directly: `$remote_addr = 127.0.0.1` while `$http_x_forwarded_for` holds the genuine external address.

### 19.3.2 Both Common Patterns Are Wrong Here

| Pattern | Result under this topology |
|---|---|
| Prefer `CF-Connecting-IP` | Everyone becomes `127.0.0.1` (the header is deliberately overwritten) |
| Take the **first** `X-Forwarded-For` segment | Returns whatever value the client injected |

The second follows from how CDNs behave: the real IP is **appended to the end** of XFF, leaving any client-supplied value in front. The correct rule is therefore **the last non-private address in XFF** — forged values (at the front) are skipped, internal hops (private addresses) are skipped, and what remains is the source the CDN attests to.

This is not forgeable under this topology, provided the L4 layer accepts **only CDN sources** for platform domains (non-CDN external connections are routed to a black hole). Connections that bypass the CDN are reset at the connection layer, so any request reaching the application necessarily passed through the CDN.

### 19.3.3 Three Very Different Consequences

| Site | Consequence of the error | Severity |
|---|---|---|
| Footprint telemetry | Every row records the same value; the IP field is meaningless | Useless data |
| per-IP login throttle | Everyone shares one counter bucket | **Availability**: anyone accumulating the failure limit locks out every tenant |
| Signature source IP | The signer chooses what the record says | **Evidentiary**: the field's purpose is inverted |

The second is the most severe. The per-IP brute-force ceiling is deliberately generous (to accommodate shared NAT and corporate egress), but once everyone collapses into one bucket, that generous ceiling becomes a **platform-wide lock** — no privileges required, and accumulating the limit in failures denies login to all tenants. The symptom (no error message, retries making it worse) is identical to a real login incident, making misdiagnosis easy.

The third is different in nature: the signature source IP belongs to the same field group as the content hash, version binding and assessor credential snapshot that together constitute **non-repudiation**. If the signer can decide which IP the record shows, the field's purpose inverts — from proving "you signed here" to recording "you say you signed there."

The timing of the fix is worth noting: no actual signature had yet occurred, so no existing records were left carrying two different semantics for one field. **Changing the semantics of an evidentiary field is cheapest before it holds any data.**

### 19.3.4 Converging on a Single Source

The three sites each had their own implementation with differing semantics. After the fix the platform holds exactly one IP-resolution implementation, locked by two tests: no module may re-implement it, and — a **behavioural** assertion — feeding an XFF with a forged prefix must yield the CDN-appended real source.

Behavioural assertions are more reliable than string matching: if someone later rewrites the implementation differently, the test still fails whenever the behaviour is wrong.

## 19.4 Observations and Limitations

- **Footprints are only valid from deployment onward.** Tenants lost earlier cannot be reconstructed — the permanent regret behind this chapter's opening question.
- **Anonymous browsing cannot be attributed.** The pricing page requires no credentials, so unauthenticated views retain only an IP; authenticated views are attributed on a best-effort basis, but that path currently sees very few hits.
- **The sample is far too small for conclusions.** Event counts in the first weeks are in the single to low double digits — not even a trend, and any product decision drawn from them would be unsafe.
- **Edge topology changes.** The rule documented here is bound to the current CDN plus L4 routing architecture; if the platform later moves to direct connection or additional proxy layers, the rule must be re-verified — which is precisely why it is converged into a single source.

This chapter's lesson compresses to one line: **failures with no error message are the most expensive.** Recording `127.0.0.1` for everyone raises no exception, a throttle collapsing into a global bucket raises no exception, and a forged signature IP raises no exception. They are found only by distrusting the mechanism itself and asserting at the behavioural layer.

## 📚 References

[^1]: Cloudflare. *Restoring original visitor IPs — CF-Connecting-IP and X-Forwarded-For*. <https://developers.cloudflare.com>
[^2]: IETF RFC 7239. *Forwarded HTTP Extension*. <https://www.rfc-editor.org/rfc/rfc7239>
[^3]: OWASP. *Blocking Brute Force Attacks*. <https://owasp.org>
[^4]: Taiwan *Personal Data Protection Act*, Article 5 (proportionality) and Article 11 (retention and deletion).
[^5]: NIST SP 800-92. *Guide to Computer Security Log Management*.

## 📝 Revision History

| Version | Date | Summary |
|:---:|:---:|---|
| v0.4 | 2026-08-24 | Initial draft. Covers the ephemeral-evidence problem, footprint design reusing `audit_logs`, telemetry in its own transaction, the retention boundary living in a DB trigger, the two common IP-resolution mistakes under this edge topology, the three distinct harms from one root cause (telemetry / brute-force protection / signature evidence), and convergence to a single source with behavioural verification. |

---

© 2026 Baiyuan Tech. Licensed under CC BY-NC 4.0.

**Nav** [← Chapter 18: Billing Model and Service Fulfilment](ch18-billing-fulfilment.md) · [Appendix A: Glossary →](appendix-a-glossary.md)
