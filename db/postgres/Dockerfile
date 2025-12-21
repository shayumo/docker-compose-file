# 使用 PostgreSQL 18 基础镜像
FROM postgres:18

# 安装 pgvector
RUN apt-get update && \
    apt-get install -y postgresql-18-pgvector && \
    rm -rf /var/lib/apt/lists/*
RUN cd /var/lib/apt && \
    wget https://github.com/tensorchord/VectorChord/releases/download/1.0.0/postgresql-18-vchord_1.0.0-1_$(dpkg --print-architecture).deb && \
    apt install ./postgresql-18-vchord_1.0.0-1_$(dpkg --print-architecture).deb

RUN psql -U postgres -c 'ALTER SYSTEM SET shared_preload_libraries = "vchord,vchord_bm25,vector,pg_tokenizer"'
    
# 设置启动命令
CMD ["postgres"]

