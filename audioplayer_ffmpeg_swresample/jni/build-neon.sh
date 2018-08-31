#!/bin/bash

NDK_PATH=/opt/android-ndk-r10e

echo Using NDK_PATH=$NDK_PATH

$NDK_PATH/ndk-build APP_ABI=armeabi-v7a-hard GLOBAL_ARCH_MODE=neon $*

