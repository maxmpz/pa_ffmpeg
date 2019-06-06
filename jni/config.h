// NOTE: overwritten by pamp-config.sh from config-pamp.h

#if HAVE_ARMV8
#	include "config-arm64.h"
#elif HAVE_NEON
#	include "config-neon.h"
#else
#error
#endif

#undef FFMPEG_CONFIGURATION
#define FFMPEG_CONFIGURATION ""

#undef CONFIG_LIBSOXR
#define CONFIG_LIBSOXR 1
