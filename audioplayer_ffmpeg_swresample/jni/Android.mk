# New FFMPEG-swresample
# TODO: REVISIT: somehow share ffmpeg project's android.mk/av.mk?

LOCAL_PATH := $(call my-dir)

AUDIOPLAYER_FFMPEG_ROOT := ../..
FFMPEG_ROOT := $(AUDIOPLAYER_FFMPEG_ROOT)/FFmpeg

include $(AUDIOPLAYER_FFMPEG_ROOT)/jni/config-pamp.mak

GLOBAL_FLTO := false # NOTE: flto doesn't work with ffmpeg properly (28-05-2014, gcc 4.9/NDK 10e) 

GLOBAL_CFLAGS := -std=c99 -ffast-math -fstrict-aliasing -Werror=strict-aliasing
GLOBAL_CFLAGS += -DHAVE_AV_CONFIG_H -DPAMP_CONFIG_FLOAT_ONLY_RESAMPLER=1

# REVISIT:-mno-unaligned-access  - probably not needed

# NOTE: there is GLOBAL_TARGET_ARCH_NAME (armeabi-v7a/arm64-v8a), TARGET_ARCH (arm/arm64), and ARCH (arm/aarch64) + GLOBAL_ARCH_MODE(neon/arm64)

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
	GLOBAL_CFLAGS += -march=armv8-a+simd -Ofast -D_NDK_MATH_NO_SOFTFP=1 -fno-integrated-as # Needed to compile aarch64 S in clang mode 
	GLOBAL_TARGET_ARCH_NAME := arm64-v8a
	
else ifeq ($(TARGET_ARCH_ABI),armeabi-v7a-hard) # HARD
	GLOBAL_CFLAGS += -march=armv7-a -mtune=cortex-a9 -mno-thumb-interwork -Ofast -mfloat-abi=hard -mhard-float -D_NDK_MATH_NO_SOFTFP=1
	GLOBAL_TARGET_ARCH_NAME := armeabi-v7a
	
else ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
	GLOBAL_CFLAGS += -march=armv7-a -mcpu=cortex-a9 -mno-thumb-interwork -mfloat-abi=softfp
	GLOBAL_TARGET_ARCH_NAME := armeabi-v7a
endif

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
	GLOBAL_CFLAGS += -DHAVE_ARMV8=1 -DHAVE_NEON=1 #-ftree-vectorize -mvectorize-with-neon-quad
else ifeq ($(GLOBAL_ARCH_MODE),neon)	
	GLOBAL_CFLAGS += -mfpu=neon -DHAVE_NEON=1 #-ftree-vectorize -mvectorize-with-neon-quad
else ifeq ($(GLOBAL_ARCH_MODE),x86) # =====
$(error TODO)
else
$(error Unknwon GLOBAL_ARCH_MODE) 	
endif # ==========

ifeq ($(NDK_APP_DEBUGGABLE),true)
$(warning NDK_APP_DEBUGGABLE for $(DIR_NAME))		
	GLOBAL_CFLAGS += -O0 
else
	GLOBAL_CFLAGS += -ffunction-sections -fdata-sections #-fvisibility=hidden 
endif

GLOBAL_TARGET_ARCH_NAME := $(strip $(GLOBAL_TARGET_ARCH_NAME))
FF_TARGET_ARCH := $(strip $(FF_TARGET_ARCH))

# MaxMP: redefine this macro to avoid inclusion of the project dir as headers dir - this breaks ffmpeg build.
define  ev-compile-c-source
_SRC:=$$(LOCAL_PATH)/$(1)
_OBJ:=$$(LOCAL_OBJS_DIR)/$(2)

_FLAGS := $$($$(my)CFLAGS) \
          $$(call get-src-file-target-cflags,$(1)) \
          $$(call host-c-includes,$$(LOCAL_C_INCLUDES)) \
          $$(LOCAL_CFLAGS) \
          $$(NDK_APP_CFLAGS) \
          $$(call host-c-includes,$$($(my)C_INCLUDES)) \
          -c \

_TEXT := "Compile $$(call get-src-file-text,$1)"
_CC   := $$(NDK_CCACHE) $$(TARGET_CC)

$$(eval $$(call ev-build-source-file))
endef

# =================================================
include $(CLEAR_VARS)
# NOTE: see av.mk for modules flags

include $(call all-makefiles-under,$(LOCAL_PATH))

