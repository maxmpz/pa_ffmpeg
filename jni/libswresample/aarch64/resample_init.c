#if PAMP_CHANGES && HAVE_NEON && HAVE_ARMV8 && defined(PAMP_DISABLE_NEON_ASM)

#include "libavutil/cpu.h"

// NOTE: disable "neon" code for arm64, as it seems to be 25% slower
#define av_get_cpu_flags(...) (0)

#endif

#include "../../../FFmpeg/libswresample/aarch64/resample_init.c"
