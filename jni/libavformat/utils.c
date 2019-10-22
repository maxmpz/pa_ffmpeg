#include "id3v2.h"
#if PAMP_CONFIG_NO_TAGS
#define ff_id3v2_read_dict(...) ff_id3v2_read_dict2(s, __VA_ARGS__)
#endif

#include "../FFmpeg/libavformat/utils.c"
