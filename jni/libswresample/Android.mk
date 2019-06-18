# swresample

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

include $(LOCAL_PATH)/../av.mk

LOCAL_SRC_FILES := $(FFFILES)

LIBSOXR_PATH := $(LOCAL_PATH)/../../audioplayer_ffmpeg_swresample/jni/libsoxr

# NOTE: important to have ../../jni first to look for overriden headers, such as ffversion.h
LOCAL_C_INCLUDES :=		\
	$(LIBSOXR_PATH) \
	$(LIBSOXR_PATH)/soxr-0.1.3/src \
	$(LOCAL_PATH)		\
	$(LOCAL_PATH)/..	\
	$(FFMPEG_LOCAL_PATH)		\
	$(FFMPEG_LOCAL_PATH)/.. \
	

LOCAL_CFLAGS = $(PA_GLOBAL_CFLAGS)
# NOTE: for best perormance, swresample requires quite specific flags
	
ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
	# NOTE: gcc seems to be better for arm64 + disabled arm64 asm opts for resampler
	# clang r20 seems to be slightly better with neon asm
	LOCAL_CFLAGS += -Ofast #-DPAMP_DISABLE_NEON_ASM
	ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION))) # clang
		LOCAL_CFLAGS += -fno-vectorize
		LOCAL_CFLAGS += -Wno-logical-op-parentheses -Wno-switch
	else # gcc
		# NOTE: not using gcc now 	
	endif
	
else ifneq (,$(findstring armeabi-v7a,$(TARGET_ARCH_ABI)))
	LOCAL_CFLAGS += -O2 
	#LOCAL_CFLAGS += -DPAMP_DISABLE_NEON_ASM # NOTE: sligtly worse vs arm neon optimized, much worse for clang
	LOCAL_CFLAGS += -mtune=cortex-a53
	LOCAL_CFLAGS += -ftree-vectorize -funroll-loops #-funroll-all-loops
	LOCAL_CFLAGS += -fno-stack-protector

	ifneq (,$(findstring clang,$(NDK_TOOLCHAIN_VERSION))) # clang
	else # gcc
	endif
endif
 
LOCAL_ARM_MODE := arm

LOCAL_STATIC_LIBRARIES := $(FFLIBS)

LOCAL_MODULE := $(FFNAME)

ifeq ($(PA_GLOBAL_FLTO),true)
	ifeq (,$(findstring -flto, $(LOCAL_CFLAGS)))
$(error No -flto in LOCAL_CFLAGS=$(LOCAL_CFLAGS)) 	
	endif
endif


include $(BUILD_STATIC_LIBRARY)
