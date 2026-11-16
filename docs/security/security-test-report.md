# Mobile App Security Assessment — Top 10 Pocket Guide

**Date:** 2026-10-23
**Platform:** Android (minSdk 24, targetSdk 36)
**Version:** 1.0.0, bundle `2026.10.5-draft`
**Package:** `com.example.top_10_app` (placeholder)
**Analyst:** Claude Code
**Mode:** `offline` static analysis of local build artifacts + `authorized-active` dynamic checks on the project's own emulator (`Medium_Phone_API_37.0`). No third-party targets were touched.

> Scope note: this assesses the application and its build configuration. It does not review the editorial accuracy of the content, which remains SME review. Findings are observations about this draft, not a certification.

---

## Executive summary

The application's own attack surface is very small: no network permission in release, no accounts, no WebView, no file I/O, no dynamic code loading, no telemetry SDKs, no hardcoded secrets. The content and progress stores hold no personal data. Dependency scans found no known advisories.

The material risks were in **release engineering**, not application logic: the release build was signed with the public debug certificate, and the build prepared for the phone is a debuggable profile build with internet access. The signing defect and the backup exposure have since been fixed and re-verified; the profile-build caveat is inherent to development builds and is now documented rather than left implicit.

**Counts at assessment:** 1 High · 1 Medium · 2 Low · 2 Informational · 0 Critical
**Counts after remediation (2026-10-23):** 0 High · 1 Medium · 0 Low · 2 Informational (2 accepted)

| ID | Severity | Finding | MASVS | Status |
| --- | --- | --- | --- | --- |
| M-01 | High | Release APK signed with the AOSP debug certificate | MASVS-RESILIENCE | **Fixed** — fail-closed signing wired |
| M-02 | Medium | The profile build (on the phone) is debuggable, has INTERNET, exposes the VM service | MASVS-RESILIENCE / NETWORK | Accepted — dev-only, documented |
| M-03 | Low | `allowBackup` defaults to true; progress DB is included in backups | MASVS-STORAGE | **Fixed** — backups disabled |
| M-04 | Low | No tamper or repackaging detection for a security-guidance app | MASVS-RESILIENCE | Accepted for draft; decision needed |
| I-01 | Info | Bundled SQLite 3.53.4 and native libraries are hardened | — | — |
| I-02 | Info | Minor outdated transitive dependencies, no advisories | MASVS-CODE | — |

---

## Artifacts and evidence base

| Artifact | SHA-256 | Notes |
| --- | --- | --- |
| `build/app/outputs/flutter-apk/app-release.apk` | — | The stale debug-signed build assessed here was removed during remediation. Release now fails closed until a real keystore is configured; the signing path was proved with a throwaway keystore that was then deleted (see M-01). |
| `build/app/outputs/flutter-apk/app-profile.apk` | `0d5884df793afc3468db4936b96ad7c3f5138790853f813acb75f218e7b82cca` | Rebuilt 2026-10-23 after remediation, versionCode 2003, `allowBackup=false`. This is the build prepared for the phone. |
| Toolchain | Flutter 3.47.7, engine `d8a2d6c768c334d53e16277f837970ffa1e2de81`, Dart 3.13.5 | |
| Dependencies | 104 Pub packages, 49 resolved Maven artifacts (release runtime classpath) | |

**Validation performed**

- `flutter analyze` — no issues (1.5 s).
- `flutter test` — 34/34 pass.
- `aapt dump badging` / `aapt dump xmltree` on both APKs (authoritative merged manifest).
- `apksigner verify --print-certs --verbose`.
- OSV `/v1/querybatch` for every locked Pub package and every resolved Maven artifact.
- `strings` and `unzip` inspection of `classes*.dex`, `libapp.so`, `libsqlite3.so`.
- Runtime: app launched on the emulator; uid, socket table, logcat and on-device SQLite inspected via `run-as`.

**Tool limitation:** the MASVS helper `scripts/apk_analyzer.py` returned undetermined fields because `pyaxmlparser` is not installed. The manifest and component analysis below was therefore done directly with `aapt` and checked by hand. No conclusion here depends on the unparsed output.

---

## MASVS coverage (MASVS 2.1 categories)

| Category | Result | Basis |
| --- | --- | --- |
| STORAGE | Pass (one Low) | DB holds risk IDs, timestamps, quiz answers and UI settings only; no PII, no credentials. Unencrypted SQLite in app-private storage is proportionate. Backup exposure is M-03. |
| CRYPTO | N/A | No application-level cryptography, keys or secrets. |
| AUTH | N/A | No accounts, login or session. |
| NETWORK | Pass (release) | Release manifest requests **no INTERNET permission**. No `usesCleartextTraffic`, no network security config needed, no pinning applicable. Zero TCP/UDP sockets observed at runtime. |
| PLATFORM | Pass | One exported component (`MainActivity`, launcher, required). `InitializationProvider` not exported. `ProfileInstallReceiver` exported but guarded by `android.permission.DUMP` (AndroidX standard). No deep links, no ContentProviders, no WebView. MethodChannel exposes one hard-coded intent. |
| CODE | Pass | Validator rejects HTML in all prose; search input capped and sanitised; no `File`, `Directory`, `Platform.`, `Isolate`, mirrors or dynamic code loading; no secrets in repo or APK; dependencies clean. |
| RESILIENCE | Partial | No anti-debug, root detection, integrity check or repackaging defence. Debug-key signing (M-01) and debuggable profile build (M-02). |

Exact MASTG test IDs are not asserted; the mappings above follow MASVS 2.1 category definitions.

---

## Findings

### M-01 — Release APK is signed with the debug certificate (High) — **Fixed 2026-10-23**

**Evidence**

```
Signer #1 certificate DN: C=US, O=Android, CN=Android Debug
Signer #1 certificate SHA-256 digest: 03932e84879116fe7e59f0384477dfe41ca5f0cd7ff23b0a451060dc44fa5081
Verified using v1 scheme: false | v2: true | v3: false
```

`android/app/build.gradle.kts` release block still contains the Flutter template:

```kotlin
release {
    // TODO: Add your own signing config for the release build.
    signingConfig = signingConfigs.getByName("debug")
}
```

The profile APK carries the same certificate digest, so the key is local and unprotected.

**Impact.** A debug key is not a secret of any strength: it is generated by tooling, commonly stored unencrypted, and carries no organisational identity. Anyone who obtains it can sign a package-identical update, and a third party can produce a doctored clone that the device will accept over the top if the signature matches. Play will reject a debug-signed upload outright. For an app that teaches secure coding, a repackaged build with altered "secure" samples is a credible harm, not a theoretical one.

**Remediation applied.** `android/app/build.gradle.kts` now reads `android/key.properties` (git-ignored) and creates a `release` signing config from it. There is no fallback to the debug key: if the properties are absent, a release task in the graph throws before packaging.

```
FAILURE: Build failed with an exception.
Release signing is not configured. android/key.properties does not exist. ...
BUILD FAILED in 2s
```

An incomplete file is also rejected, naming the missing entries:
`android/key.properties is missing: storeFile, keyAlias, keyPassword.`

The configured path was verified with a throwaway RSA-3072 keystore (`CN=Top10 Test Signing`): the release build succeeded and `apksigner` reported that DN. The keystore, `key.properties` and the test-signed APK were then deleted, so no signing material remains in the tree.

**To produce a real release build:** generate the organisation's keystore, create `android/key.properties` with `storeFile`, `storePassword`, `keyAlias`, `keyPassword`, build, then confirm with `apksigner verify --print-certs` that the DN is the organisation's, not `CN=Android Debug`. Store the keystore outside the repository and back it up — losing it prevents updates to the same package. Enable Play App Signing for store distribution.

### M-02 — The build on the phone is a debuggable profile build with internet access (Medium) — **Accepted**

**Evidence**

```
app-profile.apk: uses-permission: android.permission.INTERNET
                 application-debuggable
runtime: versionCode=2003, flags=[ DEBUGGABLE ... INTERNET granted=true ]
```

This is expected — the profile manifest adds INTERNET so the Flutter tool can attach, and profile builds are debuggable to expose the VM service. Release is unaffected and has no INTERNET permission. The remediated APK (versionCode 2003) retains this behaviour by design.

**Impact.** If this APK is handed to a stakeholder or tester as a demonstration of the product's privacy posture, the demonstration is wrong: the process can open sockets and the VM service is reachable over adb. The "no network permission, cannot phone home" statement is true only of the release build.

**Decision.** Accepted for development. Keep profile builds internal. When demonstrating the release posture, either ship a release-signed build after the content is final, or state explicitly that the demo build is a development build. Long term, consider a dedicated `staging` build type that keeps signing and behaviour release-like without the debug manifest overlay.

### M-03 — Backups include the progress database (Low) — **Fixed 2026-10-23**

**Evidence.** `android:allowBackup` was not declared (defaults to `true`); runtime flags included `ALLOW_BACKUP`.

**Impact.** Read progress, bookmarks, quiz answers and accessibility settings could be included in cloud/adb backups. None of it is sensitive, and the data is not user-identifying, so the exposure was small. It becomes relevant if progress is ever shared, synced or exported.

**Remediation applied.** `android/app/src/main/AndroidManifest.xml` now declares `android:allowBackup="false"`. Verified in the rebuilt APK (`android:allowBackup 0x0`) and on the merged manifest. If progress ever needs to survive device transfer, replace this with `dataExtractionRules` that exclude `app_flutter/top_10_app.sqlite` rather than re-enabling full backup.

### M-04 — No tamper or repackaging detection (Low) — **Accepted for draft; decision needed**

**Evidence.** No signature verification at startup, no integrity check of the bundled JSON, no obfuscation setting (`minifyEnabled`/`shrinkResources` unset). Content is compiled into the APK as `assets/flutter_assets/assets/content/bundle.json`.

**Impact.** A modified clone can present altered security guidance. Play App Signing limits this for store installs; sideloaded builds have no such control. This is defense-in-depth, not an active vulnerability.

**Remediation.** Decide whether it is in scope. If yes: verify the signing certificate at startup against a pinned digest, or hash the content bundle at build time and verify at load. If no, record the accepted risk and rely on distribution controls.

### I-01 — Native components are current and hardened (Informational)

- `libsqlite3.so` bundles **SQLite 3.53.4** (from `sqlite3` 3.5.2); no advisory found for the Maven/Pub packages.
- `libsqlite3.so` and `libdartjni.so`: `GNU_STACK` is RW (non-executable stack), `BIND_NOW` + `GNU_RELRO` (full RELRO).
- `extractNativeLibs=false`, so libraries load from the APK rather than an unpacked directory.
- `libapp.so` contains no endpoint URLs — only five Flutter framework documentation links.

### I-02 — Outdated transitive dependencies, no advisories (Informational)

`flutter pub outdated` flags 15 locked transitive packages, including `sqlite3` 3.5.2 → 3.8.0, `material_color_utilities` 0.13.0 → 0.13.1 and `vector_math` 2.4.0 → 2.4.3. None has a published advisory in OSV as of this assessment. Nothing requires action now; a periodic `flutter pub upgrade` before release candidate is reasonable.

---

## Dependency and supply-chain results

| Ecosystem | Queried | Known advisories |
| --- | ---: | ---: |
| Pub (Dart/Flutter, all locked packages) | 104 | 0 |
| Maven (Android release runtime classpath, resolved) | 49 | 0 |

Not queried: the Flutter engine and Skia (no OSV ecosystem entry), Gradle/Kotlin build plugins (build-time only), and the Android platform itself. These remain **unverified**, not "clean".

---

## Positive observations

- Release manifest requests no permissions beyond AndroidX's signature-level `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`.
- `android:taskAffinity=""` mitigates task-affinity hijacking.
- No exported services, receivers or providers beyond the launcher activity and the DUMP-protected AndroidX receiver.
- No WebView, JavaScript bridge, `DexClassLoader`, `Runtime.exec` or `ProcessBuilder` in the DEX.
- No tracker or analytics SDK strings in the DEX.
- No secrets, keystores or `key.properties` in the repository.
- Runtime: zero TCP/UDP sockets attributed to the app uid after launch; logcat contained no app-originated URLs, tokens or content.
- On-device database schema: `read_progress`, `bookmark_entries`, `quiz_attempt_entries`, `setting_entries` — no personal data fields.

---

## Limitations

- No Frida/objection instrumentation, hooking or runtime tampering tests.
- No intercepting-proxy testing: release has no network path, so TLS, pinning and API behaviour are not applicable. Profile-build traffic was not proxied.
- The release APK was assessed statically, not installed, because it correctly refuses draft content.
- Native engine/Skia, the Android runtime and Gradle plugins were not fuzzed or CVE-mapped.
- No iOS artefact exists.
- A repackaged-clone scenario was reasoned about, not built.

## Post-remediation verification (2026-10-23)

| Check | Result |
| --- | --- |
| `./gradlew :app:assembleRelease` with no `key.properties` | Fails with the explicit "Release signing is not configured" message, in 6 s |
| Release build with a throwaway keystore | Succeeds; `apksigner` reports `CN=Top10 Test Signing`; keystore, properties and APK deleted afterwards |
| Rebuilt profile APK (versionCode 2003) | `android:allowBackup 0x0` (disabled), INTERNET and debuggable unchanged by design |
| `flutter analyze` / `flutter test` | Clean / 34 of 34 pass |
| Debug and profile builds | Unaffected by the signing guard (task-graph check matches release tasks only) |

## Prioritised next steps

1. **M-01 (remaining half)** — the wiring is done; the organisation must now generate and own a real keystore, create `android/key.properties`, and confirm the certificate DN. Nothing else blocks distribution.
2. **M-02** — keep profile builds internal; qualify the privacy claim in any demo using one.
3. **M-04** — decide and record (mitigate or accept).
4. Before hand-off: rebuild release from the final bundle once SME review closes, re-run this assessment, and attach the result to the hand-off record.

---

## Re-verification (2026-10-28)

**Mode:** `offline` static analysis of local artifacts + `authorized-active` checks on a wiped local AVD (`Medium_Phone_API_37.0`, API 37, x86_64). Full method and toolchain in [`security-test-methodology.md`](security-test-methodology.md).

**Artifacts observed**

| Artifact | SHA-256 | State |
| --- | --- | --- |
| `build/app/outputs/apk/release/app-release.apk` | `220f2520621f53342209a6cbc9f30f17f787fee001fb927065552f8b184b2799` | Present, v2-signed `CN=Top10 Test Signing` |
| `build/app/outputs/flutter-apk/app-profile.apk` | `0d5884df793afc3468db4936b96ad7c3f5138790853f813acb75f218e7b82cca` | Unchanged (2026-10-23 16:13) |
| `assets/content/bundle.json` | `9666069322ade3cc9e97d28671fadc96c25c0655f6132da1c4101807b34455f1` | `2026.10.5-draft`, status `draft`; identical copy inside the release APK |

**What still holds**

- **M-01 fixed:** `./gradlew :app:assembleRelease --offline` with no `key.properties` fails in 2 s with the explicit "Release signing is not configured" error. No keystore or `key.properties` exists in the tree.
- **M-03 fixed:** release and profile manifests both report `android:allowBackup 0x0`; runtime package flags contain no `ALLOW_BACKUP`.
- **M-02 accepted and now confirmed dynamically:** the profile build exposes the Dart VM service on loopback `127.0.0.1:32867`. An HTTP request without the token returns `403 missing or invalid authentication code`; the token is printed to logcat. There were **zero outbound** sockets. The earlier statement "zero TCP/UDP sockets attributed to the app uid" was therefore incomplete: it missed this loopback listener. The release build remains unaffected (no `INTERNET`, no debugger).
- **Dependencies:** OSV returned 0 advisories for 99 Pub packages and 49 resolved Maven artifacts.
- **Build health:** `flutter analyze` clean; `flutter test` 34/34 pass.

**Corrections and new observations**

- **M-05 (Low) — the test-signed release APK was not deleted.** The 2026-10-23 post-remediation table says the APK was deleted; it is still present at `build/app/outputs/apk/release/app-release.apk`, signed by the throwaway `CN=Top10 Test Signing` key whose keystore is gone. It must not be distributed; delete it and add `build/` to `.gitignore`.
- **I-03 (Info) — build outputs are not ignored.** `build/`, `.dart_tool/`, `.idea/`, `.metadata` and `.flutter-plugins-dependencies` are untracked but not covered by `.gitignore`.
- **I-04 (Info) — fat APK ABI mismatch.** The fat profile/release APKs advertise `arm64-v8a`, `armeabi-v7a` and `x86_64`, but only the arm64 directory contains `libflutter.so`/`libapp.so`. On x86_64 the app installs and then fails with `dlopen ... libflutter.so is for EM_AARCH64 instead of EM_X86_64`. Split-per-ABI builds run correctly.
- **I-05 (Info) — version/toolchain drift.** Release versionCode is 1 while development builds are 2003/4001; the README documents JDK 21 while the build host uses JDK 25.0.5-ea.

**Unchanged limitation:** the release APK was not installed because `kReleaseMode` correctly refuses draft content; dynamic evidence comes from a development profile build.
