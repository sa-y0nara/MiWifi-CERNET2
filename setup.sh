#!/bin/sh


cd ~
sudo apt install build-essential bison flex zlib1g-dev libncurses5-dev subversion quilt intltool ruby fastjar unzip gawk autogen autopoint ccache gettext libssl-dev xsltproc zip git make gcc -y
mkdir minieap && cd minieap

#根据设备型号更改，但要保证sdk版本为18.06
wget https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/18.06.4/targets/mediatek/mt7622/openwrt-sdk-18.06.4-mediatek-mt7622_gcc-7.3.0_musl.Linux-x86_64.tar.xz

tar -xvJf openwrt-sdk-18.06.4-mediatek-mt7622_gcc-7.3.0_musl.Linux-x86_64.tar.xz
mv openwrt-sdk-18.06.4-mediatek-mt7622_gcc-7.3.0_musl.Linux-x86_64 sdk

PATH=$PATH:~/minieap/sdk/staging_dir/toolchain-aarch64_cortex-a53_gcc-7.3.0_musl/bin
STAGING_DIR=~/minieap/sdk/staging_dir/toolchain-aarch64_cortex-a53_gcc-7.3.0_musl/bin
export PATH
export STAGING_DIR

git clone https://github.com/updateing/minieap
cd minieap
sed -i s/"ENABLE_GBCONV := false"/"ENABLE_GBCONV := true"/ config.mk
sed -i s/"STATIC_BUILD  := false"/"STATIC_BUILD  := true"/ config.mk
sed -i s/"ENABLE_ICONV  := true"/"ENABLE_ICONV  := false"/ config.mk

#根据cpu类型更改
sed -i s/"# CC := arm-brcm-linux-uclibcgnueabi-gcc"/"CC := aarch64-openwrt-linux-gcc"/ config.mk

make  
