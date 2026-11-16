# Resources

Everything needed to install, use, build, test and contribute to the project.

## Requirements

**Using the app**

- Android 7.0 (API level 24) or later, phone or tablet.
- About 20 MB of storage per CPU architecture for a release build (profile builds are
  about 29 MB).
- No account, no sign-in, no network connection.

**Building the app**

| Tool | Version |
| --- | --- |
| Flutter | 3.47.7 (pinned in `.fvmrc`) |
| Dart | 3.13.5 |
| JDK | 21 (Temurin) |
| Android SDK | 36, build-tools 36.0.0 |
| Gradle | via the Flutter plugin |

## Installation

**End users.** Install from Google Play `[link TBC — listing not published]`. Test builds
are distributed as APKs; installing one requires allowing installs from the source used
(file manager, browser or ADB).

**From source**

```sh
git clone https://github.com/[org]/Top-10-App.git
cd Top-10-App
flutter pub get
flutter run                 # debug build, shows draft content
```

**Release build.** Release builds fail closed without a signing key. Create
`android/key.properties` (git-ignored) with:

```properties
storeFile=/absolute/path/to/release.jks
storePassword=...
keyAlias=...
keyPassword=...
```

Then `flutter build apk --release`. Without that file the build stops with
"Release signing is not configured". The keystore must be owned by the organisation and
backed up: losing it prevents updates to the same package.

**Evaluation build.** Profile builds show draft content and are the right artefact for
reviewing before the content is final:

```sh
flutter build apk --profile --target-platform android-arm64
```

Profile builds are debuggable and request network access for the development tool. They
are not distribution artefacts.

## Usage

| Task | Where |
| --- | --- |
| Look up a risk | **Learn** → search or pick an edition → open a risk |
| Read the explanation, code or fix | Risk detail → **Overview** / **Code** / **Defend** |
| Practise | **Practice** → answer five questions per edition |
| Revise before a review | **Sheets** → choose an edition → open a cheatsheet |
| Track what you have covered | **Progress** → read count, bookmarks, quiz history |
| Change theme, text size or contrast | **Access** |

Search is scoped to the selected edition. Editions are never mixed.

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| "Draft content cannot be shown in a release build" | Content is not reviewed; release is gated | Use a profile build, or wait for a reviewed release |
| Red draft banner | Bundle status is `draft` | Expected until sign-off completes |
| "Release signing is not configured" | No `android/key.properties` | Create it with the four entries above |
| Search finds nothing | Search is edition-scoped | Select the edition first |
| TalkBack reads reference URLs as text | Flutter's selectable-text semantics | Known limitation; the reference title is the hint |
| Code scrolls sideways at 200% text | Lines are not wrapped | Intentional; scroll the block |
| App does not start after build | Bundle failed validation | Check the error screen; run `flutter test` to see the validation message |

## Testing and quality

```sh
flutter analyze        # static analysis
flutter test           # 34 tests, including bundle validation and theme contrast
dart run tool/generate_sme_review_packet.dart   # regenerate the SME packet
```

Security: see [`../security/security-test-report.md`](../security/security-test-report.md)
for the current assessment, scope and limitations.

## Content

Content lives in one validated bundle, `assets/content/bundle.json` (schema 1.0.0). Models
and the validator are plain Dart with no widget dependency. Rules enforced by the
validator include unique IDs, answer indices in range, quiz links that resolve, citations
and review dates on every risk, a language label on every code sample, and no HTML in
prose. A `final` bundle additionally requires ten risks and five questions per edition and
named reviewers.

Review packet: [`../sme-review/README.md`](../sme-review/README.md).

## Contributing

Contribution guidance, code of conduct and issue templates are `[TBC]` — they will be
published when the repository's home and licence are settled. Until then:

- Content corrections: open an issue naming the edition, risk code and official source.
- Code changes: keep `flutter analyze` clean and all tests passing; accessibility and
  security checks must not regress.
- Do not add analytics, advertising or network calls; offline operation is a product
  requirement, not an implementation detail.

## Support

- Questions and defects: GitHub Issues `[link TBC]`.
- Security reports: `[contact TBC]` — please do not open a public issue for a vulnerability.
- Project decisions and open questions: [`open-questions.md`](open-questions.md).

## Project documents

| Document | Purpose |
| --- | --- |
| [`overview.md`](overview.md) | Problem, scope, design principles, platforms |
| [`leaders.md`](leaders.md) | Leadership roles and responsibilities |
| [`status.md`](status.md) | Status, versions, licences, phases and deliverables |
| [`metrics.md`](metrics.md) | How success is measured without telemetry |
| [`open-questions.md`](open-questions.md) | Unresolved decisions with owners |
| [`../owasp/website-submission.md`](../owasp/website-submission.md) | Content for the OWASP project page |
