
# UOS签名 Docker 镜像使用指南

本文档介绍了如何使用提供的 Dockerfile 构建 uos签名工具的 Docker 镜像，并运行容器以签名 `.deb` 文件。

使用本项目可以不使用UOS系统来进行UOS系统所要求的deb签名，UOS的试用期实在是太短了。

当然，你首先需要从UOS购买一个含有证书的硬件设备。

---

## 1. 准备工作

### 1.1 文件结构
确保你的工作目录包含以下文件：
- `Dockerfile`：用于构建镜像的 Dockerfile。
- `start.sh`：容器启动脚本。
- `deepin-elf-sign-tool_1.3.23.1-1_amd64.deb`：`amd64` 架构的 Deepin-ELF-Sign 工具。
- `deepin-elf-signverify-common_1.3.23.1-1_all.deb`：通用的 Deepin-ELF-Sign 依赖包。
- `deepin-elf-sign-tool_1.2.16-2+u1_arm64.deb`：`arm64` 架构的 Deepin-ELF-Sign 工具。
- `Info.plist`：PC/SC 驱动配置文件。

### 1.2 环境要求
- 已安装 Docker。
- 确保 Docker 服务正在运行。

---

## 2. 构建 Docker 镜像

### 2.1 构建 `amd64` 镜像
如果你的目标架构是 `amd64`，运行以下命令：
```bash
docker build --build-arg TARGET_ARCH=amd64 -t my-deepin-signer .
```

### 2.2 构建 `arm64` 镜像
如果你的目标架构是 `arm64`，运行以下命令：
```bash
docker build --build-arg TARGET_ARCH=arm64 -t my-deepin-signer .
```

### 2.3 验证镜像
构建完成后，运行以下命令查看镜像：
```bash
docker images
```
你应该会看到 `my-deepin-signer` 镜像。

---

## 3. 运行 Docker 容器，进行uos的deb签名

### 3.1 准备文件
确保以下文件在本地目录中：
- 待签名的 `.deb` 文件（如 `my-package.deb`）。
- 证书文件（如 `certificate.crt`）。
- 配置文件（如 `wosign.conf`）。

### 3.2 运行容器
运行以下命令启动容器并签名 `.deb` 文件：
```bash
docker run --rm \
  -v $(pwd):/app \
  -e DEB_FILE=/app/my-package.deb \
  -e CRT_FILE=/app/certificate.crt \
  -e CONF_FILE=/app/wosign.conf \
  my-deepin-signer
```

#### 参数说明：
- `-v $(pwd):/app`：将当前目录挂载到容器的 `/app` 目录。
- `-e DEB_FILE=/app/my-package.deb`：指定待签名的 `.deb` 文件路径。
- `-e CRT_FILE=/app/certificate.crt`：指定证书文件路径。
- `-e CONF_FILE=/app/wosign.conf`：指定配置文件路径。

### 3.3 输出结果
如果签名成功，你会看到以下输出：
```
Signing completed successfully.
```
