#if PAMP_CHANGES && HAVE_NEON && HAVE_ARMV8 && defined(PAMP_DISABLE_NEON_ASM)

#include "libavutil/cpu.h"

#define av_get_cpu_flags(...) (0)

#endif

#include "../../../FFmpeg/libswresample/aarch64/audio_convert_init.c"
