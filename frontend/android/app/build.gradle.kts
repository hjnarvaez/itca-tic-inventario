import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeystorePropertiesFile = rootProject.file("key.properties")
val releaseKeystoreProperties = Properties().apply {
    if (releaseKeystorePropertiesFile.isFile) {
        releaseKeystorePropertiesFile.inputStream().use(::load)
    }
}
val releaseSigningPropertyNames =
    listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val releaseSigningConfigured =
    releaseSigningPropertyNames.all {
        !releaseKeystoreProperties.getProperty(it).isNullOrBlank()
    }
val releasePackagingRequested =
    gradle.startParameter.taskNames.any { taskName ->
        val normalizedTaskName = taskName.lowercase()
        normalizedTaskName.contains("release") &&
            listOf("assemble", "bundle", "package").any(normalizedTaskName::contains)
    }

if (releasePackagingRequested && !releaseSigningConfigured) {
    throw GradleException(
        "La firma release requiere key.properties con storeFile, storePassword, " +
            "keyAlias y keyPassword. No se usará la firma debug.",
    )
}

if (releasePackagingRequested && releaseSigningConfigured) {
    val releaseKeystoreFile =
        rootProject.file(releaseKeystoreProperties.getProperty("storeFile"))
    if (!releaseKeystoreFile.isFile) {
        throw GradleException("El keystore release configurado no existe.")
    }
}

android {
    namespace = "ec.edu.itca.itca_tic_inventario"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "ec.edu.itca.itca_tic_inventario"
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
        if (releaseSigningConfigured) {
            create("release") {
                storeFile =
                    rootProject.file(releaseKeystoreProperties.getProperty("storeFile"))
                storePassword = releaseKeystoreProperties.getProperty("storePassword")
                keyAlias = releaseKeystoreProperties.getProperty("keyAlias")
                keyPassword = releaseKeystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            if (releaseSigningConfigured) {
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
