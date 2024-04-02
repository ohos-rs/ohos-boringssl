#!/bin/sh

# should apply patch for c++ version
patch_file="${PWD}/patch/boringssl.patch"
pushd "boringssl"
git apply "${patch_file}"
popd

build_architecture() {
    local arch=$1
    local script_path="${PWD}/scripts/${arch}.sh"
    local output_dir="${PWD}/prelude/${arch}"


    echo "Start to build ${arch}"
    if source "${script_path}"; then
        pushd "boringssl"
        cmake -DOHOS_STL=c++_shared \
        -DOHOS_ARCH=${arch} \
        -DCMAKE_TOOLCHAIN_FILE=${OHOS_NDK_HOME}/native/build/cmake/ohos.toolchain.cmake \
        -DCMAKE_C_FLAGS="-Wno-unused-command-line-argument" \
        -DCMAKE_CXX_FLAGS="-Wno-unused-command-line-argument" \
        -DCMAKE_INSTALL_PREFIX:PATH="${output_dir}" \
        -B build
        make -C build
        make install -C build
        popd
    else
        echo "Failed to source script for ${arch}"
        return 1
    fi
}

build_architecture "arm64-v8a"

build_architecture "armeabi-v7a"

build_architecture "x86_64"

# rollback the patch file
pushd "boringssl"
git apply --reverse "${patch_file}"
popd