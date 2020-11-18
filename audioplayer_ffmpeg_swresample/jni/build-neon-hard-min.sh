#!/bin/bash

export ANDROID_NDK=/opt/android-ndk-r11c

echo Using ANDROID_NDK=$ANDROID_NDK

$ANDROID_NDK/ndk-build -j8 APP_ABI=armeabi-v7a-hard $*


