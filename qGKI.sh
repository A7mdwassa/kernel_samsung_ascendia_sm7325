#!/bin/bash

echo -e "\n[INFO]: BUILD STARTED..!\n"

#init submodules
#git submodule init && git submodule update

export KERNEL_ROOT="$(pwd)"
export ARCH=arm64
export KBUILD_BUILD_USER="Kebab"

# Create necessary directories
mkdir -p "${KERNEL_ROOT}/out"
# Export toolchain paths
export PATH="${HOME}/toolchains/clang-r383902b1/bin:${PATH}"
export LD_LIBRARY_PATH="${HOME}/toolchains/clang-r383902b1/lib:${LD_LIBRARY_PATH}"

# Set cross-compile environment variables
export BUILD_CROSS_COMPILE_COMPAT="${HOME}/toolchains/gcc-arm/bin/arm-linux-androideabi-"
export BUILD_CROSS_COMPILE="${HOME}/toolchains/gcc/bin/aarch64-linux-androidkernel-"
export BUILD_CC="${HOME}/toolchains/clang-r383902b1/bin/clang"
export PATH="$HOME/toolchains/clang-r383902b1/bin:${HOME}/toolchains/gcc/bin:$PATH"

export LLVM=1
export LLVM_IAS=1

export CC=clang
export LD=ld.lld
export NM=llvm-nm
export OBJCOPY=llvm-objcopy
export OBJDUMP=llvm-objdump
export STRIP=llvm-strip

export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-androidkernel-
export CROSS_COMPILE_COMPAT=arm-linux-androideabi-
export KCFLAGS="-Wno-error=strict-prototypes -Wno-error=implicit-int"
# Build options for the kernel
export BUILD_OPTIONS="
-C ${KERNEL_ROOT} \
O=${KERNEL_ROOT}/out \
-j$(nproc) \
ARCH=arm64 \
CROSS_COMPILE=${BUILD_CROSS_COMPILE} \
CROSS_COMPILE_COMPAT=${BUILD_CROSS_COMPILE_COMPAT} \
LINUX_GCC_CROSS_COMPILE_PREBUILTS_BIN=${HOME}/toolchains/aosp_gcc/aarch64-linux-android/bin \
LINUX_GCC_CROSS_COMPILE_ARM32_PREBUILTS_BIN=${HOME}/toolchains/aosp_gcc-arm/arm-linux-androideabi/bin \
CC=${BUILD_CC} \
CLANG_TRIPLE=aarch64-linux-gnu- \
LD=ld.lld \
NM=llvm-nm \
OBJCOPY=llvm-objcopy \
CLANG_PREBUILT_BIN="${HOME}/toolchains/clang-r383902b1/bin" \
DEPMOD=depmod \
KCFLAGS="${KCFLAGS}" \
"
build_kernel(){
    # Make default configuration.
    # Replace 'vendor/a52sxq_eur_open_defconfig' with the name of your kernel's defconfig
#    make ${BUILD_OPTIONS} clean
#    make ${BUILD_OPTIONS} mrproper
#    make ${BUILD_OPTIONS} vendor/a52sxq_eur_open_defconfig

#    ./scripts/kconfig/merge_config.sh -O ${KERNEL_ROOT}/out arch/arm64/configs/vendor/a52sxq_eur_open_defconfig arch/arm64/configs/ksu.config arch/arm64/configs/bbg.config arch/arm64/configs/nomount.config

    # Configure the kernel
#    nano out/.config

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
    cp "${KERNEL_ROOT}/out/arch/arm64/boot/Image" /mnt/hgfs/Firm/Android\ Image\ Kitchen/split_img/boot.img-kernel

    echo -e "\n[INFO]: BUILD FINISHED..!"
}
build_kernel
