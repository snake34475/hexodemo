---
title: json.parse记录一次线上bug排查
date: 2024-01-24 18:04:12
tags:
---

最近项目中有一个匪夷所思的问题，业务在使用的时候，偶发性的会白屏，经常下班的时候骚扰我们，开发苦不堪言，经过长达一周的排查，仍然没有查到bug的存在，最终尝试通过添加埋点日志，记录关键信息。

## 现状

​	首先讲述一下现状，首先业务进入后，页面可以认为有两个按钮

* 跳转共享链接
* 打开表单弹窗按钮，点击后展示表单。

![image-20240124132744181](https://s2.loli.net/2024/01/24/UhGXFeqOCwu9g4Y.webp)

操作顺序是，页面加载后，先点击跳转共享链接，看完链接后再返回点击表单弹窗。

> 里面有两个重要的时间节点，一个是跳转链接之前，一个是返回到当前页面。

* 跳转链接之前

  * 需要存储接口数据，接口数据包含了表单的数据

* 返回当前页面

  * 请求接口数据

    * 本地缓存无，直接使用接口数据
    * 本地缓存有，缓存和接口数据合并，接口数据优先

    

![image-20240124132901079](https://s2.loli.net/2024/01/24/G8bBY9AuSQJjo36.webp)

返回页面的时候，点击表单弹窗

正常上来说弹窗能够正常显示，但是线上环境再点击 展示弹窗的按钮导致白屏了。整个流程如下

![image-20240124133213958](https://s2.loli.net/2024/01/24/5UNLf841FCigOSV.webp)

初步判断是整合缓存和接口数据问题，于是需要给页面添加两个埋点

* 页面报错异常时上报
* 点击打开表单的时，上报缓存数据和聚合之后的数据。
  * 为什么不上报接口数据呢？因为当时修复bug比较紧急，观察代码发现接口直接返回的数据没有在公共变量中存储，如果需要存储改动较大，还有就是接口数据也可以从后端日志去排查


## 页面报错异常上报

异常上报的方法有很多，通常使用一个gif图片，地址为get的请求地址+上报信息，具体的可以自行百度，此处简单叙述下

​	使用图片是因为加载资源里面img优先级比较低，不会阻塞其他资源，而且图片请求不会跨域，用gif是因为对比图片类型他是比较小的

```js
//utils/utils.js
/**
 * 异常上报方法
 * 希望抽离出来同步异常类和异步异常类
 */
function uploadError() {
  //上报处理参数
  const upload = errObj =>{
    const logUrl = 'https://xxx.xxx.com/log.gif'; // 上报接口
    //将obj拼接成url
    const queryStr = Object.entries(errObj)
        .map(([key, value]) => `${key}=${value}`)
        .join('&');
      const oImg = new Image();
      oImg.src = logUrl + '?' + encodeURIComponent(queryStr);
  }
  //同步方法
  function handleError(e) {
    try {
      let baseInfo = localStorage.getItem('base_info'); // 域账户
      let masterName = baseInfo ? JSON.parse(baseInfo)?.master_name : ''; // 域账户
      let errObj = {
        masterName: masterName,//域账户
        url: window.location.href,//报错的路由，利于排查
        reason: JSON.stringify({
          message: e?.error?.message, //报错信息
          stack: e?.error?.stack,//调用栈
        }),
        message: e?.message, //报错信息
      };
      upload(errObj)
      console.log('error', errObj);
    } catch (err) {
      console.log('error', err);
    }
  }
  window.addEventListener('error', handleError);//调用监听
}

//app.js
//异常上报方法 开发环境禁止上报
if(!['dev'].includes(process.env.BUILD_ENV)){
  uploadError()
}
```

## 点击弹窗的异常上报

```js
//打开弹窗的操作  
const open = () => {
    setShow(!show);//控制表单的展示隐藏
    if(!show){
      const logUrl = 'https://xxx.xxx.com/log.gif'; // 上报接口
      const oImg = new Image();
      let initFormVal = localStorage.getItem('initFormVal' + query?.id);
      oImg.src = logUrl + '?' + encodeURIComponent(`initFormVal=${initFormVal}&integratedData=${JSON.stringify(integratedData)}`);
    }
  };
//initFormVal为缓存中的数据 integratedData为整合后的数据
```

## 发现问题原因

通过添加以上异常上报，业务员进行操作时，又出现了白屏，此时根据业务员token与上报关键字与时间查到了相关日志，其中日志中记录的是

```js
https://xxx.xxx.com/log.gif?initFormVal=&integratedData=null
```

integratedData是后端接口数据和缓存的融合呀！通过查日志发现当时后端确确实实返回正常的响应了，不可能为null，同时还有一个疑问浮出水面，为什么initFormVal没有值，而不是null

正常来说如果initFormVal从json中取值时，取不到应该默认就是null，此处为''，只说明一个问题，缓存的时候给他赋值了

那么问题大致可以定位到以下两个操作节点

* 缓存时
* 返回页面后，缓存和接口数据融合时

```js
//缓存时操作  
const getFormValues = () => {
    let formVal = childRef?.current?.getFormVal() || '';
		localStorage.setItem('initFormVal' + query.id, JSON.stringify(formVal));
  };
```

缓存时，如果子节点获取不到，那么childRef?.current?.getFormVal()就为undefind,又由于使用了或运算符，那么此时存储的是''，那么取这个暂时看也没问题呀，然后也写入了缓存

> 更严格来讲，应该先判断formVal是否存在然后再去缓存，没有就不缓存。

再看一下返回页面，数据融合的代码

```js
const getDataFn = url => {
    dispatch({
      type: url,
      payload: { id: query.id },
      callback: res => {
        if (res.ret === 1) {
          let initFormVal = localStorage.getItem('initFormVal' + query?.id);
          console.log('initFormVal', JSON.parse(initFormVal));
          let cacheFormVal = {};
          
          if (initFormVal) {
            //initFormVal赋值给cacheFormVal，此处省略
          }
          setPricingInfo({
            ...cacheFormVal,
            ...res.data
          }); 
        }   
```

发现有一个console.log()，JSON.parse('')会是什么？报错，果然，查异常上报日志的时候，也查到这个错误，真是一失足成千古恨，当时只是为了方便查看，打印了一下缓存数据，没想到是这个地方出现的问题 Uncaught SyntaxError: Unexpected end of JSON input

![image-20240124142222982](https://s2.loli.net/2024/01/24/8gK4ON2QmhjwJyt.webp)

## JSON.parse

那问题来了 json.parse什么情况会报错呢？通过查阅[MDN](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse)

![image-20240124143007732](https://s2.loli.net/2024/01/24/IiPdhBNaCfgls5Q.webp)

那么，什么是规范的JSON格式呢？我们此处再去查阅[MDN](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse)

此处只列出了json的结构 很显然，传入null 是合法的，但是传入空字符是不合法的，

```js
JSON = null
    or true or false
    or JSONNumber
    or JSONString
    or JSONObject
    or JSONArray
```



## 吐槽

可能有人要吐槽，直接写JSON存储的时候格式不对不就行了吗？干什么这那么多，又是异常上报，又是贴代码？又是贴MDN的。

我在这里回答一下之所以这么写一是为了记录出错的时候出现的问题，方便下次出现类似问题能够即时复盘。

二是希望贴出自己的排错方式，新手若有不明白的可以模仿这个方式得到一些启发和思考，高手也可指出我的问题，共同成长

同样我也希望大家遇到问题的时候要记得查文档，查文档再查文档，自己遇到的问题，先文档，是不是自己理解错了，如果还不行就去stackoverflow，如果再不济就去github issue看看是否有相同的问题是不是作者的bug，如果都没有，那么好了，这个问题几乎解决不了了，此时有两个选择，要么产品接受，要么 那我走？？？