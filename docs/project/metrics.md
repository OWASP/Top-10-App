# Success metrics

Success is measured from **observable, aggregate** sources only. The app collects no
telemetry, so there is no per-user analytics to report — and the metrics below are designed
so that this is not a handicap.

**Principles**

- No user-level tracking, no third-party analytics, no advertising identifiers.
- Every number must be reproducible from a public or store-provided source.
- Baselines are stated honestly: before release most counts are zero.
- Targets are proposals for discussion, not commitments, until the project is accepted and
  a release exists.

## Adoption

| Metric | Source | Baseline (Oct 2026) | 6 months after 1.0 (proposed) | 12 months (proposed) |
| --- | --- | ---: | ---: | ---: |
| Google Play installs (aggregate) | Play Console | 0 (not published) | 300 | 1,000 |
| APK downloads from release page | GitHub release download counts | 0 | 100 | 400 |
| Store rating (count / average) | Play listing | — | 10 / 4.0 | 25 / 4.3 |
| Uninstall rate | Play Console | — | < 30% | < 25% |

## Community

| Metric | Source | Baseline | 6 months | 12 months |
| --- | --- | ---: | ---: | ---: |
| GitHub stars | Repository | 0 | 25 | 75 |
| Forks | Repository | 0 | 5 | 15 |
| External contributors (merged PRs) | Git history | 0 | 2 | 5 |
| Issues opened / closed | Repository | 0 / 0 | 10 / 8 | 30 / 25 |
| Reviewers active | `docs/sme-review/sign-off.csv` | 0 | 6 (one per edition) | 6+ |
| Project meetings or demos | Manual log | 0 | 2 | 4 |

## Impact

Impact is the hardest category to measure offline, so it is tracked through review coverage
and documented use rather than usage analytics.

| Metric | Source | Baseline | 6 months | 12 months |
| --- | --- | ---: | ---: | ---: |
| Risks reviewed and signed off | `sign-off.csv` | 0 / 60 | 60 / 60 (release gate) | 60 / 60 maintained |
| Editions current with upstream | Manual check | 6 / 6 authored, 0 reviewed | 6 / 6 | 6 / 6, refreshed within 30 days of a new OWASP edition |
| Chapters or events where the app was presented | Manual log | 0 | 2 | 4 |
| Documented practitioner uses (quotes, references) | Manual log, with permission | 0 | 3 | 10 |
| Translations started | Repository | 0 | 0 | 1 (candidate) |

## Quality

| Metric | Source | Baseline | Target |
| --- | --- | --- | --- |
| Automated tests passing | `flutter test` | 34 / 34 | No merge with a failing test |
| Static analysis | `flutter analyze` | Clean | Clean |
| Open High security findings | Security assessment | 0 | 0 |
| Dependency advisories (Pub + Maven) | OSV scan | 0 known | Re-scan quarterly and before every release |
| Accessibility checks | Manual + tests | Passed on emulator | Re-run on a physical device each release |
| Content review coverage | `sign-off.csv` | 0% | 100% at every release |
| Crash-free sessions | Play vitals (aggregate) | — | ≥ 99.5% once published |
| Median time to fix a confirmed defect | Issue tracker | — | ≤ 14 days for functional defects, ≤ 30 days for content corrections |

## Review cadence

- **Quarterly**, starting after the first release: update this file with actuals, and adjust
  targets rather than quietly dropping them.
- **Before every release:** re-run quality checks and record the results in the release
  notes.
- **After each new OWASP edition:** record the refresh date and whether the app was updated
  within 30 days.

## What is deliberately not measured

- Individual learning progress, quiz scores or read counts — these never leave the device.
- User identity, location, device model or usage paths.
- Any metric that would require adding an analytics SDK. If a future metric needs one, it is
  a product decision that changes the privacy posture and must be raised in
  [`open-questions.md`](open-questions.md) first.
