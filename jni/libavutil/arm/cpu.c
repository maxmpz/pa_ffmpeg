#if PAMP_CHANGES
// Avoid runtime cpu detection
#undef __linux__
#undef __ANDROID__
#endif
#include "../../../FFmpeg/libavutil/arm/cpu.c"
