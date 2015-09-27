LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

ifneq ($(TARGET_ARCH_ABI),x86)
	LOCAL_ARM_MODE := arm
endif

SOXR_SRC_DIR := soxr-0.1.1/src

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH) \
	$(FFMPEG_LOCAL_PATH)/.. \	

LOCAL_MODULE    := libsoxr
LOCAL_SRC_FILES := \
	data-io.c \
	dbesi0.c \
	rate32.c \
	fft4g64.c \
	filter.c \
	soxr.c \
	vr32.c \
	rate32s.c \
	simd.c \
	pffft32.c \
	pffft32s.c \

#	avfft32.c \
	avfft32s.c \


LOCAL_SRC_FILES := $(addprefix $(SOXR_SRC_DIR)/, $(LOCAL_SRC_FILES))
	
LOCAL_CFLAGS = $(GLOBAL_CFLAGS) -DSOXR_LIB -std=gnu99 -Ofast # -ftree-vectorize

include $(BUILD_STATIC_LIBRARY)

