# OWASP website — project page content

**Prepared:** 23 October 2026
**Purpose:** field-by-field content for the OWASP Foundation project page, following the
template in `~/projects/OWASP/Top10Plan/Requirements-by-OWSP.md`.
**Status of the project:** draft, OWASP project.

> **Submission note — read before publishing.** This is proposal content, not a live
> listing. Nothing here should be published until the Foundation accepts the project page.
> Use of the OWASP name and marks is confirmed. Items marked `[TBC]` are tracked in
> [`../project/open-questions.md`](../project/open-questions.md) and must be resolved
> before the page goes live.

---

## Overview

### Description

An offline mobile study guide that brings six OWASP Top 10 editions — Web, API Security,
LLM Applications, Agentic Skills, Agentic Applications and MCP — into one searchable app
for Android phones and tablets. Every risk keeps its official citation, so the app is a way
into the source material rather than a replacement for it.

### Project Overview

Security guidance is spread across separate OWASP Top 10 lists. A practitioner working on
a modern application often needs the web, API and AI editions at the same time,
keeps several documents open, loses the citations when copying notes, and may have no
network access at the moment the guidance is needed — during an incident, a design review
or a client visit.

The Pocket Guide puts the current editions in one place and structures each risk the same
way: a short summary, a real-world example, vulnerable and secure code samples, how to test
for the issue, how to fix it, and links to the official OWASP source. On top of that it adds
practice questions and condensed cheatsheets, so the material can be studied and revised,
not only looked up.

**Contents at this stage**

| Edition | Year | Risks | Quiz questions | Cheatsheets |
| --- | --- | ---: | ---: | ---: |
| OWASP Top 10 | 2025 | 10 | 5 | 3 |
| OWASP API Security Top 10 | 2023 | 10 | 5 | 2 |
| OWASP Top 10 for LLM Applications | 2026 | 10 | 5 | 2 |
| OWASP Agentic Skills Top 10 | 2026 | 10 | 5 | 2 |
| OWASP Top 10 for Agentic Applications | 2026 | 10 | 5 | 2 |
| OWASP MCP Top 10 | 2025 | 10 | 5 | 2 |
| **Total** | | **60** | **30** | **13** |

The app is organised as five tabs: **Learn** (all risks, search and edition filters),
**Practice** (five questions per edition with explanations), **Sheets** (the cheatsheets),
**Progress** (what the learner has covered, with bookmarks and quiz history) and **Access**
(appearance and accessibility settings). The four AI-related editions are grouped together
in the filters so that guidance reads as one set.

The app is offline by design: release builds request no network permission, there are no
accounts, no analytics and no advertising, and all progress stays on the device. Draft
content is visibly marked, and a release build refuses to display content that has not
completed review. Accessibility is treated as a requirement: WCAG 2.2 AA contrast is
checked by automated tests, layouts are verified at 200% text size, and controls meet the
48 dp touch-target minimum.

**Current status.** The Android application and all six editions are authored and working,
covered by an automated test suite, an accessibility pass and a security assessment. The
content is still a **draft**: none of the 60 risks has completed subject-matter review. A
release candidate follows review, not before.

**Platforms.** Android is implemented and has been tested on a physical phone and on an
emulator (Android 7.0 and later). iOS and tablet-specific layouts are on the roadmap after
the first Android release; the codebase is Flutter, so iOS is a port rather than a rewrite.

### Requirements

- Android 7.0 (API level 24) or later; phone or tablet.
- Approximately 20 MB download per CPU architecture for a release build; draft-evaluation
  (profile) builds are about 29 MB.
- No account, no sign-in, no network connection required at any point.
- Progress is stored only on the device.
- For development: Flutter 3.47.x (pinned via FVM), Dart 3.13, JDK 21 and Android SDK 36.
- A release build requires a signing keystore; the build fails deliberately without one.

---

## Resources

### Installation Guide

**End users.** The app will be distributed through Google Play `[TBC — store listing not yet
published]`. Test builds are installed from an APK; sideloading requires allowing installs
from the source used (file manager, browser or ADB).

**Developers.**

```sh
git clone https://github.com/[org]/Top-10-App.git
cd Top-10-App
flutter pub get          # Flutter 3.47.7, pinned in .fvmrc
flutter run              # debug build
flutter analyze          # static analysis
flutter test             # test suite
```

Draft content is shown by debug and profile builds. A release build additionally needs
`android/key.properties` containing `storeFile`, `storePassword`, `keyAlias` and
`keyPassword`; without it the build stops with "Release signing is not configured".

### Usage Examples

- **Look up a risk.** Open *Learn*, type `broken access` in the search field, open the
  result and read *Overview*, *Code* and *Defend* for the summary, samples, test advice,
  fix and citation.
- **Study an edition.** Open *Practice*, answer the five questions, and read the
  explanation shown after each answer. Results are kept locally and summarised in
  *Progress*.
- **Prepare for a review.** Open *Sheets* and work through the cheatsheet for the edition
  in scope; each item maps back to a risk entry.
- **Make it comfortable.** In *Access*, switch between system, light and dark themes,
  enlarge text up to the application maximum (combined with the system font scale), enable
  high contrast or readable spacing, and reduce motion.

### Troubleshooting

| Symptom | Explanation | What to do |
| --- | --- | --- |
| "Draft content cannot be shown in a release build" | The bundled content has not completed review, and release builds fail closed. | Use a profile or debug build for evaluation, or wait for a reviewed release. |
| A red "Draft content" banner is visible | The content is authored but not signed off. | Expected at this stage; the banner disappears only when the bundle is final. |
| Build stops with "Release signing is not configured" | No release keystore is configured. | Create `android/key.properties` with the four signing entries, then rebuild. |
| Search returns nothing | Search is scoped to the selected edition, and editions are never mixed. | Select the edition first, then search. |
| TalkBack reads reference URLs as text | Flutter exposes selectable text this way; the reference title is used as the hint. | Known limitation, recorded in the accessibility notes. |
| Long code lines scroll sideways at 200% text | Code is kept on its original lines rather than wrapped. | Scroll the code block horizontally; this is intentional. |

---

## Project Information

### Meta Title

OWASP Top 10 Pocket Guide — six editions, one offline app

### Meta Description

An offline Android study guide for six OWASP Top 10 editions — Web, API, LLM, Agentic
Skills, Agentic Applications and MCP — with quizzes, cheatsheets and official citations.

### Latest Version

0.1.0-draft (build `1.0.0+1`; not publicly released)

> The build number in `pubspec.yaml` will be aligned to the public version scheme before
> the first release. See [`../project/open-questions.md`](../project/open-questions.md).

---

## Additional fields requested on project pages

The template above covers Overview, Resources and Project Information. OWASP project pages
also carry classification and contact details; proposed values:

| Field | Value |
| --- | --- |
| Project type | Tool / code, with documentation |
| Classification | Incubator (proposed) |
| Project leader | Bo Kaung |
| Co-leaders | Maryam Tehrani (content and review); Marc Daniel Sevigny (engineering and release) |
| Licence (code) | `[TBC]` — currently GPL-3.0; under review against OWASP expectations |
| Licence (content) | CC BY-SA 4.0 for all six editions; attribution carried in the bundle |
| Repository | `[TBC]` — currently a private working repository |
| Platforms | Android (verified); iOS post-1.0; tablet layouts post-1.0 |
| Roadmap | [`../project/status.md`](../project/status.md) |
| Contributing | [`../project/resources.md`](../project/resources.md) |
| Security policy | [`../security/security-test-report.md`](../security/security-test-report.md) |
| Contact | `[TBC]` |

---

## Before publication — checklist

- [ ] Foundation confirms the project and use of the OWASP name and logo.
- [ ] Code licence decided and `LICENSE` updated if it changes.
- [ ] All 60 risks reviewed and signed off; bundle promoted from draft to final.
- [ ] Repository location and public URL confirmed.
- [ ] Leaders named (three roles) and contact address chosen.
- [ ] Version scheme agreed and `pubspec.yaml` aligned.
- [ ] Store listing, privacy statement and signing key in place.
