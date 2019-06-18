#if PAMP_CHANGES && HAVE_NEON && defined(PAMP_DISABLE_NEON_ASM)

#include "libavutil/cpu.h"

#define av_get_cpu_flags(...) (0)

#endif

#include "../../../FFmpeg/libswresample/arm/audio_convert_init.c"
