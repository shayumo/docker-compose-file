# 项目上下文：Docker Compose 配置文件集合

## 目录概述

本目录是一个 **Docker Compose 配置文件** 的集合仓库。它包含了用于部署各种应用程序和服务的 `docker-compose.yml` (或 `.yaml`) 文件。这些文件既可以是独立的单服务配置（位于根目录），也可以是更复杂的多服务应用栈（位于各自的子目录中）。

主要用途是集中管理和版本控制个人或团队使用的 Docker 应用部署配置，便于在不同环境（如家庭服务器、NAS、开发机）中快速、一致地启动所需的服务。

## 项目结构

- **根目录**: 包含一系列以 `<service_name>.yaml` 命名的文件，每个文件通常定义一个独立服务的部署配置。
    - 例如: `jellyfin_stack.yaml`, `mariadb_stack.yaml`, `heimdall.yaml` 等。
- **子目录**: 每个子目录（如 `bitwarden/`, `dify/`, `alist/`）代表一个更复杂的应用或应用套件，其内部包含完整的 `docker-compose.yml` 文件以及可能需要的配套文件（如 `.env` 文件、自定义配置等）。
- **关键文件**:
    - `templates-2.0.json`: 一个 Portainer 应用模板文件，用于在 Portainer UI 中快速部署常用服务。
    - `mariadb.md`: 关于 MariaDB 栈的简要说明文档。

## 使用方法

### 部署单个服务（根目录下的 `.yaml` 文件）

1.  **导航到项目根目录**:
    ```bash
    cd /media/hiext/COMMON/docker-compose-file
    ```
2.  **使用 `docker compose` 命令并指定文件进行部署**:
    ```bash
    # 例如，部署 Jellyfin 服务
    docker compose -f jellyfin_stack.yaml up -d

    # 例如，部署 Heimdall 服务
    docker compose -f heimdall.yaml up -d
    ```

### 部署复杂应用栈（子目录中的应用）

1.  **导航到对应的应用子目录**:
    ```bash
    # 例如，部署 Bitwarden
    cd /media/hiext/COMMON/docker-compose-file/bitwarden/docker
    ```
2.  **在该目录下直接运行 `docker compose` 命令** (它会自动查找 `docker-compose.yml`):
    ```bash
    docker compose up -d
    ```
    > **注意**: 部分应用（如 Bitwarden）在启动前可能需要先进行初始化配置，请务必查阅该应用官方文档。

### 在 Portainer 中使用

根目录下的 `templates-2.0.json` 文件可以直接导入到 Portainer 中，作为应用模板使用，从而通过图形界面一键部署常用服务。

## 开发与维护约定

- **配置管理**: 所有 Docker Compose 配置都应通过此仓库进行版本控制。
- **路径约定**: 配置文件中的卷（volumes）挂载路径通常是针对特定主机环境（如 `/srv/dev-disk-by-uuid-...`）定制的，在迁移到新环境时需要根据实际情况进行调整。
- **安全性**: 配置文件中可能包含默认密码（如 `mariadb_stack.yaml` 中的 `MYSQL_ROOT_PASSWORD: admin`）。**在生产或公共网络环境中，必须修改这些默认凭据**。
- **文档**: 对于复杂的自定义栈，建议在对应目录下添加 `README.md` 文件，说明部署步骤、依赖项和配置选项。