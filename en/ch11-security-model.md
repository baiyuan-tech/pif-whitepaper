---
title: "Chapter 11: Security Model"
description: "Threat model, AES-256 encryption, JWT+TOTP, audit logging, i18n security considerations, and OWASP Top 10 mapping"
chapter: 11
lang: en
authors:
  - "Vincent Lin"
keywords:
  - "security"
  - "threat model"
  - "AES-256"
  - "JWT"
  - "TOTP"
  - "OWASP"
  - "audit"
word_count: approx 2000
last_updated: 2026-04-19
last_modified_at: '2026-04-21T15:50:45Z'
---




# Chapter 11: Security Model

> This chapter is primary reading for auditors, security researchers, and CISOs. We use STRIDE threat modeling to inventory PIF AI's attack surface, provide a mitigation for each threat, and map to OWASP Top 10 (2021). The chapter closes with the specific security rationale behind the 5-locale i18n + super-admin exception.

## 📌 Key Takeaways

- **STRIDE** threat modeling; mapped to OWASP Top 10 item-by-item
- Double encryption: app-layer AES-256 for formulations + storage-layer S3 SSE-KMS
- Dual-factor auth: JWT access (15 min) + refresh; SA operations require TOTP
- Audit logs are immutable (DB user has no UPDATE/DELETE); archived to WORM S3
- Super-admin UI NOT localized — a **security design** to avoid mistranslation-induced ops errors

## 11.1 Threat Model (STRIDE)

STRIDE[^1] (Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege) is the threat taxonomy PIF AI adopts.

### 11.1.1 Asset Inventory

Assets prioritized for protection:

| Asset | Sensitivity | Consequence |
|------|--------|------|
| Formulation (INCI + concentrations) | **Critical** | Trade-secret leak → legal liability |
| SA signature | **Critical** | Forgery → regulatory liability + criminal forgery |
| User credentials | High | Identity theft → broad data exposure |
| Toxicology summaries | Medium | Derived from public data; limited impact |
| System configuration | High | Impacts all tenants' availability |

### 11.1.2 Threat Matrix

| Threat | Example attack | Mitigation |
|------|---------|------|
| **Spoofing** | Impersonate another user | JWT short-lived + refresh + device fingerprint (planned) |
| **Tampering** | Modify requests / audit | HTTPS everywhere + audit log immutable |
| **Repudiation** | SA denies signature | SA requires TOTP + e-signature recorded with IP + UA in audit |
| **Information disclosure** | Formulation leak | Four-layer isolation (§10) + AES-256 + alerts on anomaly |
| **Denial of service** | Flood AI calls | Rate limit + Cloudflare + fail-soft degradation |
| **Elevation of privilege** | Regular user → super admin | DB CHECK on `role` + super-admin requires separate user record (not upgrade) |

## 11.2 Authentication and Authorization

### 11.2.1 Identity Verification

PIF AI offers:

1. **Email + password** (bcrypt 12 rounds)
2. **Google OAuth** (Turnstile anti-bot)
3. **Passkey** (WebAuthn, planned)

### 11.2.2 JWT Design

| Token | Lifetime | Storage | Use |
|------|---------|------|------|
| Access Token | 15 min | Memory (not localStorage) | API authorization |
| Refresh Token | 7 days | HttpOnly Cookie | Access token renewal |
| Session cookie (NextAuth) | 24 hours | HttpOnly + Secure | Frontend session |

Short access tokens shrink stolen-token exposure. Refresh tokens in HttpOnly cookies are not XSS-exfiltratable.

### 11.2.3 TOTP Second Factor

SA is a high-sensitivity role. All `sa_review.*` endpoint calls require TOTP (Google Authenticator / Authy compatible):

```python
# app/core/security.py (conceptual)
def verify_totp(user: User, code: str) -> bool:
    if not user.totp_enabled:
        return True  # Non-SA users who haven't opted in
    totp = pyotp.TOTP(user.totp_secret)
    return totp.verify(code, valid_window=1)
```

`users.totp_secret` is stored with application-level encryption, not plaintext — even DB dumps don't reveal the seed.

### 11.2.4 Super-Admin Isolation

Super admin (Baiyuan Tech internal ops) is PIF's highest-privilege role. Isolations:

- Separate login URL: `/super-admin/login`
- Uses a dedicated DB user (`pifai_superadmin`) with BYPASSRLS
- All ops require TOTP
- **Super-admin UI is not localized** (see §11.5)

## 11.3 Encryption

### 11.3.1 Transit

- Site-wide HTTPS (**TLS 1.3** only)
- HSTS `max-age=31536000; includeSubDomains; preload`
- Certificates auto-renewed by Let's Encrypt (cert-manager on K8s / certbot on Docker)

### 11.3.2 Formulation File Double Encryption

As in §8.5, formulation files use **app-layer AES-256-GCM** + **S3 SSE-KMS**:

```python
# app/services/encryption.py (conceptual)
def encrypt_formula(plaintext: bytes, key: bytes) -> EncryptedPayload:
    nonce = os.urandom(12)
    aes = Cipher(algorithms.AES(key), modes.GCM(nonce)).encryptor()
    ciphertext = aes.update(plaintext) + aes.finalize()
    return EncryptedPayload(
        nonce=nonce,
        ciphertext=ciphertext,
        tag=aes.tag,
    )
```

`FILE_ENCRYPTION_KEY` is 256-bit, managed by Secret Manager (AWS Secrets Manager / HashiCorp Vault). **Never in git, never in .env plaintext** (loaded dynamically via IAM role / service token).

### 11.3.3 DB Field Encryption

Sensitive fields are encrypted at application layer before DB write:

| Field | Encryption | Reason |
|------|----------|------|
| `users.totp_secret` | Fernet (symmetric) | 2FA seed |
| `users.sa_certificate_url` | Fernet | SA qualification link |
| `organizations.api_keys` | Fernet | Third-party service keys (ECHA, etc.) |

## 11.4 Audit

### 11.4.1 Scope

See §8.4 for the full list. Security-focused events:

| Event | Trigger |
|------|---------|
| `auth.login_success` / `auth.login_failed` | `app/api/v1/auth.py` |
| `auth.totp_failed` | TOTP verification error |
| `org.data_export` | Organization data download |
| `admin.bypass_rls` | Super admin uses BYPASSRLS |
| `security.suspicious_login` | Anomalous IP or excessive failures |

### 11.4.2 Immutability

- The application's DB user has INSERT-only permission
- A daily cron writes `audit_logs` to a WORM S3 bucket (Object Lock compliance mode, 10-year retention)
- Each row includes a SHA-256 hash of the previous row (hash chain, blockchain-inspired)

### 11.4.3 Real-time Alerts

The following trigger Slack / PagerDuty alerts:

- 5 consecutive `auth.login_failed` (same user or IP)
- Any `admin.bypass_rls` event
- 5 consecutive `rag_client` failures (external service outage)
- DB connection pool exhaustion

## 11.5 i18n and Security

### 11.5.1 Why Super-Admin Is Not Localized

PIF AI supports 5 locales (zh-TW / en / ja / ko / fr) in user-facing UI. However, `/super-admin/*` pages deliberately do **not** import `useI18n()`. Security rationale:

1. **Ops precision**: "revoke beta exemption" could be misinterpreted if mistranslated
2. **Translation QA risk**: 5 locales would need 5 native ops reviewers; missing any reduces reliability
3. **Reduce attack surface**: translation strings are also input; XSS risk exists — super-admin in one language means 4× less exposure
4. **Internal lingua franca**: Baiyuan Tech ops staff speak Chinese natively; direct Chinese is clearest

This is a **design decision**, clearly noted in [CLAUDE.md](https://github.com/baiyuan-tech/pif/blob/master/CLAUDE.md) and memory `memory/project_pif_i18n.md`.

### 11.5.2 Translation Security in User-Facing UI

The 5-locale JSON is professionally translated (via Claude Code, not machine translation), but security requires:

- Translation strings rendered as React props via `{t("key")}`, never as HTML
- React auto-escapes special chars (< > & ")
- No `dangerouslySetInnerHTML` on translated content

## 11.6 OWASP Top 10 (2021) Mapping

| OWASP Risk | PIF AI |
|------|------|
| **A01 Broken Access Control** | Four-layer isolation (§10.3.3) |
| **A02 Cryptographic Failures** | Double AES-256 + TLS 1.3 + Fernet DB |
| **A03 Injection** | SQLAlchemy ORM + Pydantic + zod |
| **A04 Insecure Design** | Threat-model-driven design; fail-soft principle |
| **A05 Security Misconfiguration** | Docker image trivy scan; no DEBUG in production |
| **A06 Vulnerable Components** | dependabot + renovate auto-update |
| **A07 ID & Auth Failures** | JWT short-lived + TOTP + rate limit |
| **A08 Software & Data Integrity** | Immutable audit + hash chain |
| **A09 Logging & Monitoring** | Structured logging + real-time alerts |
| **A10 SSRF** | External API allowlist (PubChem/ECHA/RAG only) |

## 11.7 Future Threat Hunting

Phase 2+ plans:

- **Anomaly detection**: user behavior baseline + deviation alerts
- **SIEM integration**: audit logs → ELK / Datadog
- **Bug bounty**: public vulnerability disclosure program (see parent project SECURITY.md)

## 📚 References

[^1]: Microsoft. *The STRIDE Threat Model*. <https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats>
[^2]: OWASP. *OWASP Top 10 (2021)*. <https://owasp.org/Top10/>
[^3]: NIST (2017). *NIST SP 800-63B Digital Identity Guidelines*.
[^4]: RFC 6238. *TOTP: Time-Based One-Time Password Algorithm*.

## 📝 Revision History

| Version | Date | Summary |
|:---:|:---:|---|
| v0.1 | 2026-04-19 | First draft. STRIDE, auth, encryption, audit, i18n security, OWASP mapping |

---

© 2026 Baiyuan Tech. Licensed under CC BY-NC 4.0.

**Nav** [← Chapter 10: Central RAG](ch10-central-rag.md) · [Chapter 12: Roadmap →](ch12-roadmap-deployment-opensource.md)
