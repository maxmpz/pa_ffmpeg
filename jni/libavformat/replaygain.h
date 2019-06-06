// Both funcs becomes noop
#if !PAMP_CHANGES
#include "../FFmpeg/libavformat/replaygain.h"
#else

#ifndef AVFORMAT_REPLAYGAIN_H
#define AVFORMAT_REPLAYGAIN_H

#define ff_replaygain_export(...) (0)
#define ff_replaygain_export_raw(...) (0)

#endif

#endif
