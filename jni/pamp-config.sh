#!/bin/bash

TARGET_CONFIG_SUFFIX=$1

if [[ $1 ==  'arm64' ]] ; then
	echo "Config: arm64"
	echo
	
elif [[ $1 == 'neon-hard' ]] ; then
	echo "Config: neon-hard"
	echo
	# NOTE: using -neon/-neon-min suffix for the neon-hard
	TARGET_CONFIG_SUFFIX=neon

elif [[ $1 == 'x64' ]] ; then
	echo "Config: x64"
	echo
	
elif [[ $1 ==  'arm64-min' ]] ; then
	echo "Config: arm64-min"
	echo
	
elif [[ $1 == 'neon-hard-min' ]] ; then
	echo "Config: neon-hard-min"
	echo
	# NOTE: using -neon/-neon-min suffix for the neon-hard
	TARGET_CONFIG_SUFFIX=neon-min

else 
    echo "Usage: pamp-config.sh neon-hard|arm64|x64|neon-hard-min|arm64-min"
    echo
    exit 1
fi

FFMPEG_PATH=../FFmpeg
NDK_PATH=/opt/android-ndk-r11c
GCC_VER=4.9
LOCAL_PATH=$PWD
MIN=

if [[ $1 ==  'arm64-min' ]] || [[ $1 == 'neon-hard-min' ]]; then
	MIN=1
fi


if [[ $1 ==  'arm64' ]] || [[ $1 ==  'arm64-min' ]]; then
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
		-Wl,--no-warn-mismatch -lm \
		-L$LOCAL_PATH/../../mbedtls/crypto/build/arm64-v8a \
		-L$LOCAL_PATH/../../mbedtls/build/arm64-v8a \
		"
	
elif [[ $1 == 'neon-hard' ]] || [[ $1 ==  'neon-hard-min' ]]; then
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
		-Wl,--no-warn-mismatch -lm_hard \
		-L$LOCAL_PATH/../../mbedtls/crypto/build/armeabi-v7a \
        -L$LOCAL_PATH/../../mbedtls/build/armeabi-v7a \
        "
elif [[ $1 == 'x64' ]] ; then
	FFMPEG_ARCH=aarch64
	PLATFORM=$NDK_PATH/platforms/android-21/arch-x86_64
	EABI=x86_64-4.9
	ARM_FF_FLAGS="-march=armv8-a+simd -O3 -D_NDK_MATH_NO_SOFTFP=1 "	
	PREBUILT=$NDK_PATH/toolchains/$EABI/prebuilt/darwin-x86_64
	GCC_PREFIX=aarch64-linux-android-
	LDFLAGS="--sysroot=$PLATFORM \
		-Wl,--no-whole-archive $PREBUILT/lib/gcc/aarch64-linux-android/$GCC_VER/libgcc.a \
		-Wl,--no-undefined -Wl,-z,noexecstack -L$PLATFORM/usr/lib \
		-llog -lz -lc \
		-Wl,--no-warn-mismatch -lm \
		"
# TODO: mbedtls x86_64 out build dirs
		
fi


NEON_CONFIG=" \
	$FF_FLAGS \
	--extra-cflags=\"-DANDROID --sysroot=$PLATFORM \
		$ARM_FF_FLAGS \
		-MMD -MP -fstrict-aliasing -Werror=strict-aliasing -ffunction-sections -funwind-tables -fstack-protector -Wno-psabi -fomit-frame-pointer \
		-std=c99 -Wno-sign-compare -Wno-switch -Wno-pointer-sign -ffast-math -Wa,--noexecstack -I$PLATFORM/usr/include \
		-I$LOCAL_PATH/../../mbedtls/include -I$LOCAL_PATH/../../mbedtls/crypto/include\""

#--enable-demuxer=wv \
#--enable-decoder=mp3 \
#--enable-decoder=mp2 \
#--enable-decoder=mp3on4 \
#--enable-decoder=mp3adu \
#--enable-avresample \
#--enable-decoder=wavpack \
#--enable-decoder=libopus \
#--enable-decoder=libopencore_amrnb \
#--enable-decoder=libopencore_amrwb \
#--enable-demuxer=amr \
#--enable-shared \
#--disable-fast-unaligned \
#--enable-protocol=crypto \
#--enable-protocol=tcp \
#--enable-protocol=udp \
#--enable-protocol=tls \

# NEW:

MIN_CONFIG="\
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
--enable-zlib \
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
--disable-swresample \
--disable-swscale \
\
--enable-version3 \
--enable-rdft \
--enable-avutil \
\
" 

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
--enable-zlib \
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
--enable-protocol=data \
\
--enable-version3 \
--enable-mbedtls \
--enable-network \
--enable-protocol=http \
--enable-protocol=https \
--enable-protocol=hls \
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
--enable-decoder=dca \
--enable-decoder=ac3 \
--enable-decoder=eac3 \
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
--enable-demuxer=hls \
--enable-demuxer=ac3 \
--enable-demuxer=eac3 \
--enable-parser=ac3 \
--enable-demuxer=wav \
--enable-demuxer=flv \
--enable-demuxer=live_flv \
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
--enable-demuxer=dts \
--enable-demuxer=dtshd \
--enable-parser=dca \
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

#--enable-protocol=cache \ # NOTE: cache requires file_open.c modification with TMPDIR support + appropirate TMPDIR env setting prior lib loading
#--enable-protocol=async \ # NOTE: doesn't work with hack for neon-hard (requires some work with pthreads inclusion)
# --env='async_protocol_deps=\"\"'\ hack, forcing async without threads dependency (which it doesn't actually require)

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


if [[ "$MIN" == 1 ]]; then
	#echo "$MIN_CONFIG $NEON_CONFIG"
	#exit 1
	eval "$MIN_CONFIG $NEON_CONFIG"
else
	#echo "$COMMON_CONFIG $NEON_CONFIG"
	#exit 1
	eval "$COMMON_CONFIG $NEON_CONFIG"
fi


if [ $? -ne 0 ]; then
	exit 1
fi

#libavutil/avconfig.h
#libavfilter/filter_list.c
#libavcodec/codec_list.c
#libavcodec/parser_list.c
#libavcodec/bsf_list.c
#libavformat/demuxer_list.c
#libavformat/muxer_list.c
#libavdevice/indev_list.c
#libavdevice/outdev_list.c
#libavformat/protocol_list.c
#ffbuild/config.sh is unchange

# Move copy all the generated files
mv ffbuild/config.mak ffbuild/config-${TARGET_CONFIG_SUFFIX}.mak  
mv config.h config-${TARGET_CONFIG_SUFFIX}.h  
mv libavutil/avconfig.h libavutil/avconfig-${TARGET_CONFIG_SUFFIX}.h
mv libavfilter/filter_list.c libavfilter/filter_list-${TARGET_CONFIG_SUFFIX}.c
mv libavcodec/codec_list.c libavcodec/codec_list-${TARGET_CONFIG_SUFFIX}.c
mv libavcodec/parser_list.c libavcodec/parser_list-${TARGET_CONFIG_SUFFIX}.c
mv libavcodec/bsf_list.c libavcodec/bsf_list-${TARGET_CONFIG_SUFFIX}.c
mv libavformat/demuxer_list.c libavformat/demuxer_list-${TARGET_CONFIG_SUFFIX}.c
#mv libavformat/muxer_list.c libavformat/muxer_list-${TARGET_CONFIG_SUFFIX}.c # NOTE: always nulls now
#mv libavdevice/indev_list.c libavdevice/indev_list-${TARGET_CONFIG_SUFFIX}.c # NOTE: always nulls now
#mv libavdevice/outdev_list.c libavdevice/outdev_list-${TARGET_CONFIG_SUFFIX}.c # NOTE: always nulls now
mv libavformat/protocol_list.c libavformat/protocol_list-${TARGET_CONFIG_SUFFIX}.c

cp config-pamp.h config.h
cp config-pamp.mak ffbuild/config.mak
cp libavutil/avconfig-pamp.h libavutil/avconfig.h
cp libavfilter/filter_list-pamp.c libavfilter/filter_list.c
cp libavcodec/codec_list-pamp.c libavcodec/codec_list.c
cp libavcodec/parser_list-pamp.c libavcodec/parser_list.c
cp libavcodec/bsf_list-pamp.c libavcodec/bsf_list.c
cp libavformat/demuxer_list-pamp.c libavformat/demuxer_list.c
#cp libavformat/muxer_list-pamp.c libavformat/muxer_list.c
#cp libavdevice/indev_list-pamp.c libavdevice/indev_list.c
#cp libavdevice/outdev_list-pamp.c libavdevice/outdev_list.c
cp libavformat/protocol_list-pamp.c libavformat/protocol_list.c

#mv libavutil/avconfig.h $FFMPEG_PATH/libavutil/

$FFMPEG_PATH/ffbuild/version.sh $FFMPEG_PATH libavutil/ffversion.h # NOTE: creates in jni/libavutil/  

#rm -f "./-ffunction-sections" # remove some trash after configure
#rm -f "./config.h" # remove some trash after configure
#rm -f "./config.mak" # remove some trash after configure
rm -f src

