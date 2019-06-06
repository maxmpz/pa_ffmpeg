#!/bin/sh

FFMPEG_PATH=../FFmpeg

echo Using ANDROID_NDK=$ANDROID_NDK

NM=$ANDROID_NDK/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64/bin/aarch64-linux-android-nm
echo $NM

$NM -D --size-sort --print-size ../libs/arm64-v8a/libffmpeg_neon.so

