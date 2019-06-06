# avcodec

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

#LOCAL_OBJS_TO_REMOVE := arm/ac3dsp_armv6.o arm/ac3dsp_arm.o arm/ac3dsp_neon.o arm/ac3dsp_init_arm.o \
	arm/jrevdct_arm.o arm/mpegvideo_arm.o arm/simple_idct_arm.o arm/simple_idct_armv6.o \
	arm/mpegvideo_neon.o arm/simple_idct_neon.o arm/simple_idct_armv5te.o \
	arm/hpeldsp_arm.o arm/hpeldsp_armv6.o arm/hpeldsp_init_arm.o arm/hpeldsp_init_armv6.o \
	log2_tab.o \
		dv_profile.o \
       rawdec.o                                                         \
       bitstream_filter.o                                               \
       faanidct.o                                                       \
       jrevdct.o                                                        \
       resample.o                                                       \
       resample2.o                                                      \
       simple_idct.o                                                    \
       audioconvert.o                                                   \
       \
       frame_thread_encoder.o \
       avpicture.o \
       \
       dirac.o \
 	   qsv_api.o \
       fft_fixed.o \
       fft_init_table.o \
       mdct_fixed.o \
       mdct_fixed_32.o \
       arm/fft_fixed_neon.o \
       arm/mdct_fixed_neon.o \
       arm/fft_fixed_init_arm.o \
       golomb.o \
       

# mpc:		
#       mpegaudiodsp_fixed.o \
#       arm/mpegaudiodsp_fixed_armv6.o \
#       dct32_fixed.o \
# Others:       
#		imgconvert.o \
		arm/fft_vfp.o \
		arm/mdct_vfp.o \
       fft_fixed_32.o \
		
# 
# 
# raw.o
#  \
# arm/mpegaudiodsp_fixed_armv6.o \
# 

# NOTE: doesn't affect so size 
LOCAL_OBJS_TO_REMOVE := \
       
        
include $(LOCAL_PATH)/../av.mk

LOCAL_SRC_FILES := $(FFFILES)

LOCAL_C_INCLUDES :=		\
	$(LOCAL_PATH)		\
	$(LOCAL_PATH)/..	\
	$(FFMPEG_LOCAL_PATH)		\
	$(FFMPEG_LOCAL_PATH)/.. \
	
#	$(LOCAL_PATH)/../../../audioplayer_libopus/opus-1.0.1/include

# funroll-loops helps a bit (-0.03% realtime) mp3, but adds 40 kb
LOCAL_CFLAGS += $(GLOBAL_CFLAGS) #-funroll-loops #-ftree-vectorize -mvectorize-with-neon-quad 
#LOCAL_CFLAGS += --param max-inline-insns-single=1600
      
LOCAL_STATIC_LIBRARIES := $(FFLIBS)

LOCAL_MODULE := $(FFNAME)

include $(BUILD_STATIC_LIBRARY)


