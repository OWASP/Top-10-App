# Project leaders

Three leadership roles are defined below: the project leader and two co-leaders.

| Role | Name |
| --- | --- |
| Project leader | Bo Kaung |
| Co-leader — content and review | Maryam Tehrani |
| Co-leader — engineering and release | Marc Daniel Sevigny |

> Add GitHub handles or a project-page link once confirmed. Do not publish personal
> email addresses.

## Responsibilities

### Project leader

- Owns the project's direction, scope and public communication.
- Acts as the liaison with the OWASP Foundation: project application, annual review,
  branding and licensing questions.
- Chairs decisions that change scope — adding or retiring an edition, changing the release
  policy, changing the licence.
- Maintains the roadmap and ensures each phase has an owner.

### Co-leader — content and review

- Coordinates subject-matter reviewers for all six editions and maintains the sign-off
  record (`docs/sme-review/sign-off.csv`).
- Owns the promotion of the content bundle from `draft` to `final`, and the rule that no
  edition ships unreviewed.
- Tracks upstream OWASP editions and schedules content refreshes, including any change in
  official numbering or wording.
- Owns content licensing questions together with the project leader.

### Co-leader — engineering and release

- Owns the release process: signing key custody, build reproducibility, store submission.
- Owns quality gates: tests, static analysis, accessibility checks and the security
  assessment, and keeps their results current.
- Leads the post-1.0 platform work — iOS port and tablet layouts — including the hardware,
  accounts and testing that each requires.
- Maintains the dependency and security posture, including advisory scans.

## How the three roles work together

- **Two-person rule for releases.** A release needs the engineering co-leader to build and
  the project leader to approve the content state. Neither alone can publish.
- **One owner per phase.** Every phase in [`status.md`](status.md) names a responsible
  role; an unowned phase is treated as blocked.
- **Decisions are recorded.** Anything that changes scope, licensing or release policy is
  written into [`open-questions.md`](open-questions.md) when raised and updated when
  decided, so the reasoning survives.
- **Bus factor.** Each role should have a named deputy before the first public release.

## Before publishing this file

- [ ] Confirm the three names.
- [ ] Confirm that all three are willing to be listed publicly.
- [ ] Check the Foundation's current leader requirements at application time.
- [ ] Decide the public contact route (GitHub Discussions, a mailing list or an OWASP
      Slack channel) and add it here.
