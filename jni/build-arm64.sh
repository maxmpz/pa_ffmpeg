#!/bin/bash

export ANDROID_NDK=/opt/android-ndk-r20
#export ANDROID_NDK=/opt/android-ndk-r21d

echo Using ANDROID_NDK=$ANDROID_NDK

# --output-sync=none for r21
$ANDROID_NDK/ndk-build -j16 APP_ABI=arm64-v8a PA_GLOBAL_ARCH_MODE=arm64 $*
