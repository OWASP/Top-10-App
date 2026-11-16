# OWASP Top 10 Pocket Guide

## Project summary for stakeholders

**Prepared:** 22 October 2026  
**Status:** Working draft. Content is not yet reviewed and the app is not ready for public release.  
**Name:** OWASP Top 10 Pocket Guide (the application ID `com.example.top_10_app` is a placeholder).

> **OWASP project:** The Pocket Guide is an OWASP project. Use of the OWASP name, logo and other marks is confirmed. The content remains a draft until SME review.

---

## Executive summary

The Pocket Guide is a single Android app that puts six OWASP Top 10 editions in one offline, searchable reference: Web (2025), API Security (2023), LLM Applications (2026), Agentic Skills (2026), Agentic Applications (2026) and MCP (2025). Each risk is presented as a short summary, a real-world example, vulnerable and secure code, how to test for it, how to fix it, and the official citation with its source URL. Five questions per list and thirteen condensed cheatsheets turn reading into practice.

The product is functionally complete and has been exercised on an emulator and on a physical Samsung phone. Its content, however, is still a **draft**: none of the 60 risk entries has been signed off by a subject-matter expert (SME), and the package ID remains unresolved. Engineering has deliberately made these blockers impossible to ship past: a release build refuses to display draft content.

**What we are asking for:** approval of the review plan and named reviewers, and a decision on the package ID. Details are in [Decisions requested](#9-decisions-requested).

---

## 1. The problem

Security guidance is fragmented. OWASP publishes separate Top 10 lists for web applications, APIs, AI/LLM systems, agentic skills, agentic applications and MCP servers. Practitioners who work across those areas keep six documents open, lose the citations when they copy notes, and often cannot get online at the moment they need the guidance — during an incident, a design review or a client visit. The app groups the four AI-related editions — LLM, Agentic Skills, Agentic Applications and MCP — together in the filters, so the AI guidance reads as one set.

Existing summaries tend to drop the parts that matter: the official wording, the reason a risk is ranked where it is, and the link back to the source of truth. The Pocket Guide is built around the opposite idea: **short enough to read in a queue, but every claim is traceable to the OWASP edition it came from.**

---

## 2. What has been built

| Area | State |
| --- | --- |
| Android app (Flutter) | Working; installs and runs on a physical device |
| Content | 6 editions, 60 risk entries, 30 quiz questions, 13 cheatsheets — all authored and validated |
| Search and filters | Working, including input hardening |
| Progress, bookmarks, quiz history | Working; stored only on the device |
| Accessibility settings | Working; verified with TalkBack and 200% text |
| Automated tests | 34 passing; static analysis clean |
| SME review packet | Generated and ready to circulate |
| Release build | **Blocked by design** until content is promoted from draft to final |
| Store listing, signing, distribution | Not started |

### Scope by edition

| Edition | Year | Risks | Quiz questions | Cheatsheets | Content licence |
| --- | --- | ---: | ---: | ---: | --- |
| OWASP Top 10 | 2025 | 10 | 5 | 3 | CC BY-SA 4.0 |
| OWASP API Security Top 10 | 2023 | 10 | 5 | 2 | CC BY-SA 4.0 |
| OWASP Top 10 for LLM Applications | 2026 | 10 | 5 | 2 | CC BY-SA 4.0 |
| OWASP Agentic Skills Top 10 | 2026 | 10 | 5 | 2 | CC BY-SA 4.0 |
| OWASP Top 10 for Agentic Applications | 2026 | 10 | 5 | 2 | CC BY-SA 4.0 |
| OWASP MCP Top 10 | 2025 | 10 | 5 | 2 | CC BY-SA 4.0 |
| **Total** | | **60** | **30** | **13** | |

---

## 3. The experience

Five tabs, one learning loop:

| Tab | What it does | Why it matters |
| --- | --- | --- |
| **Learn** | Every risk, with search, edition filter and a read marker | A single place to look something up, even with no signal |
| **Practice** | Five questions per edition, with an explanation after each answer | Checks understanding instead of only presenting text |
| **Sheets** | Thirteen condensed cheatsheets | Fast revision and a checklist for reviews |
| **Progress** | Read count, bookmarks, quiz results, local reset | Shows the learner what they have covered |
| **Access** | Theme, text size, high contrast, readable spacing, reduced motion, screen-reader status | Lets each person make the app work for them |

A risk opens on three tabs: **Overview** (summary and real-world example), **Code** (vulnerable and secure samples), and **Defend** (how to test, how to fix, official sources). Each screen carries a clear draft banner until the content is approved.

### Design

- Material 3, seeded from OWASP blue, so the app chrome matches the official mark.
- A distinct colour per edition (teal for Web, blue for API, purple for LLM, and so on) and a distinct colour per tab, so location is recognisable at a glance.
- Light, dark and high-contrast themes from the same palette.
- Five hand-drawn navigation glyphs that share one stroke weight, instead of generic icons.

### Technology

| Choice | Role | Reason |
| --- | --- | --- |
| Flutter 3.47 / Dart | App framework | One codebase, predictable rendering, good accessibility support |
| Material 3 | Design system | Built-in contrast and text-scaling behaviour; familiar to Android users |
| Riverpod 3 | State management | Explicit, testable dependencies; no hidden global state |
| go_router 18 | Navigation | Typed routes and independent per-tab navigation history |
| Drift (SQLite) | Local storage | Durable, queryable progress data with schema migrations |
| Validated JSON bundle | Content | Content can be reviewed and updated without touching UI code |

The app is layered: screens depend on providers, providers depend on a content repository and a progress repository, and those depend on the bundled JSON and the local database. The content layer has no knowledge of the UI, which is what allows the same bundle to drive the app and the SME review packet.

---

## 4. Quality, security and privacy

**Offline and private by construction.** The app declares no network permission, has no accounts and no analytics, and stores progress only in a local database. There is no server to breach and no user data to leak.

**Content fails closed.** The bundle is validated when the app starts. IDs must be unique, quiz answers must be in range, each question must point to a risk in the same edition, every risk must carry a citation and review date, code samples must be labelled, and prose fields must not contain HTML. If anything fails, the app shows an error instead of partial content. A release build additionally refuses to display a bundle whose status is `draft`.

**Search is hardened.** Input is capped at 120 characters (without splitting emoji or multi-byte characters), control and invisible formatting characters are removed, and the query never reaches a database or a query language — it is an in-memory substring match. SQL, HTML and shell metacharacters are treated as literal text, which is the correct behaviour for a search box.

**Accessibility is tested, not assumed.** Text and UI contrast meet WCAG 2.2 AA in light, dark and high-contrast themes; this is asserted by automated tests for every colour pair the app uses. Touch targets are at least 48 dp, the layout survives 200% text scaling, and read state, quiz feedback and progress are announced to screen readers.

**Verification performed**

- `flutter analyze`: no issues.
- `flutter test`: 34 tests passing, covering content validation, theme contrast, settings persistence, review-packet coverage, search handling and widget behaviour.
- Emulator: both themes, all five tabs, 200% text, TalkBack on and off.
- Physical device (Samsung Galaxy S22 Ultra): installed and used.

---

## 5. What "draft" means

The bundle is `status: draft` and versioned `2026.10.4-draft`. Draft means:

1. Every risk was written from the official OWASP material and cites it, but **no named reviewer has signed it off**.
2. The app shows a persistent "Draft content — under review, not for release" banner.
3. A release build will not display the content at all. Only debug and profile builds run in this state, which is why internal test builds are profile builds.
4. The bundle is promoted to `final` only when every risk has named reviewers and a review date, the validator passes, and the tests are green.

This is intentional. It makes it impossible to ship unreviewed security advice by accident.

---

## 6. Risks and open items

| # | Item | Impact if unresolved | Current position |
| --- | --- | --- | --- |
| R1 | No SME sign-off on 60 risks | Content cannot be promoted to final; no release build | Review packet ready in `docs/sme-review/`; reviewers not yet named |
| R2 | OWASP name and logo permission | Branding and store listing could be challenged | Confirmed |
| R3 | Package ID is a placeholder | Changing `com.example.top_10_app` later breaks upgrades and store identity | Decide before any public build |
| R4 | Release signing uses the Android debug key | Build cannot be distributed through a store | Needs a release keystore and an owner |
| R5 | LLM 2026 citations point to the edition landing page | Reviewers cannot check page-level references on the web yet | Category pages not yet published by OWASP; page ranges from the official PDF are cited |
| R6 | Content ages as OWASP publishes new editions | App becomes misleading over time | Propose a named content owner and a twice-yearly review |

---

## 7. Decisions requested

1. **Approve the SME review plan and name reviewers.** At least one reviewer per edition, ideally one practitioner and one editor. Target: two weeks from approval.
2. **Confirm the package ID.** Recommendation: decide before the first external build; changing it later breaks upgrades and store identity.
3. **Confirm the branding route.** Permission for the OWASP name and logo is confirmed; confirm the store-listing and About-screen wording.
4. **Choose the distribution path and signing owner.** Recommendation: Play Store internal testing first, then production; direct APK only for controlled pilots.
5. **Approve a content refresh cadence and owner.** Recommendation: review on every new OWASP edition and at least twice a year.

---

## 8. Proposed plan

| Milestone | Outcome | Duration after approval |
| --- | --- | --- |
| M1 — Review | Reviewers assigned; corrections applied to the bundle | 2 weeks |
| M2 — Content final | All risks signed off; bundle promoted to `final` | 1 week after M1 |
| M3 — Release candidate | Release signing, store assets, privacy statement, device matrix tested | 2 weeks |
| M4 — Pilot | Internal testing with a small group; fix findings | 2–4 weeks |
| M5 — Public release | Store listing or approved distribution channel | After M4 sign-off |

The engineering work for M3 is small; the schedule is dominated by review and the remaining package-ID and licensing decisions in section 7.

---

## 9. Out of scope and not claimed

- No user accounts, cloud sync or social features.
- No analytics, advertising or telemetry.
- No network access of any kind.
- Not a substitute for the official OWASP documents; the app cites them and shows their URLs, and should be used alongside them.
- Only Android is built today. The Flutter codebase can target iOS, but that has not been attempted or tested.

---

## Appendix A — How to see the current build

```sh
cd ~/projects/OWASP/Top-10-App
~/development/flutter/bin/flutter pub get
~/development/flutter/bin/flutter analyze
~/development/flutter/bin/flutter test
~/development/flutter/bin/flutter run            # emulator or debug device
```

For a device build that runs the draft content:

```sh
~/development/flutter/bin/flutter build apk --profile
```

The profile APK is written to `build/app/outputs/flutter-apk/app-profile.apk`. A release APK will start but refuse to show content until the bundle is final.

Content lives in one file, `assets/content/bundle.json` (about 120 KB). The SME packet is generated from it with:

```sh
dart run tool/generate_sme_review_packet.dart
```

## Appendix B — Evidence in the repository

| Evidence | Location |
| --- | --- |
| Product overview and commands | `README.md` |
| SME review packet and sign-off CSV | `docs/sme-review/` |
| Content bundle | `assets/content/bundle.json` |
| Content rules | `lib/content/content_validator.dart` |
| Search input handling | `lib/core/search_query.dart` |
| Theme and contrast rules | `lib/app/theme.dart`, `test/app/theme_contrast_test.dart` |
| Screenshots used in this pack | `docs/stakeholders/screenshots/` |
| Presentation outline and deck | `docs/stakeholders/presentation.md`, `docs/stakeholders/OWASP-Top-10-Pocket-Guide.pptx` |
