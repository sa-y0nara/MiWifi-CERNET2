MiRouter-CERNET2  


由于学校的wifi十分垃圾，而且自己买了AX6S这种垃圾路由，且Openwrt第三方固件极不稳定。故作此文，让大家能在18.06的垃圾小米原版系统上使用minieap。  


release中提供了AX6S(mt7622b，aarch64)的1.2.7开发版固件可用的minieap二进制文件，大家可以拿去试一试，不行再自己编译。  
1、 Minieap编译流程（以AX6S为例）：  

Linux (ubuntu22.04):  

```

cd ~
sudo apt install build-essential bison flex zlib1g-dev libncurses5-dev subversion quilt intltool ruby fastjar unzip gawk autogen autopoint ccache gettext libssl-dev xsltproc zip git make gcc -y
mkdir minieap && cd minieap

#根据设备型号更改，但要保证sdk版本为18.06
wget https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/18.06.4/targets/mediatek/mt7622/openwrt-sdk-18.06.4-mediatek-mt7622_gcc-7.3.0_musl.Linux-x86_64.tar.xz

tar -xjf openwrt-sdk-18.06.4-mediatek-mt7622_gcc-7.3.0_musl.Linux-x86_64.tar.xz
mv openwrt-sdk-18.06.4-mediatek-mt7622_gcc-7.3.0_musl.Linux-x86_64 sdk

PATH=$PATH:~/minieap/sdk/staging_dir/toolchain-aarch64_cortex-a53_gcc-7.3.0_musl/bin
STAGING_DIR=~/minieap/sdk/staging_dir/toolchain-aarch64_cortex-a53_gcc-7.3.0_musl/bin
export PATH
export STAGING_DIR

git clone https://github.com/updateing/minieap
cd minieap
sed s/ENABLE_GBCONV := false/ENABLE_GBCONV := true/ config.mk
sed s/STATIC_BUILD  := false/STATIC_BUILD  := true/ config.mk
sed s/ENABLE_ICONV  := true/ENABLE_ICONV  := false/ config.mk

#根据cpu类型更改
sed s/# CC := arm-brcm-linux-uclibcgnueabi-gcc/CC := aarch64-openwrt-linux-gcc/ config.mk

make  

```

~/minieap/minieap中即有minieap二进制程序。    


2.解锁ssh 根据不同型号路由方法进行解锁，并将minieap二进制程序、config.conf以及auto_minieap.sh上传至/userdisk。  
ssh连接路由，执行以下命令:  

```
cd /userdisk
chmod +x minieap
chmod +x auto_minieap.sh
```

修改config.conf.  

随后
```  
./auto.minieap.sh install  
```
即可实现基础ipv4上网功能。  

3.子网下设备cernet-ipv6分配：  
懒得写，别急。  















