plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rsislam.surabaya.rs_islam_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.rsislam.surabaya.rs_islam_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Unity's unityLibrary requires minSdk 29 (T4.4); manifest merge needs the app
        // to be >= the library. Override Flutter's lower default.
        minSdk = maxOf(29, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Unity only built native libs for arm64-v8a — restrict the app to match, else
        // other ABIs fail to package. Real AR devices are arm64 anyway.
        ndk {
            abiFilters += "arm64-v8a"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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

dependencies {
    // Unity as a Library — the DARSI AR module. Launched full-screen via MainActivity
    // MethodChannel (T4.4).
    implementation(project(":unityLibrary"))
    // DarsiUnityActivity subclasses UnityPlayerGameActivity (T4.5); its supertypes are
    // hidden behind unityLibrary's `implementation` deps, so surface them to the app:
    //  - GameActivity (androidx.games:games-activity)
    //  - Unity player interfaces (IUnityPlayerLifecycleEvents, ...) live in unity-classes.jar,
    //    already packaged by unityLibrary at runtime → compileOnly here.
    implementation("androidx.games:games-activity:4.4.0")
    implementation("androidx.appcompat:appcompat:1.5.1") // GameActivity -> AppCompatActivity
    compileOnly(files("../unityLibrary/libs/unity-classes.jar"))
}
