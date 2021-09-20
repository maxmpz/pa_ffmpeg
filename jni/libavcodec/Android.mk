# avcodec

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

# NOTE: doesn't affect so size
LOCAL_OBJS_TO_REMOVE :=

include $(LOCAL_PATH)/../av.mk

LOCAL_SRC_FILES := $(FFFILES)

LOCAL_C_INCLUDES :=        \
    $(LOCAL_PATH)        \
    $(LOCAL_PATH)/..    \
    $(FFMPEG_LOCAL_PATH)        \
    $(FFMPEG_LOCAL_PATH)/.. \
    $(mbedtls_PATH)/include $(mbedtls_PATH)/crypto/include \

LOCAL_CFLAGS += $(PA_GLOBAL_CFLAGS)

LOCAL_STATIC_LIBRARIES := $(FFLIBS)

LOCAL_MODULE := $(FFNAME)

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
    ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION))) # clang
        LOCAL_CFLAGS += -O2
    endif
else
    ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION))) # clang
        LOCAL_CFLAGS += -Os # Same or better performance for arm32, -280kb vs Ofast
    endif
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


