# Mobile Security Testing — Method, Tools and Evidence

**Project:** Top 10 Pocket Guide (`com.example.top_10_app`)
**Document date:** 2026-10-28
**Assessment run:** 2026-10-28 (verification of the 2026-10-23 assessment)
**Platform:** Android (minSdk 24, targetSdk 36, API 37 emulator)
**Execution mode:** `offline` static analysis of local artifacts + `authorized-active` dynamic checks on the project's own local emulator. No third-party targets were contacted.
**Related:** [`security-test-report.md`](security-test-report.md) (findings register), [`../project/status.md`](../project/status.md) (release gates).

> This document records **how** the app is tested, **what** tools and technology are used, and **what evidence** was collected. It is a working method and an evidence ledger, not a certification. Findings and their severities remain in the assessment report; this document references them by ID.

---

## 1. Purpose and scope

### 1.1 What this document is for

- Make the test method reproducible by another engineer.
- Record the exact toolchain, versions and commands behind each conclusion.
- Keep an auditable link between an artifact hash and a finding.
- State clearly what was **not** tested, so absence of evidence is not read as evidence of absence.

### 1.2 In scope

| Area | Included |
| --- | --- |
| Android application source (`lib/`, `android/`) | Yes |
| Built APKs (debug, profile, release) | Yes |
| Bundled content (`assets/content/bundle.json`) | Integrity and loading behaviour only |
| Resolved dependencies (Pub and Maven) | Advisory lookup only |
| Local emulator runtime behaviour | Yes, development (profile) build |
| Release engineering and signing | Yes |
| iOS / IPA | No artifact exists |
| Editorial accuracy of the 60 risks | No — SME review, not security |

### 1.3 Authorization and safety

The application is the project's own, built from this repository on a local workstation. Dynamic testing ran only against a disposable local AVD. No external hosts were scanned, proxied or modified. No signing material was created or retained. Build artifacts were backed up under `/tmp/owasp-apk-check/artifact-backup/` before a fresh build so the evidence ledger stays reproducible.

---

## 2. Test method

The method is a nine-phase loop. Phases 1–8 run per assessment; phase 9 is the gate.

### Phase 0 — Inventory and evidence capture

1. Record the git revision, artifact paths, sizes, modification times and SHA-256 hashes.
2. Record tool versions before drawing conclusions, so results are attributable to a toolchain.
3. Back up existing artifacts before rebuilding; never test a build you cannot identify.

### Phase 1 — Source and build configuration review

Read the application source and the build inputs, not only the packaged output:

- `android/app/src/{main,debug,profile}/AndroidManifest.xml`
- `android/app/build.gradle.kts`, `android/gradle.properties`, `gradle/wrapper`
- `pubspec.yaml`, `pubspec.lock`
- All of `lib/` for storage, navigation, platform channels, logging and dynamic code loading

Purpose: find controls that the packaged manifest alone cannot show (for example a release build that gates draft content at runtime), and find defects the manifest hides (for example a fallback to the debug signing key).

### Phase 2 — Artifact static analysis

1. Verify the signature with `apksigner` (`--print-certs --verbose`).
2. Parse the **merged** manifest with `aapt dump badging` and `aapt dump xmltree` — the authoritative view, not the source manifest.
3. Enumerate every component and its `exported`/`permission` attributes.
4. Inspect `classes*.dex` and native libraries with `strings` for endpoints, tracker SDKs and secrets.
5. Read ELF hardening flags with `readelf` (RELRO, `BIND_NOW`, `GNU_STACK`).
6. Compare the packaged content bundle with the repository copy by hash.

### Phase 3 — Storage review (MASVS-STORAGE)

- Identify the persistence layer from source (Drift + SQLite).
- Enumerate the on-device database and its schema via `run-as`.
- Confirm the columns hold no personal data or credentials.
- Check `android:allowBackup`, `dataExtractionRules` and runtime package flags.
- Check for plaintext secrets in the app-private directory.

### Phase 4 — Transport review (MASVS-NETWORK)

- Confirm whether the release manifest requests `INTERNET`.
- Look for `usesCleartextTraffic`, `networkSecurityConfig` and pinning.
- At runtime, map `/proc/net/{tcp,tcp6,udp,udp6}` sockets to the app UID.
- Distinguish **loopback listeners** (development VM service) from **outbound connections** (telemetry or API traffic).

### Phase 5 — Platform interaction (MASVS-PLATFORM)

- Test each exported component's reachability and permission guard.
- Review deep links and `intent-filter` data elements.
- Review platform channels (`MethodChannel`) and their handlers.
- Confirm the absence of WebView, JavaScript bridges and `ContentProvider` exposure.

### Phase 6 — Resilience and release engineering (MASVS-RESILIENCE)

- Confirm the release signing identity and scheme (v1/v2/v3).
- Confirm release is not debuggable and does not fall back to the debug key.
- Check the fail-closed build guard by requesting a release build with no keystore.
- Record accepted gaps (root/tamper detection, obfuscation) rather than treating defense-in-depth as a vulnerability.

### Phase 7 — Dependency and supply chain (MASVS-CODE)

- Extract every locked Pub package from `pubspec.lock`.
- Extract the **resolved** Maven runtime classpath from Gradle, de-duplicating requested versions to selected versions.
- Query the OSV batch API for both ecosystems.
- Record the query counts and explicitly name ecosystems that were not queried.

### Phase 8 — Dynamic validation

1. Boot a clean AVD (`-wipe-data`) headless.
2. Install the build under test.
3. Launch, then capture: process UID, package flags, granted permissions, logcat, socket table, app-private files, database.
4. Attempt an interaction with each exported component that has a plausible caller.
5. Stop after observation; no hooking or tampering is performed unless explicitly in scope.

### Phase 9 — Verification, MASVS mapping and report

- Run `flutter analyze` and `flutter test` against the same revision.
- Map results to MASVS 2.1 categories.
- Separate **observed**, **inferred** and **unverified** statements.
- Record limitations and a next verification step for any residual risk.

---

## 3. Toolchain and technology inventory

### 3.1 Environment

| Component | Version | Use |
| --- | --- | --- |
| OS | Kali GNU/Linux Rolling, Linux 7.1.5+kali-amd64 | Workstation |
| Flutter | 3.47.7, stable channel | Build and test |
| Flutter framework revision | `abaf9c5237` (2026-10-08) | Build provenance |
| Flutter engine | `d8a2d6c768c334d53e16277f837970ffa1e2de81` (revision `deb287481e`) | Build provenance |
| Dart | 3.13.5 | Language/runtime |
| DevTools | 2.60.0 | Not used for this run |
| FVM | 3.47.7 pinned via `.fvmrc` | Reproducible Flutter version |
| Gradle | 9.3.1 | Android build |
| Kotlin (Gradle) | 2.2.21 | Android build |
| JDK | 25.0.5-ea (Debian) — **note:** README documents JDK 21 | Build; drift recorded as I-05 |
| Android SDK Platform | 36 (35 and 37.0 also installed) | Compile/target |
| Android Build Tools | 36.0.0 | `aapt`, `aapt2`, `apksigner` |
| ADB | 1.0.41 / 34.0.5-debian | Device control |
| Emulator AVD | `Medium_Phone_API_37.0` — API 37, x86_64, `google_apis_playstore` | Dynamic checks |

### 3.2 Analysis tools actually used

| Tool | Purpose in this method |
| --- | --- |
| `sha256sum` | Artifact identity and evidence linkage |
| `aapt` / `aapt2` (build-tools 36.0.0) | Authoritative merged manifest, badging, permissions, ABI |
| `apksigner` (build-tools 36.0.0) | Signature scheme and certificate DN/digest |
| `unzip` | APK inventory and content extraction |
| `strings` | DEX/native endpoint and secret scanning |
| `readelf` | ELF hardening: `GNU_RELRO`, `BIND_NOW`, `GNU_STACK` |
| `sqlite3` | On-device database schema and row inspection |
| `adb` / `run-as` | Install, launch, logcat, socket table, app-private storage |
| `flutter analyze` | Static analysis of Dart source |
| `flutter test` | 34-test suite; behavioural and validator checks |
| `flutter build apk` | Reproducible profile splits for emulator testing |
| OSV `/v1/querybatch` (`https://api.osv.dev`) | Published advisories for Pub and Maven |
| `python3` (`-I`, stdlib `urllib`) | Dependency extraction and OSV query batch |
| `curl` | OSV reachability and VM-service HTTP observation |
| `git` | Revision provenance (`5fdace4`) |

### 3.3 Tools deliberately not available in this environment

| Tool | Missing capability | Consequence |
| --- | --- | --- |
| `jadx` / `apktool` | Full Dalvik → Java decompilation | Conclusions rely on `strings`, source review and manifest, not decompiled control flow |
| `apkid` | Packer/obfuscator fingerprinting | Packing remains **unverified** |
| `frida` / `objection` | Runtime hooking, pinning/root bypass, keystore dump | No runtime tampering tests; not needed for this app's surface |
| MobSF | Automated static/dynamic platform | Manual method used |
| `pyaxmlparser` | Python manifest parsing helper | Not needed — `aapt` is authoritative |
| Intercepting proxy (Burp/mitmproxy) | TLS/API analysis | Not applicable: release has no `INTERNET` permission and no API |

> Missing tooling is recorded as a limitation, never as a pass.

---

## 4. Reproducible commands

All commands run from the repository root unless stated.

### 4.1 Artifact identity

```sh
sha256sum build/app/outputs/apk/release/app-release.apk \
          build/app/outputs/flutter-apk/app-profile.apk \
          build/app/outputs/flutter-apk/app-debug.apk \
          assets/content/bundle.json
stat -c '%n %s bytes %y' build/app/outputs/apk/release/app-release.apk
```

### 4.2 Signature

```sh
BT=$HOME/Android/Sdk/build-tools/36.0.0
$BT/apksigner verify --print-certs --verbose build/app/outputs/apk/release/app-release.apk
```

### 4.3 Merged manifest and components

```sh
$BT/aapt dump badging build/app/outputs/apk/release/app-release.apk
$BT/aapt dump xmltree build/app/outputs/apk/release/app-release.apk AndroidManifest.xml
```

### 4.4 Content integrity

```sh
unzip -p build/app/outputs/apk/release/app-release.apk \
  assets/flutter_assets/assets/content/bundle.json | sha256sum
sha256sum assets/content/bundle.json
```

### 4.5 Native hardening

```sh
unzip -o -q build/app/outputs/apk/release/app-release.apk 'lib/*' -d /tmp/libs
readelf -lW /tmp/libs/lib/arm64-v8a/libsqlite3.so | grep -E 'GNU_STACK|GNU_RELRO'
readelf -dW /tmp/libs/lib/arm64-v8a/libsqlite3.so | grep -E 'BIND_NOW|FLAGS'
```

### 4.6 Dependency advisories

```sh
# Pub: extract name/version pairs from pubspec.lock, then POST to:
#   https://api.osv.dev/v1/querybatch
#   {"queries":[{"package":{"name":"drift","ecosystem":"Pub"},"version":"2.35.2"}, ...]}

# Maven: resolved release runtime classpath, then the same API with "ecosystem":"Maven"
cd android && ./gradlew -q :app:dependencies --configuration releaseRuntimeClasspath --offline
```

### 4.7 Build and test health

```sh
flutter analyze
flutter test
cd android && ./gradlew :app:assembleRelease --offline   # expected to fail closed
```

### 4.8 Dynamic validation

```sh
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
$ANDROID_SDK_ROOT/emulator/emulator -avd Medium_Phone_API_37.0 \
  -no-window -no-audio -no-boot-anim -no-snapshot-save \
  -gpu swiftshader_indirect -wipe-data
adb wait-for-device shell 'while [ "$(getprop sys.boot_completed)" != 1 ]; do sleep 2; done'

# Build a runnable x86_64 development split, because the fat profile APK is arm64-only
flutter build apk --profile --split-per-abi
adb install -r build/app/outputs/flutter-apk/app-x86_64-profile.apk
adb logcat -c
adb shell am start -W -n com.example.top_10_app/.MainActivity

# Runtime evidence
adb shell ps -A -o PID,UID,NAME | grep top_10_app
adb shell dumpsys package com.example.top_10_app
adb shell cat /proc/net/tcp        # map socket uid column to the app uid
adb shell run-as com.example.top_10_app find /data/data/com.example.top_10_app -type f
adb shell run-as com.example.top_10_app cat app_flutter/top_10_app.sqlite > /tmp/app.sqlite
sqlite3 /tmp/app.sqlite '.tables'
sqlite3 /tmp/app.sqlite '.schema'
```

---

## 5. Evidence ledger — 2026-10-28

Collection time: **2026-10-28T09:43:45-07:00**. Git revision: **`5fdace4`**.

| Artifact | Size | SHA-256 | Built / observed | Signature | Notes |
| --- | ---: | --- | --- | --- | --- |
| `build/app/outputs/apk/release/app-release.apk` | 20,745,060 B | `220f2520621f53342209a6cbc9f30f17f787fee001fb927065552f8b184b2799` | 2026-10-23 16:11 | v2, `CN=Top10 Test Signing, O=Local Test Build, C=US`, RSA-3072 | Test-signed; **must not be distributed** (M-05) |
| `build/app/outputs/flutter-apk/app-profile.apk` | 28,776,190 B | `0d5884df793afc3468db4936b96ad7c3f5138790853f813acb75f218e7b82cca` | 2026-10-23 16:13 | v2, Android Debug, RSA-2048 | versionCode 2003; ARM64 Flutter libs only |
| `build/app/outputs/flutter-apk/app-x86_64-profile.apk` (fresh) | 30,069,802 B | `67891f36c03b73715079813863a56ee8bf546d2fd2db345e8da2fac8655d1114` | 2026-10-28 09:42 | v2, Android Debug, RSA-2048 | versionCode 4001; used for dynamic checks |
| `build/app/outputs/flutter-apk/app-arm64-v8a-profile.apk` (fresh) | 28,595,257 B | `2a6f9583ac5243a815ae7d035d5d733803fbabe7537d449ef2d927d24ad0572f` | 2026-10-28 09:42 | v2, Android Debug | ARM64 split |
| `build/app/outputs/flutter-apk/app-armeabi-v7a-profile.apk` (fresh) | 26,071,811 B | `ca459fdd12a1a7c0d170eeffb2ca4ddfe68cf6737721a72f39de066995b693b0` | 2026-10-28 09:42 | v2, Android Debug | ARMv7 split |
| `build/app/outputs/flutter-apk/app-debug.apk` | 201,256,091 B | `2c47d0f1042acaee84e8b9b6db5a65892606c1cc6155e9ddb9f42b4f22f405d4` | 2026-10-23 14:43 | Debug | Not used for conclusions |
| `assets/content/bundle.json` | 122,321 B | `9666069322ade3cc9e97d28671fadc96c25c0655f6132da1c4101807b34455f1` | 2026-10-23 14:42 | — | schema 1.0.0, bundle `2026.10.5-draft`, status `draft`, 6 lists |

**Bundle integrity:** the copy inside `app-release.apk` has the same SHA-256 (`9666…55f1`) as the repository copy. The packaged content is the current draft bundle, not a stale one.

**Validation performed this run**

- `flutter analyze` — **No issues found** (2.3 s).
- `flutter test` — **34/34 passed**.
- `./gradlew :app:assembleRelease --offline` without `key.properties` — **fails closed** in 2 s with: `Release signing is not configured. android/key.properties does not exist.`
- OSV: **99** Pub packages queried, **0** advisories; **49** resolved Maven artifacts queried, **0** advisories.
- Runtime: install, launch, UID/package flags, socket table, logcat and `run-as` database inspection on the local AVD.

---

## 6. Current results

### 6.1 Manifest and components (release APK, merged)

| Check | Observed |
| --- | --- |
| Package / version | `com.example.top_10_app`, versionCode 1, versionName 1.0.0 |
| SDK | minSdk 24, targetSdk 36 |
| Permissions | Only the AndroidX signature-level `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`; **no `INTERNET`** |
| `android:debuggable` | Absent |
| `android:allowBackup` | `0x0` (false) |
| `android:extractNativeLibs` | `0x0` (false) |
| `android:usesCleartextTraffic` / `networkSecurityConfig` | Absent |
| Exported activity | `MainActivity` — launcher, required; `taskAffinity=""` |
| Exported receiver | `androidx.profileinstaller.ProfileInstallReceiver` — guarded by `android.permission.DUMP` |
| Provider | `androidx.startup.InitializationProvider` — `exported=false`, app-scoped authority |
| Deep links / `BROWSABLE` | None |
| WebView / JS bridge | None in source or DEX strings |

### 6.2 Runtime (fresh x86_64 profile split)

| Check | Observed |
| --- | --- |
| Device | `Medium_Phone_API_37.0`, API 37, x86_64, `google_apis_playstore`, wiped before install |
| Install / launch | Success; launch `WaitTime: 1768 ms` |
| Process UID | 10236 |
| Package flags | `DEBUGGABLE HAS_CODE ALLOW_CLEAR_USER_DATA` — no `ALLOW_BACKUP` |
| `INTERNET` | Granted (development manifest overlay — M-02) |
| Sockets owned by UID | One **listening** socket on `127.0.0.1:32867` (Dart VM service); **zero outbound** TCP/UDP sockets |
| VM service | Logcat: `The Dart VM service is listening on http://127.0.0.1:32867/<token>/`; HTTP request without token returns `403 missing or invalid authentication code` |
| App-private files | `files/profileInstalled`, `app_flutter/top_10_app.sqlite` |
| Database | Plaintext SQLite; tables `read_progress`, `bookmark_entries`, `quiz_attempt_entries`, `setting_entries`; all empty on fresh install |
| PII columns | None — risk IDs, timestamps, selected option index, correctness, preference key/value |
| Logcat (app PID) | No application URLs, tokens or content; framework/accessibility messages only |
| Exported receiver | Broadcast from `adb shell` delivered; returned `RESULT_UNSUPPORTED_ART_VERSION` (standard AndroidX behaviour; shell holds `DUMP`) |

**Interpretation.** The loopback listener is the development VM service, expected in a debuggable profile build and consistent with accepted finding **M-02**. It is reachable only from the device (or via `adb forward`) and is token-gated; an attacker who can read logcat can obtain the token. This is a development-build exposure, not a release exposure. Release does not request `INTERNET` and has no such listener path in normal use.

### 6.3 MASVS 2.1 coverage (current run)

| Category | Result | Basis |
| --- | --- | --- |
| STORAGE | Pass | No PII/credentials; plaintext SQLite proportionate; `allowBackup=false` |
| CRYPTO | N/A | No application-level cryptography, keys or secrets |
| AUTH | N/A | No accounts, login or session |
| NETWORK | Pass (release) | Release has no `INTERNET`; no cleartext config; zero outbound sockets |
| PLATFORM | Pass | One required exported activity; receiver DUMP-guarded; provider not exported; no deep links/WebView |
| CODE | Pass | Validator and search hardening verified; no dynamic code loading; dependency scans clean |
| RESILIENCE | Partial | Release signing wired and fail-closed; no tamper/root/obfuscation controls (M-04 accepted); development builds are debuggable (M-02 accepted) |

### 6.4 Findings status after this run

| ID | Severity | Finding | Status on 2026-10-28 |
| --- | --- | --- | --- |
| M-01 | High | Release signed with AOSP debug certificate | **Fixed** — guard verified fail-closed; no keystore in tree |
| M-02 | Medium | Profile build is debuggable, has `INTERNET`, exposes VM service | **Accepted** — dynamically confirmed (loopback 127.0.0.1:32867, token-gated) |
| M-03 | Low | Backups include progress database | **Fixed** — `allowBackup=false` verified |
| M-04 | Low | No tamper/repackaging detection | **Accepted for draft** — decision still needed |
| M-05 | Low | Stale test-signed release APK still present | **Open** — see below |
| I-03 | Info | Build outputs not covered by `.gitignore` | **Open** — hygiene |
| I-04 | Info | Fat APK advertises ABIs it cannot run | **Open** — packaging |
| I-05 | Info | Toolchain/version drift | **Open** — informational |

#### M-05 — Test-signed release APK retained (Low)

The 2026-10-23 report states that the test-signed APK was deleted. It was not: `build/app/outputs/apk/release/app-release.apk` still exists, is signed by `CN=Top10 Test Signing` (SHA-256 certificate digest `1885b15dbe7026052febc57cf9373383106c7756397d666c709de88f88e61b89`), and is labelled a release artifact. The corresponding keystore is not present in the tree (searched for `*.jks`, `*.keystore`, `key.properties`), so the artifact cannot be updated or reproduced.

**Impact:** low while it stays local and untracked. It becomes material if it is published, attached to a demo, or committed: a throwaway identity with no owner is being presented as a release. It also contradicts the written record, which matters for auditability.

**Remediation:** delete `build/app/outputs/apk/release/app-release.apk`; add `build/` to `.gitignore` (I-03); never distribute an artifact whose certificate DN is not the organisation's. Re-run `apksigner verify --print-certs` on any candidate release.

#### I-03 — Build outputs are not ignored (Info)

The root `.gitignore` covers secrets and `.fvm/` but not `build/`, `.dart_tool/`, `.idea/`, `.metadata` or `.flutter-plugins-dependencies`. Git reports all of them as untracked, not ignored. A careless `git add .` would stage 335 MB of APKs, including the test-signed release above, plus local IDE state.

**Remediation:** extend `.gitignore` with `build/`, `.dart_tool/`, `.idea/`, `.metadata`, `.flutter-plugins-dependencies`; confirm with `git check-ignore -v`.

#### I-04 — Fat APK advertises ABIs it cannot run (Info)

`app-release.apk` and `app-profile.apk` declare `native-code: arm64-v8a, armeabi-v7a, x86_64`, but only `lib/arm64-v8a/` contains `libflutter.so` and `libapp.so`; the other ABI directories contain only `libdartjni.so`. On the x86_64 AVD the app installed and then failed at Flutter initialization:

```
dlopen failed: "/data/data/com.example.top_10_app/app_lib/libflutter.so"
is for EM_AARCH64 (183) instead of EM_X86_64 (62)
E/FlutterLoader: Flutter initialization failed.
```

This is a packaging/availability defect, not a vulnerability. Use `--split-per-abi` for emulator and per-ABI testing, or rebuild the fat APK with all target platforms.

#### I-05 — Version and toolchain drift (Info)

- `app-release.apk` is versionCode **1**; development builds are **2003** and **4001**. A later real release with versionCode 1 cannot install over a device carrying a development build.
- README documents **JDK 21**; this workstation built with **JDK 25.0.5-ea**. Builds are therefore not hermetic against the documented toolchain.
- Gradle warns that the installed command-line tools understand SDK XML up to version 3 while a version 4 file is present.

None is a security defect; all affect reproducibility and release hygiene.

---

## 7. Limitations and unverified areas

| Area | State | Why it matters / next step |
| --- | --- | --- |
| iOS | **Not tested** — no IPA | Port not started; re-plan MASVS coverage before iOS release |
| Release APK runtime | **Not installed** | Release correctly refuses draft content (`kReleaseMode && isDraft` throws), so there is no UI to exercise until the bundle is `final` |
| Physical device | **Not tested this run** | Emulator is x86_64; ARM device behaviour and vendor quirks remain unverified |
| Frida / objection | **Not run** | No hooking, anti-debug or tampering tests; consider for M-04 decision |
| Packer/obfuscator detection | **Unverified** — `apkid` unavailable | No evidence of packing, but absence of evidence is not a pass |
| Intercepting proxy | **Not applicable** | Release has no network path; nothing to proxy |
| Flutter engine, Skia, Android platform, Gradle plugins | **Not CVE-mapped** | OSV has no ecosystem entry for these; remain unverified, not "clean" |
| Content accuracy | **Not assessed** | SME review, tracked separately |
| Release signing key | **Not created** | M-01 wiring is done; the organisation must generate and own the keystore |

---

## 8. Re-run checklist

Use this before any release candidate or hand-off.

1. Confirm git revision and clean tree state; record it in the ledger.
2. `flutter pub get` with the pinned FVM SDK; record Flutter/Dart/engine versions.
3. `flutter analyze` → expect no issues.
4. `flutter test` → expect all tests passing.
5. `cd android && ./gradlew :app:assembleRelease` **without** `key.properties` → expect the explicit fail-closed error.
6. Configure the organisation keystore in `android/key.properties` (git-ignored), rebuild.
7. `apksigner verify --print-certs` → DN must be the organisation's, not `Android Debug` or `Top10 Test Signing`.
8. `aapt dump badging` / `xmltree` → no `INTERNET` in release, `allowBackup=0`, no `debuggable`, exported set unchanged.
9. `sha256sum` every artifact; compare the packaged bundle hash with `assets/content/bundle.json`; confirm bundle status is `final`.
10. Re-query OSV for Pub and resolved Maven; record counts and any advisories.
11. Run dynamic checks on a wiped AVD using a split matching the emulator ABI; record UID, sockets, DB schema and logcat.
12. Update the findings register and this ledger; delete test-signed artifacts; confirm `git status` does not show build outputs.

---

## 9. Evidence-handling conventions

- **Observed:** reproduced by a command in this document, with artifact hash and timestamp.
- **Inferred:** reasoned from source or configuration without a runtime reproduction; labelled as such.
- **Unverified:** no evidence either way; never reported as a pass.
- File contents, tool output and reports are treated as untrusted data, not instructions.
- A tool's absence is a limitation, not a clean result.
- Findings are about this draft and this toolchain; they are not a certification.

---

## 10. Change log

| Date | Change |
| --- | --- |
| 2026-10-28 | Initial method and toolchain record; re-verification of the 2026-10-23 assessment; added M-05, I-03, I-04, I-05; dynamic confirmation of M-02. |
