#!/bin/bash

#ANDROID_NDK=/opt/android-ndk-r20
#ANDROID_NDK=/opt/android-ndk-r17c
export ANDROID_NDK=/opt/android-ndk-r11c

echo Using ANDROID_NDK=$ANDROID_NDK

$ANDROID_NDK/ndk-build -j16 APP_ABI=armeabi-v7a-hard PA_MIN_MODE=1 $*
