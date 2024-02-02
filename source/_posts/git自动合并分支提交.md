---
title: git自动合并分支提交
date: 2024-02-02 23:38:42
tags:
---

**平常业务开发的同学，应该经常性的会遇到git提交，git合并。尤其是改bug的时候，我们需要频繁的在开发分支开发修复=》合并到测试分支，发布测试分支。这其中要敲击数个命令。对我们程序员来说，重复的运动就是对我们的侮辱！我们要使用其他办法克服他！**

![侮辱](https://s2.loli.net/2024/02/02/iLMxXcG1gIyD8BK.webp)

**由于多数git提交工具无法合并的时候添加注释，但是公司要求提交与合并须添加注释，因此需要merge添加注释**

## git提交要求

### 分支约定

**master：主分支**

**develop：测试主分支**

**hotfix-日期：线上修复分支**

**jira-ID：开发分支，开发完成后合并测试分支，产品验收通过后合并master**

### 提交规范

**格式：**`<type>(<scope>): <subject> <body>`

**type：说明本次commit的类别，只允许下面标识**

| **type**     | **说明**         | **样例**                   |
| ------------------ | ---------------------- | -------------------------------- |
| **feat**     | **新功能开发**   | **新的功能、模块、工具**   |
| **fix**      | **修复bug**      | **提测后的bug、线上的bug** |
| **docs**     | **修改文档**     | **readme等**               |
| **style**    | **修改css**      | **只改了css**              |
| **refactor** | **重构代码**     | **重写了某个插件、库等**   |
| **chore**    | **更新依赖或库** | **更新依赖库版本等**       |

**scope（非必要）：影响范围。**

**subject：commit描述，简洁清晰，必须“动词” + 文字，控制在20字以内。**

**body（非必要）：subject的详细说明。**

### 多人协作

**多人协作需多pull代码**

**看完我的表情就是这样的**

![萌新](https://s2.loli.net/2024/02/02/tDXUsk2irCKxypA.webp)

**其实举个例子就简单了，比如说我们本次改了一个弹窗，只有单一页面使用我们就可以说**

> **fix(用户详情页):调整了弹窗的文案**

## git合并代码复习

**首先，我们复习一下修复bug需要提交的命令**

**假设开发分支为jira-9527**

**测试分支为 develop**

```
# 开发分支
git add .
git commit -m "fix：修复xx页面xx功能"
git pull origin jira-9527 # 同步其他人的代码
git push origin jira-9527

git checkout develop
# 测试分支
git pull origin jira-9527
git merge jira-9527 --no-ff -m "fix：修复xx页面xx功能"
git push origin develop
git checkout jira-9527 
```

**我们可以发现，我们修改一个bug，需要敲击这9行命令，这9行命令有极大的可能敲错，尤其是开发分支，我们的分支一般是产品分给我们一个jira号，这个号通常是不规律的，忘记开发分支需要重复的去查找，这几个命令敲下来，少说得有30s。**

**让我们再看看加上线上环境的bug修复**

```
# 开发分支
git add .
git commit -m "fix：修复xx页面xx功能"
git pull origin jira-9527 # 同步其他人的代码
git push origin jira-9527

git checkout develop
# 测试分支
git pull origin develop
git merge jira-9527 --no-ff -m "fix：修复xx页面xx功能"
git push origin develop

git checkout master
# 线上
git pull origin master
git merge jira-9527 --no-ff -m "fix：修复xx页面xx功能"
git push origin master
git checkout jira-9527 
```

**修复一个线上bug我们需要同时提交测试分支，线上分支，因而我们又需要多敲几行，又多了45秒**

**来让我们看一下我平常的提交状态**

![image-20240202142141597](https://s2.loli.net/2024/02/02/6d9sOiZ3CpHyYw7.webp)

**57个提交！假设57个提交中，一半是提交开发分支，一半是测试分支，大概就是需要敲击29次上方的命令，29*30s，一天大概有15分钟我们是再敲这个枯燥的命令，并且敲这些命令对我们个人没有任何的提升，不行，得改变，不能让这些毫无意义的事情发生，每天省出的15分钟还能够让自己多摸鱼。**

![摸鱼](https://s2.loli.net/2024/02/02/4lZ8QJFLnONzhAD.webp)

## 分析

**我们首先要明白，如果要让脚本自动化，我们一定要记录自己的命令，我又不希望安装一些例如node，java等框架或库，我就让我们的电脑能直接运行，于是我使用了bash，那bash是什么呢？**

**维基百科：Bash是一个命令处理器，通常运行于文本窗口中，并能执行用户直接输入的命令。Bash还能从文件中读取命令，这样的文件称为脚本。**

**好了，我们明白了，bash能够在窗口使用命令，也能够执行后缀为.bash的文件中的命令。我们平常的git命令完全就可以贴进去了**

## 最简单的bash

```
#!/bin/bash
message="feat(博客首页)：我加了两个页面，你们都让开！" #message消息
curBranch='jira-9528' #当前的分支
branch='develop' #要提交的分支
git add .
git commit -m "$message"
git pull origin "$curBranch"
git push origin "$curBranch"

git checkout "$branch"
git pull origin "$branch"
git merge "$curBranch" --no-ff -m "$message" 
git push origin "$branch"

#可以新建一个test.bash文件，将这个文件中的所有内容粘贴进去
#bash test.bash 就可以运行以上命令
```

**可能聪明的同学就要问了，**`#!/bin/bash`这个是什么，他是预先告诉处理器他是个什么东西，例如我们使用 `bash test.bash`的命令执行时，我们已经告诉处理器这是个bash文件了，但是也有人喜欢使用 `. test.bash`这个时候处理器就不知道这个脚本到底是什么东西，因而无法进行正常编译

**我们看上面使用了一个message赋值，下方使用的时候使用$message,这样直接可以使用message变量，是的，你已经学会了bash脚本如何使用变量赋值了，奇怪的知识钻进了脑门。我们再着重一下，在设置变量的时候，不需要使用$,在使用的时候需要加上$。**

> **有一个小坑，在使用变量声明的时候等号要紧贴着左边的变量，否则会导致赋值不上去，例如** `test =2是不可以的`

**同样我们看引号，通常定义变量使用双引号，使用单引号在shell中会不被认为是变量，例如使用** `git checkout '$branch'`不可以，因为使用了单引号

## bash for循环的使用

### 数组

**在使用for循环之前，我们需要先了解一个小知识，就是数组类型，这个数组可能和我们之前认识的不太一样，他可以使用下标方法添加，或者使用扩号的方法添加，访问使用** `${arr[下标]}`就行取出。

**使用@或者*可以打印出里面所有的枚举值**

```
#下标的方法
arr[0]="第一"
arr[1]="第二"
echo "${arr[0]}" #第一 
echo "${arr[1]}" #第二

#括号的方法添加
arr=("第一" "第二") #使用空格隔开
arr+=("第三")
echo "${arr[0]}" #第一
echo "${arr[1]}" #第二
echo "${arr[2]}" #第三
echo "${arr[*]}" #第一 第二 第三
echo "${arr[@]}" #第一 第二 第三
```

**遍历数组**

```
arr[0]="第一"
arr[1]="第二"

for i in "${!arr[@]}"  #此处需注意，使用了!感叹号，使用感叹号说明要使用他的下标而不是value
do 
 echo The key value of element "${arr[$i]}" is "$i" #循环中做些什么
done #表示结束

#The key value of element 第一 is 0
#The key value of element 第二 is 1
```

### 优化的git提交

**这个时候我们来吧之前的git提交代码重写一下**

```
#!/bin/bash
message="feat(博客首页)：我加了两个页面，你们都让开！" #message消息
curBranch='jira-9528' #当前的分支
branchArr=('develop' 'master') #要提交的分支

git add .
git commit -m "$message"
git pull origin "$curBranch"
git push origin "$curBranch"

# 提交命令行参数中的分支代码
for branch in "${branchArr[@]}"; do
  git checkout "$branch"
  git pull origin "$branch"
  git merge "$curBranch" --no-ff -m "$message"
  git push origin "$branch"
done
```

**怎么样？这样是不是感觉很简单？**

**但是我们会发现，我们的当前分支，要提交的分支，和message这些都是死的，每次我们都需要改这个文件再去提交，这样当然不符合我们操作习惯，还不如之前方便。我们仍然需要进行依次优化**

## bashz自定义命令

### whilte循环

**在学习之前，我们先了解一下while do循环，while do与其他编程语言一致，只要括号中的条件为真，就一直执行其中的命令，通常用于逐行读取文本**

```
i=10
while [ $i -gt 0 ];  # -gt 大于 -lt 小于
do  
((i=i-1)) #如果使用计算需要使用双括号括起来
echo 这是我吃的第"$i"顿饭
done
```

### case的使用

```
expression="a"
case $expression in
    a)
       echo 吃饭
        ;; #必须使用分号进行分割子项
    b)
      echo  睡觉
        ;;
    c)
       echo 打豆豆
        ;;
    *) #类似于default
       echo 啥也不干
        ;;
esac #case结束，用来关闭case语句
```

### 自定义命令

**getopts命令，在使用命令的时候，例如npm,会使用 -v,等选项来查看版本**

**我们再写bash脚本的时候，也可自定义选项参数，并且使用getopts解析选项参数**

`getopts optstring name [args]`

`optstring`参数支持的选项列表，一个**字符**表示一个选项，字符后有冒号，说明跟着一个参数，不能使用:冒号和?问号作为选项

**我们来举例几个**

```
getopts "hi" name # -h是选项 -i是选项都没参数
getopts "hi:" name # -h是选项 -i是选项并且-i有参数
getopts "h:i:" name # -h是选项并且-h有参数 -i是选项并且-i有参数
getopts ":h:i:" name # -h是选项并且-h有参数 -i是选项并且-i有参数 前方的引号一般用于容错表示前方有参数

```

`name` 每次调用name，直接解析一个参数，并且把解析值放到name中，并且不包含-字符。

**通常在解析的时候，使用while或for循环多次执行gtopts命令直到完毕为止**

`[args]`为可选参数

**来练习一下getopts吧**

```
# test.bash文件
while getopts ":hvm:" name; do
case $name in
    h)
        echo 这里提供一些帮助的信息
        ;;
    v)
        echo 当前版本为1.0
        ;;
    m)
        echo 我有一些话给你说：$OPTARG # $OPTARG能获取到之后的输入信息
        ;;
    *)
        echo 这里什么都没有，换一种命令吧 
        ;;
esac
done
#测试一下以下的命令吧
# bash test.bash -h
# bash test.bash -g
# bash test.bash -v
# bash test.bash -m 我手机忘带了
```

**有小伙伴讲这太简单了，这不有手都会？**

![](https://s2.loli.net/2024/02/02/wbEvfmT7oSrVXnW.webp)

**来让我们加点注释把所有的方案一起实现**

## 最终解决方案

```
#gitpush.bash 文件夹
#!/bin/bash

# 获取命令行参数
while getopts ":b:m:" opt; do
  case $opt in
    b) branchArr+=("$OPTARG");;
    m) message="$OPTARG";;
    \?) echo "无效的选项: -$OPTARG" >&2; exit 1;;
  esac
done
shift $((OPTIND -1))  # 将已解析的选项参数移除

# 获取当前分支
curBranch=$(git rev-parse --abbrev-ref HEAD)
echo "当前分支为: $curBranch"

# 提交当前分支代码
git add .
git commit -m "$message"
git pull origin "$curBranch"
git push origin "$curBranch"

# 提交命令行参数中的分支代码
for branch in "${branchArr[@]}"; do
  git checkout "$branch"
  git pull origin "$branch"
  git merge "$curBranch" --no-ff -m "$message"
  git push origin "$branch"
done

# 切回当前分支
git checkout "$curBranch"

echo "全部提交成功，已切回当前分支: $curBranch"

# 使用方法 将此文件放到项目文件的外侧
# ../gitpush.bash -b branch1 branch2 -m "提交信息"
```

**通常开发的时候我更倾向于以下结构,因为不会影响影响其他项目**

```
|----buscode #公司项目目录
|           |----项目A
|           |----项目B
|           |----gitppush.bash #脚本文件
```

**终于肝完了，这篇文章是于2月2日加班通宵之空隙完成的，因为提交的bug太多，实在是难受，因而学bash为了省时间。希望能够帮助到你**

![](https://s2.loli.net/2024/02/02/gedZLwAthSDvVTl.webp)

## 引用

**	**【1】[getopts 可选参数_Bash技巧：介绍 getopts 内置命令解析选项参数的用法](https://blog.csdn.net/weixin_36028920/article/details/112494187)
