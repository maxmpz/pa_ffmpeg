#!/bin/bash

#ANDROID_NDK=/opt/android-ndk-r20
#ANDROID_NDK=/opt/android-ndk-r17c
export ANDROID_NDK=/opt/android-ndk-r11c

echo Using ANDROID_NDK=$ANDROID_NDK

PARAMS="PA_NDK_VERSION_MAJOR=11 PA_GLOBAL_FLTO=false PA_UNIFIED_BUILD=true APP_ABI=armeabi-v7a-hard PA_GLOBAL_ARCH_MODE=arm32"

#$ANDROID_NDK/ndk-build clean $PARAMS
$ANDROID_NDK/ndk-build -j16 $PARAMS  $*
