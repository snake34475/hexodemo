---
title: 常用typescript
date: 2022-07-15 09:34:20
tags:
categories:
- typescript
---


 ## 类型声明常用

```tsx
//boolean
let isDone: boolean = false; 
//string
let name: string = "bob";
//number
let decLiteral: number = 6;
//数组
let list: number[] = [1, 2, 3];
let list: Array<number> = [1, 2, 3];
let ro: ReadonlyArray<number> = a; //只读数组，除非用断言重写
 //元祖
let x: [string, number]; 
//枚举
enum Color {Red, Green, Blue}
//任意
let notSure: any = 4;
//void
function warnUser(): void {
    console.log("This is my warning message");
}
let unusable: void = undefined; //只能赋值undefined或null
//null和undefined是所有类型的子类型
let u: undefined = undefined; 
let n: null = null;
//never
function error(message: string): never {
    throw new Error(message);
}
//对象  declare为声明一个全局变量的类型,一般在根目录下
declare function create(o: object | null): void;
create({ prop: 0 }); // OK
create(null); // OK

//解构声明类型
function f([first, second]: [number, number]) {
    console.log(first);
    console.log(second);
}
//对象
let {a, b}: {a: string, b: number} = o;
type C = { a: string, b?: number }
function f({ a, b }: C): void {
    // ...
}
```

## 类型断言

类型断言就是能够绕开ts的类型警告,类似一种强制执行

```tsx
let someValue: any = "this is a string";
let strLength: number = (<string>someValue).length;
```

```tsx
let someValue: any = "this is a string";
let strLength: number = (someValue as string).length;
```

## 接口interface

### 	对象和索引类型

```tsx
//对象
interface SquareConfig {
  color?: string;//可选属性 option bags
   readonly x: number;//只读属性
  [propName: string]: any; //SquareConfig具有不是以上的数据并且为string
}
//索引类型，索引类型尽量使用数字统一标准，使用不同类型容易导致出现不同的结果
//尽量使用只读
interface StringArray {
 readonly [index: number]: string;  
}
```

### 	数组

```tsx
//数组
interface StringArray {
  [index: number]: string;
}
let myArray: StringArray;
myArray = ["Bob", "Fred"];
```



### 	函数

```tsx
interface searchFn{
    (a:number,b:string):boolean
}
let mySearch: searchFn
//名称不必相同，下方函数参数类型不写也可
mySearch=function(apple:number,good:string) { 
return true
}
```

### 类

```tsx
interface ClockInterface {
    currentTime: Date;
    setTime(d: Date);
}
class Clock implements ClockInterface {
    currentTime: Date;
    setTime(d: Date) {
        this.currentTime = d;
    }
    constructor(h: number, m: number) { }
}
```

### 继承接口

```tsx
interface Shape {
    color: string;
}
interface PenStroke {
    penWidth: number;
}
interface Square extends Shape, PenStroke {
    sideLength: number;
}
```



### 绕过接口检查的三种方式

1.使用类型断言
2.将对象传递给一个新变量,用这个变量进行传参
3.字符串索引签名,[propName:string]:any

ts本地测试

```
1.全局安装ts
2.tsc --init 初始化ts配置
3.vscode终端 运行任务 tsc 
```

箭头函数的类型添加

 ```js
let getName:(x:number,y:number)=>number =
  //上半部分
function(x:number,y:number):string{return x+y}
//总感觉在箭头函数中使用ts有点麻烦
var myAdd = function (x, y) { return x + y + y + ""; };
//翻译成js
 ```

