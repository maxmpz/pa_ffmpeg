#!/bin/bash

#ANDROID_NDK=/opt/android-ndk-r20
#export ANDROID_NDK=/opt/android-ndk-r17c
#export ANDROID_NDK=/opt/android-ndk-r11c
#export ANDROID_NDK=/Users/maksimpetrov/Library/Android/sdk/ndk/20.1.5948944
#export ANDROID_NDK=/Users/maksimpetrov/Library/Android/sdk/ndk/21.4.7075529/
#export ANDROID_NDK=/Users/maksimpetrov/Library/Android/sdk/ndk/22.1.7171670
export ANDROID_NDK=/Users/maksimpetrov/Library/Android/sdk/ndk/23.0.7599858

echo Using ANDROID_NDK=$ANDROID_NDK

PARAMS="PA_NDK_VERSION_MAJOR=23 PA_GLOBAL_FLTO=full PA_UNIFIED_BUILD=true APP_ABI=armeabi-v7a PA_GLOBAL_ARCH_MODE=arm32"

#$ANDROID_NDK/ndk-build clean $PARAMS
$ANDROID_NDK/ndk-build -j16 $PARAMS  $*
