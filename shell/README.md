# 服务器初始化脚本 (init.sh)

## 概述

`init.sh` 是一个用于快速初始化 Linux 服务器的 Bash 脚本。它旨在自动化完成新服务器部署后的常见配置任务，包括配置国内软件源、安装基础工具、设置时间同步以及安装和配置 Docker。

## 功能特性

- **操作系统支持**:
  - Ubuntu / Debian
  - CentOS / RHEL / Fedora
- **配置国内软件源**: 自动将系统包管理器（APT/YUM/DNF）的更新源切换为阿里云镜像，以加速软件包下载。
- **安装常用工具**: 安装 `curl`, `wget`, `vim`, `git`, `htop`, `net-tools`, `lsof` 等日常运维和开发必备工具。
- **时间同步**: 配置并启用 NTP 服务，使用 `ntp.aliyun.com` 作为时间服务器，确保系统时间准确。
- **Docker 安装与配置**:
  - 从 Docker 官方仓库安装最新版 Docker 引擎 (`docker-ce`) 和 Compose 插件 (`docker-compose-plugin`)。
  - 自动配置国内 Docker 镜像加速器（中科大、网易、百度），大幅提升镜像拉取速度。
  - 将当前执行用户添加到 `docker` 用户组，以便无需 `sudo` 即可运行 `docker` 命令。

## 使用方法

1.  **获取脚本**:
    确保 `init.sh` 脚本在您的工作目录中，并具有可执行权限。
    ```bash
    chmod +x init.sh
    ```

2.  **运行脚本**:
    在目标服务器上以具有 `sudo` 权限的用户身份执行脚本。
    ```bash
    ./init.sh
    ```

3.  **后续操作**:
    脚本执行完毕后，如果提示已将用户加入 `docker` 组，请**重新登录**您的会话，以使组权限生效。之后即可直接使用 `docker` 和 `docker compose` 命令。

## 注意事项

- **Root 权限**: 脚本内部大量使用 `sudo` 命令，因此执行用户必须拥有 `sudo` 权限。
- **网络连接**: 脚本需要访问互联网以下载软件包和配置文件。
- **备份**: 脚本在修改系统源时会自动备份原始配置文件（例如 `/etc/apt/sources.list.bak.*`）。
- **Docker 用户组**: 用户组的更改在当前会话中不会立即生效，必须重新登录或使用 `newgrp docker` 命令来激活。