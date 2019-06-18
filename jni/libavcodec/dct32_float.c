#if PAMP_OPTIMIZE_MACROS
#pragma GCC optimize ("Os") // NOTE: Os vs O3 here is -30ms from sample mp3 decoding
//#pragma GCC optimize ("-funroll-loops")
//#pragma GCC optimize ("-funroll-all-loops")
//#pragma GCC optimize ("-fno-tree-vectorize")
//#pragma GCC optimize ("-ftree-loop-if-convert-stores")
//#pragma GCC optimize ("-ftree-vectorize")
#endif

#include "../../FFmpeg/libavcodec/dct32_float.c"
