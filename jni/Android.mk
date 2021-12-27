# FFMPEG

$(info Using TOOLCHAIN_NAME=$(TOOLCHAIN_NAME))
$(info TARGET_ARCH_ABI=$(TARGET_ARCH_ABI))
ifeq ($(PA_MIN_MODE),1)
    $(info PA_MIN_MODE PA_MIN_MODE PA_MIN_MODE PA_MIN_MODE)
endif
$(info (libffmpeg*) Using TOOLCHAIN_NAME=$(TOOLCHAIN_NAME) PA_GLOBAL_FLTO=$(PA_GLOBAL_FLTO) \
    PA_UNIFIED_BUILD=$(PA_UNIFIED_BUILD) PA_NDK_VERSION_MAJOR=$(PA_NDK_VERSION_MAJOR))
ifeq (,$(findstring $(PA_NDK_VERSION_MAJOR),$(ANDROID_NDK)))
    $(error "Please ensre PA_NDK_VERSION_MAJOR=$(PA_NDK_VERSION_MAJOR) matches ANDROID_NDK=$(ANDROID_NDK)")
endif
ifeq (,$(PA_NDK_VERSION_MAJOR))
    $(error "Please define PA_NDK_VERSION_MAJOR")
endif

audioplayer_ffmpeg_PATH := $(call my-dir)
LOCAL_PATH := $(audioplayer_ffmpeg_PATH)

# IMPORTANT: should be relative to this script
FFMPEG_ROOT := ../FFmpeg
# Absolute path to this dir
FFMPEG_OVERRIDE_ROOT := $(LOCAL_PATH)
mbedtls_PATH := $(abspath $(audioplayer_ffmpeg_PATH)/../thirdparty/mbedtls)
libsoxr_PATH := $(abspath $(audioplayer_ffmpeg_PATH)/../thirdparty/libsoxr)


include $(LOCAL_PATH)/config-pamp.mak

# Seems to work (at least, compile) for ndk-11c gcc4.9, but it's slow to build
# Also, resulting build is slow and can be also larger vs usual one
# It's quite fast for clang ndk-r20
# NOTE: disabled for hard or gcc
# NOTE: should be false|thin|full (no empty strings allowed)
PA_GLOBAL_FLTO ?= false
PA_GLOBAL_APPLY_FFMPEG_OPTS ?= true

# NOTE: mbedtls doesn't use PA_GLOBAL_CFLAGS

PA_GLOBAL_CFLAGS := -std=c99 -ffast-math -fstrict-aliasing -Werror=strict-aliasing
PA_GLOBAL_LDFLAGS :=

# NOTE: these are needed just for ffmpeg compilation - shouldn't be replicated to any other code   
# Also, PAMP_* there shouldn't be used in (outside accessible) headers
PA_GLOBAL_CFLAGS += -DHAVE_AV_CONFIG_H 
# NOTE: disables inclusion of termbits.h, which defines macros like B0 - these conflict with FFmpeg code
PA_GLOBAL_CFLAGS += -D__ASM_GENERIC_TERMBITS_H
# Disabling this ffmpeg-wide
PA_GLOBAL_CFLAGS += -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0

ifeq ($(strip $(PA_GLOBAL_APPLY_FFMPEG_OPTS)),true)
PA_GLOBAL_CFLAGS += -DPAMP_CONFIG_NO_VIDEO=1  -DPAMP_CONFIG_FLOAT_ONLY_RESAMPLER=1 -DPAMP_CHANGES=1 -DPAMP_CONFIG_NO_TAGS=1
PA_GLOBAL_CFLAGS += -DPAMP_OPTIMIZE_MACROS=1
# NOTE: don't expose any paths to .so 
PA_GLOBAL_CFLAGS += -D__FILE__=\"\" -Wno-builtin-macro-redefined
else
$(warning no PA_GLOBAL_APPLY_FFMPEG_OPTS)
endif

audioplayer_PATH := $(abspath $(LOCAL_PATH)/../../audioplayer/)

# NOTE: there is PA_GLOBAL_TARGET_ARCH_NAME (armeabi-v7a/arm64-v8a), TARGET_ARCH (arm/arm64), and ARCH (arm/aarch64)

ifeq (,$(PA_GLOBAL_FLTO)) # Ensure we have non-empty lto
PA_GLOBAL_FLTO := false
endif

ifeq ($(TARGET_ARCH_ABI),arm64-v8a) # clang implied
    PA_GLOBAL_CFLAGS += -march=armv8-a+simd
    PA_GLOBAL_CFLAGS += -DHAVE_ARMV8=1 -DHAVE_NEON=1
    PA_GLOBAL_CFLAGS += -mcpu=kryo -mtune=kryo
    PA_GLOBAL_CFLAGS += -Os

else ifneq (,$(findstring armeabi-v7a, $(TARGET_ARCH_ABI)))
    PA_GLOBAL_CFLAGS += -march=armv7-a
    #PA_GLOBAL_CFLAGS += -mfpu=neon
    PA_GLOBAL_CFLAGS += -mfpu=neon-vfpv3
    #PA_GLOBAL_CFLAGS += -mfpu=neon-vfpv4
    PA_GLOBAL_CFLAGS += -DHAVE_NEON=1
    PA_GLOBAL_CFLAGS += -Os

# Enabled for avformat/avutil, disabled for resamplers/avcodec
#    PA_GLOBAL_CFLAGS += -fno-stack-protector

    ifeq ($(TARGET_ARCH_ABI),armeabi-v7a-hard)
        $(info Hard-floats)
        PA_GLOBAL_CFLAGS += -mfloat-abi=hard -mhard-float -D_NDK_MATH_NO_SOFTFP=1 # NOTE: also used in config-pamp.h - to define HAVE_VFP_ARGS
    else
        PA_GLOBAL_CFLAGS += -mfloat-abi=softfp
    endif

    ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION))) # clang
        #PA_GLOBAL_CFLAGS += -mcpu=krait
        PA_GLOBAL_CFLAGS += -mcpu=cortex-a9 -mtune=krait

    else # gcc
        PA_GLOBAL_CFLAGS += -mtune=cortex-a9
        PA_GLOBAL_CFLAGS += -mno-thumb-interwork
    endif
endif

ifneq (,$(ASAN)) 
$(info ASAN build ==============================================)
    PA_GLOBAL_CFLAGS += -fsanitize=address -fno-omit-frame-pointer -g
    PA_GLOBAL_LDFLAGS += -fsanitize=address
endif

ifeq ($(PA_MIN_MODE),1)
    PA_GLOBAL_CFLAGS += -DHAVE_PA_MIN_MODE=1
endif

ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION))) # clang

    ifneq (,$(call gte,$(PA_NDK_VERSION_MAJOR),23))
        # Disable HAVE_AS_FUNC to compile properly with clang as
        PA_GLOBAL_CFLAGS += -DPAMP_DISABLE_AS_FUNC -Wno-implicit-const-int-float-conversion
    else
        # Needed to compile aarch64 S in clang mode, but not needed for gcc or ndk-23+
        PA_GLOBAL_CFLAGS += -fno-integrated-as
    endif

    ifneq (,$(call gte,$(PA_NDK_VERSION_MAJOR),22))
        PA_GLOBAL_CFLAGS += -Wno-implicit-const-int-float-conversion
    endif
        PA_GLOBAL_CFLAGS += -Wno-incompatible-pointer-types-discards-qualifiers -Wno-nonportable-include-path

        PA_GLOBAL_CFLAGS += -Wno-string-plus-int -Wno-switch

else # gcc

endif



ifneq (false,$(PA_GLOBAL_FLTO)) # NOTE: PA_GLOBAL_FLTO can be false,full,thin
ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION))) # clang
    PA_GLOBAL_CFLAGS += -flto=$(PA_GLOBAL_FLTO)
    PA_GLOBAL_LDFLAGS += -fuse-ld=lld
else
# NOTE: lto doesn't seem to be working for gcc 4.9 + neon
    PA_GLOBAL_CFLAGS += -flto -falign-functions=16
    PA_GLOBAL_LDFLAGS += -flto
endif

else
    # No gold/lld => best size (~-100kb)
endif

ifeq ($(NDK_APP_DEBUGGABLE),true)
    $(error NDK_APP_DEBUGGABLE)
    PA_GLOBAL_CFLAGS += -Og -g -fno-omit-frame-pointer
else
    # NOTE: fvisibility=hidden doesn't work for us, as it hides ALL the funcs, but we need some available
    PA_GLOBAL_CFLAGS += -ffunction-sections
    PA_GLOBAL_CFLAGS += -fdata-sections
    PA_GLOBAL_CFLAGS += -fomit-frame-pointer
endif

PA_GLOBAL_CFLAGS += -DPAMP_FFMPEG_CONFIGURATION='"$(PA_NDK_VERSION_MAJOR) $(TARGET_ARCH_ABI) lto=$(PA_GLOBAL_FLTO) $(NDK_TOOLCHAIN_VERSION)"'

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

# Link static libs only for non-unified builds
# ============================================ Link soxr
ifneq ($(PA_UNIFIED_BUILD),true)

include $(CLEAR_VARS)
LOCAL_MODULE := libsoxr-prebuilt
LOCAL_SRC_FILES := $(libsoxr_PATH)/obj/local/$(TARGET_ARCH_ABI)/libsoxr.a
include $(PREBUILT_STATIC_LIBRARY)

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

endif #!PA_UNIFIED_BUILD

# ============================================== 

include $(CLEAR_VARS)
LOCAL_ARM_MODE := arm


LOCAL_CFLAGS := $(PA_GLOBAL_CFLAGS)
LOCAL_CFLAGS += $(PA_GLOBAL_OVERRIDE_CFLAGS)
LOCAL_LDLIBS += -llog -lz 

LOCAL_WHOLE_STATIC_LIBRARIES :=

ifeq ($(PA_UNIFIED_BUILD),true) # Unified
LOCAL_WHOLE_STATIC_LIBRARIES += libsoxr libmbedtls-all
else # Old way
LOCAL_WHOLE_STATIC_LIBRARIES += libsoxr-prebuilt libmbedcrypto-prebuilt libmbedx509-prebuilt libmbedtls-prebuilt
endif

LOCAL_WHOLE_STATIC_LIBRARIES += libavformat libavutil libswresample libavcodec #libswresample-prebuilt #libtta #libjni

# REVISIT: drop _neon. For now using this as it's used everywhere
LOCAL_LDFLAGS := $(PA_GLOBAL_LDFLAGS) -Wl,--discard-all -Wl,--gc-sections #-Wl,--print-gc-sections

ifeq ($(PA_MIN_MODE),1)
    LOCAL_LDFLAGS += -Wl,--version-script=version-script-min.txt
    LOCAL_MODULE := libffmpeg_min
    LOCAL_FLAVOR_APP := "peq"
else
    LOCAL_LDFLAGS += -Wl,--version-script=version-script.txt
    LOCAL_MODULE := libffmpeg_neon
    LOCAL_FLAVOR_APP := "pa"
endif

#LOCAL_SHARED_LIBRARIES := libopus-prebuilt 


ifeq ($(NDK_APP_DEBUGGABLE),true)
$(info NO_STRIP SO)
cmd-strip = echo
else
#$(warning STRIPPING SO)
#cmd-strip = echo


ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
    LOCAL_LDFLAGS += $(PA_GLOBAL_LDFLAGS) -lm
    LOCAL_LDLIBS += -lm
else ifeq ($(TARGET_ARCH_ABI),armeabi-v7a-hard) # HARD
    LOCAL_LDFLAGS += $(PA_GLOBAL_LDFLAGS) -Wl,--no-warn-mismatch -lm_hard
    LOCAL_LDLIBS += -lm_hard
endif 

# -g -S -d --strip-debug           Remove all debugging symbols & sections
LOCAL_STRIP_ARGS := -g -S -d --strip-debug --strip-unneeded --discard-all -R .comment -R .gnu.version

# NOTE: cmd-strip is expanded later, so we pass $1 there, not in $(LOCAL_STRIP_ARGS) where it will expand right now instead
ifneq (,$(call gte,$(PA_NDK_VERSION_MAJOR),23))
    cmd-strip = $(LLVM_TOOLCHAIN_PREFIX)llvm-strip $(LOCAL_STRIP_ARGS) $1
else
    cmd-strip = $(TOOLCHAIN_PREFIX)strip $(LOCAL_STRIP_ARGS) $1
endif


endif

LIBS_CUSTOM_PATH := $(audioplayer_PATH)/src/$(LOCAL_FLAVOR_APP)/jniLibs/$(PA_GLOBAL_TARGET_ARCH_NAME)

PAMP_DST_BASE := $(LIBS_CUSTOM_PATH)/$(LOCAL_MODULE)
PAMP_DST := $(PAMP_DST_BASE).so

PAMP_DST_CLEAN := $(PAMP_DST_BASE).*

PAMP_SRC := $(abspath $(LOCAL_PATH)/../libs/$(PA_GLOBAL_TARGET_ARCH_NAME)/$(LOCAL_MODULE).so)


# For arm32, copy ffmpeg into jniLibs as we don't do gradle based ndk build for this target
# IMPORTANT: tabs here
ifneq (,$(findstring armeabi-v7a, $(TARGET_ARCH_ABI)))
pamp-install-custom: installed_modules
	$(hide) mkdir -p $(LIBS_CUSTOM_PATH)
	@echo "Clean: $(PAMP_DST_CLEAN)"
	$(hide) rm -f $(PAMP_DST_CLEAN)
	@echo "Copy : $(PAMP_SRC) => $(PAMP_DST)"
	$(hide) cp $(PAMP_SRC) $(PAMP_DST)
	@echo "Size: `stat -f %z $(PAMP_DST)`"

else
# WARNING: tabs here
pamp-install-custom: installed_modules
	@echo "Size: `stat -f %z $(PAMP_SRC)`"

endif

ALL_SHARED_LIBRARIES += pamp-install-custom
all: pamp-install-custom

ifeq (,$(findstring -O, $(LOCAL_CFLAGS))) # Check for optimization flag
$(error No -Ox in LOCAL_CFLAGS=$(LOCAL_CFLAGS))
endif
ifneq (false,$(PA_GLOBAL_FLTO))
ifeq (,$(findstring -flto, $(LOCAL_CFLAGS)))
$(error No -flto in LOCAL_CFLAGS=$(LOCAL_CFLAGS))
endif
endif

include $(BUILD_SHARED_LIBRARY)


# =================================================
include $(CLEAR_VARS)
# NOTE: see av.mk for modules flags


# Build sub-projects
# REVISIT: audioplayer_libpoweramputils/milk currently define own PA_* vars
# we may want to define those globally instead

ifeq ($(PA_UNIFIED_BUILD),true)
    include $(mbedtls_PATH)/Android.mk

    include $(libsoxr_PATH)/Android.mk

    include $(CLEAR_VARS)
endif


# NOTE: this includes all our custom jni/*/Android.mk
include $(call all-makefiles-under,$(audioplayer_ffmpeg_PATH))


