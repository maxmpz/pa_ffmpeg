#!/bin/bash

if [[ $1 != 'arm64' && $1 != 'neon' && $1 != 'neon-hard' && $1 != 'arm64-min' ]] ; then
    echo "Usage: build-all.sh arm64|neon|neon-hard|arm64-min"
    echo
    exit 1
fi

CMD=./build-$1.sh

echo Building everything for libffmpeg_neon.so target=$1

pushd ../mbedtls
$CMD
res=$?
popd
echo
if [ $res != 0 ]; then
	exit $res
fi

# NOTE: not necessary to run each time as once configured, all targets keep same files around
#pushd jni
#echo Configuring
#./pamp-config.sh $1 
#res=$?
#popd
#echo

res=0

if [ "$res" != 0 ]; then
	exit $res
fi

pushd audioplayer_ffmpeg_swresample/jni
echo Building audioplayer_ffmpeg_swresample
$CMD clean
$CMD 
res=$?
popd
echo

if [ $res != 0 ]; then
	exit $res
fi

pushd jni
echo Building audioplayer_ffmpeg
$CMD clean
$CMD 
res=$?
popd
echo

if [ $res != 0 ]; then
	exit $res
fi

echo DONE
 
