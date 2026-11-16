# OWASP Top 10 Pocket Guide — SME content review packet

Generated from `assets/content/bundle.json` for bundle **2026.10.29-draft** (schema 1.0.0, status **draft**). Do not edit the generated files by hand; change the bundle and run `dart run tool/generate_sme_review_packet.dart`.

## Scope

This packet covers every risk, quiz question and cheatsheet in the MVP bundle. Reviewers should confirm technical accuracy and alignment with the official OWASP edition cited for each list.

## Coverage

| List | Edition | Risks | Quiz questions | Cheatsheets | Risks with reviewer | License |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| OWASP Top 10 | 2025 | 10 | 5 | 3 | 0 | CC-BY-SA-4.0 |
| OWASP API Security Top 10 | 2023 | 10 | 5 | 2 | 0 | CC-BY-SA-4.0 |
| OWASP Top 10 for LLM Applications | 2026 | 10 | 5 | 2 | 0 | CC-BY-SA-4.0 |
| OWASP MCP Top 10 | 2025 | 10 | 5 | 2 | 0 | CC-BY-SA-4.0 |
| OWASP Agentic Skills Top 10 | 2026 | 10 | 5 | 2 | 0 | CC-BY-SA-4.0 |
| OWASP Top 10 for Agentic Applications | 2026 | 10 | 5 | 2 | 0 | CC-BY-SA-4.0 |

## How to review

1. Open the sheet for each list: [WEB 2025](web-2025.md), [API 2023](api-2023.md), [LLM 2026](llm-2026.md), [MCP 2025](mcp-2025.md), [AGENTIC-SKILLS 2026](agentic-skills-2026.md), [AGENTIC-APP 2026](agentic-applications-2026.md).
2. For every risk, check the reviewer checklist and record a decision (approve, approve with edits, or reject).
3. Record decisions in `sign-off.csv` or the table below. Put the reviewer name and review date on every row you decide.
4. Send the completed CSV and any corrections back to the app maintainers. Corrections are applied to `bundle.json`, not to this packet.

## LLM 2026 source note

OWASP has not yet published category pages for the 2026 LLM edition on `genai.owasp.org`. The LLM sheet therefore cites the edition landing page and gives section/page ranges from the official v1.0 PDF (August 2026). Reviewers should confirm titles and page ranges against that PDF; citations can be updated to category pages once OWASP publishes them.

## Promotion from draft to final

The bundle stays `status: "draft"` until the content validator and tests pass with these conditions:

- every list has at least 10 risks and 5 quiz questions;
- every risk has a non-empty `reviewers` list and a `lastReviewed` date;
- every risk has at least one reference;
- all code samples name a language and label, quiz answers are in range, and IDs are unique.

After the reviewer names and dates are added, update `status` and `bundleVersion` in `bundle.json`, then run `flutter analyze` and `flutter test`.

## License and attribution

Bundle content license: **CC-BY-SA-4.0**. Each list records its own attribution; keep the attribution text with any reuse. The app source code is licensed under **GPL-3.0** (see `LICENSE`). OWASP marks are subject to the OWASP Foundation brand rules, separate from both licenses.

## Sign-off

| List | Risk | Reviewer | Decision | Date | Comments |
| --- | --- | --- | --- | --- | --- |
| WEB 2025 | A01 — Broken Access Control | | | | |
| WEB 2025 | A02 — Security Misconfiguration | | | | |
| WEB 2025 | A03 — Software Supply Chain Failures | | | | |
| WEB 2025 | A04 — Cryptographic Failures | | | | |
| WEB 2025 | A05 — Injection | | | | |
| WEB 2025 | A06 — Insecure Design | | | | |
| WEB 2025 | A07 — Authentication Failures | | | | |
| WEB 2025 | A08 — Software or Data Integrity Failures | | | | |
| WEB 2025 | A09 — Security Logging & Alerting Failures | | | | |
| WEB 2025 | A10 — Mishandling of Exceptional Conditions | | | | |
| API 2023 | API1 — Broken Object Level Authorization | | | | |
| API 2023 | API2 — Broken Authentication | | | | |
| API 2023 | API3 — Broken Object Property Level Authorization | | | | |
| API 2023 | API4 — Unrestricted Resource Consumption | | | | |
| API 2023 | API5 — Broken Function Level Authorization | | | | |
| API 2023 | API6 — Unrestricted Access to Sensitive Business Flows | | | | |
| API 2023 | API7 — Server Side Request Forgery | | | | |
| API 2023 | API8 — Security Misconfiguration | | | | |
| API 2023 | API9 — Improper Inventory Management | | | | |
| API 2023 | API10 — Unsafe Consumption of APIs | | | | |
| LLM 2026 | LLM01 — Prompt Injection | | | | |
| LLM 2026 | LLM02 — Sensitive Information Disclosure | | | | |
| LLM 2026 | LLM03 — Excessive Agency | | | | |
| LLM 2026 | LLM04 — Supply Chain | | | | |
| LLM 2026 | LLM05 — Data and Model Poisoning | | | | |
| LLM 2026 | LLM06 — Unbounded Consumption | | | | |
| LLM 2026 | LLM07 — Misinformation | | | | |
| LLM 2026 | LLM08 — Hidden Context Exposure | | | | |
| LLM 2026 | LLM09 — Vector and Embedding Weaknesses | | | | |
| LLM 2026 | LLM10 — Improper Output Handling | | | | |
| MCP 2025 | MCP01 — Token Mismanagement & Secret Exposure | | | | |
| MCP 2025 | MCP02 — Privilege Escalation via Scope Creep | | | | |
| MCP 2025 | MCP03 — Tool Poisoning | | | | |
| MCP 2025 | MCP04 — Software Supply Chain Attacks & Dependency Tampering | | | | |
| MCP 2025 | MCP05 — Command Injection & Execution | | | | |
| MCP 2025 | MCP06 — Prompt Injection via Contextual Payloads | | | | |
| MCP 2025 | MCP07 — Insufficient Authentication & Authorization | | | | |
| MCP 2025 | MCP08 — Lack of Audit and Telemetry | | | | |
| MCP 2025 | MCP09 — Shadow MCP Servers | | | | |
| MCP 2025 | MCP10 — Context Injection & Over-Sharing | | | | |
| AGENTIC-SKILLS 2026 | AST01 — Malicious Skills | | | | |
| AGENTIC-SKILLS 2026 | AST02 — Supply Chain Compromise | | | | |
| AGENTIC-SKILLS 2026 | AST03 — Over-Privileged Skills | | | | |
| AGENTIC-SKILLS 2026 | AST04 — Insecure Metadata | | | | |
| AGENTIC-SKILLS 2026 | AST05 — Untrusted External Instructions | | | | |
| AGENTIC-SKILLS 2026 | AST06 — Weak Isolation | | | | |
| AGENTIC-SKILLS 2026 | AST07 — Update Drift | | | | |
| AGENTIC-SKILLS 2026 | AST08 — Poor Scanning | | | | |
| AGENTIC-SKILLS 2026 | AST09 — No Governance | | | | |
| AGENTIC-SKILLS 2026 | AST10 — Cross-Platform Reuse | | | | |
| AGENTIC-APP 2026 | ASI01 — Agent Goal Hijack | | | | |
| AGENTIC-APP 2026 | ASI02 — Tool Misuse and Exploitation | | | | |
| AGENTIC-APP 2026 | ASI03 — Identity and Privilege Abuse | | | | |
| AGENTIC-APP 2026 | ASI04 — Agentic Supply Chain Vulnerabilities | | | | |
| AGENTIC-APP 2026 | ASI05 — Unexpected Code Execution | | | | |
| AGENTIC-APP 2026 | ASI06 — Memory and Context Poisoning | | | | |
| AGENTIC-APP 2026 | ASI07 — Insecure Inter-Agent Communication | | | | |
| AGENTIC-APP 2026 | ASI08 — Cascading Failures | | | | |
| AGENTIC-APP 2026 | ASI09 — Human-Agent Trust Exploitation | | | | |
| AGENTIC-APP 2026 | ASI10 — Rogue Agents | | | | |
