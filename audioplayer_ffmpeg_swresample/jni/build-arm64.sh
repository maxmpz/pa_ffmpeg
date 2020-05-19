#!/bin/bash

#ANDROID_NDK=/opt/android-ndk-r20
export ANDROID_NDK=/opt/android-ndk-r17c

echo Using ANDROID_NDK=$ANDROID_NDK

$ANDROID_NDK/ndk-build -j16 APP_ABI=arm64-v8a $*
