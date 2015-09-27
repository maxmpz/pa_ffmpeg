#!/bin/bash

echo Using ANDROID_NDK=$ANDROID_NDK

$ANDROID_NDK/ndk-build APP_ABI=armeabi-v7a-hard GLOBAL_ARCH_MODE=neon $*

