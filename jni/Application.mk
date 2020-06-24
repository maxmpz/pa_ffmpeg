# This doesn't properly work due to FFMPEG config variables conflicts. Use separate "ndk-build APP_ABI=armeabi" and "ndk-build APP_ABI=armeabi-v7a".
#APP_ABI := armeabi-v7a armeabi

APP_OPTIM := release

APP_PLATFORM := android-21

ifeq ($(APP_ABI),arm64-v8a)
	NDK_TOOLCHAIN_VERSION := clang
	
else
	ifneq (,$(findstring -r2,$(ANDROID_NDK)))
		# ndk-r20
		NDK_TOOLCHAIN_VERSION := clang
	else
		NDK_TOOLCHAIN_VERSION := 4.9
	endif
endif

ifneq (,$(ASAN)) # ASAN build
$(info APP ASAN build)
	APP_DEBUGGABLE := true # Old ndks
	APP_DEBUG := true # r20
endif

# Disable cleaning everything in /libs as we need previous/other lib
NDK_APP.local.cleaned_binaries := true
