#include "libavutil/avassert.h"

#if PAMP_CHANGES // Pamp change: disable unconditional assert
#undef av_assert0
#define av_assert0(cond) av_assert1(cond)
#endif


#include "../FFMpeg/libavcodec/parser.c"
