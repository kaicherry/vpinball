#!/bin/bash

set -e

SDL2_VERSION=2.28.5
SDL2_IMAGE_VERSION=2.6.3

PINMAME_SHA=505d906a1f6d113f646007c85eddd8f32bc06cb8
LIBALTSOUND_SHA=3f17617df55c46efd101885b015e67a48663cada
LIBDMDUTIL_SHA=9a3abffa41df66113b7d5af6e11148333defd693

if [[ $(uname) == "Linux" ]]; then
	NUM_PROCS=$(nproc)
elif [[ $(uname) == "Darwin" ]]; then
	NUM_PROCS=$(sysctl -n hw.ncpu)
else
	NUM_PROCS=1
fi

echo "Building external libraries..."
echo "  SDL2_VERSION: ${SDL2_VERSION}"
echo "  SDL2_IMAGE_VERSION: ${SDL2_IMAGE_VERSION}"
echo "  PINMAME_SHA: ${PINMAME_SHA}"
echo "  LIBALTSOUND_SHA: ${LIBALTSOUND_SHA}"
echo "  LIBDMDUTIL_SHA: ${LIBDMDUTIL_SHA}"
echo ""

if [ -z "${BUILD_TYPE}" ]; then
   BUILD_TYPE="Release"
fi

echo "Build type: ${BUILD_TYPE}"
echo "Procs: ${NUM_PROCS}"
echo ""

rm -rf external
mkdir external
mkdir external/include
mkdir external/lib

rm -rf tmp
mkdir tmp
cd tmp

#
# build freeimage, and copy to external
#

curl -sL https://downloads.sourceforge.net/project/freeimage/Source%20Distribution/3.18.0/FreeImage3180.zip -o FreeImage3180.zip
unzip FreeImage3180.zip
cd FreeImage
cp ../../freeimage/Android.mk Android.mk
cd ..

$ANDROID_NDK_HOME/ndk-build \
	-C FreeImage \
	-j${NUM_PROC} \
	NDK_PROJECT_PATH=$ANDROID_NDK_HOME \
	APP_BUILD_SCRIPT=$(pwd)/FreeImage/Android.mk \
	APP_STL="c++_static" \
	APP_PLATFORM=android-19 \
	APP_ABI=arm64-v8a \
	NDK_OUT=$(pwd)/obj \
	NDK_LIBS_OUT=$(pwd)/libs

cp libs/arm64-v8a/libFreeImage.so ../external/lib

#
# download bass24 and copy to external
#

curl -sL https://www.un4seen.com/files/bass24-android.zip -o bass.zip
unzip bass.zip 
cp libs/arm64-v8a/libbass.so ../external/lib

#
# build SDL2 and copy to external
# (derived from: https://github.com/AlexanderAgd/SDL2-Android)
#

curl -sL https://github.com/libsdl-org/SDL/releases/download/release-${SDL2_VERSION}/SDL2-${SDL2_VERSION}.zip -o SDL2-${SDL2_VERSION}.zip
unzip SDL2-${SDL2_VERSION}.zip
cp -r SDL2-${SDL2_VERSION}/include ../external/include/SDL2

$ANDROID_NDK_HOME/ndk-build \
	-C SDL2-${SDL2_VERSION} \
	-j${NUM_PROC} \
	NDK_PROJECT_PATH=$ANDROID_NDK_HOME \
	APP_BUILD_SCRIPT=$(pwd)/SDL2-${SDL2_VERSION}/Android.mk \
	APP_PLATFORM=android-19 \
	APP_ABI=arm64-v8a \
	NDK_OUT=$(pwd)/obj \
	NDK_LIBS_OUT=$(pwd)/libs

cp libs/arm64-v8a/libSDL2.so ../external/lib

#
# build SDL2_image and copy to external
# (derived from: https://github.com/AlexanderAgd/SDL2-Android)
#

curl -sL https://github.com/libsdl-org/SDL_image/releases/download/release-${SDL2_IMAGE_VERSION}/SDL2_image-${SDL2_IMAGE_VERSION}.zip -o SDL2_image-${SDL2_IMAGE_VERSION}.zip
unzip SDL2_image-${SDL2_IMAGE_VERSION}.zip
cp -r SDL2_image-${SDL2_IMAGE_VERSION}/SDL_image.h ../external/include/SDL2

MK_ADDON=$'include $(CLEAR_VARS)\\\n'
MK_ADDON+=$'LOCAL_MODULE := SDL2\\\n'
MK_ADDON+=$'LOCAL_SRC_FILES := '"$(pwd)/libs/arm64-v8a"$'/libSDL2.so\\\n'
MK_ADDON+=$'LOCAL_EXPORT_C_INCLUDES += '"$(pwd)/SDL2-${SDL2_VERSION}/include"$'\\\n'
MK_ADDON+="include \$(PREBUILT_SHARED_LIBRARY)"

sed -e $'/(call my-dir)/a\\\n'"$MK_ADDON" SDL2_image-${SDL2_IMAGE_VERSION}/Android.mk > tmp_mk
cp tmp_mk SDL2_image-${SDL2_IMAGE_VERSION}/Android.mk

$ANDROID_NDK_HOME/ndk-build \
	-C SDL2_image-${SDL2_IMAGE_VERSION} \
	-j${NUM_PROC} \
	NDK_PROJECT_PATH=$ANDROID_NDK_HOME \
	APP_BUILD_SCRIPT="$(pwd)/SDL2_image-${SDL2_IMAGE_VERSION}/Android.mk" \
	APP_PLATFORM=android-19 \
	APP_ABI=arm64-v8a \
	APP_ALLOW_MISSING_DEPS=true \
	NDK_OUT=$(pwd)/obj \
	NDK_LIBS_OUT=$(pwd)/libs

cp libs/arm64-v8a/libSDL2_image.so ../external/lib

#
# build libpinmame and copy to external
#

curl -sL https://github.com/vpinball/pinmame/archive/${PINMAME_SHA}.zip -o pinmame.zip
unzip pinmame.zip
cd pinmame-$PINMAME_SHA
cp src/libpinmame/libpinmame.h ../../external/include
cp cmake/libpinmame/CMakeLists_android-arm64-v8a.txt CMakeLists.txt
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -B build
cmake --build build -- -j${NUM_PROCS}
cp build/libpinmame.3.6.so ../../external/lib
cd ..

#
# build libaltsound and copy to external
#

curl -sL https://github.com/vpinball/libaltsound/archive/${LIBALTSOUND_SHA}.zip -o libaltsound.zip
unzip libaltsound.zip
cd libaltsound-$LIBALTSOUND_SHA
cp src/altsound.h ../../external/include
platforms/android/arm64-v8a/external.sh
cmake -DPLATFORM=android -DARCH=arm64-v8a -DBUILD_STATIC=OFF -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -B build
cmake --build build -- -j${NUM_PROCS}
cp build/libaltsound.so ../../external/lib
cd ..

#
# build libdmdutil (libserum, and libzedmd) and copy to external
#

curl -sL https://github.com/jsm174/libdmdutil/archive/${LIBDMDUTIL_SHA}.zip -o libdmdutil.zip
unzip libdmdutil.zip
cd libdmdutil-$LIBDMDUTIL_SHA
cp -r include/DMDUtil ../../external/include
platforms/android/arm64-v8a/external.sh
cmake -DPLATFORM=android -DARCH=arm64-v8a -DBUILD_STATIC=OFF -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -B build
cmake --build build -- -j${NUM_PROCS}
cp third-party/runtime-libs/android/arm64-v8a/libserum.so ../../external/lib
cp third-party/runtime-libs/android/arm64-v8a/libzedmd.so ../../external/lib
cp build/libdmdutil.so ../../external/lib
cd ..
