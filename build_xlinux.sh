#!/bin/bash
set -e

mkdir -p /data/data/com.termux/files/usr/opt/android-sdk
cd /data/data/com.termux/files/usr/opt/android-sdk

curl -O https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip -o commandlinetools-linux-11076708_latest.zip
mkdir -p cmdline-tools/latest
mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true

export ANDROID_HOME=/data/data/com.termux/files/usr/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

sdkmanager --install "platform-tools" "platforms;android-34" "build-tools;34.0.0"

cd /data/data/com.termux/files/home/XLinuxTerminal
export ANDROID_HOME=/data/data/com.termux/files/usr/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0

gradle assembleRelease --no-daemon
