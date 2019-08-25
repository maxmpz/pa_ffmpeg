# FFMPEG
# NOTE: we build target (lib*) folders only if Android.mk is there and not disabled

$(info Using TOOLCHAIN_NAME=$(TOOLCHAIN_NAME))
$(info TARGET_ARCH_ABI=$(TARGET_ARCH_ABI))

LOCAL_PATH := $(call my-dir)
PA_GLOBAL_PATH := $(call my-dir)


USE_VERSION := #yes # Enables build.version based versioning. Ffmpeg requires this to be in sync

FFMPEG_ROOT := ../FFmpeg
FFMPEG_OVERRIDE_ROOT := $(LOCAL_PATH) # This dir, basically
mbedtls_PATH := $(abspath $(LOCAL_PATH)/../../mbedtls)


include $(LOCAL_PATH)/config-pamp.mak

# Seems to work (at least, compile) for ndk-11c gcc4.9, but it's slow to build
# Also, resulting build is slow and can be also larger vs usual one
# It's quite fast for clang ndk-r20
# NOTE: disabled for hard or gcc
PA_GLOBAL_FLTO := false
PA_GLOBAL_APPLY_FFMPEG_OPTS := true

PA_GLOBAL_CFLAGS := -std=c99 -ffast-math -fstrict-aliasing -Werror=strict-aliasing
PA_GLOBAL_CFLAGS += -Os # gcc
# NOTE: if we pass e.g. PA_GLOBAL_CFLAGS or -Os to PA_GLOBAL_LDFLAGS, it's applied to whole code, causing very slow ffmpeg
PA_GLOBAL_LDFLAGS := 

# NOTE: these are needed just for ffmpeg compilation - shouldn't be replicated to any other code   
# Also, PAMP_* there shouldn't be used in (outside accessible) headers
PA_GLOBAL_CFLAGS += -DHAVE_AV_CONFIG_H 

#NOTE: disables inclusion of termbits.h, which defines macros like B0, which conflict with FFmpeg code
PA_GLOBAL_CFLAGS += -D__ASM_GENERIC_TERMBITS_H

ifeq ($(strip $(PA_GLOBAL_APPLY_FFMPEG_OPTS)),true)
PA_GLOBAL_CFLAGS += -DPAMP_CONFIG_NO_VIDEO=1  -DPAMP_CONFIG_FLOAT_ONLY_RESAMPLER=1 -DPAMP_CHANGES=1 -DPAMP_CONFIG_NO_TAGS=1 -DPAMP_OPTIMIZE_MACROS=1
# NOTE: don't expose any paths to .so 
PA_GLOBAL_CFLAGS += -D__FILE__=\"\" -Wno-builtin-macro-redefined
else
$(warning no PA_GLOBAL_APPLY_FFMPEG_OPTS)
endif

#PA_GLOBAL_CFLAGS += -fprofile-generate=/sdcard/profile # NOTE: doesn't give anything in terms of perf.
#PA_GLOBAL_CFLAGS += -fprofile-use=../../profile -fprofile-correction

# REVISIT:-mno-unaligned-access  - probably not needed

audioplayer_PATH := $(abspath $(LOCAL_PATH)/../../audioplayer/)

ifeq ($(USE_VERSION),yes)
include $(audioplayer_PATH)/build.num # build.number=xxx => $(build.number)
endif

# NOTE: there is PA_GLOBAL_TARGET_ARCH_NAME (armeabi-v7a/arm64-v8a), TARGET_ARCH (arm/arm64), and ARCH (arm/aarch64)

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
	PA_GLOBAL_CFLAGS += -march=armv8-a+simd #-D_NDK_MATH_NO_SOFTFP=1
	PA_GLOBAL_CFLAGS += -DHAVE_ARMV8=1 -DHAVE_NEON=1
	
else ifneq (,$(findstring armeabi-v7a, $(TARGET_ARCH_ABI)))
	# TODO -mtune=cortex-a53
	PA_GLOBAL_CFLAGS += -march=armv7-a -marm -mtune=cortex-a9 -Os -mtune=cortex-a53  
	PA_GLOBAL_CFLAGS += -mfpu=neon -DHAVE_NEON=1 #-ftree-vectorize -mvectorize-with-neon-quad
	PA_GLOBAL_CFLAGS += -fno-stack-protector 

	ifeq ($(TARGET_ARCH_ABI),armeabi-v7a-hard)
$(info Hard-floats)
		PA_GLOBAL_CFLAGS += -mfloat-abi=hard -mhard-float -D_NDK_MATH_NO_SOFTFP=1 # NOTE: also used in config-pamp.h - to define HAVE_VFP_ARGS
		PA_GLOBAL_FLTO := false
	else
		PA_GLOBAL_CFLAGS += -mfloat-abi=softfp
	endif
		
	ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION))) # clang
		PA_GLOBAL_CFLAGS += -fvectorize
	else # gcc
		PA_GLOBAL_CFLAGS += -mno-thumb-interwork
	endif
	
endif

ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION))) # clang
	PA_GLOBAL_CFLAGS += -fno-integrated-as # Needed to compile aarch64 S in clang mode, but not needed for gcc
	PA_GLOBAL_CFLAGS += -Wno-incompatible-pointer-types-discards-qualifiers -Wno-nonportable-include-path
	PA_GLOBAL_CFLAGS += -fvectorize
	PA_GLOBAL_CFLAGS += -Ofast
else # gcc
endif

ifeq ($(PA_GLOBAL_FLTO),true)
	PA_GLOBAL_CFLAGS += -flto
	PA_GLOBAL_LDFLAGS += -flto -fuse-ld=lld #-fuse-ld=gold # -fuse-ld=gold #-marm -march=armv7-a -mfpu=neon -mfloat-abi=hard -mhard-float
else
	# No gold/lld => best size (~-100kb)
endif

ifeq ($(NDK_APP_DEBUGGABLE),true)
$(warning NDK_APP_DEBUGGABLE for $(DIR_NAME))		
	PA_GLOBAL_CFLAGS += -Og 
else
	PA_GLOBAL_CFLAGS += -ffunction-sections -fdata-sections #-fvisibility=hidden - NOTE: fvisibility=hidden doesn't work for us, as it hides ALL the funcs, but we need some available 
endif

PA_NDK_VER := $(subst /opt/android-ndk-,,$(ANDROID_NDK))
PA_GLOBAL_CFLAGS += -DPAMP_FFMPEG_CONFIGURATION='"$(PA_NDK_VER) $(TARGET_ARCH_ABI) lto=$(PA_GLOBAL_FLTO) $(NDK_TOOLCHAIN_VERSION)"'

PA_GLOBAL_TARGET_ARCH_NAME := $(subst -hard,,$(TARGET_ARCH_ABI))

# MaxMP: redefine this macro to avoid inclusion of the project dir as headers dir - this breaks ffmpeg build.
# NOTE: was needed for ndk <= 10
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

# ============================================ Link swresample. NOTE: now building it in this project
#include $(CLEAR_VARS)
#LOCAL_MODULE := libswresample-prebuilt
#LOCAL_SRC_FILES := $(abspath $(LOCAL_PATH)/../audioplayer_ffmpeg_swresample/obj/local/$(TARGET_ARCH_ABI)/libswresample.a)
#include $(PREBUILT_STATIC_LIBRARY)

# ============================================ Link soxr
include $(CLEAR_VARS)
LOCAL_MODULE := libsoxr-prebuilt
LOCAL_SRC_FILES := $(abspath $(LOCAL_PATH)/../audioplayer_ffmpeg_swresample/obj/local/$(TARGET_ARCH_ABI)/libsoxr.a)

include $(PREBUILT_STATIC_LIBRARY)

# REVISIT: this can build vs wrong architecture

# ============================================ Link mbedcrypto
include $(CLEAR_VARS)
LOCAL_MODULE := libmbedcrypto-prebuilt
LOCAL_SRC_FILES := $(mbedtls_PATH)/crypto/build/$(PA_GLOBAL_TARGET_ARCH_NAME)/libmbedcrypto.a
include $(PREBUILT_STATIC_LIBRARY)
# ============================================ Link mbedx509
include $(CLEAR_VARS)
LOCAL_MODULE := libmbedx509-prebuilt
LOCAL_SRC_FILES :=  $(mbedtls_PATH)/build/$(PA_GLOBAL_TARGET_ARCH_NAME)/libmbedx509.a
include $(PREBUILT_STATIC_LIBRARY)
# ============================================ Link mbedtls
include $(CLEAR_VARS)
LOCAL_MODULE := libmbedtls-prebuilt
LOCAL_SRC_FILES :=  $(mbedtls_PATH)/build/$(PA_GLOBAL_TARGET_ARCH_NAME)/libmbedtls.a
include $(PREBUILT_STATIC_LIBRARY)


# ============================================== 

include $(CLEAR_VARS)
LOCAL_ARM_MODE := arm
 
LOCAL_LDLIBS += -llog -lz 

LOCAL_WHOLE_STATIC_LIBRARIES := libavformat libavutil libsoxr-prebuilt libmbedcrypto-prebuilt libmbedx509-prebuilt libmbedtls-prebuilt libswresample libavcodec #libswresample-prebuilt #libtta #libjni

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
LOCAL_LDFLAGS := $(PA_GLOBAL_LDFLAGS) -Wl,--discard-all -Wl,--gc-sections -Wl,--version-script=version-script.txt #-Wl,--print-gc-sections


ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
	LOCAL_LDFLAGS += $(PA_GLOBAL_LDFLAGS) -lm 
	LOCAL_LDLIBS += -lm 
else ifeq ($(TARGET_ARCH_ABI),armeabi-v7a-hard) # HARD
	LOCAL_LDFLAGS += $(PA_GLOBAL_LDFLAGS) -Wl,--no-warn-mismatch -lm_hard
	LOCAL_LDLIBS += -lm_hard 
endif 

cmd-strip = $(TOOLCHAIN_PREFIX)strip -g -S -d --strip-debug --strip-unneeded --discard-all -R .comment -R .gnu.version $1 
endif

LIBS_CUSTOM_PATH := $(audioplayer_PATH)/libs/$(PA_GLOBAL_TARGET_ARCH_NAME)

ifeq ($(USE_VERSION),yes)
PAMP_DST_BASE := $(LIBS_CUSTOM_PATH)/$(subst .$(build.number),,$(LOCAL_MODULE))
PAMP_DST := $(PAMP_DST_BASE).$(build.number).so
else
PAMP_DST_BASE := $(LIBS_CUSTOM_PATH)/$(LOCAL_MODULE)
PAMP_DST := $(PAMP_DST_BASE).so
endif

PAMP_DST_CLEAN := $(PAMP_DST_BASE).*

PAMP_SRC := $(abspath $(LOCAL_PATH)/../libs/$(PA_GLOBAL_TARGET_ARCH_NAME)/$(LOCAL_MODULE).so)

pamp-install-custom: installed_modules
	$(hide) mkdir -p $(LIBS_CUSTOM_PATH)
	@echo "Clean: $(PAMP_DST_CLEAN)"
	$(hide) rm -f $(PAMP_DST_CLEAN)
	@echo "Copy : $(PAMP_SRC) => $(PAMP_DST)"
	$(hide) cp $(PAMP_SRC) $(PAMP_DST)
	@echo "Size: `stat -f %z $(PAMP_DST)`"
	
include $(BUILD_SHARED_LIBRARY)

#ALL_SHARED_LIBRARIES += pamp-install-custom
all: pamp-install-custom 


# =================================================
include $(CLEAR_VARS)
# NOTE: see av.mk for modules flags

include $(call all-makefiles-under,$(PA_GLOBAL_PATH))

#include $(PA_GLOBAL_PATH)/../audioplayer_ffmpeg_swresample/jni/Android.mk

