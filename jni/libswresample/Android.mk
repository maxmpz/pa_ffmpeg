# swresample

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

include $(LOCAL_PATH)/../av.mk

LOCAL_SRC_FILES := $(FFFILES)


# NOTE: important to have ../../jni first to look for overridden headers, such as ffversion.h
LOCAL_C_INCLUDES :=        \
    $(libsoxr_PATH) \
    $(libsoxr_PATH)/soxr-0.1.3/src \
    $(LOCAL_PATH)        \
    $(LOCAL_PATH)/..    \
    $(FFMPEG_LOCAL_PATH)        \
    $(FFMPEG_LOCAL_PATH)/.. \

LOCAL_CFLAGS := $(PA_GLOBAL_CFLAGS)

LOCAL_CFLAGS += -fno-stack-protector

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
    ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION))) # clang
        # Best for ndk-23
        LOCAL_CFLAGS += -DPAMP_DISABLE_NEON_ASM
        LOCAL_CFLAGS += -Ofast
        LOCAL_CFLAGS += -Wno-logical-op-parentheses -Wno-switch
    endif
else ifneq (,$(findstring armeabi-v7a,$(TARGET_ARCH_ABI)))
    ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION))) # clang
        LOCAL_CFLAGS += -Ofast
    else # gcc
        LOCAL_CFLAGS += -O2
        LOCAL_CFLAGS += -mtune=cortex-a53
        LOCAL_CFLAGS += -ftree-vectorize -funroll-loops #-funroll-all-loops
    endif
endif
 
#$(error $(LOCAL_CFLAGS))

LOCAL_ARM_MODE := arm

LOCAL_STATIC_LIBRARIES := $(FFLIBS)

LOCAL_MODULE := $(FFNAME)

ifeq (,$(findstring -O, $(LOCAL_CFLAGS))) # Check for optimization flag
    $(error No -Ox in LOCAL_CFLAGS=$(LOCAL_CFLAGS))
endif
ifneq (false,$(PA_GLOBAL_FLTO)) # NOTE: PA_GLOBAL_FLTO can be false,full,thin
    ifeq (,$(findstring -flto, $(LOCAL_CFLAGS)))
        $(error No -flto in LOCAL_CFLAGS=$(LOCAL_CFLAGS))
    endif
endif


include $(BUILD_STATIC_LIBRARY)
