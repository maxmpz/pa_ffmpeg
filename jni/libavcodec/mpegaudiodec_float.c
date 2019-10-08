#if PAMP_OPTIMIZE_MACROS
#pragma GCC optimize ("O2")
//#pragma GCC optimize ("-funroll-loops")
//#pragma GCC optimize ("-funroll-all-loops")
//#pragma GCC optimize ("-fno-tree-vectorize")
//#pragma GCC optimize ("-ftree-vectorize")
//#pragma GCC optimize ("-ftree-loop-if-convert-stores")
//#pragma GCC optimize ("-fno-tree-loop-if-convert")
#endif

#include "libavutil/log.h"

#undef AV_LOG_ERROR
#define AV_LOG_ERROR AV_LOG_DEBUG // Reduce log spam

#include "../FFMpeg/libavcodec/mpegaudiodec_float.c"
