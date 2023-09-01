# 使用 Node.js 作为基础镜像
FROM node:16

# 设置工作目录
WORKDIR /app

COPY package*.json ./

# 安装项目依赖
RUN npm install

RUN npm install hexo-cli -g


# 构建生产环境静态文件
RUN npm run build

# 设置容器启动命令
CMD ["hexo","s"]
