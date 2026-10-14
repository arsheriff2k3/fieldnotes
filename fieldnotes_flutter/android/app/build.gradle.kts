import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// ---------------------------------------------------------------------------
// Release identity and signing.
//
// Nothing real is committed. Each value is read, in order, from:
//   1. a Gradle property (-Pfieldnote.applicationId=... or ~/.gradle/gradle.properties),
//   2. android/key.properties (git-ignored; copy key.properties.example), or
//   3. an environment variable (for CI).
// Debug and profile builds fall back to harmless placeholders. Release builds
// fail in :app:validateFieldnoteRelease when anything is missing.
// ---------------------------------------------------------------------------
val keyProperties: Properties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

fun fieldnoteSetting(name: String, envName: String): String? =
    (project.findProperty(name) as? String)?.trim()?.takeIf { it.isNotEmpty() }
        ?: keyProperties.getProperty(name)?.trim()?.takeIf { it.isNotEmpty() }
        ?: System.getenv(envName)?.trim()?.takeIf { it.isNotEmpty() }

// Placeholder used only by debug/profile builds when no ID is configured.
val placeholderApplicationId = "com.example.fieldnotes_flutter"
// Placeholder App Links host for debug/profile builds.
val placeholderLinkHost = "localhost"

val configuredApplicationId: String? =
    fieldnoteSetting("fieldnote.applicationId", "FIELDNOTE_APPLICATION_ID")
val configuredLinkHost: String? =
    fieldnoteSetting("fieldnote.linkHost", "FIELDNOTE_LINK_HOST")

val releaseStoreFile: String? = fieldnoteSetting("storeFile", "FIELDNOTE_KEYSTORE_PATH")
val releaseStorePassword: String? =
    fieldnoteSetting("storePassword", "FIELDNOTE_KEYSTORE_PASSWORD")
val releaseKeyAlias: String? = fieldnoteSetting("keyAlias", "FIELDNOTE_KEY_ALIAS")
val releaseKeyPassword: String? = fieldnoteSetting("keyPassword", "FIELDNOTE_KEY_PASSWORD")
val hasReleaseSigning: Boolean = listOf(
    releaseStoreFile,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { it != null }

// All client Maps keys live in one git-ignored file. Android only reads its
// own restricted key and injects it into AndroidManifest.xml at build time.
val googleMapsApiKey: String = Properties().run {
    val file = rootProject.file("../.env.maps")
    if (file.exists()) file.inputStream().use { load(it) }
    getProperty("GOOGLE_MAPS_ANDROID_API_KEY", "")
}

android {
    namespace = "com.example.fieldnotes_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Set fieldnote.applicationId (see the header of this file). The
        // placeholder is accepted for debug/profile builds only.
        applicationId = configuredApplicationId ?: placeholderApplicationId
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
        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey
        // Host for https://<host>/c/<id> App Links (android:autoVerify).
        manifestPlaceholders["fieldnoteLinkHost"] = configuredLinkHost ?: placeholderLinkHost
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                // storeFile is resolved relative to android/ (or absolute).
                storeFile = rootProject.file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            // Never fall back to the debug key. Without key.properties the
            // release build is stopped by validateFieldnoteRelease.
            signingConfig = if (hasReleaseSigning) signingConfigs.getByName("release") else null
        }
    }
}

val fieldnoteReleaseProblems: List<String> = buildList {
    val applicationId = configuredApplicationId
    when {
        applicationId == null -> add(
            "fieldnote.applicationId is not set. Add it to android/key.properties, " +
                "pass -Pfieldnote.applicationId=<your.reverse.dns.id>, or set FIELDNOTE_APPLICATION_ID.",
        )
        applicationId.startsWith("com.example") -> add(
            "fieldnote.applicationId '$applicationId' still uses the com.example placeholder namespace.",
        )
    }
    if (!hasReleaseSigning) {
        add(
            "Release signing is not configured. Copy android/key.properties.example to " +
                "android/key.properties and set storeFile, storePassword, keyAlias and keyPassword.",
        )
    } else if (!rootProject.file(releaseStoreFile!!).exists()) {
        add("Release keystore not found at '${rootProject.file(releaseStoreFile).path}'.")
    }
    val linkHost = configuredLinkHost
    when {
        linkHost == null || linkHost == placeholderLinkHost -> add(
            "fieldnote.linkHost is not set. Set it to the production web host that serves " +
                "/.well-known/assetlinks.json (host name only, no scheme or path).",
        )
        linkHost.contains("://") || linkHost.contains("/") -> add(
            "fieldnote.linkHost '$linkHost' must be a bare host name (no scheme or path).",
        )
    }
}

val validateFieldnoteRelease = tasks.register("validateFieldnoteRelease") {
    group = "verification"
    description = "Fails release builds that lack a real application ID, signing key or link host."
    val problems = fieldnoteReleaseProblems
    doLast {
        if (problems.isNotEmpty()) {
            throw GradleException(
                "FieldNote release configuration is incomplete:\n - " +
                    problems.joinToString("\n - "),
            )
        }
    }
}

tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    dependsOn(validateFieldnoteRelease)
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
