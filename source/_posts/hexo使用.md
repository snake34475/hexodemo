---
title: hexo使用
date: 2022-07-11 15:46:12
tags:
---


## 配置

[详细请看](https://hexo.io/zh-cn/docs/)

1.[hexo安装](https://hexo.io/docs/setup)

```
$ hexo init <folder>
$ cd <folder>
$ npm install
```

2.选主题（可跳过）

3.一键式部署

```shell
$ npm install hexo-deployer-git --save
```

```
_config.yml 文件

deploy:
  type: git  //提交工具
  repo: <repository url> # https://bitbucket.org/JohnSmith/johnsmith.bitbucket.io  //git地址，用的是ssh，前提要先把ssh配置了
  branch: [branch]
  message: [message]  //commit 信息
```

4.

```shell
$ npm run build -d # 文件生成之后立即部署文件
```

> 注意，gitpage的名称必须是github的用户名+github.io



## 命令

```shell
$ hexo new 文件名 #新建文档
$ hexo s #启用本地服务器
$ hexo d #自动生成静态文件并部设定仓库
$ hexo clean #清除缓存和生成的public
$ hexo g #生成静态文件到public文件
```



### 修改主页

>凡是涉及根目录_config.yml的配置，需要重启项目才生效
>
>修改注意一下换行和缩进，换行不对会导致报错

node_modules=>hero-theme-volantis=>_config.yml文件中进行修改



文档中markdown格式

```


2.添加影视 {% vimeo 82090131 %}或{% youtube TIbZDRXM-Tg %}

3.注释
{% codeblock Array.map %}

array.map(callback[, thisArg])

{% endcodeblock %}
```



