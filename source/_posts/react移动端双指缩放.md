---
title: react移动端双指缩放
date: 2022-07-12 16:22:47
tags:
---
在服务端渲染的项目中，例如coop，m项目中，无法访问到本地window导致插件引入报错，所以直接引入hammerjs会导致报错：window is undefined，所以使用react-hammerjs实现双指缩放

首先我们可以简单的认为双指缩放可以实现以下三个功能
	1.支持双指放大
	2.支持双指放大后移动图片预览
	3.支持双指缩小

我们通过查阅npm中react-hammerjs文档，看到有以下API

* pan 触碰
* pinch 双指捏
* press 按压
* rotate 旋转
* swipe 滑动
* Tap 轻点

从而可以将三个功能解析成以下
1.pinch 双指放大，双指缩小
2.tap 移动预览

首先实现的是双指放大功能，图片放大通过改变css中transform属性中scale进行缩放放大

- pinchstart  开始捏合
- pinchend  捏合结束
- pinchin    向内捏合
- pinchout   向外捏合

然后是移动功能

- panstart
- panmove
- panend

我们可以根据需求拆分出来


![](http://rew00265f.hb-bkt.clouddn.com/image/2022/07/12/wu_1g7oo4n591agj10je1mmv1g3onnm6.png)


​	一般情况下我们认为从内到外是放大，从外到内是缩小，因而放大使用pinchin ，缩小使用pinchout事件，先实现放大功能可以这样做

```shell
$ npm i react-hammerjs
```

```react
//项目中引入
import Hammer from 'react-hammerjs';
//由于hammerjs可能会屏蔽pinch所以需要在option将他设置为true
 <Hammer onDoubleTap={this.picControlor} onPanStart={this.moveStart} onPan={this.moving} onTap={this.onTap}
 onPinchIn={this.pinchIn} onPinchOut={this.pinchOut} onPinchStart={this.pinchStart} onPinchEnd={this.pinchEnd}
options={{ recognizers: { pan: { enable: this.state.panEnable }, pinch: { enable: true } } }}><img className={this.props.className ? `${this.props.className} ${this.state.className}` : `${this.state.className}`} src={this.props.src} onError={this.props.onError} style={{transform: `${this.state.transform} `}} /></Hammer>
```

## 当双指移动开始时

1.第一次缩放,记录下 双指中心到图片中心的距离，方便缩放的时候计算
2.第二次缩放,直接继承上次距离，但是由于move触发时，这个距离又会改变，需要在move事件中更新

```js
this.state.ParCli.w //父级的宽度
this.state.ParCli.h //父级的高

preStartDirX //图片的x移动距离
preStartDirY //图片的y移动距离

startDirX //开始移动的中心
startDirY //开始移动的中心
pinchStart = (e) => {
        this.setState({
            isPinchPic: true,
            startDirX: this.state.scale == 1 ? this.state.ParCli.w / 2 - e.center.x : this.state.preStartDirX,
            startDirY: this.state.scale == 1 ? this.state.ParCli.h / 2 - e.center.y : this.state.preStartDirY
        });
    }
```

## 缩放放大

1.缩放中
缩放时，如果单纯的围绕图片中心缩放太过生硬，苹果原生的缩放是围绕着双指中心进行放大，我们在此基础上加上边界限制，防止出现黑边
	a.当页面放大，我们要让双指居中，因而每次放大偏移的距离就是缩放差值乘以距离
	b.由于缩放会导致移动到黑边，所以需要严格限制移动的距离

2.缩放到最大,限制他为最大

```js
  pinchOut = (e) => {
    //缩放到最大
        if (this.state.scale + 0.02 > 2) {
            this.setState({
                scale: 2,
            })

        } else {
          //缩放中
            const { scale, startDirX, startDirY } = this.state
            let x = startDirX * (scale - 1)
            let y = startDirY * (scale - 1)
            x = this.lintFN(x, y).x
            y = this.lintFN(x, y).y

            this.setState({
                scale: scale + 0.02,
                isPinchPic: true,
                transform: `scale(${scale}) translate(${x}px,${y}px)`,
                preStartDirX: this.state.startDirX,
                preStartDirY: this.state.startDirY,
            });
        }
    }
```

## 缩放缩小

与缩放放大同理

 ```js
 pinchIn = () => {
        if (isZoomed) return;
        // this.pinchStatus = 'in'
        if (this.state.scale - 0.02 < 1) {
            this.setState({
                scale: 1,
                transform: `scale(1)`,
                isPinchPic: false
            });

        } else {
            const { scale, ParCli, startDirX, startDirY } = this.state
            let x = startDirX * (scale - 1)
            let y = startDirY * (scale - 1)
            x = this.lintFN(x, y).x
            y = this.lintFN(x, y).y
            this.setState({
                scale: scale - 0.02,
                transform: `scale(${scale}) translate(${x}px, ${y}px)`,
                isPinchPic: true

            });
            this.props.scrollOpen()
        }
    }
 ```

## 平移开始

缩放比例不是1的时候，支持平移

思路是移动前记录下图片当前的trasfrom的x位移与y位移

```js
  moveStart = (e) => {
        this.setState({ className: '' });
        let translateStr = e.target.style.transform;
        let translateArr = translateStr.match(/-?\d+\.?\d+px/g);
        this.oldTranslate.x = parseFloat(translateArr[0], 10) || this.oldTranslate.x;
        this.oldTranslate.y = parseFloat(translateArr[1], 10) || this.oldTranslate.y;
    }
```

## 平移中

上方提到的preStartDirX用来缩放参考的位移也更改


```js
 moving = (e) => {

        // 获取拖拽的距离
        let transX = this.oldTranslate.x + e.deltaX;
        let transY = this.oldTranslate.y + e.deltaY;

        //图片移动，暂存的位移也更改
        this.setState({
            preStartDirX: transX + e.deltaX,
            preStartDirY: transY + e.deltaY
        })
        transX = this.lintFN(transX, transY).x
        transY = this.lintFN(transX, transY).y

        if (this.state.scale !== 1 || 2) {
            this.setState({ transform: `scale(${this.state.scale}) translate(${transX}px, ${transY}px)` });
        } else {
            this.setState({ transform: `scale(2) translate(${transX}px, ${transY}px)` });

        }
    }
```

边界函数

​	边界函数就是限制move的时候防止拖出屏幕外，但是我通过计算下方应该是乘以二分之一，但是这样容易出界，四分之一研究了两天也未研究出来，下次明白了希望补全

```js
    
			lintFN = (x, y) => {
        const { scale, ParCli } = this.state
        let Xn = (scale - 1) * 1 / 4
        let Yn = (scale - 1) * 1 / 4

//x轴边界
        if (x > ParCli.w * Xn) {
            x = ParCli.w * Xn
        } else if (x < -ParCli.w * Xn) {
            x = -ParCli.w * Xn
        }
//y轴边界
        if (y > ParCli.h * Yn) {
            y = ParCli.h * Yn
        } else if (y < -ParCli.h * Yn) {
            y = -ParCli.h * Yn
        }

        return {
            x: x,
            y: y
        }
    }
```



