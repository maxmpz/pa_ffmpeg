# New FFMPEG-swresample
# TODO: REVISIT: somehow share ffmpeg project's android.mk/av.mk?
$(info Using TOOLCHAIN_NAME=$(TOOLCHAIN_NAME))
$(info TARGET_ARCH_ABI=$(TARGET_ARCH_ABI))

LOCAL_PATH := $(call my-dir)

AUDIOPLAYER_FFMPEG_ROOT := ../..
FFMPEG_ROOT := $(AUDIOPLAYER_FFMPEG_ROOT)/FFmpeg
FFMPEG_OVERRIDE_ROOT := $(AUDIOPLAYER_FFMPEG_ROOT)/jni

include $(AUDIOPLAYER_FFMPEG_ROOT)/jni/config-pamp.mak

# NOTE: disabled for hard or gcc
PA_GLOBAL_FLTO := false

PA_GLOBAL_APPLY_FFMPEG_OPTS := true

PA_GLOBAL_CFLAGS := -std=c99 -ffast-math -fstrict-aliasing -Werror=strict-aliasing
PA_GLOBAL_CFLAGS += -DHAVE_AV_CONFIG_H

ifeq ($(strip $(PA_GLOBAL_APPLY_FFMPEG_OPTS)),true)
PA_GLOBAL_CFLAGS += -DPAMP_CONFIG_NO_VIDEO=1  -DPAMP_CONFIG_FLOAT_ONLY_RESAMPLER=1 -DPAMP_CHANGES=1 -DPAMP_CONFIG_NO_TAGS=1 -DPAMP_OPTIMIZE_MACROS=1
# NOTE: don't expose any paths to .so 
PA_GLOBAL_CFLAGS += -D__FILE__=\"\" -Wno-builtin-macro-redefined
else
$(warning no PA_GLOBAL_APPLY_FFMPEG_OPTS)
endif

# REVISIT:-mno-unaligned-access  - probably not needed

# NOTE: there is PA_GLOBAL_TARGET_ARCH_NAME (armeabi-v7a/arm64-v8a), TARGET_ARCH (arm/arm64), and ARCH (arm/aarch64)

# NOTE: try to use specific optimization opts in per sub-dir Android.mk level, as they can be very different

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
	# -fopt-info-vec-missed  
	# NOTE: gcc seems to be better for arm64 + disabled arm64 asm opts for resampler
	PA_GLOBAL_CFLAGS += -DPAMP_DISABLE_NEON_ASM  
	PA_GLOBAL_CFLAGS += -march=armv8-a+simd 
	PA_GLOBAL_CFLAGS += -DHAVE_ARMV8=1 -DHAVE_NEON=1 -ftree-vectorize -fvectorize
	
else ifneq (,$(findstring armeabi-v7a,$(TARGET_ARCH_ABI)))
	PA_GLOBAL_CFLAGS += -march=armv7-a -marm 
	PA_GLOBAL_CFLAGS += -mtune=cortex-a53
	PA_GLOBAL_CFLAGS += -mfpu=neon -DHAVE_NEON=1  
	PA_GLOBAL_CFLAGS += -fno-stack-protector

	ifneq (,$(findstring -hard,$(TARGET_ARCH_ABI)))
$(info Hard-floats)
		PA_GLOBAL_CFLAGS += -mfloat-abi=hard -mhard-float -D_NDK_MATH_NO_SOFTFP=1 # NOTE: also used in config-pamp.h - to define HAVE_VFP_ARGS
		PA_GLOBAL_FLTO := false
	else
		PA_GLOBAL_CFLAGS += -mfloat-abi=softfp
	endif
	
	ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION))) # clang
	else # gcc
		PA_GLOBAL_FLTO := false
		PA_GLOBAL_CFLAGS += -mno-thumb-interwork
	endif
endif
 
ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION)))
	PA_GLOBAL_CFLAGS += -fno-integrated-as
	PA_GLOBAL_CFLAGS += -Wno-logical-op-parentheses -Wno-switch
endif

ifneq (,$(ASAN)) 
$(info ASAN build ==============================================)
	PA_GLOBAL_CFLAGS += -fsanitize=address -fno-omit-frame-pointer 
	PA_GLOBAL_LDFLAGS += -fsanitize=address
endif


ifeq ($(strip $(PA_GLOBAL_FLTO)),true)
	PA_GLOBAL_CFLAGS += -flto
endif

ifeq ($(NDK_APP_DEBUGGABLE),true)
$(info NDK_APP_DEBUGGABLE for $(DIR_NAME))		
	PA_GLOBAL_CFLAGS += -Og -g
else
	PA_GLOBAL_CFLAGS += -ffunction-sections -fdata-sections 
endif

PA_NDK_VER := $(subst /opt/android-ndk-,,$(ANDROID_NDK))
PA_GLOBAL_CFLAGS += -DPAMP_FFMPEG_CONFIGURATION='"$(PA_NDK_VER) $(TARGET_ARCH_ABI) lto=$(PA_GLOBAL_FLTO) $(NDK_TOOLCHAIN_VERSION)"'


PA_GLOBAL_TARGET_ARCH_NAME := $(subst -hard,,$(TARGET_ARCH_ABI))
FF_TARGET_ARCH := $(strip $(FF_TARGET_ARCH))


# =================================================
include $(CLEAR_VARS)
# NOTE: see av.mk for modules flags

include $(call all-makefiles-under,$(LOCAL_PATH))

