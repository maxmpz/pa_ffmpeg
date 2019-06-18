#if PAMP_CHANGES && HAVE_NEON && defined(PAMP_DISABLE_NEON_ASM)

#include "libavutil/cpu.h"

// NOTE: disable "neon" code, as it seems to be 25% slower
#define av_get_cpu_flags(...) (0)

#endif

#include "../../../FFmpeg/libswresample/arm/resample_init.c"
