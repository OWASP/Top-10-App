# Open questions

Unresolved decisions, kept in one place so they are not rediscovered in comments. Each row
names what it blocks, so the documents can be finished field by field.

**Status values:** `Open` · `In progress` · `Blocked (external)` · `Decided`

## Licensing

| ID | Question | Why it matters | Blocks | Owner | Status |
| --- | --- | --- | --- | --- | --- |
| L1 | Which licence for the source code — keep GPL-3.0, move to Apache-2.0, or another OSI licence? | OWASP projects conventionally use a permissive licence; copyleft can deter corporate reuse and affects whether the code can be combined with other OWASP tooling | `LICENSE`, OWASP page licence field, store listing, all public docs | Project leader | Open |
| L2 | Are all six bundled editions licensed CC BY-SA 4.0, and may their content be redistributed? | Attribution and share-alike are conditions of shipping the content | Content final | Project leader + content co-leader | Decided — all six editions are CC BY-SA 4.0; attribution carried in the bundle |
| L3 | What licence covers the documentation and the SME review packet? | Docs are currently unlicensed by default, which is ambiguous for contributors | Repository hygiene, OWASP page | Project leader | Open |
| L4 | Are all third-party notices complete (Flutter, Dart packages, bundled content)? | Attribution is a licence condition for CC BY-SA material | Release | Engineering co-leader | In progress — bundle attribution exists; NOTICES review pending |

## Naming and branding

| ID | Question | Why it matters | Blocks | Owner | Status |
| --- | --- | --- | --- | --- | --- |
| N1 | Is "OWASP Top 10 Pocket Guide" acceptable, and does it require Foundation approval? | Uses the OWASP mark; a fallback neutral name is needed if not granted | Project page title, app label, store listing, repository name | Project leader + OWASP | Resolved — name confirmed |
| N2 | Which reverse-DNS package ID replaces `com.example.top_10_app`? | Changing it later breaks upgrades and store identity | Release candidate and every build thereafter | Project leader | Open |
| N3 | May the OWASP logo and launcher icon be used? | Use is confirmed for the project | Store listing, app icon, About screen | OWASP | Resolved — permission confirmed |

## OWASP process

| ID | Question | Why it matters | Blocks | Owner | Status |
| --- | --- | --- | --- | --- | --- |
| O1 | Apply as an Incubator project, and with what scope (Android only, or Android + iOS roadmap)? | Determines the application content and the page classification | Submission | Project leader | Open |
| O2 | Does the repository stay personal or move to the OWASP GitHub organisation? | Affects links, CI, issue history and the project page | Submission, all docs links | Project leader | Open |
| O3 | Confirm GitHub handles, affiliations and availability for the two co-leaders. | The page requires named leaders; bus factor needs a deputy per role | Submission | Project leader | Open — names confirmed; handles and affiliations pending |
| O4 | What is the public contact route — OWASP Slack channel, GitHub Discussions or a mailing list? | Reviewers and users need one durable channel | Submission, `resources.md` | Project leader | Open |
| O5 | Who receives security reports, and what is the disclosure window? | An offline app still needs a route for tampering or content-safety reports | `resources.md`, release | Engineering co-leader | Open |

## Content

| ID | Question | Why it matters | Blocks | Owner | Status |
| --- | --- | --- | --- | --- | --- |
| C1 | Who reviews each of the six editions, and by when? | No content ships unreviewed; 0 of 60 risks are signed off | M1 → M2, release | Content co-leader | Open — packet ready |
| C2 | Who owns the refresh when OWASP publishes a new edition? | Guidance ages; an unowned refresh cadence is a known risk | Post-1.0 operation | Content co-leader | Open |
| C3 | Is the LLM 2026 citation strategy acceptable (landing page plus section/page numbers) until category pages exist? | Reviewers need a checkable citation | M1 | Content co-leader | Open |

## Release

| ID | Question | Why it matters | Blocks | Owner | Status |
| --- | --- | --- | --- | --- | --- |
| R1 | Who owns the release keystore, where is it stored, and who can sign? | Loss prevents updates; leakage allows impostor builds | M3, distribution | Engineering co-leader | Open |
| R2 | Which Google Play account is used, and is the first release internal testing? | Store identity and rollout path | M3–M5 | Project leader | Open |
| R3 | Who writes the privacy statement and store listing assets? | Required by Play; the privacy statement is simple because there is no data collection | M3 | Project leader | Open |
| R4 | Should the public version scheme start at 0.1.0 (draft) or 1.0.0? | `pubspec.yaml` currently says `1.0.0+1`, which implies a maturity the draft does not have | Public version fields | Project leader | Open |

## Platforms

| ID | Question | Why it matters | Blocks | Owner | Status |
| --- | --- | --- | --- | --- | --- |
| P1 | Which tablet layouts are in scope for 1.0, and on which devices will they be tested? | The app runs on tablets but has no tablet-specific layout | M7 | Engineering co-leader | Open — post-1.0 proposed |
| P2 | Who provides macOS hardware and an Apple developer account for iOS? | iOS cannot be built or tested without both | M6 | Project leader | Open — post-1.0 proposed |

## Measurement

| ID | Question | Why it matters | Blocks | Owner | Status |
| --- | --- | --- | --- | --- | --- |
| M1 | Are the proposed metrics targets acceptable, given there is no telemetry? | Targets must be measurable from aggregate sources only | `metrics.md` | Project leader | Open |
| M2 | What dates attach to phases M1–M5? | The page and status need a timeline, not just durations | `status.md`, submission | Project leader | Open |

## Suggested order

1. **C1** (reviewers) — it gates all content work.
2. **L1** (code licence) — needed before the repository is made public.
3. **N1/N2** (name and package ID) — needed before any external build.
4. **O1–O3** (application, repo home, leaders) — needed for the OWASP page.
5. Everything else follows the release phases.
