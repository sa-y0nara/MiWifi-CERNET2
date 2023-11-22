# MiWifi-CERNET2  


由于学校的wifi十分垃圾，自己买了AX6S这种垃圾路由，且Openwrt第三方固件极不稳定。故作此文，让大家能在18.06的垃圾小米原版系统上使用minieap。  


release中提供了AX6S(mt7622b，aarch64)的1.2.7开发版固件可用的minieap二进制文件，大家可以拿去试一试，不行再自己编译。  
## 1、 Minieap编译流程（以AX6S为例）：  

Linux (ubuntu22.04):  
你们可以修改仓库中的setup.sh并运行，也可以直接修改下面的代码然后运行。

```shell

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
```

~/minieap/minieap中即有minieap二进制程序。    


## 2.minieap运行实现
- 解锁ssh 根据不同型号路由方法进行解锁
- 将`minieap`二进制程序上传至`/userdisk/`
- ssh连接路由，执行以下命令:  

    ```shell
    cd /userdisk
    chmod +x minieap
    ```

- 现在即可运行`minieap`认证校园网，需要懂`minieap`的使用，使用`./minieap -h`获取帮助


## 3.开机自启
> 思路来源于 https://github.com/lemoeo/AX6S/blob/main/auto_ssh.sh

基于firewall在开机时可以自动执行脚本，在AX6S上可用，理论上也适用于其他基于Openwrt的小米路由器。

### 前提
由于脚本以硬编码方式写死了路径，所以需将`auto_minieap.sh`、`minieap`、`minieap.conf`都放在`/userdisk/`里面，会shell的话可以自行更改

### 上传脚本
- 将`auto_minieap.sh`上传至路由器的`/userdisk/`
- 授予脚本权限

    ```shell
    cd /userdisk
    chmod 777 auto_minieap.sh
    ```

### 获取minieap.conf
- 如果不懂minieap配置文件的格式，可以先使用minieap成功认证一次校园网（以下以锐捷认证为例）

    ```shell
    cd /userdisk
    ./minieap -u 用户名 -p 密码 -n 网卡 --module rjv3 
    # 简单的使用实例，请自行添加想要的参数，调用./minieap -h可以查看帮助
    ```

- 成功连接校园网后，退出程序，保持刚才的参数不变，添加`-w`参数
- 成功后，退出程序。如果没有指定--conf-file的话，默认会在`/etc/minieap.conf`生成配置文件，直接复制到`/userdisk/`里就好了

    ```shell
    cp /etc/minieap.conf /userdisk/
    ```

### 运行
直接运行`auto_minieap.sh`，脚本会使用`/userdisk/minieap.conf`中的配置来运行`/userdisk/minieap`程序，等价于：

```shell
/userdisk/minieap --kill --conf-file /userdisk/minieap.conf
/userdisk/minieap --conf-file /userdisk/minieap.conf
```

### 自启

```shell
./auto_minieap.sh install
```

会将脚本写入/etc/config/firewall里，在开机或防火墙重载时自动执行

### 取消自启

```shell
./auto_minieap.sh uninstall
```


## 4.路由子网下设备cernet-ipv6分配：  
以下以笔者所在学校为例。这个抽象的学校给有线连接的设备分配的是/64，至于无线连接设备，根本没分配。虽然分配的ipv6只出不进（外网不能访问），但有总好过没有。  
按照以下要点配置：  
- 1.在路由器后台将ipv6分配方式改为Native。  
- 2.ssh连接路由器，将/etc/config/dhcp中的lan口和wan口设置改成以下形式：   
```
config dhcp 'lan'
        option interface 'lan'
        option start '5'
        option limit '250'
        option leasetime '12h'
        option force '1'
        option dhcpv6 'relay'
        option ra 'relay'
        option ndp 'relay'
        option ra_management '1'
        option ra_default '1'
        option ra_preference 'high'
        option ra_maxinterval '20'

config dhcp 'wan'
        option dhcpv6 'relay'
        option master '1'
        option ra 'relay'
        option ndp 'relay'
```
- 3.重启路由。

如果你的学校分配的是/128,可能只能用NAT66咯。当然你也可以像这样试一试，死马当做活马医。  
















