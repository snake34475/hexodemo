---
title: umi2项目打包优化
date: 2024-01-17 17:09:28
tags:
---

# umi2项目打包优化

**最近项目再部署的时候十分漫长，尤其是修复bug的时候，总感觉项目的部署很慢，需要五分钟，公司其他后台管理项目部署仅仅需要1分钟，于是我十分不爽，想要研究一下，这玩意到底是为什么那么卡？**

## 自动化部署做了什么？

```
我们知道一般的自动化部署，通过git push 钩子触发jenkins的自动化部署事件，从而执行一系列命令

由于我们公司使用的是docker部署，那么流程就如下
```

1. **docker pull 镜像并启动一个容器（耗时)**
2. **拉取项目源码**
3. **执行dockerfile**
   1. 
      ```

      //以下为部分命令
      FROM hub.xxx.com/library/nginx:stable-alpine
      FROM hub.xxx.com/library/node:10@sha256:dac69681e3026f8a...
      WORKDIR  /node
      COPY package.json /node
      COPY package-lock.json /node
      RUN  --mount=type=cache,target=/node/node_modules,id=pri.. #设置缓存 以及根据环境配置一系列命令

      ```
4. **下依赖 可以指定镜像源 （耗时)**
5. **打包 + 压缩 （耗时)**
6. **发包（耗时)**
7. **配置nginx**
8. **结束**

## 分析

**我们通过分析上方做了什么，我们可以看到，耗时的主要是docker pull镜像，安装依赖，打包，压缩，发包等等**

**docker 和安装依赖的提速可以让docker使用内网或者国内网速较好的镜像**

**发包的优化就是将包压缩的足够小**

**这样我们仅仅剩下和打包，压缩，这三个都可以在前端项目开发时候进行调整**

## 优化调整

首先，既然前端开发框架使用的是umi，我们就应该优先从 [**umijs2**](https://v2.umijs.org/zh/)进行查找

### umi框架的优化

1. **按需加载组件这个似乎是默认开启的**
2. **treeShaking 这个是不用说了，**
3. **disableCSSSourceMap 禁用css源码映射，这个也能提升一些速度**
4. **参考->.env和环境变量,具体的配置**
   1. **ESLINT 通常我们会将这个开启，但是导致打包的时候也会执行，此时我们可以直接在packjson中将 ESLINT=1 写入运行命令中，而不是.env中**
   2. **ANALYZE 分析bundle构成，线上部署要关闭  集成了**`webpack-bundle-analyzer`
   3. **SPEED_MEASURE 线上须关闭耗时，其实是集成了**`speed-measure-webpack-plugin`
   4. **COMPRESS 默认压缩 我没有使用这个我使用的另一种方案**`happypack`

### 多线程压缩

```
采用的是`happypack, 配置了环境变量，方便进行修改 `

通常webpack的插件，如果umi没有公开其配置项的话，需要从chainWebpack中调整
```

> **压缩做好只使用一种方案，例如我使用了**`happypack`就不要使用env中的COMPRESS，否则可能耗时反增。

```js
//config.js
  // "happypack": "^5.0.1",
import HappyPack from "happypack"
import os from 'os';
export default {
    chainWebpack(config) {
        if(process.env.HAPPYPACK ){
            const cpuCount = os.cpus().length; // 获取 CPU 核心数
            console.log("cpuCount",cpuCount)
            config.plugin('happypack').use(HappyPack, [
                {
                id: 'js',
                // 根据 CPU 核心数设置线程池大小
                threads: cpuCount,
                // 需要并行处理的 loader
                loaders: ['babel-loader'],
          },
          ]);
          }
}
}
  
```

### 添加缓存

**如果线上是docker部署的，那么线上打包部署就不能够使用缓存，所以我只在本地开发环境重配置了缓存，相当于使用mfsu**

```js
//config.js   
//添加缓存
import HardSourceWebpackPlugin from "hard-source-webpack-plugin"
chainWebpack(config) {
  if(process.env.cacheHardSource && ["dev","feature1dev"].includes(process.env.BUILD_ENV ) ){
      config.plugin('HardSourceWebpackPlugin').use(HardSourceWebpackPlugin);
    }
}
  
```

### 关闭进度条

**可以进行配置，当线上打包时，关闭滚动条，我可以提升30s左右**

```
 config.plugins.delete('progress')
```

### 提出公共组件

```
如果使用treesharking，就不要使用这个，会有冲突，导致包更大
```

### 源码展示

```bash
//.env

BROWSER=none
HAPPYPACK=true ;开启多线程
; COMPRESS=none;不压缩似乎能提高速度，不压缩能提高大概20s
cacheHardSource=1 ;本地开发使用缓存
PROGRESS=none ;线上删除进度条
; SPEED_MEASURE=CONSOLE ;耗时输出到控制台
; ANALYZE=true ;开启可视化分析 线上须关闭！！

```

```js
//config.js
// "happypack": "^5.0.1",
import HappyPack from "happypack"
import os from 'os';
const isDev = process.env.cacheHardSource && ["dev","feature1dev"].includes(process.env.BUILD_ENV)
export default {
    treeSharking:true,
    disableCSSSourceMap:process.env.BUILD_ENV === 'pro' ,//线上禁用源码
    chainWebpack(config) {
    //本地开发环境
    if(isDev){
      //添加缓存，实现了过程中提高编译速度
      config.plugin('HardSourceWebpackPlugin').use(HardSourceWebpackPlugin);
      // 删除进度条插件
    }else{
      // 删除进度条插件
      if(process.env.PROGRESS !== 'none'){
        config.plugins.delete('progress')
      }
    }

    // 使用 HappyPack 插件进行多线程构建
    if(process.env.HAPPYPACK){
      const cpuCount = os.cpus().length; // 获取 CPU 核心数
      console.log("cpuCount",cpuCount)
      config.plugin('happypack').use(HappyPack, [
        {
          id: 'js',
          // 根据 CPU 核心数设置线程池大小
          threads: cpuCount,
          // 需要并行处理的 loader
          loaders: ['babel-loader?cacheDirectory=true'],
        },
      ]);
    }
}
}
```

## 结果展示

### 优化前

**正常打包**![1705476848580](https://s2.loli.net/2024/01/24/y5YzrtAfdoTuPhs.webp)

### 优化后

**正常打包**

![1705477018954](https://s2.loli.net/2024/01/24/WrxD9Vmze5hf8AJ.webp)

**触发运维的缓存**

![1705476927484](https://s2.loli.net/2024/01/24/UDQPptimdSGcOFZ.webp)

## 引用

[webpack4打包优化HappyPackthread-loader](https://juejin.cn/post/6911519627772329991)

[玩转webpack，使你的打包速度提升百分之九十](https://juejin.cn/post/6844904071736852487)
