#pragma GCC optimize ("O3")
#pragma GCC optimize ("-funroll-loops")

#include "libavutil/avassert.h"
#include "../FFMpeg/libavcodec/mpegaudiodsp_float.c"

// Stubs: -4kb
#if PAMP_FFMPEG_STUBS
void ff_init_mpadsp_tabs_fixed(void) {
}

void ff_mpa_synth_filter_fixed(MPADSPContext *s,
                               int32_t *synth_buf_ptr, int *synth_buf_offset,
                               int32_t *window, int *dither_state,
                               int16_t *samples, int incr,
                               int32_t *sb_samples) {
	av_assert0(0);
}


void ff_mpa_synth_init_fixed(int32_t *window) {
	av_assert0(0);
}

void ff_mpadsp_apply_window_fixed(int32_t *synth_buf, int32_t *window,
                                  int *dither_state, int16_t *samples,
                                  int incr) {
	av_assert0(0);
}

void ff_imdct36_blocks_fixed(int *out, int *buf, int *in,
                             int count, int switch_point, int block_type) {
	av_assert0(0);
}


void ff_mpadsp_apply_window_fixed_armv6(int32_t *synth_buf, int32_t *window,
                                        int *dither, int16_t *out, int incr) {
	av_assert0(0);
}
#endif
