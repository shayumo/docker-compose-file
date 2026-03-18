#!/bin/bash

# init.sh - 服务器初始化脚本
# 功能: 配置系统源、安装常用工具、设置时间同步、安装并配置Docker

set -e # 遇到错误立即退出

echo "开始服务器初始化..."

# 检测操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID
else
    echo "无法检测操作系统类型。"
    exit 1
fi

echo "检测到操作系统: $OS $OS_VERSION"

# ========================
# 1. 配置系统更新源为中国镜像
# ========================
configure_apt_sources() {
    echo "正在配置 APT 源为阿里云镜像..."
    # 备份原始 sources.list
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%Y%m%d%H%M%S)
    # 获取 Ubuntu/Debian 代号
    CODENAME=$(lsb_release -cs)
    # 构建新的 sources.list 内容
    cat > /tmp/sources.list << EOF
deb http://mirrors.aliyun.com/ubuntu/ $CODENAME main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ $CODENAME-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ $CODENAME-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ $CODENAME-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ $CODENAME-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $CODENAME main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $CODENAME-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $CODENAME-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $CODENAME-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $CODENAME-backports main restricted universe multiverse
EOF
    sudo mv /tmp/sources.list /etc/apt/
    sudo apt-get update
}

configure_yum_sources() {
    echo "正在配置 YUM/DNF 源为阿里云镜像..."
    # 备份原始 repo 文件
    sudo mkdir -p /etc/yum.repos.d/bak.$(date +%Y%m%d%H%M%S)
    sudo mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak.$(date +%Y%m%d%H%M%S)/ 2>/dev/null || true

    if command -v dnf &> /dev/null; then
        # Fedora 或较新版本的 CentOS/RHEL
        cat > /tmp/fedora.repo << EOF
[fedora]
name=Fedora \$releasever - \$basearch
failovermethod=priority
baseurl=https://mirrors.aliyun.com/fedora/releases/\$releasever/Everything/\$basearch/os/
metadata_expire=28d
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/fedora/releases/\$releasever/Everything/\$basearch/os/RPM-GPG-KEY-fedora-\$releasever-\$basearch
skip_if_unavailable=False

[updates]
name=Fedora \$releasever - \$basearch - Updates
failovermethod=priority
baseurl=https://mirrors.aliyun.com/fedora/updates/\$releasever/Everything/\$basearch/
enabled=1
gpgcheck=1
metadata_expire=6h
gpgkey=https://mirrors.aliyun.com/fedora/updates/\$releasever/Everything/\$basearch/RPM-GPG-KEY-fedora-\$releasever-\$basearch
skip_if_unavailable=True
EOF
        sudo mv /tmp/fedora.repo /etc/yum.repos.d/
        sudo dnf makecache
    else
        # CentOS/RHEL 7/8
        VERSION=$(echo $OS_VERSION | cut -d '.' -f1)
        cat > /tmp/CentOS-Base.repo << EOF
[base]
name=CentOS-\$releasever - Base - mirrors.aliyun.com
baseurl=https://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-\$releasever

[updates]
name=CentOS-\$releasever - Updates - mirrors.aliyun.com
baseurl=https://mirrors.aliyun.com/centos/\$releasever/updates/\$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-\$releasever

[extras]
name=CentOS-\$releasever - Extras - mirrors.aliyun.com
baseurl=https://mirrors.aliyun.com/centos/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-\$releasever

[centosplus]
name=CentOS-\$releasever - Plus - mirrors.aliyun.com
baseurl=https://mirrors.aliyun.com/centos/\$releasever/centosplus/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-\$releasever
EOF
        sudo mv /tmp/CentOS-Base.repo /etc/yum.repos.d/
        sudo yum makecache
    fi
}

case $OS in
    ubuntu|debian)
        configure_apt_sources
        ;;
    centos|rhel|fedora)
        configure_yum_sources
        ;;
    *)
        echo "警告: 不支持的操作系统 $OS，跳过源配置。"
        ;;
esac

# ========================
# 2. 安装常用系统工具
# ========================
echo "正在安装常用系统工具..."
case $OS in
    ubuntu|debian)
        sudo apt-get install -y curl wget vim git htop net-tools lsof
        ;;
    centos|rhel|fedora)
        if command -v dnf &> /dev/null; then
            sudo dnf install -y curl wget vim git htop net-tools lsof
        else
            sudo yum install -y curl wget vim git htop net-tools lsof
        fi
        ;;
    *)
        echo "警告: 不支持的操作系统 $OS，跳过工具安装。"
        ;;
esac

# ========================
# 3. 配置并同步 NTP 时间服务器
# ========================
echo "正在配置 NTP 时间服务器..."
if command -v timedatectl &> /dev/null; then
    # 对于使用 systemd 的现代 Linux 发行版
    sudo timedatectl set-ntp on
    echo "已启用 systemd-timesyncd 服务。"
elif command -v systemctl &> /dev/null && systemctl is-active --quiet ntpd; then
    # 对于使用传统 ntpd 的系统
    echo "ntpd 服务已在运行。"
else
    # 尝试安装并启动 ntp 或 chrony
    case $OS in
        ubuntu|debian)
            if ! command -v ntpd &> /dev/null; then
                sudo apt-get install -y ntp
            fi
            sudo systemctl enable ntp
            sudo systemctl restart ntp
            ;;
        centos|rhel|fedora)
            if ! command -v chronyd &> /dev/null; then
                if command -v dnf &> /dev/null; then
                    sudo dnf install -y chrony
                else
                    sudo yum install -y chrony
                fi
            fi
            sudo systemctl enable chronyd
            sudo systemctl restart chronyd
            ;;
        *)
            echo "警告: 无法为 $OS 配置 NTP 服务。"
            ;;
    esac
fi

# 强制立即同步一次时间
if command -v ntpdate &> /dev/null; then
    sudo ntpdate -s ntp.aliyun.com
elif command -v chronyc &> /dev/null; then
    sudo chronyc makestep
elif command -v timedatectl &> /dev/null; then
    # systemd-timesyncd 通常会自动同步，这里不强制
    echo "时间同步服务已配置，将自动同步。"
else
    echo "警告: 未找到时间同步客户端，无法强制同步。"
fi

# ========================
# 4. 安装 Docker 引擎
# ========================
echo "正在安装 Docker..."
# 移除旧版本
case $OS in
    ubuntu|debian)
        sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg lsb-release
        # 添加 Docker 官方 GPG 密钥
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        # 设置仓库
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        ;;
    centos|rhel|fedora)
        if [ "$OS" = "fedora" ]; then
            sudo dnf -y remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine || true
            sudo dnf -y install dnf-plugins-core
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        else
            # CentOS/RHEL
            sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine || true
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        fi
        ;;
    *)
        echo "错误: 不支持的操作系统 $OS，无法安装 Docker。"
        exit 1
        ;;
esac

# 启动并启用 Docker 服务
sudo systemctl enable docker
sudo systemctl start docker

# 将当前用户加入 docker 组以避免每次使用 sudo
if ! groups $USER | grep &>/dev/null '\bdocker\b'; then
    sudo usermod -aG docker $USER
    echo "已将用户 $USER 加入 docker 组。请重新登录以应用组更改。"
fi

# ========================
# 5. 配置 Docker 中国国内镜像加速器
# ========================
echo "正在配置 Docker 镜像加速器..."
sudo mkdir -p /etc/docker
cat > /tmp/daemon.json << EOF
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
EOF
sudo mv /tmp/daemon.json /etc/docker/daemon.json
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "Docker 镜像加速器已配置。"

echo "服务器初始化完成！"
echo "注意：如果用户组已更改，请重新登录以使 'docker' 命令无需 sudo 生效。"
