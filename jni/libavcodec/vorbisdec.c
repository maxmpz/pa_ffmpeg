#if PAMP_OPTIMIZE_MACROS
#pragma GCC optimize ("O2")
#endif

// PAMP change - avoid file paths leaking to .so
#if PAMP_CHANGES
#undef __FILE__
#define __FILE__ ("")
#endif
#include "../FFMpeg/libavcodec/vorbisdec.c"
