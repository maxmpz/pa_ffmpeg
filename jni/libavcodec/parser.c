#include "libavutil/avassert.h"

#if PAMP_CHANGES // Pamp change: disable unconditional assert
#undef avassert0
#define avassert0 avassert1
#endif

#include "../FFMpeg/libavcodec/parser.c"
