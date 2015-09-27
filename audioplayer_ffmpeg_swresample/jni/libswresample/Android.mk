# swresample

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

include $(LOCAL_PATH)/../av.mk

LOCAL_SRC_FILES := $(FFFILES)


LOCAL_C_INCLUDES :=		\
	$(abspath $(LOCAL_PATH)/../libsoxr) \
	$(abspath $(LOCAL_PATH)/../libsoxr/soxr-0.1.1/src) \
	$(LOCAL_PATH)		\
	$(LOCAL_PATH)/..	\
	$(FFMPEG_LOCAL_PATH)		\
	$(FFMPEG_LOCAL_PATH)/..
	
LOCAL_CFLAGS += $(GLOBAL_CFLAGS)
LOCAL_CFLAGS += -funroll-loops 
#LOCAL_CFLAGS += --param max-inline-insns-single=1000
#LOCAL_CFLAGS += -ftree-vectorize -mvectorize-with-neon-quad

LOCAL_STATIC_LIBRARIES := $(FFLIBS)

LOCAL_MODULE := $(FFNAME)

include $(BUILD_STATIC_LIBRARY)
