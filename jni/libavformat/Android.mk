LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

# Important: keep empty
LOCAL_OBJS_TO_REMOVE := 

# Those are not affecting .so size
LOCAL_OBJS_TO_REMOVE := \
	log2_tab.o golomb_tab.o \
	oggparsedirac.o  \
	oggparsecelt.o   \
	oggparseogm.o    \
	oggparsespeex.o  \
	oggparsetheora.o \
	oggparsevp8.o \
	img2.o \
	avlanguage.o \
	mux.o \
	replaygain.o \
	flac_picture.o \
	
	
# \
#img2.o \
#        mux.o                \
#        sdp.o                \
#        subtitles.o          \
#         \


#LOCAL_USE_LOCAL_MAKEFILE := yes
include $(LOCAL_PATH)/../av.mk

LOCAL_SRC_FILES := $(FFFILES) 

# Important: keep LOCAL_PATH paths above ffmpeg path to ensure it overrides sources/headers.
LOCAL_C_INCLUDES :=		\
	$(LOCAL_PATH)		\
	$(LOCAL_PATH)/..	\
	$(FFMPEG_LOCAL_PATH)		\
	$(FFMPEG_LOCAL_PATH)/.. \
	$(LOCAL_PATH)/../../opus-1.0.1/include
	
LOCAL_CFLAGS += $(GLOBAL_CFLAGS)
LOCAL_CFLAGS += -include "string.h" -Dipv6mr_interface=ipv6mr_ifindex

LOCAL_STATIC_LIBRARIES := $(FFLIBS)

LOCAL_MODULE := $(FFNAME)

include $(BUILD_STATIC_LIBRARY)
