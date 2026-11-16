# Project status

**Status:** Draft — pre-release, not yet an official OWASP project.
**Last updated:** 29 October 2026

## At a glance

| Field | Value |
| --- | --- |
| Public version | 0.1.0-draft (no public release yet) |
| Build version | `1.0.0+1` (`pubspec.yaml`) — to be aligned before release |
| Content bundle | `2026.10.29-draft`, schema 1.0.0 |
| Content reviewed | 0 of 60 risks signed off |
| Platforms | Android phone (verified); tablet and iOS planned post-1.0 |
| Distribution | None yet — no store listing, no signing key |
| Test suite | 34 tests, static analysis clean |
| Security assessment | Complete; no open High findings (see [`../security/security-test-report.md`](../security/security-test-report.md)) |

## Status by area

| Area | State |
| --- | --- |
| Android app | Working; installs and runs on a physical device and an emulator |
| Six editions | Authored and validated — 60 risks, 30 questions, 13 cheatsheets |
| Search and filters | Working; AI editions grouped; input hardened |
| Progress, bookmarks, quiz history | Working; device-local only |
| Accessibility | Verified: TalkBack, 200% text, 48 dp targets, contrast asserted by tests |
| Automated tests | 34 passing; `flutter analyze` clean |
| SME review packet | Generated; awaiting reviewers |
| Release build | Intentionally blocked until content is final and a signing key exists |
| Store listing and privacy statement | Not started |
| iOS | Not started |
| Tablet layouts | Not started |

## Licence

| Asset | Licence | State |
| --- | --- | --- |
| Source code | GPL-3.0 | **Under review** against OWASP expectations; may change |
| Content — all six editions | CC BY-SA 4.0 | Attribution carried in the bundle |
| Documentation | `[TBC]` | To be decided with the code licence |

## Timeline

Phase durations are estimates; dates follow once the blocking decisions are made.

| Phase | Status | Deliverables |
| --- | --- | --- |
| **M0** Build and internal test | **Done** | Working Android app; six editions; 34 tests; accessibility pass; security assessment; stakeholder pack |
| **M1** Subject-matter review | **Not started** (packet ready) | Named reviewers per edition; 60 signed-off risks; corrections merged |
| **M2** Content final | **Blocked** — depends on M1 | Bundle promoted from `draft` to `final`; review packet regenerated; release build shows no draft banner |
| **M3** Release candidate | **Blocked** — depends on M2, name/package ID and signing key | Signed release APK; Play internal testing track; privacy statement; store listing |
| **M4** Pilot | **Planned** — 2–4 weeks | Internal tester feedback; defect fixes; accessibility re-check on real devices |
| **M5** Android 1.0 | **Planned** | Public Play release; project page live; support route published |
| **M6** iOS | **Planned** — post-1.0 | iOS scaffold; TestFlight build; App Store listing; parity of all six editions |
| **M7** Tablet layouts | **Planned** — post-1.0 | Navigation rail and two-pane detail; layouts verified on tablet sizes and at 200% text |
| **M8** Ongoing content refresh | **Ongoing after 1.0** | Each new OWASP edition assessed within 30 days; bundle updated and re-reviewed; release notes |

## Release gates

A 1.0 release requires all of the following. Any missing gate keeps the bundle in draft.

1. Every risk has named reviewers and a review date; bundle `status` is `final`.
2. Product name, package ID and branding confirmed; OWASP permission recorded.
3. Release keystore generated, held by the organisation, and used by a build that fails
   without it.
4. Security assessment re-run against the final release build with no open High findings.
5. Accessibility checks re-run on a physical device with TalkBack and 200% text.
6. Privacy statement and store listing complete.

## Known blockers

| Blocker | Affects |
| --- | --- |
| Code licence undecided | OWASP project page, `LICENSE`, distribution |
| Name and OWASP marks unconfirmed | Project page, package ID, store listing |
| No subject-matter reviewers yet | 60 risks, content final |
| No signing key owner | Release candidate and any distribution |
| No iOS build hardware or Apple account | M6 only |
| Tablet layouts not designed | M7 only |

Open decisions are tracked in [`open-questions.md`](open-questions.md).
