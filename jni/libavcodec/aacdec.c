#pragma GCC optimize ("O3")

#include "libavutil/log.h"

#undef AV_LOG_ERROR
#define AV_LOG_ERROR AV_LOG_WARNING

#include "../FFMpeg/libavcodec/aacdec.c"
