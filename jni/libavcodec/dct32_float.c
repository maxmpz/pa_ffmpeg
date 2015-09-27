#pragma GCC optimize ("Os") // NOTE: best Os for mp3 dec

#include "libavutil/avassert.h"
#include "../FFMpeg/libavcodec/dct32_float.c"

// Stub: -4kb
#if PAMP_FFMPEG_STUBS
void ff_dct32_fixed(int *dst, const int *src) {
	av_assert0(0);
}
#endif
