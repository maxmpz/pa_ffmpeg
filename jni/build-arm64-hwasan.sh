#!/bin/bash

export ANDROID_NDK=/opt/android-ndk-r21d

echo Using ANDROID_NDK=$ANDROID_NDK

$ANDROID_NDK/ndk-build -j16 --output-sync=none APP_ABI=arm64-v8a PA_GLOBAL_ARCH_MODE=arm64 ASAN=1 $*
