#!/bin/bash

pushd jni
echo Configuring arm64
./pamp-config.sh arm64
res=$?
popd
echo

if [ $res -ne 0 ]; then
	exit $res
fi

pushd jni
echo Configuring neon-hard
./pamp-config.sh neon-hard
res=$?
popd
echo

if [ $res -ne 0 ]; then
	exit $res
fi

echo DONE
 
