// NOTE: copied/moved by pamp-config.sh

#if HAVE_ARMV8
#	if HAVE_PA_MIN_MODE
#		include "parser_list-arm64-min.c"
#	else
#		include "parser_list-arm64.c"
#	endif
#elif HAVE_NEON
#	if HAVE_PA_MIN_MODE
#		include "parser_list-neon-min.c"
#	else
#		include "parser_list-neon.c"
#	endif
#else
#	error
#endif
