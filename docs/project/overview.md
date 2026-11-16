# Project overview

**OWASP Top 10 Pocket Guide** is an offline study guide for six OWASP Top 10 editions in
one mobile app.

> **Project status:** working draft. This is an OWASP project; the content is not yet
> reviewed. See [`open-questions.md`](open-questions.md).

## The problem

OWASP publishes separate Top 10 lists for web applications, APIs, LLM applications,
agentic skills, agentic applications and MCP servers. Practitioners rarely work in one of
those areas at a time, so the guidance ends up spread across several documents. Three
things tend to go wrong:

- **Citations get lost.** Notes copied out of a PDF or web page lose the link back to the
  official wording, and with it the ability to check whether a summary is current.
- **The moment of need is offline.** Incidents, design reviews and client visits happen on
  planes, in basements and behind restrictive networks.
- **Studying and looking up are different tasks**, and neither the PDFs nor most summaries
  support both.

## What the app does

| Tab | Purpose |
| --- | --- |
| **Learn** | All 60 risks with search, edition filters and read state |
| **Practice** | Five questions per edition, each with an explanation |
| **Sheets** | Thirteen condensed cheatsheets for review work |
| **Progress** | Read count, bookmarks, quiz history, local reset |
| **Access** | Theme, text size, high contrast, readable spacing, reduced motion, screen-reader state |

Each risk has three views: **Overview** (summary and real-world example), **Code**
(vulnerable and secure samples) and **Defend** (how to test, how to fix, official sources
and review state).

## Scope

| Edition | Year | Risks | Quiz questions | Cheatsheets |
| --- | --- | ---: | ---: | ---: |
| OWASP Top 10 | 2025 | 10 | 5 | 3 |
| OWASP API Security Top 10 | 2023 | 10 | 5 | 2 |
| OWASP Top 10 for LLM Applications | 2026 | 10 | 5 | 2 |
| OWASP Agentic Skills Top 10 | 2026 | 10 | 5 | 2 |
| OWASP Top 10 for Agentic Applications | 2026 | 10 | 5 | 2 |
| OWASP MCP Top 10 | 2025 | 10 | 5 | 2 |
| **Total** | | **60** | **30** | **13** |

Editions are never blended: A01 in the Web list and API1 in the API list are different
risks, and search, filters and progress all stay within the selected edition.

## Design principles

- **Traceable, not authoritative.** Every risk links to its official edition. The app is a
  route into the source material, not a replacement for it.
- **Offline and quiet.** Release builds request no network permission; there are no
  accounts, analytics or advertising, and progress never leaves the device.
- **Fail closed.** Content is validated at startup, draft content is visibly marked, and a
  release build refuses to show content that has not been reviewed.
- **Accessible by default.** WCAG 2.2 AA contrast is asserted by tests, layouts are checked
  at 200% text, and touch targets meet 48 dp.
- **One source of truth.** The same validated JSON bundle feeds the app, the test suite and
  the SME review packet.

## How it is built

Flutter and Material 3, with Riverpod for state, go_router for navigation and Drift
(SQLite) for local persistence. Content models and validation are plain Dart with no
widget dependency, which is what lets the bundle be validated in tests and turned into a
review packet. There is no server and no network path.

Details: [`../stakeholders/project-summary.md`](../stakeholders/project-summary.md) —
architecture, quality evidence and risks.

## Platforms

| Platform | State |
| --- | --- |
| Android phone | Implemented; tested on a physical device and an emulator (Android 7.0+) |
| Android tablet | Runs, but no tablet-specific layout yet; planned after 1.0 |
| iOS phone and tablet | Not started; planned after the first Android release |

The codebase is Flutter, so iOS is a port rather than a rewrite. It still requires an Apple
developer account, macOS build hardware and a separate testing cycle, which is why it is a
post-1.0 phase rather than a parallel track.

## Status and roadmap

See [`status.md`](status.md) for phases, deliverables and blockers, and
[`metrics.md`](metrics.md) for how success will be measured without collecting user data.
