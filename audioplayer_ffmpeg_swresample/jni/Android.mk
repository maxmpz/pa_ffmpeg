# New FFMPEG-swresample
# TODO: REVISIT: somehow share ffmpeg project's android.mk/av.mk?

LOCAL_PATH := $(call my-dir)

AUDIOPLAYER_FFMPEG_ROOT := ../..
FFMPEG_ROOT := $(AUDIOPLAYER_FFMPEG_ROOT)/FFmpeg
FFMPEG_OVERRIDE_ROOT := $(AUDIOPLAYER_FFMPEG_ROOT)/jni

include $(AUDIOPLAYER_FFMPEG_ROOT)/jni/config-pamp.mak

GLOBAL_FLTO := false # NOTE: flto doesn't work with ffmpeg properly (28-05-2014, gcc 4.9/NDK 10e)

GLOBAL_APPLY_FFMPEG_OPTS := true

GLOBAL_CFLAGS := -std=c99 -ffast-math -fstrict-aliasing -Werror=strict-aliasing #-mfix-cortex-a53-835769 -mfix-cortex-a53-843419 -mstrict-align
GLOBAL_CFLAGS += -DHAVE_AV_CONFIG_H

ifeq ($(GLOBAL_APPLY_FFMPEG_OPTS),true)
GLOBAL_CFLAGS += -DPAMP_CONFIG_NO_VIDEO=1  -DPAMP_CONFIG_FLOAT_ONLY_RESAMPLER=1 -DPAMP_CHANGES=1 -DPAMP_CONFIG_NO_TAGS=1
# NOTE: don't expose any paths to .so 
GLOBAL_CFLAGS += -D__FILE__=\"\" -Wno-builtin-macro-redefined
else
$(warning no GLOBAL_APPLY_FFMPEG_OPTS)
endif

# REVISIT:-mno-unaligned-access  - probably not needed

# NOTE: there is GLOBAL_TARGET_ARCH_NAME (armeabi-v7a/arm64-v8a), TARGET_ARCH (arm/arm64), and ARCH (arm/aarch64) + GLOBAL_ARCH_MODE(neon/arm64)

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
	# -fopt-info-vec-missed  
	# NOTE: gcc seems to be better for arm64 + disabled arm64 asm opts for resampler
	GLOBAL_CFLAGS += -march=armv8-a+simd -Ofast -D_NDK_MATH_NO_SOFTFP=1 -DPAMP_DISABLE_NEON_ASM  
	GLOBAL_TARGET_ARCH_NAME := arm64-v8a
	GLOBAL_CFLAGS += -DHAVE_ARMV8=1 -DHAVE_NEON=1 -ftree-vectorize
	
	ifeq ($(NDK_TOOLCHAIN_VERSION),clang3.6)
		GLOBAL_CFLAGS += -fno-integrated-as # Needed to compile aarch64 S in clang mode, but not needed for gcc
	endif
	
else ifeq ($(TARGET_ARCH_ABI),armeabi-v7a-hard) # HARD
	GLOBAL_CFLAGS += -march=armv7-a -mtune=cortex-a9 -mno-thumb-interwork -Ofast -mfloat-abi=hard -mhard-float -D_NDK_MATH_NO_SOFTFP=1
	GLOBAL_TARGET_ARCH_NAME := armeabi-v7a
	GLOBAL_CFLAGS += -mfpu=neon -DHAVE_NEON=1 #-ftree-vectorize -mvectorize-with-neon-quad
endif


ifeq ($(NDK_APP_DEBUGGABLE),true)
$(warning NDK_APP_DEBUGGABLE for $(DIR_NAME))		
	GLOBAL_CFLAGS += -O0 
else
	GLOBAL_CFLAGS += -ffunction-sections -fdata-sections #-fvisibility=hidden 
endif

GLOBAL_TARGET_ARCH_NAME := $(strip $(GLOBAL_TARGET_ARCH_NAME))
FF_TARGET_ARCH := $(strip $(FF_TARGET_ARCH))


# =================================================
include $(CLEAR_VARS)
# NOTE: see av.mk for modules flags

include $(call all-makefiles-under,$(LOCAL_PATH))

