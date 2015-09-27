$(call clear-vars, $(FFMPEG_CONFIG_VARS))

# DIR_NAME = libavcodec libavformat libavutil libswresample ...
DIR_NAME := $(notdir $(basename $(LOCAL_PATH)))

FFMPEG_LOCAL_PATH := $(FFMPEG_ROOT)/$(DIR_NAME)

SUBDIR := $(FFMPEG_LOCAL_PATH)/

ifeq ($(TARGET_ARCH_ABI),armeabi-v7a-hard)

ifeq ($(GLOBAL_ARCH_MODE),d16)
include $(FFMPEG_ROOT)/config-d16.mak
else ifeq ($(GLOBAL_ARCH_MODE),neon)
include $(FFMPEG_ROOT)/config-neon.mak
endif	

else ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)

ifeq ($(GLOBAL_ARCH_MODE),d16)
include $(FFMPEG_ROOT)/config-d16.mak
else ifeq ($(GLOBAL_ARCH_MODE),neon)
include $(FFMPEG_ROOT)/config-neon.mak

endif

else
$(error TODO)
endif

LOCAL_ARM_MODE := arm

OBJS :=
OBJS-yes :=
ARMV5TE-OBJS-yes :=
ARMV6-OBJS-yes :=
VFP-OBJS-yes :=
NEON-OBJS-yes :=
ARMV5TE-OBJS :=
ARMV6-OBJS :=
VFP-OBJS :=
NEON-OBJS :=

ifeq ($(LOCAL_USE_LOCAL_MAKEFILE),yes)
include $(LOCAL_PATH)/Makefile
-include $(LOCAL_PATH)/$(ARCH)/Makefile
LOCAL_USE_LOCAL_MAKEFILE = no
else
include $(FFMPEG_LOCAL_PATH)/Makefile
-include $(FFMPEG_LOCAL_PATH)/$(ARCH)/Makefile
endif

OBJS += $(OBJS-yes)

ifeq ($(HAVE_ARMV5TE),yes)
	OBJS += $(ARMV5TE-OBJS) $(ARMV5TE-OBJS-yes)
endif
ifeq ($(HAVE_ARMV6),yes)
	OBJS += $(ARMV6-OBJS) $(ARMV6-OBJS-yes)
endif
ifeq ($(HAVE_VFP),yes)
	OBJS += $(VFP-OBJS) $(VFP-OBJS-yes) 
endif
ifeq ($(HAVE_NEON),yes)
	OBJS += $(NEON-OBJS) $(NEON-OBJS-yes)
endif

FFNAME := lib$(NAME)
FFLIBS := $(foreach,NAME,$(FFLIBS),lib$(NAME))

LOCAL_CFLAGS :=  \
	-Wno-sign-compare -Wno-switch -Wno-pointer-sign \
	-Wno-format -Wno-deprecated-declarations -Wno-cast-qual \
	-Wno-parentheses  \
	
#	-Wno-incompatible-pointer-types -Wno-logical-op-parentheses -Wno-asm-operand-widths -Wno-unknown-warning-option  
  
ifneq ($(LOCAL_OBJS_TO_REMOVE),)
OBJS := $(filter-out $(LOCAL_OBJS_TO_REMOVE),$(OBJS))
LOCAL_OBJS_TO_REMOVE :=
endif

# OBJS now have all files to build - both .S and .c - as .o; for ndk-build we need to prepare source files list

ALL_S_FILES := $(wildcard $(FFMPEG_LOCAL_PATH)/$(TARGET_ARCH)/*.S)
ALL_S_FILES := $(addprefix $(TARGET_ARCH)/, $(notdir $(ALL_S_FILES)))

ifneq ($(ALL_S_FILES),)
ALL_S_OBJS := $(patsubst %.S,%.o,$(ALL_S_FILES))
C_OBJS := $(filter-out $(ALL_S_OBJS),$(OBJS))
S_OBJS := $(filter $(ALL_S_OBJS),$(OBJS))
else
C_OBJS := $(OBJS)
S_OBJS :=
endif

# Just .c files in both current dir and ARCH dir.
C_FILES := $(patsubst %.o,%.c,$(C_OBJS))

S_FILES := $(patsubst %.o,%.S,$(S_OBJS))

#include $(LOCAL_PATH)/Makefile
#-include $(LOCAL_PATH)/$(ARCH)/Makefile

# With full paths
OVERRIDE_S_FILES := $(wildcard $(LOCAL_PATH)/$(TARGET_ARCH)/*.S)
# now just arm/*.S
OVERRIDE_S_FILES := $(addprefix $(TARGET_ARCH)/, $(notdir $(OVERRIDE_FILES)))


# This is our override files - all of them - including those which are probably not in OBJS. Paths relative to DIR_NAME: file.c ... arm/file.c
OVERRIDE_C_FILES := $(notdir $(wildcard $(LOCAL_PATH)/*.c)) $(addprefix $(TARGET_ARCH)/, $(notdir $(wildcard $(LOCAL_PATH)/$(TARGET_ARCH)/*.c)))
OVERRIDE_S_FILES := $(addprefix $(TARGET_ARCH)/, $(notdir $(wildcard $(LOCAL_PATH)/$(TARGET_ARCH)/*.S)))

# These are just the overriden files which were also in C_FILES
OVERRIDE_C_FILES := $(sort $(filter $(OVERRIDE_C_FILES),$(C_FILES)))
OVERRIDE_S_FILES := $(sort $(filter $(OVERRIDE_S_FILES),$(S_FILES)))

# These are just C_FILES without the overriden files
C_FILES := $(filter-out $(OVERRIDE_C_FILES),$(C_FILES))
S_FILES := $(filter-out $(OVERRIDE_S_FILES),$(S_FILES))

# This is path FROM ffmpeg dir INTO override dir inside jni
RELATIVE_PATH_FOR_OVERRIDE := ../../jni/$(DIR_NAME)

# Now just add relative path prefix for overriden files and add to other file
FFFILES := $(addprefix $(RELATIVE_PATH_FOR_OVERRIDE)/, $(OVERRIDE_S_FILES)) $(addprefix $(RELATIVE_PATH_FOR_OVERRIDE)/, $(OVERRIDE_C_FILES)) $(sort $(S_FILES)) $(sort $(C_FILES))
FFFILES := $(addprefix ../$(FFMPEG_ROOT)/$(DIR_NAME)/, $(FFFILES))

#$(warning $(FFFILES))
