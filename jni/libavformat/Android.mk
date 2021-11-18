LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

# Important: keep empty
LOCAL_OBJS_TO_REMOVE := 

include $(LOCAL_PATH)/../av.mk

LOCAL_SRC_FILES := $(FFFILES) 

# Important: keep LOCAL_PATH paths above ffmpeg path to ensure it overrides sources/headers
# NOTE: local headers (e.g. libavformat/replaygain.h for libavformat/mov.c) can't be overridden this way, so appropriate c file override is needed)
LOCAL_C_INCLUDES :=        \
    $(LOCAL_PATH)        \
    $(LOCAL_PATH)/..    \
    $(FFMPEG_LOCAL_PATH)        \
    $(FFMPEG_LOCAL_PATH)/.. \
    $(mbedtls_PATH)/include $(mbedtls_PATH)/crypto/include \


LOCAL_CFLAGS += $(PA_GLOBAL_CFLAGS)
LOCAL_CFLAGS += -include "string.h" -Dipv6mr_interface=ipv6mr_ifindex

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
