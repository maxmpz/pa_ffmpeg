#!/bin/bash

echo Using ANDROID_NDK=$ANDROID_NDK

$ANDROID_NDK/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64/bin/aarch64-linux-android-addr2line -e ../obj/local/arm64-v8a/libffmpeg_neon.so -a $*

