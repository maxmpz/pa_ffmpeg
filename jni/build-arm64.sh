#!/bin/bash

ANDROID_NDK=/opt/android-ndk-r20

echo Using ANDROID_NDK=$ANDROID_NDK

$ANDROID_NDK/ndk-build -j16 APP_ABI=arm64-v8a PA_GLOBAL_ARCH_MODE=arm64 $*
