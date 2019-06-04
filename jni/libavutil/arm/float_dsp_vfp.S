// Empty
// No need in vfp func versions if we have neon versions: -8kb
#include "libavutil/arm/asm.S"

function ff_vector_fmul_vfp, export=1
endfunc

function ff_vector_fmul_window_vfp, export=1
endfunc

function ff_vector_fmul_reverse_vfp, export=1
endfunc

function ff_butterflies_float_vfp, export=1
endfunc



