#!/bin/bash

#export ANDROID_NDK=/opt/android-ndk-r21d # Use for ASAN
export ANDROID_NDK=/opt/android-ndk-r20 # Use for ASAN
#export ANDROID_NDK=/opt/android-ndk-r17c # Use normally

echo Using ANDROID_NDK=$ANDROID_NDK
# --output-sync=none 
$ANDROID_NDK/ndk-build -j16 APP_ABI=arm64-v8a ASAN=1 $*
