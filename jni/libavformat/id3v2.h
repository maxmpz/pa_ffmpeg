#pragma once
#include "../FFmpeg/libavformat/id3v2.h"

#if PAMP_CONFIG_NO_TAGS
void ff_id3v2_read_dict2(AVFormatContext *s, AVIOContext *pb, AVDictionary **metadata, const char *magic, ID3v2ExtraMeta **extra_meta); // Pamp change: add new func with explicit AVFormatContext arg
#endif
