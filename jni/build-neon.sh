#!/bin/bash

echo Using ANDROID_NDK=$ANDROID_NDK

$ANDROID_NDK/ndk-build -j6 APP_ABI=armeabi-v7a-hard GLOBAL_ARCH_MODE=neon $*

