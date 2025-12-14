#!/bin/bash

echo -e "\n[INFO]: BUILD STARTED..!\n"

#init submodules
#git submodule init && git submodule update

export KERNEL_ROOT="$(pwd)"
export ARCH=arm64
export KBUILD_BUILD_USER="Kebab"

# Create necessary directories
mkdir -p "${KERNEL_ROOT}/out" "${KERNEL_ROOT}/build" "${HOME}/toolchains"

# init snapdragon llvm
#if [ ! -d "${HOME}/toolchains/llvm-arm-toolchain-ship" ]; then
#    echo -e "\n[INFO] Cloning Snapdragon LLVM...\n"
#    cd "${HOME}/toolchains" && curl -LO "https://github.com/ravindu644/Android-Kernel-Tutorials/releases/download/toolchains/llvm-arm-toolchain-ship-10.0.9.tar.gz"
#    tar -xf llvm-arm-toolchain-ship-10.0.9.tar.gz && rm llvm-arm-toolchain-ship-10.0.9.tar.gz
#    cd "${KERNEL_ROOT}"
#fi

# init arm gnu toolchain
#if [ ! -d "${HOME}/toolchains/gcc" ]; then
#    echo -e "\n[INFO] Cloning ARM GNU Toolchain\n"
#    mkdir -p "${HOME}/toolchains/gcc" && cd "${HOME}/toolchains/gcc"
#    curl -LO "https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz"
#    tar -xf arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz
#    cd "${KERNEL_ROOT}"
#fi

# Export toolchain paths
export PATH="${HOME}/toolchains/clang-r383902b1/bin:${PATH}"
export LD_LIBRARY_PATH="${HOME}/toolchains/clang-r383902b1/lib:${LD_LIBRARY_PATH}"

# Set cross-compile environment variables
export BUILD_CROSS_COMPILE_COMPAT="${HOME}/toolchains/gcc-arm/bin/arm-linux-androideabi-"
export BUILD_CROSS_COMPILE="${HOME}/toolchains/gcc/bin/aarch64-linux-androidkernel-"
export BUILD_CC="${HOME}/toolchains/clang-r383902b1/bin/clang"
# Build options for the kernel
export BUILD_OPTIONS="
-C ${KERNEL_ROOT} \
O=${KERNEL_ROOT}/out \
-j$(nproc) \
ARCH=arm64 \
CROSS_COMPILE=${BUILD_CROSS_COMPILE} \
CROSS_COMPILE_COMPAT=${BUILD_CROSS_COMPILE_COMPAT} \
LINUX_GCC_CROSS_COMPILE_PREBUILTS_BIN=${HOME}/gcc/aarch64-linux-android/bin \
LINUX_GCC_CROSS_COMPILE_ARM32_PREBUILTS_BIN=${HOME}/gcc-arm/arm-linux-androideabi/bin \
CC=${BUILD_CC} \
CLANG_TRIPLE=aarch64-linux-gnu- \
LD=ld.lld \
NM=llvm-nm \
OBJCOPY=llvm-objcopy \
CLANG_PREBUILT_BIN="${HOME}/toolchains/clang-r383902b1/bin" \
DEPMOD=depmod \
"
build_kernel(){
    # Make default configuration.
    # Replace 'your_defconfig' with the name of your kernel's defconfig
#    make ${BUILD_OPTIONS} clean
#    make ${BUILD_OPTIONS} mrproper
#    make ${BUILD_OPTIONS} vendor/a52sxq_eur_open_defconfig

    # Configure the kernel (GUI)
#    make ${BUILD_OPTIONS} menuconfig
#     nano out/.config

    # Build the kernel
    make ${BUILD_OPTIONS} Image || exit 1
    cp out/arch/arm64/boot/Image /mnt/hgfs/Firm/Image1
    cp out/arch/arm64/boot/Image ${HOME}/kernels
    cd ${HOME}/kernels
    ./patch_linux Image
    cd $KERNEL_ROOT
    mv ../oImage out/arch/arm64/boot/Image
    # Copy the built kernel to the build directory
    cp "${KERNEL_ROOT}/out/arch/arm64/boot/Image" /mnt/hgfs/Firm

    echo -e "\n[INFO]: BUILD FINISHED..!"
}
build_kernel
