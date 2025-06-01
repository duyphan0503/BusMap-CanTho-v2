import org.gradle.api.GradleException
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "dz.duyphan.busmapcantho"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "dz.duyphan.busmapcantho"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("io.github.jan-tennert.supabase:gotrue-kt:2.6.1")
    implementation("io.github.jan-tennert.supabase:postgrest-kt:3.1.4")
    implementation("io.github.jan-tennert.supabase:realtime-kt:3.1.4")
    implementation("io.github.jan-tennert.supabase:storage-kt:3.1.4")
    implementation("io.github.jan-tennert.supabase:functions-kt:3.1.4")

    implementation("io.ktor:ktor-client-okhttp:3.1.2")
    implementation("io.ktor:ktor-client-content-negotiation:3.1.2")
    implementation("io.ktor:ktor-serialization-kotlinx-json:3.1.2")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
