#!/bin/bash

NDK_PATH=/opt/android-ndk-r10e

echo Using ANDROID_NDK=$ANDROID_NDK

$ANDROID_NDK/ndk-build -j12 APP_ABI=armeabi-v7a-hard GLOBAL_ARCH_MODE=neon $*

