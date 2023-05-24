#!/bin/bash

#首先提交代码
git pull origin master
git add .
git commit -m "通过sync脚本提交"
git push origin master

#构建并发送到github
hexo clean
hexo g
hexo d
