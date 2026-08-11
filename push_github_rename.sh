#!/bin/bash
set -e

cd /data/data/com.termux/files/home/XLinuxTerminal

git init
git add .
git commit -m "Initial commit"

BRANCH=$(git branch --show-current)
if [ "$BRANCH" != "main" ]; then
    git branch -M main
fi

git remote add origin https://github.com/XingOfficial/XLinuxTerminal.git
git push -u origin main

mkdir -p .github/workflows
cat > .github/workflows/build.yml << 'YEOF'
name: Build APK
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
    - name: Grant execute permission for gradlew
      run: chmod +x gradlew
    - name: Build with Gradle
      run: ./gradlew assembleRelease
    - name: Rename APK with version and date
      run: |
        VERSION=$(grep versionName app/build.gradle.kts | sed 's/.*"\(.*\)".*/\1/')
        DATE=$(date +%Y%m%d_%H%M%S)
        mkdir -p app/build/outputs/apk/release/renamed
        for f in app/build/outputs/apk/release/*.apk; do
          cp "$f" "app/build/outputs/apk/release/renamed/XLinuxTerminal_v${VERSION}_${DATE}.apk"
        done
    - name: Upload APK
      uses: actions/upload-artifact@v4
      with:
        name: XLinuxTerminal-APK
        path: app/build/outputs/apk/release/renamed/*.apk
YEOF

cat > app/build.gradle.kts << 'BEOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "cn.xing.terminal.xerminal"
    compileSdk = 34

    defaultConfig {
        applicationId = "cn.xing.terminal.xerminal"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
}
BEOF

cat > gradle/wrapper/gradle-wrapper.properties << 'GEOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
GEOF

git add .
git commit -m "Add GitHub Actions CI"
git push
