// NOTE: overwritten by pamp-config.sh from config-pamp.h

#if HAVE_NEON
#	include "config-neon.h"
#elif defined(PAMP_D16)
#	include "config-d16.h"
#else
#	include "config-lowend.h"
#endif

#undef FFMPEG_CONFIGURATION
#define FFMPEG_CONFIGURATION ""

#undef CONFIG_LIBSOXR
#define CONFIG_LIBSOXR 1
