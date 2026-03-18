# 反向代理设置指南

Nextcloud AIO 默认配置为使用自签名证书在端口 443 上提供安全的 HTTPS 连接。如果您的环境中已经有一个反向代理服务器（如 Apache、Nginx、Caddy、Traefik 等），或者您希望使用反向代理来处理 HTTPS 连接，本指南将帮助您正确配置它。

> **注意**：如果您不确定是否需要反向代理，请先尝试不使用反向代理进行设置。只有在您确实需要反向代理的情况下（例如端口 443 已被其他服务占用、您想在同一台服务器上托管多个服务、或者您需要更复杂的网络配置），才继续阅读本指南。

## 何时需要反向代理？

- 如果端口 443 已经被其他服务占用
- 如果您想在同一台服务器上托管多个使用 HTTPS 的服务
- 如果您想使用自定义的 SSL/TLS 证书
- 如果您想使用特定的反向代理功能（如高级负载均衡、WAF、DDoS 防护等）
- 如果您使用了 Tailscale、Cloudflare Tunnel 或其他类似的服务

## 何时不需要反向代理？

- 如果您只想运行 Nextcloud 一个服务
- 如果端口 443 可用
- 如果您不想管理额外的网络层

## 关于反向代理的建议

- **Tailscale**：如果您使用 Tailscale，建议查看这个 [Tailscale 指南](https://github.com/nextcloud/all-in-one/discussions/6817)。
- **Caddy**：如果您刚开始接触反向代理，Caddy 是一个很好的选择，因为它可以自动管理 SSL 证书。

## 配置步骤

### 1. 配置您的反向代理

选择以下与您使用的反向代理对应的配置部分，并按照说明进行设置：

#### Apache

<details>

<summary>点击展开</summary>

确保已安装并启用了以下 Apache 模块：

```bash
# 在 Debian/Ubuntu 上
 sudo a2enmod proxy proxy_http proxy_wstunnel ssl headers
```

创建一个新的虚拟主机配置文件：

```apache
<VirtualHost *:80>
    ServerName <your-nc-domain>  # 替换为您的域名
    Redirect permanent / https://<your-nc-domain>/  # 将所有 HTTP 请求重定向到 HTTPS
</VirtualHost>

<VirtualHost *:443>
    ServerName <your-nc-domain>  # 替换为您的域名

    # SSL 配置
    SSLEngine on
    SSLCertificateFile /path/to/your/cert.pem  # 替换为您的证书路径
    SSLCertificateKeyFile /path/to/your/privkey.pem  # 替换为您的私钥路径
    # 可选：如果您使用了中间证书
    # SSLCertificateChainFile /path/to/your/chain.pem

    # 反向代理配置
    ProxyPreserveHost On
    ProxyPass / http://localhost:11000/  # 确保端口号与 APACHE_PORT 环境变量匹配
    ProxyPassReverse / http://localhost:11000/

    # WebSocket 支持
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} =websocket [NC]
    RewriteRule /(.*) ws://localhost:11000/$1 [P,L]

    # 安全头部设置
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
    Header always set Referrer-Policy "same-origin"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-XSS-Protection "1; mode=block"
</VirtualHost>
```

保存配置文件并重新加载 Apache：

```bash
# 在 Debian/Ubuntu 上
 sudo systemctl reload apache2
```

---

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### Caddy 2

<details>

<summary>点击展开</summary>

Caddy 是一个现代化的 Web 服务器，它可以自动处理 SSL 证书的获取和更新。以下是一个基本的 Caddyfile 配置示例：

```caddyfile
<your-nc-domain> {
    reverse_proxy localhost:11000  # 确保端口号与 APACHE_PORT 环境变量匹配

    # 安全头部设置
    header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
    header Referrer-Policy "same-origin"
    header X-Content-Type-Options "nosniff"
    header X-Frame-Options "SAMEORIGIN"
    header X-XSS-Protection "1; mode=block"
}
```

如果您需要使用 DNS 验证而不是 HTTP 验证来获取证书（例如，当您的服务器无法从外部访问时），您可以使用 Caddy 的 DNS 挑战功能：

```caddyfile
<your-nc-domain> {
    tls {
        dns <dns-provider> <api-token>  # 替换为您的 DNS 提供商和 API 令牌
    }

    reverse_proxy localhost:11000  # 确保端口号与 APACHE_PORT 环境变量匹配

    # 安全头部设置
    header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
    header Referrer-Policy "same-origin"
    header X-Content-Type-Options "nosniff"
    header X-Frame-Options "SAMEORIGIN"
    header X-XSS-Protection "1; mode=block"
}
```

有关支持的 DNS 提供商的完整列表，请参阅 [Caddy 文档](https://caddyserver.com/docs/modules/tls.dns)。

---

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### Citrix ADC (NetScaler)

<details>

<summary>点击展开</summary>

以下是使用 Citrix ADC 作为反向代理的基本配置指南：

1. 确保您的 Citrix ADC 设备已正确配置并正在运行。
2. 创建一个新的负载均衡虚拟服务器，配置为使用 HTTPS（端口 443）。
3. 配置 SSL 证书和密钥。
4. 创建一个服务组，将流量定向到 Nextcloud AIO 的 Apache 容器（通常是 `localhost:11000`）。
5. 将服务组绑定到虚拟服务器。
6. 配置适当的 HTTP 头部，包括 WebSocket 支持。
7. 保存并应用配置。

有关更详细的配置说明，请参阅 [Citrix ADC 文档](https://docs.citrix.com/en-us/citrix-adc/)。

---

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### Cloudflare Tunnel

<details>

<summary>点击展开</summary>

Cloudflare Tunnel 提供了一种无需开放服务器端口即可使您的 Nextcloud 实例可从互联网访问的方式。以下是基本设置步骤：

1. 在您的服务器上安装并配置 [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/)。
2. 创建一个新的隧道，将流量定向到 Nextcloud AIO 的 Apache 容器（通常是 `localhost:11000`）。
3. 配置 Cloudflare 控制面板中的 DNS 记录，将您的域名指向新创建的隧道。
4. 确保在 Cloudflare 控制面板中启用了 HTTPS 加密。

**重要提示**：如果您使用 Cloudflare Tunnel，您需要将所有 [Cloudflare IP 范围](https://www.cloudflare.com/ips/) 添加到 Nextcloud 的 WOPI 允许列表中。这可以通过 Nextcloud 管理界面的 "管理 > 办公 > WOPI 请求允许列表" 完成。

---

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### HaProxy

<details>

<summary>点击展开</summary>

以下是使用 HaProxy 作为反向代理的基本配置示例：

```haproxy
frontend https
    bind *:443 ssl crt /path/to/your/cert.pem  # 替换为您的证书路径
    mode http
    option forwardfor
    option http-server-close

    # 处理 ACME 挑战（用于 Let's Encrypt 证书自动更新）
    acl acme_challenge path_beg /.well-known/acme-challenge/
    use_backend acme if acme_challenge

    # 路由到 Nextcloud
    acl nextcloud hdr(host) -i <your-nc-domain>  # 替换为您的域名
    use_backend nextcloud if nextcloud

    # WebSocket 支持
    acl websocket hdr(Upgrade) -i WebSocket
    acl websocket hdr_beg(Host) -i ws
    use_backend nextcloud if websocket

backend acme
    server acme 127.0.0.1:80

backend nextcloud
    mode http
    balance roundrobin
    option forwardfor
    option http-server-close
    option http-pretend-keepalive
    server nextcloud localhost:11000 check  # 确保端口号与 APACHE_PORT 环境变量匹配
    http-request set-header X-Forwarded-Proto https
    http-request set-header X-Forwarded-For %[src]

    # 安全头部设置
    http-response set-header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
    http-response set-header Referrer-Policy "same-origin"
    http-response set-header X-Content-Type-Options "nosniff"
    http-response set-header X-Frame-Options "SAMEORIGIN"
    http-response set-header X-XSS-Protection "1; mode=block"
```

保存配置文件并重新加载 HaProxy：

```bash
# 在 Debian/Ubuntu 上
 sudo systemctl reload haproxy
```

---

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### Nginx / OpenResty

<details>

<summary>点击展开</summary>

以下是使用 Nginx 或 OpenResty 作为反向代理的基本配置示例：

```nginx
server {
    listen 80;
    server_name <your-nc-domain>;  # 替换为您的域名
    return 301 https://$host$request_uri;  # 将所有 HTTP 请求重定向到 HTTPS
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name <your-nc-domain>;  # 替换为您的域名

    # 启用 HTTP/3 (可选)
    # listen 443 quic;
    # listen [::]:443 quic;
    # http3 on;
    # quic_retry on;

    # SSL 配置
    ssl_certificate /path/to/your/cert.pem;  # 替换为您的证书路径
    ssl_certificate_key /path/to/your/privkey.pem;  # 替换为您的私钥路径

    # 优化 SSL 设置
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;

    # 安全头部设置
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header Referrer-Policy "same-origin" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Robots-Tag none;
    add_header X-Download-Options noopen;
    add_header X-Permitted-Cross-Domain-Policies none;

    # 反向代理配置
    location / {
        proxy_pass http://localhost:11000;  # 确保端口号与 APACHE_PORT 环境变量匹配
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # 增加上传文件大小限制
        client_max_body_size 512M;

        # 支持长连接
        proxy_connect_timeout 600;
        proxy_send_timeout 600;
        proxy_read_timeout 600;
        send_timeout 600;
    }

    # WebSocket 支持
    location /apps/richdocumentscode/proxy.php/ws/ {
        proxy_pass http://localhost:11000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Talk 视频通话支持
    location /ocs/v2.php/apps/spreed/api/v1/chat/ {
        proxy_pass http://localhost:11000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

保存配置文件并重新加载 Nginx：

```bash
# 在 Debian/Ubuntu 上
 sudo systemctl reload nginx
```

---

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### Nginx-Proxy-Manager (NPM) Plus

<details>

<summary>点击展开</summary>

Nginx-Proxy-Manager Plus 是一个带有 Web 界面的 Nginx 反向代理管理工具。以下是配置步骤：

1. 安装并运行 Nginx-Proxy-Manager Plus。
2. 在 Web 界面中，点击 "代理主机" > "添加代理主机"。
3. 填写表单：
   - 域名：输入您的 Nextcloud 域名
   - 方案：http
   - 转发主机名/IP：输入 Nextcloud AIO 服务器的 IP 地址
   - 转发端口：输入 APACHE_PORT 环境变量的值（默认为 11000）
   - 启用 WebSocket 支持：勾选
4. 点击 "SSL" 选项卡，选择您的证书或启用 Let's Encrypt 自动生成证书。
5. 点击 "高级" 选项卡，添加以下自定义 Nginx 配置：
   ```nginx
   client_max_body_size 512M;
   proxy_connect_timeout 600;
   proxy_send_timeout 600;
   proxy_read_timeout 600;
   send_timeout 600;
   
   # 安全头部设置
   add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
   add_header Referrer-Policy "same-origin" always;
   add_header X-Content-Type-Options "nosniff" always;
   add_header X-Frame-Options "SAMEORIGIN" always;
   add_header X-XSS-Protection "1; mode=block" always;
   add_header X-Robots-Tag none;
   add_header X-Download-Options noopen;
   add_header X-Permitted-Cross-Domain-Policies none;
   ```
6. 点击 "保存" 完成配置。

**注意**：如果您遇到权限问题，请确保 NPM Plus 容器以正确的 PUID/PGID 运行，并考虑在主机上创建 `/etc/sysctl.conf` 文件（如果不存在），并添加 `net.ipv4.ip_unprivileged_port_start=0` 行，然后重新启动容器。

---

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### Nginx-Proxy-Manager (NPM)

<details>

<summary>点击展开</summary>

**重要提示**：标准的 Nginx-Proxy-Manager (NPM) 与 Nextcloud AIO 存在已知的兼容性问题。我们建议使用 [Nginx-Proxy-Manager Plus](#nginx-proxy-manager-npm-plus) 或其他反向代理解决方案。

如果您仍然想尝试使用标准的 Nginx-Proxy-Manager，以下是配置步骤：

1. 安装并运行 Nginx-Proxy-Manager。
2. 在主机上创建 `/etc/sysctl.conf` 文件（如果不存在），并添加 `net.ipv4.ip_unprivileged_port_start=0` 行。
3. 重启 Docker 服务。
4. 在 Nginx-Proxy-Manager Web 界面中，点击 "代理主机" > "添加代理主机"。
5. 填写表单：
   - 域名：输入您的 Nextcloud 域名
   - 方案：http
   - 转发主机名/IP：输入 Nextcloud AIO 服务器的 IP 地址
   - 转发端口：输入 APACHE_PORT 环境变量的值（默认为 11000）
   - 启用 WebSocket 支持：勾选
6. 点击 "SSL" 选项卡，选择您的证书或启用 Let's Encrypt 自动生成证书。
7. 点击 "高级" 选项卡，添加以下自定义 Nginx 配置：
   ```nginx
   client_max_body_size 512M;
   proxy_connect_timeout 600;
   proxy_send_timeout 600;
   proxy_read_timeout 600;
   send_timeout 600;
   
   # 安全头部设置
   add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
   add_header Referrer-Policy "same-origin" always;
   add_header X-Content-Type-Options "nosniff" always;
   add_header X-Frame-Options "SAMEORIGIN" always;
   add_header X-XSS-Protection "1; mode=block" always;
   add_header X-Robots-Tag none;
   add_header X-Download-Options noopen;
   add_header X-Permitted-Cross-Domain-Policies none;
   ```
8. 点击 "保存" 完成配置。

---

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### Node.js with Express

<details>

<summary>点击展开</summary>

以下是使用 Node.js 和 Express 作为反向代理的基本示例：

1. 安装必要的依赖：
   ```bash
   npm install express http-proxy-middleware vhost
   ```

2. 创建一个简单的反向代理服务器：
   ```javascript
   const express = require('express');
   const { createProxyMiddleware } = require('http-proxy-middleware');
   const vhost = require('vhost');
   
   const app = express();
   const PORT = 443;
   
   // Nextcloud 反向代理配置
   const nextcloudProxy = createProxyMiddleware({
     target: 'http://localhost:11000',  // 确保端口号与 APACHE_PORT 环境变量匹配
     changeOrigin: true,
     ws: true,  // 启用 WebSocket 支持
     onProxyReq: (proxyReq, req, res) => {
       // 设置必要的代理头部
       proxyReq.setHeader('X-Forwarded-Proto', req.protocol);
       proxyReq.setHeader('X-Forwarded-For', req.ip);
     },
     onProxyRes: (proxyRes, req, res) => {
       // 添加安全头部
       proxyRes.headers['Strict-Transport-Security'] = 'max-age=63072000; includeSubDomains; preload';
       proxyRes.headers['Referrer-Policy'] = 'same-origin';
       proxyRes.headers['X-Content-Type-Options'] = 'nosniff';
       proxyRes.headers['X-Frame-Options'] = 'SAMEORIGIN';
       proxyRes.headers['X-XSS-Protection'] = '1; mode=block';
     }
   });
   
   // 配置虚拟主机
   app.use(vhost('<your-nc-domain>', nextcloudProxy));  // 替换为您的域名
   
   // 启动服务器（注意：在生产环境中，您应该使用 HTTPS 配置）
   app.listen(PORT, () => {
     console.log(`反向代理服务器运行在端口 ${PORT}`);
   });
   ```

**注意**：在生产环境中，您应该使用 HTTPS 配置。您可以使用 `https` 模块而不是 `express` 直接创建 HTTPS 服务器，或者将此 Node.js 服务器放在另一个已配置 HTTPS 的反向代理后面。

---

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### OpenLiteSpeed

<details>

<summary>点击展开</summary>

以下是使用 OpenLiteSpeed 作为反向代理的基本配置指南：

1. 安装并运行 OpenLiteSpeed。
2. 访问 WebAdmin 控制台（默认在端口 7080 上）。
3. 创建一个新的虚拟主机：
   - 名称：输入一个描述性名称
   - 域：输入您的 Nextcloud 域名
   - 启用 SSL：勾选
   - SSL 私钥 & 证书：选择或上传您的 SSL 证书和私钥
4. 配置反向代理：
   - 点击 "上下文" 选项卡
   - 点击 "添加" > "代理"
   - URI：`/`
   - 目标：`http://localhost:11000/` （确保端口号与 APACHE_PORT 环境变量匹配）
   - 保存配置
5. 配置 WebSocket 支持：
   - 点击 "模块" > "WSGI"
   - 点击 "编辑" 配置
   - 启用 WebSocket 代理：勾选
   - 保存配置
6. 应用更改并重启 OpenLiteSpeed。

有关更详细的配置说明，请参阅 [OpenLiteSpeed 文档](https://openlitespeed.org/kb/)。

---

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### Synology Reverse Proxy

<details>

<summary>点击展开</summary>

Synology DSM 提供了一个内置的反向代理服务器。以下是配置步骤：

1. 登录到您的 Synology DSM 管理界面。
2. 打开 "控制面板" > "应用程序门户" > "反向代理服务器"。
3. 点击 "创建" 按钮。
4. 在 "常规设置" 选项卡中：
   - 描述：输入一个描述性名称
   - 来源：
     - 协议：HTTPS
     - 主机名：输入您的 Nextcloud 域名
     - 端口：443
   - 目标：
     - 协议：HTTP
     - 主机名：输入 Nextcloud AIO 服务器的 IP 地址
     - 端口：输入 APACHE_PORT 环境变量的值（默认为 11000）
5. 点击 "自定义标头" 选项卡：
   - 点击 "创建" > "Websocket"
   - 点击 "创建" > "添加自定义标头"
     - 名称：`Strict-Transport-Security`
     - 值：`max-age=63072000; includeSubDomains; preload`
   - 重复上述步骤添加其他安全头部：
     - `Referrer-Policy: same-origin`
     - `X-Content-Type-Options: nosniff`
     - `X-Frame-Options: SAMEORIGIN`
     - `X-XSS-Protection: 1; mode=block`
6. 点击 "确定" 保存配置。
7. 如果您使用 Let's Encrypt 证书，请确保已在 Synology DSM 中正确配置。

---

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### Traefik 2

<details>

<summary>点击展开</summary>

**免责声明**：下面的配置可能尚未 100% 正确工作。欢迎对其进行改进！

Traefik 的构建块（路由器、服务、中间件）需要使用类似于 [这个](https://doc.traefik.io/traefik/providers/file/#configuration-examples) 官方 Traefik 配置示例的动态配置来定义。由于项目的性质，使用 **docker 标签将不起作用**。

下面的示例在 YAML 文件中定义了动态配置。如果您更喜欢 TOML，可以使用 YAML 到 TOML 的转换器。

1. 在 Traefik 的静态配置中为动态提供者定义一个 [文件提供者](https://doc.traefik.io/traefik/providers/file/)：

    ```yml
    # 静态配置
    
    entryPoints:
      https:
        address: ":443"  # 创建一个名为 "https" 的入口点，使用端口 443
        transport:
          respondingTimeouts:
            readTimeout: 24h  # 允许上传 > 100MB 的文件；防止因分块导致的连接重置（公共上传链接）
        # 如果您想启用 HTTP/3 支持，请取消下面一行的注释
        # experimental:
          # http3: true
    ```

2. 在 `/path/to/dynamic/conf/nextcloud.yml` 中为 Nextcloud 声明路由器、服务和中间件：

    ```yml
    http:
      routers:
        nextcloud:
          rule: "Host(`<your-nc-domain>`)"
          entrypoints:
            - "https"
          service: nextcloud
          middlewares:
            - nextcloud-chain
          tls:
            certresolver: "letsencrypt"

      services:
        nextcloud:
          loadBalancer:
            servers:
              - url: "http://localhost:11000"  # 根据 APACHE_PORT 和 APACHE_IP_BINDING 进行调整。请参阅 https://github.com/nextcloud/all-in-one/blob/main/reverse-proxy.md#adapting-the-sample-web-server-configurations-below

      middlewares:
        nextcloud-secure-headers:
          headers:
            hostsProxyHeaders:
              - "X-Forwarded-Host"
            referrerPolicy: "same-origin"

        https-redirect:
          redirectscheme:
            scheme: https 

        nextcloud-chain:
          chain:
            middlewares:
              # - ...（例如速率限制中间件）
              - https-redirect
              - nextcloud-secure-headers
    ```

---

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### Traefik 3

<details>

<summary>点击展开</summary>

**免责声明**：下面的配置可能尚未 100% 正确工作。欢迎对其进行改进！

Traefik 的构建块（路由器、服务、中间件）需要使用类似于 [这个](https://doc.traefik.io/traefik/providers/file/#configuration-examples) 官方 Traefik 配置示例的动态配置来定义。由于项目的性质，使用 **docker 标签将不起作用**。

下面的示例在 YAML 文件中定义了动态配置。如果您更喜欢 TOML，可以使用 YAML 到 TOML 的转换器。

1. 在 Traefik 的静态配置中为动态提供者定义一个 [文件提供者](https://doc.traefik.io/traefik/providers/file/)：

    ```yml
    # 静态配置
    
    entryPoints:
      https:
        address: ":443"  # 创建一个名为 "https" 的入口点，使用端口 443
        transport:
          respondingTimeouts:
            readTimeout: 24h  # 允许上传 > 100MB 的文件；防止因分块导致的连接重置（公共上传链接）
        # 如果您想启用 HTTP/3 支持，请取消下面一行的注释
        # http3: {}
    
    certificatesResolvers:
      # 定义 "letsencrypt" 证书解析器
      letsencrypt:
        acme:
          storage: /letsencrypt/acme.json  # 定义证书应存储的路径
          email: <your-email-address>  # LE 发送证书过期通知的地址
          tlschallenge: true
    
    providers:
      file:
        directory: "/path/to/dynamic/conf"  # 根据您的需要调整路径。
        watch: true
    ```

2. 在 `/path/to/dynamic/conf/nextcloud.yml` 中为 Nextcloud 声明路由器、服务和中间件：

    ```yml
    http:
      routers:
        nextcloud:
          rule: "Host(`<your-nc-domain>`)"
          entrypoints:
            - "https"
          service: nextcloud
          middlewares:
            - nextcloud-chain
          tls:
            certresolver: "letsencrypt"

      services:
        nextcloud:
          loadBalancer:
            servers:
              - url: "http://localhost:11000"  # 根据 APACHE_PORT 和 APACHE_IP_BINDING 进行调整。请参阅 https://github.com/nextcloud/all-in-one/blob/main/reverse-proxy.md#adapting-the-sample-web-server-configurations-below

      middlewares:
        nextcloud-secure-headers:
          headers:
            hostsProxyHeaders:
              - "X-Forwarded-Host"
            referrerPolicy: "same-origin"

        https-redirect:
          redirectscheme:
            scheme: https 

        nextcloud-chain:
          chain:
            middlewares:
              # - ...（例如速率限制中间件）
              - https-redirect
              - nextcloud-secure-headers
    ```

---

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### IIS with ARR 和 URL Rewrite

<details>

<summary>点击展开</summary>

**免责声明**：下面的配置可能尚未 100% 正确工作。欢迎对其进行改进！

**请注意**：使用 IIS 作为反向代理有一些限制：
- 最大上传大小为 4GiB，在下面的示例配置中，限制设置为 2GiB。


#### 先决条件
1. 安装了 IIS 的 **Windows Server**。
2. 已安装 [**Application Request Routing (ARR)**](https://www.iis.net/downloads/microsoft/application-request-routing) 和 [**URL Rewrite**](https://www.iis.net/downloads/microsoft/url-rewrite) 模块。
3. 已启用 [**WebSocket Protocol**](https://learn.microsoft.com/en-us/iis/configuration/system.webserver/websocket) 功能。

有关如何设置 IIS 作为反向代理的信息，请参阅 [此文档](https://learn.microsoft.com/en-us/iis/extensions/url-rewrite-module/reverse-proxy-with-url-rewrite-v2-and-application-request-routing)。
有关如何使用 IIS Manager 的信息也可以在 [此处](https://learn.microsoft.com/en-us/iis/) 找到。

以下配置示例假设：
* 已创建一个站点，配置了 HTTPS 支持和所需的主机名。
* 已创建一个名为 `nc-server-farm` 的服务器场，并指向 Nextcloud 服务器。
* 未为 `nc-server-farm` 服务器场创建全局重写规则。

将以下 `web.config` 文件添加到您创建的反向代理站点的根目录：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.web>
    <!-- 允许所有 URL -->
    <httpRuntime requestValidationMode="2.0" requestPathInvalidCharacters="" />
  </system.web>
  <system.webServer>
    <rewrite>
      <!-- useOriginalURLEncoding 需要设置为 false，否则 IIS 会对 URL 进行双重编码，导致所有包含空格或特殊字符的文件无法访问 -->
      <rules useOriginalURLEncoding="false">
        <!-- 强制使用 HTTPS -->
        <rule name="Https" stopProcessing="true">
          <match url="(.*)" />
          <conditions>
            <add input="{HTTPS}" pattern="^OFF$" />
          </conditions>
          <action type="Redirect" url="https://{HTTP_HOST}/{REQUEST_URI}" appendQueryString="false" />
        </rule>
        <!-- 重定向到内部 Nextcloud 服务器 -->
        <rule name="To nextcloud" stopProcessing="true">
          <match url="(.*)" />
          <conditions>
            <add input="{HTTPS}" pattern="^ON$" />
          </conditions>
          <!-- 注意 {UNENCODED_URL} 已经包含起始斜杠，所以我们必须在端口号后直接添加它，不需要额外的斜杠 -->
          <action type="Rewrite" url="http://nc-server-farm:11000{UNENCODED_URL}" appendQueryString="false" />
        </rule>
      </rules>
    </rewrite>
    <security>
      <!-- 增加上传限制到 2GiB -->
      <requestFiltering allowDoubleEscaping="true">
        <requestLimits maxAllowedContentLength="2147483648" />
      </requestFiltering>
    </security>
  </system.webServer>
</configuration>
```

⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

</details>

#### Tailscale

<details>

<summary>点击展开</summary>

有关 Tailscale 反向代理示例指南，请参阅 [@Perseus333](https://github.com/Perseus333) 的本指南：https://github.com/nextcloud/all-in-one/discussions/6817

</details>


#### 其他

<details>

<summary>点击展开</summary>

目前尚未记录其他反向代理的配置示例。欢迎提交拉取请求！

</details>

## 2. 使用此启动命令

调整反向代理配置后，使用以下命令启动 AIO：<br>

（有关 `compose.yaml` 示例，请参见下面的[示例](#inspiration-for-a-docker-compose-file)。）

```
# 对于 Linux：
sudo docker run \
--init \
--sig-proxy=false \
--name nextcloud-aio-mastercontainer \
--restart always \
--publish 8080:8080 \
--env APACHE_PORT=11000 \
--env APACHE_IP_BINDING=0.0.0.0 \
--env APACHE_ADDITIONAL_NETWORK="" \
--env SKIP_DOMAIN_VALIDATION=false \
--volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
--volume /var/run/docker.sock:/var/run/docker.sock:ro \
ghcr.io/nextcloud-releases/all-in-one:latest
```

注意：您可能希望调整 Nextcloud 的数据目录，将文件存储在不同于默认 docker 卷的位置。请参阅[此文档](https://github.com/nextcloud/all-in-one#how-to-change-the-default-location-of-nextclouds-datadir)了解如何操作。

如果反向代理与 AIO 在同一主机上运行并且在主机网络中，您还应该考虑通过为此 docker run 命令提供额外的环境变量来限制 Apache 容器只监听 localhost。请参阅[第 3 点](#3-limit-the-access-to-the-apache-container)。

在 macOS 上，请参阅 https://github.com/nextcloud/all-in-one#how-to-run-aio-on-macos。

<details>

<summary>Windows 命令</summary>

在 Windows 上，安装 [Docker Desktop](https://www.docker.com/products/docker-desktop/)（如果需要，请不要忘记[启用 ipv6](https://github.com/nextcloud/all-in-one/blob/main/docker-ipv6-support.md)），并在命令提示符中运行以下命令：

```
docker run ^
--init ^
--sig-proxy=false ^
--name nextcloud-aio-mastercontainer ^
--restart always ^
--publish 8080:8080 ^
--env APACHE_PORT=11000 ^
--env APACHE_IP_BINDING=0.0.0.0 ^
--env APACHE_ADDITIONAL_NETWORK="" ^
--env SKIP_DOMAIN_VALIDATION=false ^
--volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config ^
--volume //var/run/docker.sock:/var/run/docker.sock:ro ^
ghcr.io/nextcloud-releases/all-in-one:latest
```

此外，您可能希望调整 Nextcloud 的数据目录，将文件存储在主机系统上。请参阅[此文档](https://github.com/nextcloud/all-in-one#how-to-change-the-default-location-of-nextclouds-datadir)了解如何操作。

</details>

在 Synology DSM 上，请参阅 https://github.com/nextcloud/all-in-one#how-to-run-aio-on-synology-dsm

### docker-compose 文件示例

只需将 docker run 命令转换为 docker-compose 文件。您可以查看[此文件](https://github.com/nextcloud/all-in-one/blob/main/compose.yaml)获取一些灵感，但无论如何您都需要修改它。您可以在此处找到更多示例：https://github.com/nextcloud/all-in-one/discussions/588

## 3. 限制对 Apache 容器的访问

在 mastercontainer 初始启动期间使用此环境变量，使 apache 容器仅监听 localhost：`--env APACHE_IP_BINDING=127.0.0.1`。**注意**：仅建议在反向代理配置中使用 `localhost` 连接到 AIO 实例时设置此选项。如果您使用 ip 地址而不是 localhost，则应将其设置为 `0.0.0.0`。

## 4. 打开 AIO 界面

启动 AIO 后，您应该能够通过 `https://主机的ip地址:8080` 访问 AIO 界面，并输入和验证您已配置的域名。<br>
⚠️ **重要**：访问此端口时请始终使用 ip 地址，而不是域名，因为 HSTS 可能会在以后阻止对其的访问！（由于安全考虑，此端口使用自签名证书，您需要在浏览器中接受它）<br>
在 AIO 界面中输入您在反向代理配置中使用的域名，您就应该完成了。请不要忘记在防火墙/路由器中为 Talk 容器打开/转发端口 `3478/TCP` 和 `3478/UDP`！

## 5. 可选：为使用 ip 地址而非 localhost 或 127.0.0.1 连接到 nextcloud 的反向代理配置 AIO
如果您的反向代理使用 ip 地址而非 localhost 或 127.0.0.1<sup>*</sup> 连接到 nextcloud，您必须进行以下配置更改

<small>*: 它用于连接到 AIO 的 IP 地址不在私有 IP 范围内，例如：`127.0.0.1/8,192.168.0.0/16,172.16.0.0/12,10.0.0.0/8,fd00::/8,::1`</small>

### Nextcloud 受信任代理
将其用于连接到 AIO 的 IP 添加到 Nextcloud 的 trusted_proxies，如下所示：

```
sudo docker exec --user www-data -it nextcloud-aio-nextcloud php occ config:system:set trusted_proxies 2 --value=proxy.ip.address
```

### Collabora WOPI 允许列表
如果您的反向代理使用与您的域名<sup>*</sup>不同的 IP 地址连接到 Nextcloud，并且您正在使用 Collabora 服务器，则还必须通过 `管理设置 > 管理 > 办公 > WOPI 请求允许列表` 将该 IP 添加到 WOPI 请求允许列表。

<small>*: 例如，反向代理有一个公共全局可路由 IP，并通过 Tailscale 以 `100.64.0.0/10` 范围内的 IP 连接到您的 AIO 实例，或者您使用的是 Cloudflare 隧道（[cloudflare 注意事项](https://github.com/nextcloud/all-in-one?tab=readme-ov-file#notes-on-cloudflare-proxytunnel)：您必须将所有 [Cloudflare IP 范围](https://www.cloudflare.com/ips/) 添加到 WOPI 允许列表。）</small>

### 通过 VPN 连接的外部反向代理（例如 Tailscale）

如果您的反向代理在 LAN 外部并通过 VPN（如 Tailscale）连接，您可能需要设置 `APACHE_IP_BINDING=AIO.VPN.host.IP` 以确保只有来自 VPN 的流量才能连接。

## 6. 可选：为 AIO 界面获取有效的证书

如果您还想使用有效的证书公开访问 AIO 界面，可以向 Caddyfile 添加如下配置：

```
https://<your-nc-domain>:8443 {
    reverse_proxy https://localhost:8080 {
        transport http {
            tls_insecure_skip_verify
        }
    }
}
```
⚠️ **请注意**：查看[这部分](#adapting-the-sample-web-server-configurations-below)以适应上面的示例配置。

之后，AIO 界面应该可以通过 `https://主机的ip地址:8443` 访问。您也可以通过在 Caddyfile 中使用 `https://<your-alternative-domain>:443` 而不是 `https://<your-nc-domain>:8443` 来将域名更改为不同的子域，并使用该域名访问 AIO 界面。

## 7. 如何调试问题？
<a id="how-to-debug"></a> <!-- 用于外部链接 -->
<a id="6-how-to-debug-things"></a> <!-- 为了向后兼容-->

如果出现问题，请按照以下步骤操作：
1. 确保完全按照反向代理文档的步骤从上到下进行操作！
2. 确保您使用的是本反向代理文档中描述的 `docker run` 命令。**提示**：确保您在 docker run 命令中通过 `--env APACHE_PORT=11000` 等设置了 `APACHE_PORT`！
3. 确保正确设置了 `APACHE_IP_BINDING` 变量。如果不确定，请将其设置为 `--env APACHE_IP_BINDING=0.0.0.0`
4. 确保您的反向代理指向的所有端口都与所选的 `APACHE_PORT` 匹配。
5. 确保按照[这部分](#adapting-the-sample-web-server-configurations-below)调整示例配置以适应您的特定设置！
6. 确保 mastercontainer 能够生成其他容器。您可以通过检查 mastercontainer 是否确实可以访问 Docker 套接字来做到这一点，它可能不在建议的目录之一，如 `/var/run/docker.sock`，而是在不同的目录中，这取决于您的操作系统和安装 Docker 的方式。mastercontainer 日志应该有助于解决这个问题。您可以在容器首次启动后通过运行 `sudo docker logs nextcloud-aio-mastercontainer` 来查看它们。
7. 检查 mastercontainer 启动后，如果反向代理在容器内运行，是否可以访问提供的 apache 端口。您可以通过在反向代理容器内运行 `nc -z localhost 11000; echo $?` 来测试这一点。如果输出为 `0`，则一切正常。或者，您当然可以在此测试中使用主机的 ip 地址而不是 localhost。
8. 确保您不在 CGNAT 后面。如果是这种情况，您将无法正确打开端口。在这种情况下，您可以使用 Cloudflare Tunnel！
9. 如果您使用 Cloudflare，您可能需要跳过域名验证，因为众所周知，Cloudflare 可能会阻止验证尝试。在这种情况下，请参见下面的最后一个选项！
10. 如果您的反向代理配置为使用主机网络（如上述文档中建议的那样）或在主机上运行，请确保您已配置防火墙以打开端口 443（和 80）！
11. 检查您是否有公共 IPv4 和公共 IPv6 地址。如果您只有公共 IPv6 地址（例如，由于 DS-Lite），请确保在 Docker 和整个网络基础设施中启用 IPv6（例如，还向您的域名添加 AAAA DNS 条目）！
12. [在路由器中启用 Hairpin NAT](https://github.com/nextcloud/all-in-one/discussions/5849) 或 [设置本地 DNS 服务器并添加自定义 dns 记录](https://github.com/nextcloud/all-in-one#how-can-i-access-nextcloud-locally)，允许服务器在本地访问自身
13. 尝试从头开始配置所有内容 - 如果按照 https://github.com/nextcloud/all-in-one#how-to-properly-reset-the-instance 操作后仍然不起作用。
14. 作为最后的手段，您可以通过在 docker run 命令中添加 `--env SKIP_DOMAIN_VALIDATION=true` 来禁用域名验证。但只有在您完全确定已正确配置所有内容时才使用此选项！

## 8. 移除反向代理
如果您在某个时候想移除反向代理，这里有一些一般步骤：
1. 在 AIO 界面中停止所有运行的容器。
2. 停止并移除 mastercontainer。
    ```
    sudo docker stop nextcloud-aio-mastercontainer
    sudo docker rm nextcloud-aio-mastercontainer  
    ```
3. 移除您用于反向代理的软件和配置文件（见第 1 节）。
4. 使用[主 readme 中的 docker run 命令](https://github.com/nextcloud/all-in-one?tab=readme-ov-file#how-to-use-this)重启 mastercontainer，但添加以下两个选项：
   ```
   --env APACHE_IP_BINDING=0.0.0.0 \
   --env APACHE_PORT=443 \
    ```
    请在 run 命令的最后一行之前执行此操作！  
    
    *第一个命令确保 Apache 容器正在监听所有可用的网络接口，第二个命令将其配置为监听端口 443。*
5. 在 AIO 界面中重启所有其他容器。