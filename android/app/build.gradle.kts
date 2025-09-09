import com.android.build.gradle.internal.dsl.BaseAppModuleExtension
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    id("com.android.application")
    id("kotlin-android")

    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.chirp"
    //compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        //sourceCompatibility = JavaVersion.VERSION_11
        //targetCompatibility = JavaVersion.VERSION_11
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        //new
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        //jvmTarget = JavaVersion.VERSION_11.toString()
        jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.chirp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        //minSdk = flutter.minSdkVersion
        //minSdk = 23
        minSdk = 23
        //targetSdk = flutter.targetSdkVersion
        targetSdk = 34
        //versionCode = flutter.versionCode
        versionCode = 1
        //versionName = flutter.versionName
        versionName = "1.0"
        //new
        multiDexEnabled = true
    }

    //buildTypes {
        //release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            //signingConfig = signingConfigs.getByName("debug")
        //}
    //}

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}



dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    //new: all below
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}