# 使用 PostgreSQL 18 基础镜像
FROM postgres:18

# 安装 pgvector
RUN apt-get update && \
    apt-get install -y postgresql-18-pgvector && \
    rm -rf /var/lib/apt/lists/*

# 设置启动命令
CMD ["postgres"]

