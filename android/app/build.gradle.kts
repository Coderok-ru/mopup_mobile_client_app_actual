plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.coderok.mopup"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.coderok.mopup"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = maxOf(flutter.minSdkVersion, 26)
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.yandex.android:maps.mobile:4.6.1-full")
}

// Удаляем регистрацию flutter_native_splash из GeneratedPluginRegistrant.java
// так как это dev tool, а не runtime плагин
tasks.register("fixGeneratedPluginRegistrant") {
    doLast {
        val registrantFile = file("src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java")
        if (registrantFile.exists()) {
            var content = registrantFile.readText()
            // Удаляем блок регистрации flutter_native_splash используя регулярное выражение
            val pattern = Regex(
                """\s+try\s+\{[^}]*flutterEngine\.getPlugins\(\)\.add\(new net\.jonhanson\.flutter_native_splash\.FlutterNativeSplashPlugin\(\)\);[^}]*\}\s+catch\s+\(Exception\s+e\)\s+\{[^}]*Log\.e\(TAG,\s+"Error registering plugin flutter_native_splash[^"]*",\s+e\);[^}]*\}\s*""",
                RegexOption.DOT_MATCHES_ALL
            )
            content = content.replace(pattern, "")
            registrantFile.writeText(content)
        }
    }
}

// Запускаем исправление перед компиляцией Java
afterEvaluate {
    tasks.named("compileDebugJavaWithJavac").configure {
        dependsOn("fixGeneratedPluginRegistrant")
    }
    tasks.named("compileReleaseJavaWithJavac").configure {
        dependsOn("fixGeneratedPluginRegistrant")
    }
}
