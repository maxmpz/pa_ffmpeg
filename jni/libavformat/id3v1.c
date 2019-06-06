#if !PAMP_CHANGES
#include "../FFmpeg/libavformat/id3v1.c"
#else

#include "id3v1.h"
#include "libavcodec/avcodec.h"
#include "libavutil/dict.h"

void ff_id3v1_read(AVFormatContext *s)
{
	// PAMP Change - do nothing
}
#endif
