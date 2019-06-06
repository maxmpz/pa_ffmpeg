$(call clear-vars, $(FFMPEG_CONFIG_VARS))

# DIR_NAME = libavcodec libavformat libavutil libswresample ...
DIR_NAME := $(notdir $(basename $(LOCAL_PATH)))

FFMPEG_LOCAL_PATH := $(FFMPEG_ROOT)/$(DIR_NAME)

SUBDIR := $(FFMPEG_LOCAL_PATH)/

# NOTE: using .maks from overridden == jni/ffbuild/ location
ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
include $(FFMPEG_OVERRIDE_ROOT)/ffbuild/config-arm64.mak

else ifeq ($(TARGET_ARCH_ABI),armeabi-v7a-hard)
include $(FFMPEG_OVERRIDE_ROOT)/ffbuild/config-neon.mak

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
ARMV8-OBJS :=
ARMV8-OBJS-yes :=

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
ifeq ($(HAVE_ARMV8),yes)
	OBJS += $(ARMV8-OBJS) $(ARMV8-OBJS-yes)
endif

FFNAME := lib$(NAME)
FFLIBS := $(foreach,NAME,$(FFLIBS),lib$(NAME))

LOCAL_CFLAGS :=  \
	-Wno-sign-compare -Wno-switch -Wno-pointer-sign \
	-Wno-format -Wno-deprecated-declarations -Wno-cast-qual \
	-Wno-parentheses  \
	
#	-Wno-incompatible-pointer-types -Wno-logical-op-parentheses -Wno-asm-operand-widths -Wno-unknown-warning-option  
  
ifneq ($(GLOBAL_APPLY_FFMPEG_OPTS),true)
LOCAL_OBJS_TO_REMOVE := 
endif  
  
  
ifneq ($(LOCAL_OBJS_TO_REMOVE),)
OBJS := $(filter-out $(LOCAL_OBJS_TO_REMOVE),$(OBJS))
LOCAL_OBJS_TO_REMOVE :=
endif

# OBJS now have all files to build - both .S and .c - as .o; for ndk-build we need to prepare source files list

ALL_S_FILES := $(wildcard $(FFMPEG_LOCAL_PATH)/$(ARCH)/*.S)
ALL_S_FILES := $(addprefix $(ARCH)/, $(notdir $(ALL_S_FILES)))

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
OVERRIDE_S_FILES := $(wildcard $(LOCAL_PATH)/$(ARCH)/*.S)
# now just arm/*.S
OVERRIDE_S_FILES := $(addprefix $(ARCH)/, $(notdir $(OVERRIDE_FILES)))



# This is path FROM ffmpeg dir INTO parent override jni dir instead of this jni
RELATIVE_PATH_FOR_OVERRIDE := $(FFMPEG_OVERRIDE_ROOT)/$(DIR_NAME)


# This is our override files - all of them - including those which are probably not in OBJS. Paths relative to DIR_NAME: file.c ... arm/file.c
OVERRIDE_C_FILES := $(notdir $(wildcard $(RELATIVE_PATH_FOR_OVERRIDE)/*.c)) $(addprefix $(ARCH)/, $(notdir $(wildcard $(RELATIVE_PATH_FOR_OVERRIDE)/$(ARCH)/*.c)))
OVERRIDE_S_FILES := $(addprefix $(ARCH)/, $(notdir $(wildcard $(RELATIVE_PATH_FOR_OVERRIDE)/$(ARCH)/*.S)))

# These are just the overriden files which were also in C_FILES
OVERRIDE_C_FILES := $(sort $(filter $(OVERRIDE_C_FILES),$(C_FILES)))
OVERRIDE_S_FILES := $(sort $(filter $(OVERRIDE_S_FILES),$(S_FILES)))


# These are just C_FILES without the overriden files
C_FILES := $(filter-out $(OVERRIDE_C_FILES),$(C_FILES))
S_FILES := $(filter-out $(OVERRIDE_S_FILES),$(S_FILES))


# Now just add relative path prefix for overriden files and add to other file
FFFILES := $(addprefix $(RELATIVE_PATH_FOR_OVERRIDE)/, $(OVERRIDE_S_FILES)) $(addprefix $(RELATIVE_PATH_FOR_OVERRIDE)/, $(OVERRIDE_C_FILES)) $(sort $(S_FILES)) $(sort $(C_FILES))
FFFILES := $(addprefix ../$(FFMPEG_ROOT)/$(DIR_NAME)/, $(FFFILES))

#$(error  $(FFFILES))

