LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

ifneq ($(TARGET_ARCH_ABI),x86)
    LOCAL_ARM_MODE := arm
endif

SOXR_SRC_DIR := soxr-0.1.3/src

LOCAL_C_INCLUDES := \
    $(LOCAL_PATH) \
    $(FFMPEG_OVERRIDE_ROOT)/.. \
    $(FFMPEG_ROOT) \


LOCAL_MODULE    := libsoxr
LOCAL_SRC_FILES := \
    soxr.c \
    data-io.c \
    dbesi0.c \
    filter.c \
    fft4g64.c \
    cr.c \
    cr32.c \
    cr32s.c \
    avfft32s.c \
    util32s.c \



LOCAL_SRC_FILES := $(addprefix $(SOXR_SRC_DIR)/, $(LOCAL_SRC_FILES))

LOCAL_CFLAGS := $(PA_GLOBAL_CFLAGS) -std=gnu99 -DSOXR_LIB

LOCAL_CFLAGS += -fno-stack-protector

ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION))) # clang
    ifeq ($(TARGET_ARCH_ABI),arm64-v8a) # clang implied
        LOCAL_CFLAGS += -Ofast
    else
        LOCAL_CFLAGS += -Os
    endif

else # gcc
    LOCAL_CFLAGS += -O3
endif

ifeq (,$(findstring -O, $(LOCAL_CFLAGS))) # Check for optimization flag
$(error No -Ox in LOCAL_CFLAGS=$(LOCAL_CFLAGS))
endif
ifneq (false,$(PA_GLOBAL_FLTO)) # NOTE: PA_GLOBAL_FLTO can be false,full,thin
ifeq (,$(findstring -flto, $(LOCAL_CFLAGS)))
$(error No -flto in LOCAL_CFLAGS=$(LOCAL_CFLAGS))     
endif
endif

include $(BUILD_STATIC_LIBRARY)

