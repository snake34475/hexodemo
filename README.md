# demo blog

Open terminal and run:

snake自用的博客
推荐node版本16.8以上

## master分支

master为博客项目源码

## develop分支

为网站打包网站主页


## 开发
```shell
#拉代码
git clone https://github.com/snake34475/snake34475.github.io.git
#安装hexo依赖
npm i -g hexo
#运行
hexo s
```
## 正常提交
```shell
#清楚缓存和public
hexo clean
#生成静态文件到public文件
hexo g 
#自动生成静态文件并设定指定仓库
hexo d
```

## 整合提交
```shell
yarn sync
```
