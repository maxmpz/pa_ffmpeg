#!/bin/bash

NDK_PATH=/opt/android-ndk-r10e

echo Using NDK_PATH=$NDK_PATH

$NDK_PATH/ndk-build APP_ABI=arm64-v8a GLOBAL_ARCH_MODE=arm64 $*

