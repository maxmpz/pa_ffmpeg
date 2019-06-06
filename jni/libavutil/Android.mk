# avutil

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

# NOTE: this reduces compile speed, but resulting so doesn't change as these are pretty well optimized out by linker anyway
LOCAL_OBJS_TO_REMOVE := \
       xga_font_data.o                                                  \
       xtea.o                                                           \
       tree.o                                                           \
		aes.o                                                            \
       blowfish.o                                                       \
       lls.o                                                            \
		cast5.o \
		ripemd.o \
		hash.o \
		parseutils.o \
		camellia.o \
		twofish.o \
		murmur3.o \
		threadmessage.o \
		pixelutils.o \
		color_utils.o \
		adler32.o \
		aes_ctr.o \
		
#		fixed_dsp.o \
		imgutils.o                                                       \
       pixdesc.o                                                        \
       lzo.o                                                            \
		

#LOCAL_USE_LOCAL_MAKEFILE := yes
include $(LOCAL_PATH)/../av.mk

LOCAL_SRC_FILES := $(FFFILES)

# NOTE: can't build libavutil/time.h dependent sources as it will fail on #include <time.h>. Still I used ../ dirs for include path, this allows inclusion of ffmpeg headers with directory name
# prepended path, e.g.: "libavutil/time.h".
LOCAL_C_INCLUDES :=		\
	$(LOCAL_PATH)/..	\
	$(FFMPEG_LOCAL_PATH)/.. \	
#	$(LOCAL_PATH)		\	
#	$(FFMPEG_LOCAL_PATH)		\


LOCAL_CFLAGS += $(GLOBAL_CFLAGS) #-O3 -ftree-vectorize -mvectorize-with-neon-quad -funroll-loops

LOCAL_STATIC_LIBRARIES := $(FFLIBS)

LOCAL_MODULE := $(FFNAME)

include $(BUILD_STATIC_LIBRARY)

