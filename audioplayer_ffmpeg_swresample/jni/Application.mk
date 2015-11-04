# This doesn't properly work due to FFMPEG config variables conflicts. Use separate "ndk-build APP_ABI=armeabi" and "ndk-build APP_ABI=armeabi-v7a".
#APP_ABI := armeabi-v7a armeabi

APP_OPTIM := release

APP_DEBUGGABLE := false

APP_MODULES := libsoxr libswresample # NOTE: this forces static lib build

NDK_TOOLCHAIN_VERSION := clang3.6
#NDK_TOOLCHAIN_VERSION := 4.9
#NDK_TOOLCHAIN_VERSION := 4.8

