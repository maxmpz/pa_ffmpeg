#!/bin/sh

FFMPEG_PATH=../FFmpeg
NDK_PATH=/opt/android-ndk-r10d
PLATFORM=$NDK_PATH/platforms/android-14/arch-arm
GCC_VER=4.9
EABI=arm-linux-androideabi-4.9
PREBUILT=$NDK_PATH/toolchains/$EABI/prebuilt/darwin-x86_64

# HARD
#-mno-unaligned-access 
ARM_FF_FLAGS="-march=armv7-a -mcpu=cortex-a9 -mno-thumb-interwork -O3 -mfloat-abi=hard -mhard-float -D_NDK_MATH_NO_SOFTFP=1 \
-std=c99 -ffast-math -fstrict-aliasing -Werror=strict-aliasing"  

# SOFT
#ARM_FF_FLAGS="-march=armv7-a -mcpu=cortex-a9 -mno-thumb-interwork -mno-unaligned-access -Os -mfloat-abi=softfp \
#-std=c99 -ffast-math -fstrict-aliasing -Werror=strict-aliasing"  

NEON_AND_D16_CONFIG="--cpu=armv7-a \
--extra-cflags=\"-DANDROID --sysroot=$PLATFORM \
$ARM_FF_FLAGS \
-MMD -MP -ffunction-sections -funwind-tables -fstack-protector -Wno-psabi -fomit-frame-pointer \
-std=c99 -Wno-sign-compare -Wno-switch -Wno-pointer-sign -ffast-math -mno-thumb-interwork -Wa,--noexecstack -I$PLATFORM/usr/include "

#--enable-demuxer=wv \
#--enable-decoder=mp3 \
#--enable-decoder=mp2 \
#--enable-decoder=mp3on4 \
#--enable-decoder=mp3adu \
#--enable-avresample \
#--enable-decoder=wavpack \
#--enable-demuxer=wv \
#--enable-decoder=libopus \

D16_CONFIG="--disable-neon $NEON_AND_D16_CONFIG -mfpu=vfpv3-d16 \""
NEON_CONFIG="$NEON_AND_D16_CONFIG -mfpu=neon \""

LOWEND_CONFIG="--cpu=armv6 \
--disable-vfp \
--disable-neon \
--enable-decoder=mp3 \
--extra-cflags=\"-DANDROID --sysroot=$PLATFORM -MMD -MP -ffunction-sections \
-funwind-tables -fstack-protector -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ \
-Wno-psabi -mtune=xscale -msoft-float -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300 \
-std=c99 -Wno-sign-compare -Wno-switch -Wno-pointer-sign -ffast-math -mno-thumb-interwork \
-march=armv6 -mno-unaligned-access -Wa,--noexecstack -I$PLATFORM/arch-arm/usr/include -O0 \" "


LDFLAGS="--sysroot=$PLATFORM \
-Wl,--no-whole-archive $PREBUILT/lib/gcc/arm-linux-androideabi/$GCC_VER/libgcc.a \
-Wl,--no-undefined -Wl,-z,noexecstack -L$PLATFORM/usr/lib \
-llog -lz -lc \
-Wl,--no-warn-mismatch -lm_hard"

#--enable-decoder=libopencore_amrnb \
#--enable-decoder=libopencore_amrwb \
#--enable-demuxer=amr \
#--enable-shared \
#--disable-fast-unaligned \

# NEW: 

COMMON_CONFIG="\
$FFMPEG_PATH/configure --target-os=linux \
--arch=arm \
--enable-cross-compile \
--cc=$PREBUILT/bin/arm-linux-androideabi-gcc \
--as=$PREBUILT/bin/arm-linux-androideabi-gcc \
--cross-prefix=$PREBUILT/bin/arm-linux-androideabi- \
--sysinclude=$PLATFORM/usr/include \
--nm=$PREBUILT/bin/arm-linux-androideabi-nm \
--extra-ldflags=\"$LDFLAGS\" \
--enable-small \
--enable-pic \
\
--disable-runtime-cpudetect \
--disable-symver \
--disable-pixelutils \
--disable-doc \
--disable-dxva2 \
--disable-debug \
--disable-ffplay \
--disable-ffprobe \
--disable-ffserver \
--disable-avdevice \
--disable-swscale \
--disable-avfilter \
--disable-everything \
--disable-network \
--disable-vaapi \
--disable-vdpau \
--disable-pthreads \
\
--enable-protocol=file \
--enable-protocol=pipe \
--enable-protocol=http \
--enable-protocol=rtp \
\
--enable-decoder=aac \
--enable-decoder=mp3float \
--enable-decoder=mp2float \
--enable-decoder=mp3on4float \
--enable-decoder=mp3adufloat \
--enable-decoder=vorbis \
--enable-decoder=wmav1 \
--enable-decoder=wmav2 \
--enable-decoder=alac \
--enable-decoder=mace3 \
--enable-decoder=mace6 \
--enable-decoder=wmapro \
--enable-decoder=wmalossless \
--enable-decoder=ape \
--enable-decoder=tta \
--enable-decoder=flac \
--enable-decoder=opus \
--enable-decoder=tak \
--enable-decoder=dsd_* \
\
--enable-parser=opus \
--enable-parser=flac \
--enable-demuxer=flac \
--enable-parser=vorbis \
--enable-parser=tak \
--enable-demuxer=tak \
--enable-demuxer=dsf \
--enable-demuxer=iff \
\
--enable-decoder=mpc7 \
--enable-decoder=mpc8 \
--enable-demuxer=mpc \
--enable-demuxer=mpc8 \
\
--enable-demuxer=wav \
--enable-demuxer=flv \
--enable-demuxer=mp3 \
--enable-demuxer=mov \
--enable-demuxer=asf \
--enable-demuxer=gsm \
--enable-demuxer=aiff \
--enable-demuxer=ape \
--enable-demuxer=aac \
--enable-demuxer=ogg \
--enable-demuxer=tta \
--enable-parser=aac \
--enable-parser=mpegaudio \
--enable-parser=gsm \
\
--enable-decoder=pcm_s8 \
--enable-decoder=pcm_s8_planar \
--enable-decoder=pcm_s16be \
--enable-decoder=pcm_s16le \
--enable-decoder=pcm_u16be \
--enable-decoder=pcm_u16le \
--enable-decoder=pcm_s16be_planar \
--enable-decoder=pcm_s16le_planar \
--enable-decoder=pcm_f64le \
--enable-decoder=pcm_f64be \
--enable-decoder=pcm_s24be \
--enable-decoder=pcm_s24daud \
--enable-decoder=pcm_s24le \
--enable-decoder=pcm_s24le_planar \
--enable-decoder=pcm_u24be \
--enable-decoder=pcm_u24le \
--enable-decoder=pcm_s32be \
--enable-decoder=pcm_s32le \
--enable-decoder=pcm_u32be \
--enable-decoder=pcm_u32le \
--enable-decoder=pcm_f32be \
--enable-decoder=pcm_f32le \
--enable-decoder=pcm_s32le_planar \
--enable-decoder=pcm_alaw \
--enable-decoder=pcm_mulaw \
--enable-decoder=adpcm_ms \
--enable-decoder=adpcm_g726 \
--enable-decoder=gsm \
--enable-decoder=gsm_ms \
--enable-decoder=adpcm_ima_qt \
--enable-decoder=adpcm_4xm \
--enable-decoder=adpcm_adx \
--enable-decoder=adpcm_ct \
--enable-decoder=adpcm_ea \
--enable-decoder=adpcm_ea_maxis_xa \
--enable-decoder=adpcm_ea_r1 \
--enable-decoder=adpcm_ea_r2 \
--enable-decoder=adpcm_ea_r3 \
--enable-decoder=adpcm_ea_xas \
--enable-decoder=adpcm_ima_amv \
--enable-decoder=adpcm_ima_dk3 \
--enable-decoder=adpcm_ima_dk4 \
--enable-decoder=adpcm_ima_ea_eacs \
--enable-decoder=adpcm_ima_ea_sead \
--enable-decoder=adpcm_ima_iss \
--enable-decoder=adpcm_ima_smjpeg \
--enable-decoder=adpcm_ima_wav \
--enable-decoder=adpcm_ima_ws \
--enable-decoder=adpcm_swf \
--enable-decoder=adpcm_xa \
--enable-decoder=adpcm_yamaha \
--enable-decoder=pcm_zork \
--enable-decoder=pcm_bluray \
--enable-decoder=pcm_lxf \
--enable-decoder=pcm_dvd \
\
--enable-demuxer=pcm_s8 \
--enable-demuxer=pcm_u8 \
--enable-demuxer=pcm_s16be \
--enable-demuxer=pcm_s16le \
--enable-demuxer=pcm_u16be \
--enable-demuxer=pcm_u16le \
--enable-demuxer=pcm_u16be \
--enable-demuxer=pcm_u24be \
--enable-demuxer=pcm_u24le \
--enable-demuxer=pcm_s24be \
--enable-demuxer=pcm_s24le \
--enable-demuxer=pcm_u32be \
--enable-demuxer=pcm_u32le \
--enable-demuxer=pcm_s32be \
--enable-demuxer=pcm_s32le \
--enable-demuxer=pcm_f32be \
--enable-demuxer=pcm_f32le \
--enable-demuxer=pcm_f64be \
--enable-demuxer=pcm_f64le \
--enable-demuxer=pcm_alaw \
--enable-demuxer=pcm_mulaw \
\
"
# NOTE: tta demuxer is needed for tta decoder to read tags.



cp $FFMPEG_PATH/config.h $FFMPEG_PATH/config.old.h
rm -f $FFMPEG_PATH/config.h

#eval "$COMMON_CONFIG $LOWEND_CONFIG"
#if [ $? -ne 0 ]; then
#	exit 1
#fi
#cp config.h $FFMPEG_PATH/config-lowend.h
#cp config.mak $FFMPEG_PATH/config-lowend.mak

#eval "$COMMON_CONFIG $D16_CONFIG"
#if [ $? -ne 0 ]; then
	#exit 1
#fi
#cp config.h $FFMPEG_PATH/config-d16.h
#cp config.mak $FFMPEG_PATH/config-d16.mak

eval "$COMMON_CONFIG $NEON_CONFIG"
if [ $? -ne 0 ]; then
	exit 1
fi
cp config.h $FFMPEG_PATH/config-neon.h
cp config.mak $FFMPEG_PATH/config-neon.mak

cp config-pamp.h $FFMPEG_PATH/config.h
cp config-pamp.mak $FFMPEG_PATH/config.mak

mv libavutil/avconfig.h $FFMPEG_PATH/libavutil/

$FFMPEG_PATH/version.sh $FFMPEG_PATH libavutil/ffversion.h # NOTE: creates in jni/libavutil/  

#rm -f "./-ffunction-sections" # remove some trash after configure
rm -f "./config.h" # remove some trash after configure
rm -f "./config.mak" # remove some trash after configure

