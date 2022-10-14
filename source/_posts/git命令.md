---
title: git命令
date: 2022-07-12 09:56:50
categories:
- git
---


```shell
git remote show origin         		//显示远程库origin里的资源 
git push origin master:develop     //本地库和服务器进行关联
git branch -D master develop      //删除本地库develop
git remote show 查看远程库
git rm 文件名(包括路径) 从git中删除指定文件
git config --list 看所有用户
git ls-files 看已经被提交的
git rm [file name] 删除一个文件
git commit -a 提交当前repos的所有的改变
git add [file name] 添加一个文件到git index
git commit -v 当你用－v参数的时候可以看commit的差异
git commit -m "This is the message describing the commit" 添加commit信息
git commit -a -a是代表add，把所有的change加到git index里然后再commit
git commit -a -v 一般提交命令
git log 看你commit的日志
git diff 查看尚未暂存的更新
git rm a.a 移除文件(从暂存区和工作区中删除)
git rm --cached a.a 移除文件(只从暂存区中删除)
git commit -m "remove" 移除文件(从Git中删除)
git rm -f a.a 强行移除修改后文件(从暂存区和工作区中删除)
git diff --cached 或 $ git diff --staged 查看尚未提交的更新
git stash push 将文件给push到一个临时空间中
git stash pop 将文件从临时空间pop下来
git remote remove origin 远程仓库断开连接
git remote add origin git@github.com:username/Hello-World.git 与远程仓库建立连接
git fetch 相当于是从远程获取最新版本到本地，不会自动merge
git branch branch_0.1 master 从主分支master创建branch_0.1分支
git branch -m branch_0.1 branch_1.0 将branch_0.1重命名为branch_1.0
```

详情看https://blog.csdn.net/halaoda/article/details/78661334

## **切换分支，管理暂存的代码**

例如我们正在一个分支进行开发，但是另一个分支的需要进行上线，而切换到另一个分支，此时必须commit，才能够切换，

使用

```
git stash // 将本地改动暂存到“栈”里面 

git stash pop // 再将刚才暂存到“栈”里面的代码取出来

git branch  // 查看当前分支  

git stash // 将本地改动暂存到“栈”里面  

git checkout master // 切换到master分支  

git pull // 拉取master分支最新的代码,

当我们再想切换回当前的feature分支  

git checkout feature // 切换回到feature分支  

git stash pop // 再将刚才暂存到“栈”里面的代码取出来,

这样就可以继续接着刚才的业务逻辑继续开发了
```



 原文链接：https://blog.csdn.net/CherryLee_1210/article/details/108298304

## **git pull 强制覆盖本地**

从远程仓库下载最新版本 git fetch --all  

将本地设为刚获取的最新的内容  git reset --hard origin/master

## **删除分支**

```
查看本地分支 ： git branch 

删除本地已合并的分支： git branch -d [branchname] 

删除远程分支: git push origin --delete [branchname]
```
## commit之后发现错了不想提交
``` 
git reset HEAD -- . //一次性撤销所有放入残存去的文件
git reset HEAD -- filename //撤销指定目标文件
```

## 回退到上一个版本

```
git reset --hard head
git reset --hard  版本好
git reflog 查看版本号

git reset HEAD^  //把提交撤回,文件还是处于commit之前状态
```

## **删除本地仓库**

**未pull master代码直接合并develop**

背景：

本地从master新建分支，jira-1234，但是本地master不是最新的，然后在分支上修改后，直接合并到了develop，

此时，只需要把master合并到jira分支上，然后将jira合并到devleop就可以了

**部署**

```
//首先切换到自己分支 git checkout 分支名称 
git status git add . 
git commit -m "注释" 
git push origin "分支名" 
git checkout develop   //切换到主分支 
git pull origin develop 
git merge "次分支" --no-ff -m "注释名称" 
git push origin "主分支名称" 
git checkout jira-2554  //切换回来分支
```



## **没有在开发分支上开发,直接在测试分值上开发,并且已经commit了怎么办**

```
1.git reset HEAD^ //把上次提交恢复到未提交状态 
2.git stash 放置暂存区 
3.git checkout "目标分支上" 
4.git stash pop
```



## **多人协作开发**

思路：将自己代码切换到master拉一下最新代码在master里面pull更新到最新代码在develop里面pull到最新代码然后合并到develop进行测试

```
git checkout 分支名称 
git merge master --no-ff -m "" 
git status git add . 
git commit -m "注释" 
git push origin "分支名" //这里从自己的jira里面切换到develop 
git checkout develop 
git pull origin develop 
git merge //分支 --no-ff -m ""//注释 ，有规则情况可能要加:fix，这种情况去gitlab看别人怎么注释的 
git push origin develop 
git checkout jira-2554  //切换回来分支 
```



## **gitHub连不上去**

### 手动设置hash

https://ipaddress.com/website/www.github.com这个网站中搜索[github.com](https://ipaddress.com/website/github.com)的ip

然后在C:\Windows\System32\Drivers\etc      添加，将查找的ip替换以下的ip

\#github 140.82.114.4 github.com  199.232.69.194 github.global.ssl.fastly.net   

**教学**[**https://www.cnblogs.com/lifexy/p/8353040.html**](https://www.cnblogs.com/lifexy/p/8353040.html)

### 自动获取设置hash的ip

​	具体教学是在gitee中看到的，由于不会使用safari的历史记录就找不到了，上链接http://www.electronjs.org/apps/switchhosts

目前用于github的连接，偶尔不稳定

如果不起作用，清空一下dns缓存

```
在 Windows 下命令行执行：ipconfig /flushdns
在 macOS 下执行命令：sudo killall -HUP mDNSResponder


//修复键盘
sudo killall -STOP -c usbd
```







## **将vscode的终端启动默认项改为git bash**

\1. 在首选项中搜索shell.windows，

 2.在default profile：windows中的选项改为git bash 

3.找到setting.json中添加 

```
 "terminal.integrated.profiles.windows": {   "Git-Bash": {    "path": "D:\\Git\\bin\\bash.exe",   }, 
 "PowerShell -NoProfile": {    "source": "PowerShell",    "args": ["-NoProfile"]   } 
 }, 
 "terminal.integrated.defaultProfile.windows": "Git-Bash",  
```

 4.如果有以下一行记得注释 "terminal.integrated.shell.windows": "C:\\windows\\Sysnative\\cmd.exe"  

5.重启vscode

## git断开远程仓库

git remote remove origin



## git eslit报错

```
git commit --no-verify -m "更新物料" 这样提交就可以了 
```

## git拉取不同版本

```
git log //获取之前的分支日志查看后面的版本号
git checkout 版本号(类似这样:d4e86275490ace7d30ba731e7b2d95d2310bbe77)  //就可以了
```

换电脑拉不下另一台电脑的分支

```
git branch -a  //查看连接的分支
git fetch // 更新远程分支
```

