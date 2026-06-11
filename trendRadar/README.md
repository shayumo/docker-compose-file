# 方式一：使用 docker compose（推荐）

1. **创建项目目录和配置**:

   ```bash
   # 克隆项目到本地
   git clone https://github.com/sansan0/TrendRadar.git
   cd TrendRadar
   ```

   > 💡 **说明**：Docker 部署需要的关键目录结构如下：
```
当前目录/
├── config/
│   ├── config.yaml                 # 核心功能配置（必需）
│   ├── frequency_words.txt         # 关键词配置（必需）
│   ├── timeline.yaml               # 时间线配置
│   ├── ai_analysis_prompt.txt      # AI 分析提示词（可选）
│   ├── ai_translation_prompt.txt   # AI 翻译提示词（可选）
│   ├── ai_interests.txt            # AI 兴趣过滤配置（可选）
│   ├── ai_filter/                  # AI 过滤相关提示词
│   │   ├── prompt.txt
│   │   ├── extract_prompt.txt
│   │   └── update_tags_prompt.txt
│   └── custom/                     # 用户自定义配置（可选）
│       ├── ai/                     # 自定义 AI 提示词
│       └── keyword/                # 自定义关键词文件
└── docker/
    ├── .env                        # 敏感信息 + Docker 特有配置
    └── docker-compose.yml          # Docker Compose 编排文件
```

2. **配置文件说明**:

   **配置分工原则（v4.6.0 优化）**：

   | 文件                               | 用途                           | 修改频率 | 说明                                                                        |
   | ---------------------------------- | ------------------------------ | -------- | --------------------------------------------------------------------------- |
   | `config/config.yaml`               | **核心功能配置**               | 低       | 报告模式、推送设置、存储格式、推送窗口、AI 分析开关、平台启用等全局行为控制 |
   | `config/frequency_words.txt`       | **关键词配置**                 | 高       | 设置你关心的热点词汇，支持分组、正则、别名等高级语法                        |
   | `config/timeline.yaml`             | **时间线配置**                 | 低       | 控制新闻时间线的展示和过滤规则                                              |
   | `config/ai_analysis_prompt.txt`    | **AI 分析提示词**              | 中       | 自定义 AI 分析的角色定义和输出格式（v5.0.0+）                               |
   | `config/ai_translation_prompt.txt` | **AI 翻译提示词**              | 低       | 自定义 AI 翻译的提示词模板                                                  |
   | `config/ai_interests.txt`          | **AI 兴趣过滤**                | 中       | 定义 AI 基于兴趣自动过滤新闻的规则                                          |
   | `config/ai_filter/`                | **AI 过滤提示词**              | 低       | AI 过滤模块的内部提示词（一般无需修改）                                     |
   | `config/custom/`                   | **用户自定义扩展**             | 按需     | `custom/ai/` 放自定义 AI 提示词，`custom/keyword/` 放自定义关键词文件       |
   | `docker/.env`                      | **敏感信息 + Docker 特有配置** | 低       | webhook URLs、API Key、S3 密钥、定时任务等，**不会被 git 追踪**             |

   > 💡 **分工要点**：
   > - **功能行为** → 改 `config.yaml`（如开启/关闭某个平台、调整推送模式）
   > - **关注内容** → 改 `frequency_words.txt`（如添加新的关注关键词）
   > - **AI 输出风格** → 改 `ai_analysis_prompt.txt` 或 `ai_translation_prompt.txt`
   > - **密钥与凭证** → 改 `docker/.env`（API Key、Webhook URL 等敏感信息统一放这里）
   > - **个性化扩展** → 使用 `config/custom/` 目录，避免直接修改默认配置被升级覆盖

   > 💡 **配置修改生效**：修改 `config.yaml` 后，执行 `docker compose up -d` 重启容器即可生效

   **⚙️ 环境变量覆盖机制（v3.0.5+）**

   `.env` 文件中的环境变量会覆盖 `config.yaml` 中的对应配置：

   | 环境变量              | 对应配置                                   | 示例值                           | 说明                                             |
   | --------------------- | ------------------------------------------ | -------------------------------- | ------------------------------------------------ |
   | `WEBSERVER_PORT`      | -                                          | `8080`                           | Web 服务器端口                                   |
   | `FEISHU_WEBHOOK_URL`  | `notification.channels.feishu.webhook_url` | `https://...`                    | 飞书 Webhook（多账号用 `;` 分隔）                |
   | `AI_ANALYSIS_ENABLED` | `ai_analysis.enabled`                      | `true` / `false`                 | 是否启用 AI 分析（v5.0.0 新增）                  |
   | `AI_API_KEY`          | `ai.api_key`                               | `sk-xxx...`                      | AI API Key（ai_analysis 和 ai_translation 共享） |
   | `AI_PROVIDER`         | `ai.provider`                              | `deepseek` / `openai` / `gemini` | AI 提供商                                        |
   | `S3_*`                | `storage.remote.*`                         | -                                | 远程存储配置（5 个参数）                         |

   **配置优先级**：环境变量 > config.yaml

   **使用方法**：
   - 修改 `.env` 文件，填写需要的配置
   - 或在 NAS/群晖 Docker 管理界面的"环境变量"中直接添加
   - 重启容器后生效：`docker compose up -d`


3. **启动服务**:

   **选项 A：启动所有服务（推送 + AI 分析）**
   ```bash
   # 拉取最新镜像
   docker compose pull

   # 启动所有服务（trendradar + trendradar-mcp）
   docker compose up -d
   ```

   **选项 B：仅启动新闻推送服务**
   ```bash
   # 只启动 trendradar（定时抓取和推送）
   docker compose pull trendradar
   docker compose up -d trendradar
   ```

   **选项 C：仅启动 MCP AI 分析服务**
   ```bash
   # 只启动 trendradar-mcp（提供 AI 分析接口）
   docker compose pull trendradar-mcp
   docker compose up -d trendradar-mcp
   ```

   > 💡 **提示**：
   > - 大多数用户只需启动 `trendradar` 即可实现新闻推送功能
   > - 只有需要使用 ChatGPT/Gemini 进行 AI 对话分析时，才需启动 `trendradar-mcp`
   > - 两个服务相互独立，可根据需求灵活组合

4. **查看运行状态**:
   ```bash
   # 查看新闻推送服务日志
   docker logs -f trendradar

   # 查看 MCP AI 分析服务日志
   docker logs -f trendradar-mcp

   # 查看所有容器状态
   docker ps | grep trendradar

   # 停止特定服务
   docker compose stop trendradar      # 停止推送服务
   docker compose stop trendradar-mcp  # 停止 MCP 服务
   ```

#### 方式二：本地构建（开发者选项）

如果需要自定义修改代码或构建自己的镜像：

```bash
# 克隆项目
git clone https://github.com/sansan0/TrendRadar.git
cd TrendRadar

# 修改配置文件
vim config/config.yaml
vim config/frequency_words.txt

# 使用构建版本的 docker compose
cd docker
cp docker-compose-build.yml docker-compose.yml
```

**构建并启动服务**：

```bash
# 选项 A：构建并启动所有服务
docker compose build
docker compose up -d

# 选项 B：仅构建并启动新闻推送服务
docker compose build trendradar
docker compose up -d trendradar

# 选项 C：仅构建并启动 MCP AI 分析服务
docker compose build trendradar-mcp
docker compose up -d trendradar-mcp
```

> 💡 **架构参数说明**：
> - 默认构建 `amd64` 架构镜像（适用于大多数 x86_64 服务器）
> - 如需构建 `arm64` 架构（Apple Silicon、树莓派等），设置环境变量：
>   ```bash
>   export DOCKER_ARCH=arm64
>   docker compose build
>   ```

#### 镜像更新

```bash
# 方式一：手动更新（爬虫 + MCP 镜像）
docker pull wantcat/trendradar:latest
docker pull wantcat/trendradar-mcp:latest
docker compose down
docker compose up -d

# 方式二：使用 docker compose 更新
docker compose pull
docker compose up -d
```

**可用镜像**：

| 镜像名称                 | 用途         | 说明                   |
| ------------------------ | ------------ | ---------------------- |
| `wantcat/trendradar`     | 新闻推送服务 | 定时抓取新闻、推送通知 |
| `wantcat/trendradar-mcp` | MCP 服务     | AI 分析功能（可选）    |

#### 服务管理命令

```bash
# 查看运行状态
docker exec -it trendradar python manage.py status

# 手动执行一次爬虫
docker exec -it trendradar python manage.py run

# 查看实时日志
docker exec -it trendradar python manage.py logs

# 显示当前配置
docker exec -it trendradar python manage.py config

# 显示输出文件
docker exec -it trendradar python manage.py files

# Web 服务器管理（用于浏览器访问生成的报告）
docker exec -it trendradar python manage.py start_webserver   # 启动 Web 服务器
docker exec -it trendradar python manage.py stop_webserver    # 停止 Web 服务器
docker exec -it trendradar python manage.py webserver_status  # 查看 Web 服务器状态

# 查看帮助信息
docker exec -it trendradar python manage.py help

# 重启容器
docker restart trendradar

# 停止容器
docker stop trendradar

# 删除容器（保留数据）
docker rm trendradar
```

> 💡 **Web 服务器说明**：
> - cron 模式下自动启动，通过浏览器访问 `http://localhost:8080` 查看最新报告
> - 通过目录导航访问历史报告（如：`http://localhost:8080/2025-xx-xx/`）
> - 端口可在 `.env` 文件中配置 `WEBSERVER_PORT` 参数
> - 手动停止：`docker exec -it trendradar python manage.py stop_webserver`
> - 手动启动：`docker exec -it trendradar python manage.py start_webserver`
> - 安全提示：仅提供静态文件访问，限制在 output 目录，只绑定本地访问