# OWASP Top 10 Pocket Guide (working title)

Offline study guide for six OWASP Top 10 lists: Web (2025), API Security (2023), LLM
Applications (2026), Agentic Skills (2026), Agentic Applications (2026) and MCP (2025).
Web and API come first; the four AI-related editions are grouped together in the filters.

Android phone is implemented and tested. Android tablet layouts and iOS are on the roadmap
after the first release; the codebase is Flutter, so iOS is a port rather than a rewrite.

> **Status: draft.** All 60 risks are awaiting SME review and the bundle is
> gated as draft in the UI. Official product name, application ID and OWASP
> affiliation wording are still pending confirmation.

## Features

- **Learn** — all 60 risks with search, family filters and read state.
- **Risk detail** — summary, real-world example, vulnerable and secure code,
  how to test, how to fix, and official citations.
- **Practice** — five questions per list with answer explanations; results are
  stored on the device.
- **Cheatsheets** — three for Web 2025 and two for every other list.
- **Progress** — read count, bookmarks, quiz history and a local reset.
- **Access** — in-app appearance and accessibility settings: system/light/dark
  theme, three text sizes that combine with the system font scale, high
  contrast, readable spacing, and reduced motion. Settings are saved locally.
- Fully offline: release builds declare no network permission.

## Content

The app ships one validated bundle at `assets/content/bundle.json`
(schema `1.0.0`). The loader fails closed if the bundle is missing, malformed
or invalid, and a visible banner marks draft content.

| List | Edition | Risks | Quizzes | Cheatsheets | Content license |
| --- | --- | ---: | ---: | ---: | --- |
| OWASP Top 10 | 2025 | 10 | 5 | 3 | CC BY-SA 4.0 |
| OWASP API Security Top 10 | 2023 | 10 | 5 | 2 | CC BY-SA 4.0 |
| OWASP Top 10 for LLM Applications | 2026 | 10 | 5 | 2 | CC BY-SA 4.0 |
| OWASP Agentic Skills Top 10 | 2026 | 10 | 5 | 2 | CC BY-SA 4.0 |
| OWASP Top 10 for Agentic Applications | 2026 | 10 | 5 | 2 | CC BY-SA 4.0 |
| OWASP MCP Top 10 | 2025 | 10 | 5 | 2 | CC BY-SA 4.0 |

The app's source code is licensed under **GPL-3.0**; see [`LICENSE`](LICENSE).
Bundled content keeps each list's own license and attribution in the bundle;
every included edition is CC BY-SA 4.0 and has been condensed for this app.
OWASP marks and branding follow the OWASP Foundation's rules, separate from the
code and content licenses.

## Development

Requires Flutter 3.47.7 (pinned in `.fvmrc`), JDK 21 and Android SDK 36.

```sh
flutter pub get
flutter run
flutter analyze
flutter test
```

Architecture: Flutter + Material 3, Riverpod 3, go_router 18 and Drift for
local persistence. Content models and validation are plain Dart.

Release builds require a signing keystore in `android/key.properties` and fail
deliberately without one; see [`docs/project/resources.md`](docs/project/resources.md).

## Project documents

| Document | Purpose |
| --- | --- |
| [`docs/project/overview.md`](docs/project/overview.md) | Problem, scope, design principles, platforms |
| [`docs/project/status.md`](docs/project/status.md) | Status, versions, licences, phases and deliverables |
| [`docs/project/leaders.md`](docs/project/leaders.md) | Leadership roles and responsibilities |
| [`docs/project/metrics.md`](docs/project/metrics.md) | Success metrics measurable without telemetry |
| [`docs/project/resources.md`](docs/project/resources.md) | Install, usage, troubleshooting, contributing |
| [`docs/project/open-questions.md`](docs/project/open-questions.md) | Unresolved decisions with owners |
| [`docs/owasp/website-submission.md`](docs/owasp/website-submission.md) | Content prepared for the OWASP project page |
| [`docs/security/security-test-report.md`](docs/security/security-test-report.md) | Security assessment, scope and limitations |
| [`docs/stakeholders/project-summary.md`](docs/stakeholders/project-summary.md) | Stakeholder summary, quality evidence and decisions |

## SME review

`docs/sme-review/` contains the content review packet: one sheet per list,
per-risk checklists, quiz answers, citations, a sign-off table and
`sign-off.csv`. Start at `docs/sme-review/README.md`.

Regenerate the packet after changing the bundle:

```sh
dart run tool/generate_sme_review_packet.dart
```

The bundle is promoted from `draft` to `final` only after every risk has named
reviewers, the content validator passes and the tests are green.
