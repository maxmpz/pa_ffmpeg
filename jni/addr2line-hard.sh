#!/bin/bash

echo Using ANDROID_NDK=$ANDROID_NDK

$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-addr2line -e ../obj/local/armeabi-v7a-hard/libffmpeg_neon.so -a $*

