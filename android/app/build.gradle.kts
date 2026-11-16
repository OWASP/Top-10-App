import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing material lives in android/key.properties, which is git-ignored.
// It is read at configuration time so debug and profile builds need no keystore.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val keystoreFileExists = keystorePropertiesFile.exists()
if (keystoreFileExists) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}
val requiredKeystoreKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val missingKeystoreKeys = requiredKeystoreKeys.filter {
    keystoreProperties.getProperty(it).isNullOrBlank()
}
val hasReleaseKeystore = keystoreFileExists && missingKeystoreKeys.isEmpty()

android {
    namespace = "com.example.top_10_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.top_10_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Release must never be signed with the debug key. When no keystore is
            // configured this is left unset and the build fails below, rather than
            // producing an APK carrying the public debug identity.
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Fail loudly instead of silently producing a release artefact with no signing
// identity. Checked against the task graph so debug and profile builds are
// unaffected. See docs/security/security-test-report.md (M-01).
gradle.taskGraph.whenReady {
    if (hasReleaseKeystore) return@whenReady
    val releaseRequested = allTasks.any { task ->
        task.project == project && task.name.contains("Release")
    }
    if (releaseRequested) {
        val reason = if (keystoreFileExists) {
            "android/key.properties is missing: ${missingKeystoreKeys.joinToString(", ")}."
        } else {
            "android/key.properties does not exist."
        }
        throw GradleException(
            "Release signing is not configured. $reason Create the file with " +
                "storeFile, storePassword, keyAlias and keyPassword entries, then " +
                "rebuild. See docs/security/security-test-report.md (M-01).",
        )
    }
}
