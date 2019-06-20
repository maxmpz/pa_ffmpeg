#if !PAMP_CHANGES
#include "../../FFmpeg/libavcodec/alacdsp.c"
#else
/*
 * ALAC (Apple Lossless Audio Codec) decoder
 * Copyright (c) 2005 David Hammerton
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#include "libavutil/attributes.h"
#include "alacdsp.h"
#include "config.h"

static void decorrelate_stereo(int32_t *buffer[2], int nb_samples,
                               int decorr_shift, int decorr_left_weight)
{
    int i;

    int32_t* __restrict__ buffer0 = buffer[0];
    int32_t* __restrict__ buffer1 = buffer[1];

    const int cnb_samples = nb_samples;
    const int cdecorr_left_weight = decorr_left_weight;
    const int cdecorr_shift = decorr_shift;

    #pragma clang loop vectorize_width(4)
	#pragma clang loop interleave(enable)
    #pragma clang loop unroll_count(16)

    for (i = 0; i < cnb_samples; i++) {
        int32_t a, b;

        a = buffer0[i];
        b = buffer1[i];

        a -= (b * cdecorr_left_weight) >> cdecorr_shift;
        b += a;

        buffer0[i] = b;
        buffer1[i] = a;
    }
}

static void append_extra_bits(int32_t* buffer[2], int32_t* extra_bits_buffer[2],
                              int extra_bits, int channels, int nb_samples)
{
    const int cchannels = channels;
	const int cnb_samples = nb_samples;
	const int cextra_bits = extra_bits;

	if(channels == 2) {
		int32_t* __restrict__ buffer0 = buffer[0];
		int32_t* __restrict__ buffer1 = buffer[1];
		int32_t* __restrict__ extra_bits_buffer0 = extra_bits_buffer[0];
		int32_t* __restrict__ extra_bits_buffer1 = extra_bits_buffer[1];

		#pragma clang loop unroll_count(16)
        for (int i = 0; i < cnb_samples; i++) {
            buffer0[i] = (buffer0[i] << cextra_bits) | extra_bits_buffer0[i];
            buffer1[i] = (buffer1[i] << cextra_bits) | extra_bits_buffer1[i];
        }

	} else if(channels == 1) {
		for (int ch = 0; ch < cchannels; ch++) {
			for (int i = 0; i < cnb_samples; i++) {
				buffer[ch][i] = (buffer[ch][i] << cextra_bits) | extra_bits_buffer[ch][i]; // MaxMP: this will fail for # of channels > 2
			}
		}
	}
}

av_cold void ff_alacdsp_init(ALACDSPContext *c)
{
    c->decorrelate_stereo   = decorrelate_stereo;
    c->append_extra_bits[0] =
    c->append_extra_bits[1] = append_extra_bits;

    if (ARCH_X86)
        ff_alacdsp_init_x86(c);
}
#endif
