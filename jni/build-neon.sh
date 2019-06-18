#!/bin/bash

#ANDROID_NDK=/opt/android-ndk-r11c
#ANDROID_NDK=/opt/android-ndk-r17c
ANDROID_NDK=/opt/android-ndk-r20

echo Using ANDROID_NDK=$ANDROID_NDK

$ANDROID_NDK/ndk-build -j16 APP_ABI=armeabi-v7a $*
