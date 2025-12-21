# 使用 PostgreSQL 18 基础镜像
FROM postgres:18



# 安装 pgvector 和 vectorchord
RUN apt-get update && \
    apt-get install -y wget gnupg && \
    wget -qO- https://packages.vectorchord.ai/gpg.key | gpg --dearmor -o /usr/share/keyrings/vectorchord.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/vectorchord.gpg] https://packages.vectorchord.ai/debian stable main" > /etc/apt/sources.list.d/vectorchord.list && \
    apt-get update && \
    apt-get install -y postgresql-18-pgvector vectorchord-postgresql && \
    rm -rf /var/lib/apt/lists/*

RUN psql -U postgres -c 'ALTER SYSTEM SET shared_preload_libraries = "vchord"'
RUN psql -U postgres -c 'CREATE EXTENSION IF NOT EXISTS vector;'

# 设置启动命令
CMD ["postgres"]
