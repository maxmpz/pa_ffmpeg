#!/bin/bash

if [[ $1 != 'arm64' && $1 != 'neon' ]] ; then
    echo "Usage: build-all.sh neon|arm64"
    echo
    exit 1
fi

if [[ $1 == 'arm64' ]]; then
CMD=./build-arm64.sh
elif [[ $1 == 'neon' ]] ; then
CMD=./build-neon.sh
fi

echo Building everything for libffmpeg_neon.so $1

echo Building arm64
echo

# NOTE: not necessary to run each time as once configured, all targets keep same files around
#pushd jni
#echo Configuring
#./pamp-config.sh $1 
#res=$?
#popd
#echo

if [ $res -ne 0 ]; then
	exit $res
fi

pushd audioplayer_ffmpeg_swresample/jni
echo Building audioplayer_ffmpeg_swresample
$CMD clean
$CMD 
res=$?
popd
echo

if [ $res -ne 0 ]; then
	exit $res
fi

pushd jni
echo Building audioplayer_ffmpeg
$CMD clean
$CMD 
res=$?
popd
echo

if [ $res -ne 0 ]; then
	exit $res
fi

echo DONE
 
