// NOTE: overwritten by pamp-config.sh from config-pamp.h

#if HAVE_ARMV8
#	include "config-arm64.h"
#elif HAVE_NEON
#	include "config-neon.h"
#	undef HAVE_VFP_ARGS // NOTE: IMPORTANT to propertly handle soft/hard floats for passing params to .S
#	if _NDK_MATH_NO_SOFTFP
#		define HAVE_VFP_ARGS 1
#	else
#		define HAVE_VFP_ARGS 0
#	endif
#else
	#error
#endif

#ifndef PAMP_FFMPEG_CONFIGURATION // This one should be provided by Android.mk
#define PAMP_FFMPEG_CONFIGURATION ""
#endif

#undef FFMPEG_CONFIGURATION

#if defined(__clang_major__)
#define FFMPEG_CONFIGURATION PAMP_FFMPEG_CONFIGURATION" "AV_STRINGIFY(__clang_major__)"."AV_STRINGIFY(__clang_minor__)
#elif defined(__GNUC_MINOR__)
#define FFMPEG_CONFIGURATION PAMP_FFMPEG_CONFIGURATION
#else
#define FFMPEG_CONFIGURATION PAMP_FFMPEG_CONFIGURATION
#endif

#undef CONFIG_LIBSOXR
#define CONFIG_LIBSOXR 1
