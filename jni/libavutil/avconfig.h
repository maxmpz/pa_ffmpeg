// NOTE: copied/moved by pamp-config.sh

#if HAVE_ARMV8
#	if HAVE_PA_MIN_MODE
#		include "avconfig-arm64-min.h"
#	else
#		include "avconfig-arm64.h"
#	endif
#elif HAVE_NEON
#	if HAVE_PA_MIN_MODE
#		include "avconfig-neon-min.h"
#	else
#		include "avconfig-neon.h"
#	endif
#else
	#error Unknown config!
#endif
