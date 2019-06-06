#if !PAMP_CHANGES
#include "../FFmpeg/libavcodec/arm/mdct_vfp.S"
#else

// Empty
// No need in vfp func versions if we have neon versions: -8kb
#include "libavutil/arm/asm.S"

function ff_imdct_half_vfp, export=1
endfunc

#endif
