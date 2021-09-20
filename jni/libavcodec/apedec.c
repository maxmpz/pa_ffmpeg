#if PAMP_OPTIMIZE_MACROS
#ifndef __clang__
#pragma GCC optimize ("O2")
#endif
#endif

#if PAMP_CHANGES
//#define ff_ape_decoder static ff_ape_decoder__
#endif

#include "../FFMpeg/libavcodec/apedec.c"

#if PAMP_CHANGES
#undef ff_ape_decoder
//
//static const AVOption options2[] = {
//    { "max_samples", NULL_IF_CONFIG_SMALL("maximum number of samples decoded per call"),             OFFSET(blocks_per_loop), AV_OPT_TYPE_INT,   { .i64 = 4608 },    1,       INT_MAX, PAR, "max_samples" },
////    { "all",         "no maximum. decode all samples for each packet at once", 0,                       AV_OPT_TYPE_CONST, { .i64 = INT_MAX }, INT_MIN, INT_MAX, PAR, "max_samples" },
//    { NULL},
//};
//
//static const AVClass ape_decoder_class2 = {
//    .class_name = "APE decoder",
//    .item_name  = av_default_item_name,
//    .option     = options2,
//    .version    = LIBAVUTIL_VERSION_INT,
//};
//
//AVCodec ff_ape_decoder = {
//    .name           = "ape",
//    .long_name      = NULL_IF_CONFIG_SMALL("Monkey's Audio"),
//    .type           = AVMEDIA_TYPE_AUDIO,
//    .id             = AV_CODEC_ID_APE,
//    .priv_data_size = sizeof(APEContext),
//    .init           = ape_decode_init,
//    .close          = ape_decode_close,
//    .decode         = ape_decode_frame,
//    .capabilities   = AV_CODEC_CAP_SUBFRAMES | AV_CODEC_CAP_DELAY |
//                      AV_CODEC_CAP_DR1,
//    .flush          = ape_flush,
//    .sample_fmts    = (const enum AVSampleFormat[]) { AV_SAMPLE_FMT_U8P,
//                                                      AV_SAMPLE_FMT_S16P,
//                                                      AV_SAMPLE_FMT_S32P,
//                                                      AV_SAMPLE_FMT_NONE },
//    .priv_class     = &ape_decoder_class2,
//};

#endif
