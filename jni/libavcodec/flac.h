/*
 * FLAC (Free Lossless Audio Codec) decoder/demuxer common functions
 * Copyright (c) 2008 Justin Ruggles
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

/**
 * @file
 * FLAC (Free Lossless Audio Codec) decoder/demuxer common functions
 */

#ifndef AVCODEC_FLAC_H
#define AVCODEC_FLAC_H

#include "libavcodec/avcodec.h"
#include "libavcodec/bytestream.h"
#include "libavcodec/get_bits.h"

#define FLAC_STREAMINFO_SIZE   34
#define FLAC_MAX_CHANNELS       8
#define FLAC_MIN_BLOCKSIZE     16
#define FLAC_MAX_BLOCKSIZE  65535
#define FLAC_MIN_FRAME_SIZE    11

enum {
    FLAC_CHMODE_INDEPENDENT = 0,
    FLAC_CHMODE_LEFT_SIDE   = 1,
    FLAC_CHMODE_RIGHT_SIDE  = 2,
    FLAC_CHMODE_MID_SIDE    = 3,
};

enum {
    FLAC_METADATA_TYPE_STREAMINFO = 0,
    FLAC_METADATA_TYPE_PADDING,
    FLAC_METADATA_TYPE_APPLICATION,
    FLAC_METADATA_TYPE_SEEKTABLE,
    FLAC_METADATA_TYPE_VORBIS_COMMENT,
    FLAC_METADATA_TYPE_CUESHEET,
    FLAC_METADATA_TYPE_PICTURE,
    FLAC_METADATA_TYPE_INVALID = 127
};

enum FLACExtradataFormat {
    FLAC_EXTRADATA_FORMAT_STREAMINFO  = 0,
    FLAC_EXTRADATA_FORMAT_FULL_HEADER = 1
};

#define FLACCOMMONINFO \
    int samplerate;         /**< sample rate                             */\
    int channels;           /**< number of channels                      */\
    int bps;                /**< bits-per-sample                         */\

/**
 * Data needed from the Streaminfo header for use by the raw FLAC demuxer
 * and/or the FLAC decoder.
 */
#define FLACSTREAMINFO \
    FLACCOMMONINFO \
    int max_blocksize;      /**< maximum block size, in samples          */\
    int max_framesize;      /**< maximum frame size, in bytes            */\
    int64_t samples;        /**< total number of samples                 */\

typedef struct FLACStreaminfo {
    FLACSTREAMINFO
} FLACStreaminfo;

typedef struct FLACFrameInfo {
    FLACCOMMONINFO
    int blocksize;          /**< block size of the frame                 */
    int ch_mode;            /**< channel decorrelation mode              */
    int64_t frame_or_sample_num;    /**< frame number or sample number   */
    int is_var_size;                /**< specifies if the stream uses variable
                                         block sizes or a fixed block size;
                                         also determines the meaning of
                                         frame_or_sample_num             */
} FLACFrameInfo;

#if PAMP_CHANGES // Pamp change: moved to flac.h
#include "libavcodec/flacdsp.h"
typedef struct FLACContext {
    AVClass *class;
    struct FLACStreaminfo flac_stream_info;

    AVCodecContext *avctx;                  ///< parent AVCodecContext
    GetBitContext gb;                       ///< GetBitContext initialized to start at the current frame

    int blocksize;                          ///< number of samples in the current frame
    int sample_shift;                       ///< shift required to make output samples 16-bit or 32-bit
    int ch_mode;                            ///< channel decorrelation type in the current frame
    int got_streaminfo;                     ///< indicates if the STREAMINFO has been read

    int32_t *decoded[FLAC_MAX_CHANNELS];    ///< decoded samples
    uint8_t *decoded_buffer;
    unsigned int decoded_buffer_size;
    int buggy_lpc;                          ///< use workaround for old lavc encoded files

    FLACDSPContext dsp;
} FLACContext;
#endif

/**
 * Parse the Streaminfo metadata block
 * @param[out] avctx   codec context to set basic stream parameters
 * @param[out] s       where parsed information is stored
 * @param[in]  buffer  pointer to start of 34-byte streaminfo data
 *
 * @return negative error code on faiure or >= 0 on success
 */
int ff_flac_parse_streaminfo(AVCodecContext *avctx, struct FLACStreaminfo *s,
                              const uint8_t *buffer);

/**
 * Validate the FLAC extradata.
 * @param[in]  avctx codec context containing the extradata.
 * @param[out] format extradata format.
 * @param[out] streaminfo_start pointer to start of 34-byte STREAMINFO data.
 * @return 1 if valid, 0 if not valid.
 */
int ff_flac_is_extradata_valid(AVCodecContext *avctx,
                               enum FLACExtradataFormat *format,
                               uint8_t **streaminfo_start);

/**
 * Calculate an estimate for the maximum frame size based on verbatim mode.
 * @param blocksize block size, in samples
 * @param ch number of channels
 * @param bps bits-per-sample
 */
int ff_flac_get_max_frame_size(int blocksize, int ch, int bps);

/**
 * Validate and decode a frame header.
 * @param      avctx AVCodecContext to use as av_log() context
 * @param      gb    GetBitContext from which to read frame header
 * @param[out] fi    frame information
 * @param      log_level_offset  log level offset. can be used to silence error messages.
 * @return non-zero on error, 0 if ok
 */
int ff_flac_decode_frame_header(AVCodecContext *avctx, GetBitContext *gb,
                                FLACFrameInfo *fi, int log_level_offset);

void ff_flac_set_channel_layout(AVCodecContext *avctx);

/**
 * Parse the metadata block parameters from the header.
 * @param[in]  block_header header data, at least 4 bytes
 * @param[out] last indicator for last metadata block
 * @param[out] type metadata block type
 * @param[out] size metadata block size
 */
static av_always_inline void flac_parse_block_header(const uint8_t *block_header,
                                                      int *last, int *type, int *size)
{
    int tmp = bytestream_get_byte(&block_header);
    if (last)
        *last = tmp & 0x80;
    if (type)
        *type = tmp & 0x7F;
    if (size)
        *size = bytestream_get_be24(&block_header);
}

#endif /* AVCODEC_FLAC_H */
