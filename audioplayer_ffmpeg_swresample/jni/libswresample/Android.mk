# swresample

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

include $(LOCAL_PATH)/../av.mk

LOCAL_SRC_FILES := $(FFFILES)

# /Andro/Andro509/audioplayer_ffmpeg/audioplayer_ffmpeg_swresample/jni/libsoxr 
# /Andro/Andro509/audioplayer_ffmpeg/audioplayer_ffmpeg_swresample/jni/libsoxr/soxr-0.1.1/src
# /Andro/Andro509/audioplayer_ffmpeg/audioplayer_ffmpeg_swresample/jni/libswresample 
# /Andro/Andro509/audioplayer_ffmpeg/audioplayer_ffmpeg_swresample/jni/libswresample/.. 
# ../../FFmpeg/libswresample ../../FFmpeg/libswresample/...  Stop.

# NOTE: important to have ../../jni first to look for overriden headers, such as ffversion.h
LOCAL_C_INCLUDES :=		\
	$(abspath $(LOCAL_PATH)/../libsoxr) \
	$(abspath $(LOCAL_PATH)/../libsoxr/soxr-0.1.3/src) \
	$(LOCAL_PATH)		\
	../../jni \
	$(FFMPEG_LOCAL_PATH)		\
	$(FFMPEG_LOCAL_PATH)/..
	
LOCAL_CFLAGS += $(GLOBAL_CFLAGS)
#LOCAL_CFLAGS += -funroll-loops 
#LOCAL_CFLAGS += --param max-inline-insns-single=1000
#LOCAL_CFLAGS += -ftree-vectorize -mvectorize-with-neon-quad

LOCAL_STATIC_LIBRARIES := $(FFLIBS)

LOCAL_MODULE := $(FFNAME)

include $(BUILD_STATIC_LIBRARY)
