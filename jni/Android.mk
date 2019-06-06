# FFMPEG
# NOTE: we build target (lib*) folders only if Android.mk is there and not disabled

LOCAL_PATH := $(call my-dir)
GLOBAL_PATH := $(call my-dir)

USE_VERSION := #yes # Enables build.version based versioning. Ffmpeg requires this to be in sync

FFMPEG_ROOT := ../FFmpeg
FFMPEG_OVERRIDE_ROOT := $(LOCAL_PATH) # This dir, basically

include $(LOCAL_PATH)/config-pamp.mak

GLOBAL_FLTO := false # NOTE: flto doesn't work with ffmpeg properly (28-05-2014, gcc 4.9/NDK 10e)

GLOBAL_APPLY_FFMPEG_OPTS := true

GLOBAL_CFLAGS := -std=c99 -ffast-math -fstrict-aliasing -Werror=strict-aliasing -Os #-mfix-cortex-a53-835769 -mfix-cortex-a53-843419 -mstrict-align 
# NOTE: these are needed just for ffmpeg compilation - shouldn't be replicated to any other code   
# Also, PAMP_* there shouldn't be used in (outside accessible) headers
GLOBAL_CFLAGS += -DHAVE_AV_CONFIG_H 
# NOTE: don't expose any paths to .so 

#NOTE: disables inclusion of termbits.h, which defines macros like B0, which conflict with FFmpeg code
GLOBAL_CFLAGS += -D__ASM_GENERIC_TERMBITS_H

ifeq ($(GLOBAL_APPLY_FFMPEG_OPTS),true)
GLOBAL_CFLAGS += -DPAMP_CONFIG_NO_VIDEO=1  -DPAMP_CONFIG_FLOAT_ONLY_RESAMPLER=1 -DPAMP_CHANGES=1 -DPAMP_CONFIG_NO_TAGS=1
GLOBAL_CFLAGS += -D__FILE__=\"\" -Wno-builtin-macro-redefined
else
$(warning no GLOBAL_APPLY_FFMPEG_OPTS)
endif

#GLOBAL_CFLAGS += -fprofile-generate=/sdcard/profile # NOTE: doesn't give anything in terms of perf.
#GLOBAL_CFLAGS += -fprofile-use=../../profile -fprofile-correction

# REVISIT:-mno-unaligned-access  - probably not needed

audioplayer_PATH := $(abspath $(LOCAL_PATH)/../../audioplayer/)

ifeq ($(USE_VERSION),yes)
include $(audioplayer_PATH)/build.num # build.number=xxx => $(build.number)
endif

# NOTE: there is GLOBAL_TARGET_ARCH_NAME (armeabi-v7a/arm64-v8a), TARGET_ARCH (arm/arm64), and ARCH (arm/aarch64) + GLOBAL_ARCH_MODE(neon/arm64)

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
	GLOBAL_CFLAGS += -march=armv8-a+simd #-D_NDK_MATH_NO_SOFTFP=1
	GLOBAL_CFLAGS += -DHAVE_ARMV8=1 -DHAVE_NEON=1
	GLOBAL_TARGET_ARCH_NAME := arm64-v8a 
	
else ifeq ($(TARGET_ARCH_ABI),armeabi-v7a-hard) # HARD
	GLOBAL_CFLAGS += -march=armv7-a -mtune=cortex-a9 -mno-thumb-interwork -mfloat-abi=hard -mhard-float -D_NDK_MATH_NO_SOFTFP=1 
	GLOBAL_CFLAGS += -mfpu=neon -DHAVE_NEON=1  #-ftree-vectorize -mvectorize-with-neon-quad #NOTE: neon-vfpv4 doesn't seem to give anything for gcc 4.9/r10e
	GLOBAL_TARGET_ARCH_NAME := armeabi-v7a
	 
endif

ifeq ($(GLOBAL_FLTO),true)
GLOBAL_CFLAGS += -flto
endif

ifeq ($(NDK_APP_DEBUGGABLE),true)
$(warning NDK_APP_DEBUGGABLE for $(DIR_NAME))		
	GLOBAL_CFLAGS += -Og 
else
	GLOBAL_CFLAGS += -ffunction-sections -fdata-sections #-fvisibility=hidden 
endif

GLOBAL_TARGET_ARCH_NAME := $(strip $(GLOBAL_TARGET_ARCH_NAME))
GLOBAL_LDFLAGS := $(GLOBAL_CFLAGS) 


# MaxMP: redefine this macro to avoid inclusion of the project dir as headers dir - this breaks ffmpeg build.
#define  ev-compile-c-source
#_SRC:=$$(LOCAL_PATH)/$(1)
#_OBJ:=$$(LOCAL_OBJS_DIR)/$(2)
#
#_FLAGS := $$($$(my)CFLAGS) \
#          $$(call get-src-file-target-cflags,$(1)) \
#          $$(call host-c-includes,$$(LOCAL_C_INCLUDES)) \
#          $$(LOCAL_CFLAGS) \
#          $$(NDK_APP_CFLAGS) \
#          $$(call host-c-includes,$$($(my)C_INCLUDES)) \
#          -c \
#
#_TEXT := "Compile $$(call get-src-file-text,$1)"
#_CC   := $$(NDK_CCACHE) $$(TARGET_CC)
#
#$$(eval $$(call ev-build-source-file))
#endef

# ============================================ Link swresample
include $(CLEAR_VARS)
LOCAL_MODULE := libswresample-prebuilt
LOCAL_SRC_FILES := $(abspath $(LOCAL_PATH)/../audioplayer_ffmpeg_swresample/obj/local/$(TARGET_ARCH_ABI)/libswresample.a)

include $(PREBUILT_STATIC_LIBRARY)

# ============================================ Link swresample/soxr
include $(CLEAR_VARS)
LOCAL_MODULE := libsoxr-prebuilt
LOCAL_SRC_FILES := $(abspath $(LOCAL_PATH)/../audioplayer_ffmpeg_swresample/obj/local/$(TARGET_ARCH_ABI)/libsoxr.a)

include $(PREBUILT_STATIC_LIBRARY)

# ============================================== 

include $(CLEAR_VARS)
LOCAL_ARM_MODE := arm
 
LOCAL_LDLIBS += -llog -lz 

#LOCAL_STATIC_LIBRARIES := libavformat libavcodec libavutil libswresample #libjni #libopus # libtta libopencore_amr

LOCAL_WHOLE_STATIC_LIBRARIES := libavformat libavutil libsoxr-prebuilt libswresample-prebuilt libavcodec #libtta #libjni NOTE: libswresample has Android.mk.disabled

ifeq ($(USE_VERSION),yes)
LOCAL_MODULE := libffmpeg_neon.$(build.number)
else
# REVISIT: drop _neon. For now using this as it's used everywhere
LOCAL_MODULE := libffmpeg_neon
endif 

#LOCAL_SHARED_LIBRARIES := libopus-prebuilt 


ifeq ($(NDK_APP_DEBUGGABLE),true)
$(warning NO_STRIP SO)		
cmd-strip = echo
else
#$(warning NO_STRIP SO)
#cmd-strip = echo
LOCAL_LDFLAGS := $(GLOBAL_LDFLAGS) -Wl,--discard-all -Wl,--gc-sections -Wl,--version-script=version-script.txt #-Wl,-Map=moblox.map,--cref #-Wl,--print-gc-sections


ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
LOCAL_LDFLAGS += -Wl,--no-warn-mismatch -lm
LOCAL_LDLIBS += -lm 

else ifeq ($(TARGET_ARCH_ABI),armeabi-v7a-hard) # HARD
LOCAL_LDFLAGS += -Wl,--no-warn-mismatch -lm_hard
LOCAL_LDLIBS += -lm_hard 

endif 

cmd-strip = $(TOOLCHAIN_PREFIX)strip -g -S -d --strip-debug --strip-unneeded --discard-all -R .comment $1
endif

LIBS_CUSTOM_PATH := $(audioplayer_PATH)/libs/$(GLOBAL_TARGET_ARCH_NAME)

ifeq ($(USE_VERSION),yes)
PAMP_DST_BASE := $(LIBS_CUSTOM_PATH)/$(subst .$(build.number),,$(LOCAL_MODULE))
PAMP_DST := $(PAMP_DST_BASE).$(build.number).so
else
PAMP_DST_BASE := $(LIBS_CUSTOM_PATH)/$(LOCAL_MODULE)
PAMP_DST := $(PAMP_DST_BASE).so
endif

PAMP_DST_CLEAN := $(PAMP_DST_BASE).*

PAMP_SRC := $(abspath $(LOCAL_PATH)/../libs/$(GLOBAL_TARGET_ARCH_NAME)/$(LOCAL_MODULE).so)


pamp-install-custom: installed_modules
	@echo "Clean: $(PAMP_DST_CLEAN)"
	$(hide) rm -f $(PAMP_DST_CLEAN)
	@echo "Copy : $(PAMP_SRC) => $(PAMP_DST)"
	$(hide) cp $(PAMP_SRC) $(PAMP_DST) 
	
include $(BUILD_SHARED_LIBRARY)

#ALL_SHARED_LIBRARIES += pamp-install-custom
all: pamp-install-custom 


# =================================================
include $(CLEAR_VARS)
# NOTE: see av.mk for modules flags

include $(call all-makefiles-under,$(GLOBAL_PATH))

#include $(GLOBAL_PATH)/../audioplayer_ffmpeg_swresample/jni/Android.mk

