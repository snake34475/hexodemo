#!/bin/bash

##首先提交代码
#git pull origin master
#git add .
#git commit -m "通过sync脚本提交"
#git push origin master

#构建并发送到github
hexo clean
hexo g
#hexo d

#发包到服务器上
# 请将以下变量替换为远程服务器和 SSH 私钥文件的真实信息
# 如果本地没有秘钥请注释以下
REMOTE_USER=root
REMOTE_HOST=81.68.128.43
SSH_KEY=../Secretkey/hp_omen.pem
REMOTE_DIR=/www/wwwroot/
LOCAL_DIR=./www.onestyle.top/
#echo $tx_linux_ip
rm -rf  www.onestyle.top
cp -r public www.onestyle.top
echo "执行scp传输"
# 使用 scp 命令将本地 build 文件夹上传到远程服务器上
scp -r -i $SSH_KEY $LOCAL_DIR $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR
rm -rf  www.onestyle.top

wait $!
echo "scp传输执行完毕"
hexo
