#!/bin/bash


if [[ $1 ==  'arm64' ]] ; then
	echo "Config: arm64"
	echo
	
elif [[ $1 == 'neon' ]] ; then
	echo "Config: neon"
	echo
	
else 
    echo "Usage: pamp-config.sh neon|arm64"
    echo
    exit 1
fi

FFMPEG_PATH=../FFmpeg
NDK_PATH=/opt/android-ndk-r10e
GCC_VER=4.9

if [[ $1 ==  'arm64' ]] ; then
	FFMPEG_ARCH=aarch64
	PLATFORM=$NDK_PATH/platforms/android-21/arch-arm64
	EABI=aarch64-linux-android-4.9
	ARM_FF_FLAGS="-march=armv8-a+simd -O3 -D_NDK_MATH_NO_SOFTFP=1 "	
	PREBUILT=$NDK_PATH/toolchains/$EABI/prebuilt/darwin-x86_64
	GCC_PREFIX=aarch64-linux-android-
	LDFLAGS="--sysroot=$PLATFORM \
		-Wl,--no-whole-archive $PREBUILT/lib/gcc/aarch64-linux-android/$GCC_VER/libgcc.a \
		-Wl,--no-undefined -Wl,-z,noexecstack -L$PLATFORM/usr/lib \
		-llog -lz -lc \
		-Wl,--no-warn-mismatch -lm"
	TARGET_CONFIG_FILENAME=config-arm64	
	
elif [[ $1 == 'neon' ]] ; then
	FFMPEG_ARCH=arm
	PLATFORM=$NDK_PATH/platforms/android-21/arch-arm
	EABI=arm-linux-androideabi-4.9
	
	# HARD
	#-mno-unaligned-access 
	ARM_FF_FLAGS="-march=armv7-a -mcpu=cortex-a9 -mfpu=neon -O3 -mfloat-abi=hard -mhard-float -D_NDK_MATH_NO_SOFTFP=1"  

	# SOFT
	#ARM_FF_FLAGS="-march=armv7-a -mcpu=cortex-a9 -mno-thumb-interwork -mno-unaligned-access -Os -mfloat-abi=softfp \
	PREBUILT=$NDK_PATH/toolchains/$EABI/prebuilt/darwin-x86_64	
	GCC_PREFIX=arm-linux-androideabi-
	FF_FLAGS=--cpu=armv7-a 
	LDFLAGS="--sysroot=$PLATFORM \
		-Wl,--no-whole-archive $PREBUILT/lib/gcc/arm-linux-androideabi/$GCC_VER/libgcc.a \
		-Wl,--no-undefined -Wl,-z,noexecstack -L$PLATFORM/usr/lib \
		-llog -lz -lc \
		-Wl,--no-warn-mismatch -lm_hard"
	TARGET_CONFIG_FILENAME=config-neon
fi


NEON_CONFIG=" \
	$FF_FLAGS \
	--extra-cflags=\"-DANDROID --sysroot=$PLATFORM \
		$ARM_FF_FLAGS \
		-MMD -MP -fstrict-aliasing -Werror=strict-aliasing -ffunction-sections -funwind-tables -fstack-protector -Wno-psabi -fomit-frame-pointer \
		-std=c99 -Wno-sign-compare -Wno-switch -Wno-pointer-sign -ffast-math -Wa,--noexecstack -I$PLATFORM/usr/include \""

#--enable-demuxer=wv \
#--enable-decoder=mp3 \
#--enable-decoder=mp2 \
#--enable-decoder=mp3on4 \
#--enable-decoder=mp3adu \
#--enable-avresample \
#--enable-decoder=wavpack \
#--enable-demuxer=wv \
#--enable-decoder=libopus \
#--enable-decoder=libopencore_amrnb \
#--enable-decoder=libopencore_amrwb \
#--enable-demuxer=amr \
#--enable-shared \
#--disable-fast-unaligned \

# NEW: 

COMMON_CONFIG="\
$FFMPEG_PATH/configure --target-os=linux \
--arch=$FFMPEG_ARCH \
--enable-cross-compile \
--cc=$PREBUILT/bin/${GCC_PREFIX}gcc \
--as=$PREBUILT/bin/${GCC_PREFIX}gcc \
--cross-prefix=$PREBUILT/bin/${GCC_PREFIX} \
--sysinclude=$PLATFORM/usr/include \
--nm=$PREBUILT/bin/${GCC_PREFIX}nm \
--extra-ldflags=\"$LDFLAGS\" \
--enable-small \
--enable-pic \
\
--disable-autodetect \
--disable-runtime-cpudetect \
--disable-symver \
--disable-pixelutils \
--disable-doc \
--disable-debug \
--disable-programs \
--disable-avdevice \
--disable-swscale \
--disable-avfilter \
--disable-everything \
--disable-network \
--disable-pthreads \
--disable-faan \
--disable-lzo \
--disable-parser=dirac \
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
--enable-decoder=wmapro \
--enable-decoder=wmalossless \
--enable-decoder=ape \
--enable-decoder=tta \
--enable-decoder=flac \
--enable-decoder=opus \
--enable-decoder=tak \
--enable-decoder=dsd_* \
--enable-decoder=dst \
--enable-decoder=als \
--enable-decoder=mlp \
--enable-decoder=truehd \
\
--enable-parser=opus \
--enable-parser=flac \
--enable-parser=mlp \
--enable-demuxer=flac \
--enable-parser=vorbis \
--enable-parser=tak \
--enable-demuxer=tak \
--enable-demuxer=dsf \
--enable-demuxer=iff \
--enable-demuxer=matroska \
--enable-demuxer=mpegts \
--enable-demuxer=mpegtsraw \
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
--enable-parser=mlp \
--enable-parser=truehd \
\
--enable-decoder=pcm_s8 \
--enable-decoder=pcm_s8_planar \
--enable-decoder=pcm_u8 \
--enable-decoder=pcm_s16be \
--enable-decoder=pcm_s16le \
--enable-decoder=pcm_u16be \
--enable-decoder=pcm_u16le \
--enable-decoder=pcm_s16be_planar \
--enable-decoder=pcm_s16le_planar \
--enable-decoder=pcm_f16le \
--enable-decoder=pcm_f24le \
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
--enable-decoder=pcm_zork \
--enable-decoder=pcm_bluray \
--enable-decoder=pcm_lxf \
--enable-decoder=pcm_dvd \
\
--enable-decoder=gsm \
--enable-decoder=gsm_ms \
\
--enable-decoder=adpcm_4xm	 \
--enable-decoder=adpcm_adx	 \
--enable-decoder=adpcm_afc	 \
--enable-decoder=adpcm_ct	 \
--enable-decoder=adpcm_dtk	 \
--enable-decoder=adpcm_ea	 \
--enable-decoder=adpcm_ea_maxis_xa \
--enable-decoder=adpcm_ea_r1	 \
--enable-decoder=adpcm_ea_r2	 \
--enable-decoder=adpcm_ea_r3	 \
--enable-decoder=adpcm_ea_xas \
--enable-decoder=adpcm_g722	 \
--enable-decoder=adpcm_g726	 \
--enable-decoder=adpcm_g726le \
--enable-decoder=g723_1 \
--enable-decoder=g729 \
--enable-decoder=adpcm_ima_amv \
--enable-decoder=adpcm_ima_apc \
--enable-decoder=adpcm_ima_dk3 \
--enable-decoder=adpcm_ima_dk4 \
--enable-decoder=adpcm_ima_ea_eacs \
--enable-decoder=adpcm_ima_ea_sead \
--enable-decoder=adpcm_ima_iss \
--enable-decoder=adpcm_ima_oki \
--enable-decoder=adpcm_ima_qt \
--enable-decoder=adpcm_ima_rad \
--enable-decoder=adpcm_ima_smjpeg \
--enable-decoder=adpcm_ima_wav \
--enable-decoder=adpcm_ima_ws \
--enable-decoder=adpcm_ms	 \
--enable-decoder=adpcm_swf	 \
--enable-decoder=adpcm_xa \
--enable-decoder=adpcm_yamaha \
\
--enable-demuxer=pcm_s8 \
--enable-demuxer=pcm_u8 \
--enable-demuxer=pcm_s16be \
--enable-demuxer=pcm_s16le \
--enable-demuxer=pcm_u16be \
--enable-demuxer=pcm_u16le \
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
--enable-demuxer=g722 \
--enable-demuxer=g723_1 \
--enable-demuxer=g729 \
\
"

#--enable-decoder=mace3 \
#--enable-decoder=mace6 \
#--enable-decoder=mpc7 \
#--enable-decoder=mpc8 \
#--enable-demuxer=mpc \
#--enable-demuxer=mpc8 \

# NOTE: tta demuxer is needed for tta decoder to read tags.
#--enable-demuxer=afc \
#--enable-demuxer=adx \
#--enable-demuxer=adp \
#--enable-demuxer=thp \
#--enable-demuxer=xa \
#--enable-demuxer=smjpeg \
#--enable-demuxer=siff \

#--enable-decoder=adpcm_sbpro_2 \
#--enable-decoder=adpcm_sbpro_3 \
#--enable-decoder=adpcm_sbpro_4 \
#--enable-decoder=adpcm_thp	 \
#--enable-decoder=adpcm_vima \

#cp $FFMPEG_PATH/config.h $FFMPEG_PATH/config.old.h
rm -f config.h

#echo "$COMMON_CONFIG $NEON_CONFIG"
#exit 1

eval "$COMMON_CONFIG $NEON_CONFIG"
if [ $? -ne 0 ]; then
	exit 1
fi

mv config.h ${TARGET_CONFIG_FILENAME}.h  # REVISIT: use local dir
mv ffbuild/config.mak ffbuild/${TARGET_CONFIG_FILENAME}.mak  # REVISIT: use local dir

cp config-pamp.h config.h
cp config-pamp.mak ffbuild/config.mak

#mv libavutil/avconfig.h $FFMPEG_PATH/libavutil/

$FFMPEG_PATH/ffbuild/version.sh $FFMPEG_PATH libavutil/ffversion.h # NOTE: creates in jni/libavutil/  

#rm -f "./-ffunction-sections" # remove some trash after configure
#rm -f "./config.h" # remove some trash after configure
#rm -f "./config.mak" # remove some trash after configure
rm -f src

