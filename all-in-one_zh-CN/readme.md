# Nextcloud 一体化安装方案

> [!NOTE]
> Nextcloud AIO 正在积极寻找贡献者。请参阅[论坛帖子](https://help.nextcloud.com/t/nextcloud-aio-is-looking-for-contributors/205234)。

官方的 Nextcloud 安装方法。Nextcloud AIO 提供了简单的部署和维护，包含了这个 Nextcloud 实例中的大多数功能。

包含的功能：
- Nextcloud 主程序
- Nextcloud 文件的高性能后端
- Nextcloud Office（可选）
- Nextcloud Talk 和 TURN 服务器的高性能后端（可选）
- Nextcloud Talk 录制服务器（可选）
- 备份解决方案（可选，基于 [BorgBackup](https://github.com/borgbackup/borg#what-is-borgbackup)）
- Imaginary（可选，用于预览 heic、heif、illustrator、pdf、svg、tiff 和 webp 格式）
- ClamAV（可选，Nextcloud 防病毒后端）
- 全文搜索（可选）
- 白板（可选）
- Docker Socket Proxy（可选，用于 [Nextcloud App API](https://github.com/cloud-py-api/app_api#nextcloud-appapi)）
- [社区容器](https://github.com/nextcloud/all-in-one/tree/main/community-containers#community-containers)
<details><summary>还有更多功能：</summary>

- 包含简单的 Web 界面，支持轻松安装和维护
- [包含简单的更新功能](https://github.com/nextcloud/all-in-one#how-to-update-the-containers)
- 包含更新和备份通知
- 可以从 AIO 界面启用每日备份，更新所有容器、Nextcloud 及其应用
- 可以通过 AIO 界面从备份归档恢复实例（只需归档和密码即可在新的 AIO 实例上恢复整个实例）
- APCu 作为本地缓存
- Redis 作为分布式缓存和文件锁定
- Postgresql 作为数据库
- PHP-FPM 具有性能优化的配置（默认启用 Opcache 和 JIT 等）
- 在 Nextcloud 安全扫描中达到 A+ 安全等级
- 可在现有[反向代理](https://github.com/nextcloud/all-in-one/blob/main/reverse-proxy.md)后面使用
- 可在 [Cloudflare Tunnel](https://github.com/nextcloud/all-in-one#how-to-run-nextcloud-behind-a-cloudflare-tunnel) 后面使用
- 可通过 [Tailscale](https://github.com/nextcloud/all-in-one/discussions/6817) 使用
- 支持公开链接的大文件上传，最大可达 10 GB，[可调整](https://github.com/nextcloud/all-in-one#how-to-adjust-the-upload-limit-for-nextcloud)（已登录用户可以使用 Web 界面或移动/桌面客户端上传更大的文件，因为在这种情况下使用了分块上传）
- PHP 和 Web 服务器超时设置为 3600 秒，[可调整](https://github.com/nextcloud/all-in-one#how-to-adjust-the-max-execution-time-for-nextcloud)（对大文件上传很重要）
- 每个 PHP 进程默认最大内存为 512 MB，[可调整](https://github.com/nextcloud/all-in-one#how-to-adjust-the-php-memory-limit-for-nextcloud)
- 包含自动 TLS（通过使用 Let's Encrypt）
- 默认启用 Brotli 压缩（针对 JavaScript、CSS 和 SVG 文件），减少 Nextcloud 加载时间
- 支持 HTTP/2 和 HTTP/3
- 默认启用 Nextcloud 的"美化 URL"（从所有链接中删除 index.php）
- 视频预览开箱即用，启用 Imaginary 后，许多最新的图像格式也支持预览！
- 所有功能只需一个域名，不需要多个域名（通常每个服务需要一个域名，这要复杂得多）
- Nextcloud 数据目录的[位置可调整](https://github.com/nextcloud/all-in-one#how-to-change-the-default-location-of-nextclouds-datadir)（例如，便于在 Windows 和 MacOS 上与主机系统共享文件）
- 默认受限制（有利于安全），但可以[允许访问其他存储](https://github.com/nextcloud/all-in-one#how-to-allow-the-nextcloud-container-to-access-directories-on-the-host)，以便启用本地外部存储功能的使用
- 可以[调整默认安装的 Nextcloud 应用](https://github.com/nextcloud/all-in-one#how-to-change-the-nextcloud-apps-that-are-installed-on-the-first-startup)
- Nextcloud 安装不是只读的 - 这意味着您可以应用补丁（而不必等待下一个版本应用它们）
- 默认包含 `ffmpeg`、`smbclient`、`libreoffice` 和 `nodejs`
- 可以[永久添加额外的 OS 包到 Nextcloud 容器](https://github.com/nextcloud/all-in-one#how-to-change-the-nextcloud-apps-that-are-installed-on-the-first-startup)，而无需构建自己的 Docker 镜像
- 可以[永久添加额外的 PHP 扩展到 Nextcloud 容器](https://github.com/nextcloud/all-in-one#how-to-add-php-extensions-permanently-to-the-nextcloud-container)，而无需构建自己的 Docker 镜像
- 可以[传递硬件转码所需的设备](https://github.com/nextcloud/all-in-one#how-to-enable-hardware-acceleration-for-nextcloud)到 Nextcloud 容器
- 可以[将所有与 Docker 相关的文件存储在单独的驱动器上](https://github.com/nextcloud/all-in-one#how-to-store-the-filesinstallation-on-a-separate-drive)
- [LDAP 可用作 Nextcloud 的用户后端](https://github.com/nextcloud/all-in-one/tree/main#ldap)
- 可以从任何以前的 Nextcloud 安装迁移到 AIO。请参阅[此文档](https://github.com/nextcloud/all-in-one/blob/main/migration.md)
- [可以添加 Fail2Ban](https://github.com/nextcloud/all-in-one#fail2ban)
- [可以添加 phpMyAdmin、Adminer 或 pgAdmin](https://github.com/nextcloud/all-in-one#phpmyadmin-adminer-or-pgadmin)
- [可以添加邮件服务器](https://github.com/nextcloud/all-in-one#mail-server)
- 可以[通过域名本地访问 Nextcloud](https://github.com/nextcloud/all-in-one#how-can-i-access-nextcloud-locally)
- 可以[本地安装](https://github.com/nextcloud/all-in-one/blob/main/local-instance.md)（如果您不想或无法使实例公开可访问）
- [支持 IPv6](https://github.com/nextcloud/all-in-one/blob/main/docker-ipv6-support.md)
- 可以与 [Docker rootless](https://github.com/nextcloud/all-in-one/blob/main/docker-rootless.md) 一起使用（有利于提高安全性）
- 可在 Docker 支持的所有平台上运行（例如，也可在 Windows 和 MacOS 上运行）
- 包含的容器易于调试，可以直接从 AIO 界面检查它们的日志
- [支持 Docker-compose](./compose.yaml)
- 可以[在没有容器访问 docker socket 的情况下安装](https://github.com/nextcloud/all-in-one/tree/main/manual-install)
- 可以使用 [Docker Swarm](https://github.com/nextcloud/all-in-one#can-i-run-this-with-docker-swarm) 安装
- 可以使用 [Kubernetes](https://github.com/nextcloud/all-in-one/tree/main/nextcloud-aio-helm-chart) 安装
- 几乎所有包含的容器都基于 Alpine Linux（有利于安全和大小）
- 许多包含的容器以非 root 用户身份运行（有利于安全）
- 许多包含的容器具有只读根文件系统（有利于安全）
- 包含的容器在其自己的 Docker 网络中运行（有利于安全），并且只在主机上暴露真正必要的端口
- [一台服务器上的多个实例](https://github.com/nextcloud/all-in-one/blob/main/multiple-instances.md)可以在不使用 VM 的情况下实现
- 可以从 AIO 界面调整备份路径或远程 borg 存储库（如果使用本地备份路径，便于将备份放在不同的驱动器上）
- 可以备份外部 Docker 卷或主机路径（可用于主机备份）
- Borg 备份可以完全从 AIO 界面管理，包括备份创建、备份恢复、备份完整性检查和完整性修复
- [远程备份](https://github.com/nextcloud/all-in-one#are-remote-borg-backups-supported)的其他形式间接可行
- 可以[从外部脚本运行更新和备份](https://github.com/nextcloud/all-in-one#how-to-stopstartupdate-containers-or-trigger-the-daily-backup-from-a-script-externally)。有关完整示例，请参阅[此文档](https://github.com/nextcloud/all-in-one#how-to-enable-automatic-updates-without-creating-a-backup-beforehand)。

</details>

## 截图
| 首次设置 | 安装后 |
|---|---|
| ![image](https://github.com/user-attachments/assets/6ef5d7b5-86f2-402c-bc6c-b633af2ca7dd) | ![image](https://github.com/user-attachments/assets/939d0fdf-436f-433d-82d3-27548263a040) |

## 如何使用？
>[!WARNING]
> 首先，您应该确保没有使用通过 snap 安装的 docker。您可以通过运行 `sudo docker info | grep "Docker Root Dir" | grep "/var/snap/docker/"` 来检查这一点。如果输出包含提到的字符串 `/var/snap/docker/`，您应该首先通过 `sudo snap remove docker` 卸载 docker snap，然后按照下面的说明进行操作。⚠️ 注意：只有在这是全新的 docker 安装并且您没有运行任何已经使用它的服务时才运行该命令。

> [!NOTE]
> 以下说明适用于尚未安装 Web 服务器或反向代理（如 Apache、Nginx、Caddy、Cloudflare Tunnel 等）的情况。如果您想在 Web 服务器或反向代理（如 Apache、Nginx、Caddy、Cloudflare Tunnel 等）后面运行 AIO，请参阅[反向代理文档](https://github.com/nextcloud/all-in-one/blob/main/reverse-proxy.md)。此外，下面的说明特别适用于 Linux。对于 macOS，请参阅[此部分](#how-to-run-aio-on-macos)，对于 Windows，请参阅[此部分](#how-to-run-aio-on-windows)，对于 Synology，请参阅[此部分](#how-to-run-aio-on-synology-dsm)。

1. 按照官方文档在您的 Linux 安装上安装 Docker：https://docs.docker.com/engine/install/#supported-platforms。
>[!WARNING]
> 您可以使用下面的便捷脚本来安装 docker。但是，我们建议不要盲目下载并以 sudo 权限执行脚本。但如果您愿意，当然可以使用它。请参阅下文：

<details>
    <summary>使用便捷脚本</summary>

```sh
curl -fsSL https://get.docker.com | sudo sh
```

</details>

2. 如果您需要 IPv6 支持，应该按照 https://github.com/nextcloud/all-in-one/blob/main/docker-ipv6-support.md 启用它。
3. 运行以下命令以在 Linux 上启动容器，且前提是没有 Web 服务器或反向代理（如 Apache、Nginx、Caddy、Cloudflare Tunnel 等）：
    ```
    # 适用于 Linux 且没有 Web 服务器或反向代理（如 Apache、Nginx、Caddy、Cloudflare Tunnel 等）的情况：
    sudo docker run \
    --init \
    --sig-proxy=false \
    --name nextcloud-aio-mastercontainer \
    --restart always \
    --publish 80:80 \
    --publish 8080:8080 \
    --publish 8443:8443 \
    --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    ghcr.io/nextcloud-releases/all-in-one:latest
    ```
    <details>
    <summary>命令解释</summary>

    - `sudo docker run` 此命令启动一个新的 docker 容器。如果用户被添加到 docker 组，可以选择不使用 `sudo` 执行 Docker 命令（这与 docker rootless 不同，请参见下面的 FAQ）。
    - `--init` 此选项确保不会创建僵尸进程。请参阅 [Docker 文档](https://docs.docker.com/reference/cli/docker/container/run/#init)。
    - `--sig-proxy=false` 此选项允许使用 `[CTRL] + [C]` 退出自动附加的容器 shell，而不会关闭容器。
    - `--name nextcloud-aio-mastercontainer` 这是容器的名称。这一行不允许更改，因为主容器更新会失败。
    - `--restart always` 这是"重启策略"。`always` 意味着容器应该始终与 Docker 守护进程一起启动。有关重启策略的更多详细信息，请参阅 Docker 文档：https://docs.docker.com/config/containers/start-containers-automatically/
    - `--publish 80:80` 这意味着容器的端口 80 应该在主机上使用端口 80 发布。如果您想使用端口 8443，它用于为 AIO 界面获取有效证书。如果您在 Web 服务器或反向代理后面运行 AIO，则不需要它，因为您可以使用端口 8080 作为 AIO 界面。
    - `--publish 8080:8080` 这意味着容器的端口 8080 应该在主机上使用端口 8080 发布。此端口用于 AIO 界面，默认使用自签名证书。如果端口 8080 已在您的主机上使用，您也可以使用不同的主机端口，例如 `--publish 8081:8080`（只有第一个端口可以为主机更改，第二个端口用于容器，必须保持为 8080）。
    - `--publish 8443:8443` 这意味着容器的端口 8443 应该在主机上使用端口 8443 发布。如果您将端口 80 和 8443 发布到公共互联网，则可以通过此端口使用有效证书访问 AIO 界面。如果您在 Web 服务器或反向代理后面运行 AIO，则不需要它，因为您可以使用端口 8080 作为 AIO 界面。
    - `--volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config` 这意味着主容器创建的文件将存储在名为 `nextcloud_aio_mastercontainer` 的 docker 卷中。这一行不允许更改，因为内置备份稍后会失败。
    - `--volume /var/run/docker.sock:/var/run/docker.sock:ro` docker socket 被挂载到容器中，用于启动所有其他容器和其他功能。在 Windows/macOS 和 docker rootless 上需要调整。请参阅此适用文档。如果调整，请不要忘记也设置 `WATCHTOWER_DOCKER_SOCKET_PATH`！如果您不喜欢这样，请参阅 https://github.com/nextcloud/all-in-one/tree/main/manual-install。
    - `ghcr.io/nextcloud-releases/all-in-one:latest` 这是使用的 docker 容器镜像。
    - 可以使用环境变量设置更多选项，例如 `--env NEXTCLOUD_DATADIR="/mnt/ncdata"`（这是适用于 Linux 的示例。有关其他操作系统以及此值的说明，请参阅[此文档](https://github.com/nextcloud/all-in-one#how-to-change-the-default-location-of-nextclouds-datadir)。如果您想将其更改为特定路径而不是默认的 Docker 卷，则需要在首次启动时指定此特定选项）。要查看更多变量的解释和示例（例如更改 Nextcloud 数据目录的位置或将某些位置作为外部存储挂载到 Nextcloud 容器中），请阅读本 readme 并查看 docker-compose 文件：https://github.com/nextcloud/all-in-one/blob/main/compose.yaml
    </details>

    注意：您可能有兴趣调整 Nextcloud 的数据目录，将文件存储在默认 docker 卷以外的位置。请参阅[此文档](https://github.com/nextcloud/all-in-one#how-to-change-the-default-location-of-nextclouds-datadir)了解如何操作。

4. 初始启动后，您现在应该能够在此服务器的端口 8080 上打开 Nextcloud AIO 界面。<br>
例如：`https://您的服务器的IP地址:8080`<br>
⚠️ **重要：** 访问此端口时，请始终使用 IP 地址，而不是域名，因为 HSTS 可能会在以后阻止对它的访问！（由于安全考虑，此端口使用自签名证书，您需要在浏览器中接受它）<br><br>
如果您的防火墙/路由器已打开/转发端口 80 和 8443，并且您将域名指向您的服务器，则可以通过以下方式自动获取有效证书：<br>
`https://指向此服务器的域名.tld:8443`
5. 请不要忘记在防火墙/路由器中为 Talk 容器打开端口 `3478/TCP` 和 `3478/UDP`！

### 如何通过 Tailscale 运行 Nextcloud？
有关 Tailscale 的反向代理示例指南，请参阅 [@Perseus333](https://github.com/Perseus333) 的指南：https://github.com/nextcloud/all-in-one/discussions/6817

### 如何使用 ACME DNS-challenge 运行 Nextcloud？
您可以在反向代理模式下安装 AIO，其中还记录了如何使用 ACME DNS-challenge 为 AIO 获取有效证书。请参阅[反向代理文档](./reverse-proxy.md)。（指的是 `Caddy with ACME DNS-challenge` 部分）。也可以参阅 https://github.com/dani-garcia/vaultwarden/wiki/Running-a-private-vaultwarden-instance-with-Let%27s-Encrypt-certs#getting-a-custom-caddy-build 获取有关此主题的更多文档。

### 如何在本地运行 Nextcloud？不需要域名，或希望在局域网内进行内网访问。
如果您不想将 Nextcloud 开放到公共互联网，您可以查看以下文档了解如何在本地设置它：[local-instance.md](./local-instance.md)，但请记住您仍然需要确保 https 正常工作。

### 我可以使用 IP 地址而不是域名为 Nextcloud 吗？
不可以，将来也不会添加此功能。如果您只想在本地运行它，您可以查看以下文档：[local-instance.md](./local-instance.md)。推荐使用 [Tailscale](https://github.com/nextcloud/all-in-one/discussions/6817)。

### 我可以在离线或空气隔离的系统中运行 AIO 吗？
不可以。由于多种原因（更新检查、通过应用商店安装应用、按需下载额外的 docker 镜像等），这不可能实现，将来也不会添加。

### Nextcloud 是否支持自签名证书？
不支持，将来也不会添加。如果您想在本地运行它，而不将 Nextcloud 开放到公共互联网，请查看[本地实例文档](./local-instance.md)。推荐使用 [Tailscale](https://github.com/nextcloud/all-in-one/discussions/6817)。

### 我可以使用多个域名的 AIO 吗？
不可以，将来也不会添加。但是您可以使用[此功能](https://github.com/nextcloud/all-in-one/blob/main/multiple-instances.md)来创建多个 AIO 实例，每个域名对应一个实例。

### 是否支持 Nextcloud 默认 443 以外的端口？
不支持，将来也不会添加。如果端口 443 和/或 80 对您来说被阻止，您可以使用 [Tailscale](https://github.com/nextcloud/all-in-one/discussions/6817) 如果您想将其发布到网上。如果您已经在端口 443 上运行了不同的服务，请为 Nextcloud 使用专用域名并通过遵循[反向代理文档](./reverse-proxy.md)正确设置它。但在所有情况下，Nextcloud 界面都会将您重定向到端口 443。

### 我可以在域名的子目录中运行 Nextcloud 吗？
不可以，将来也不会添加。请为 Nextcloud 使用专用（子）域名并通过遵循[反向代理文档](./reverse-proxy.md)正确设置它。或者，如果您想将其发布到网上，您可以使用 [Tailscale](https://github.com/nextcloud/all-in-one/discussions/6817)。

### 如何本地访问 Nextcloud？
请注意，如果您在 Cloudflare Tunnel 后面运行 AIO，则无法本地访问，因为在这种情况下，TLS 代理被卸载到 Cloudflare 的基础设施上。您可以通过设置自己的反向代理来解决这个问题，该反向代理在本地处理 TLS 代理，并将使下面的步骤生效。

请确保如果您在反向代理后面运行 AIO，反向代理被配置为在运行它的服务器上使用端口 443。否则，下面的步骤将不起作用。

既然这已经解决了，本地访问 Nextcloud 的推荐方法是设置一个本地 DNS 服务器，如 pi-hole，并为该域设置一个自定义 DNS 记录，指向运行 Nextcloud AIO 的服务器的内部 IP 地址。以下是一些指南：
- https://www.howtogeek.com/devops/how-to-run-your-own-dns-server-on-your-local-network/
- https://help.nextcloud.com/t/need-help-to-configure-internal-access/156075/6
- https://howchoo.com/pi/pi-hole-setup 与 https://web.archive.org/web/20221203223505/https://docs.callitkarma.me/posts/PiHole-Local-DNS/ 一起使用
- https://dockerlabs.collabnix.com/intermediate/networking/Configuring_DNS.html
除此之外，现在还有一个社区容器可以添加到 AIO 堆栈中：https://github.com/nextcloud/all-in-one/tree/main/community-containers/pi-hole

### 如何跳过域名验证？
如果您完全确定已正确配置了所有内容但无法通过域名验证，您可以通过在主容器的 docker run 命令中添加 `--env SKIP_DOMAIN_VALIDATION=true` 来跳过域名验证（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）。

### 如何解决 Fedora Linux、RHEL OS、CentOS、SUSE Linux 等的防火墙问题？
已知使用 [firewalld](https://firewalld.org) 作为防火墙守护程序的 Linux 发行版在 docker 网络方面存在问题。如果容器无法相互通信，您可以通过运行以下命令将 firewalld 更改为使用 iptables 后端：
```
sudo sed -i 's/FirewallBackend=nftables/FirewallBackend=iptables/g' /etc/firewalld/firewalld.conf
sudo systemctl restart firewalld docker
```
之后应该可以工作。

有关此问题的更多详细信息，请参阅 https://dev.to/ozorest/fedora-32-how-to-solve-docker-internal-network-issue-22me。这个限制甚至在官方的 firewalld 网站上也有提及：https://firewalld.org/#who-is-using-it

### 如何解决内部或保留 IP 地址错误？
如果您在域名验证期间收到错误，指出您的 IP 地址是内部或保留的 IP 地址，您可以通过首先确保您的域名确实具有指向服务器的正确公共 IP 地址，然后在主容器的 docker run 命令中添加 `--add-host yourdomain.com:<public-ip-address>`（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）来修复此问题，这将允许域名验证正常工作。您知道：即使您的域的 `A` 记录随时间变化，这也没有问题，因为主容器在初始域名验证后不会尝试访问所选域。

### 如何调整 docker 网络的 MTU 大小
您可以通过预先创建带有自定义 MTU 的 docker 网络来调整其 MTU 大小：
```
docker network create --driver bridge --opt com.docker.network.driver.mtu=1440 nextcloud-aio
```
当您在执行 `docker run` 命令后第一次打开 AIO 界面时，它将自动连接到具有自定义 MTU 的 `aio-nextcloud` 网络。请记住，如果您之前在没有使用额外选项创建网络的情况下启动了主容器，您需要删除旧的 `aio-nextcloud` 网络并使用新配置重新创建它。

如果您想使用 docker compose，您可以查看 `compose.yaml` 文件中的注释以获取更多详细信息。

## 基础设施

### 支持哪些 CPU 架构？
您可以在 Linux 上通过运行以下命令来检查：`uname -m`
- x86_64/x64/amd64
- aarch64/arm64/armv8

### 不推荐的 VPS 提供商
- 使用 Virtuozzo 的*较旧* Strato VPS 会导致问题，尽管 2023 年第三季度及以后的应该可以工作。
  如果您的 VPS 有 `/proc/user_beancounters` 文件并且在其中设置了低 `numproc` 限制
  您的服务器一旦达到此限制可能会行为异常
  AIO 很快就会达到此限制，请参阅[此处](https://github.com/nextcloud/all-in-one/discussions/1747#discussioncomment-4716164)。
- Hostingers 的 VPS 似乎缺少 AIO 正确运行所需的特定内核功能。请参阅[此处](https://help.nextcloud.com/t/help-installing-nc-via-aio-on-vps/153956)。

### 推荐的 VPS
一般来说，推荐的 VPS 是 KVM/非虚拟化的，因为 Docker 在它们上面应该运行得最好。

### 关于存储选项的注意事项
- AIO 不推荐使用 SD 卡，因为它们会降低性能，而且它们不适用于许多写入操作，而数据库和其他部分需要这些操作
- 推荐使用 SSD 存储
- HDD 存储也应该可以工作，但当然比 SSD 存储慢得多

### SELinux 启用时是否有已知问题？
是的。如果 SELinux 已启用，您可能需要在主容器的 docker run 命令中添加 `--security-opt label:disable` 选项，以允许它访问 docker socket（或在 compose.yaml 中使用 `security_opt: ["label:disable"]`）。请参阅 https://github.com/nextcloud/all-in-one/discussions/485

## 自定义

### 如何更改 Nextcloud 数据目录的默认位置？
> [!WARNING]  
> 不要在初始 Nextcloud 安装完成后设置或调整此值！如果您仍然想在之后执行此操作，请参阅[此处](https://github.com/nextcloud/all-in-one/discussions/890#discussioncomment-3089903)了解如何执行此操作。

您可以配置 Nextcloud 容器使用主机上的特定目录作为数据目录。您可以通过在主容器的 docker run 命令中添加环境变量 `NEXTCLOUD_DATADIR` 来实现这一点（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）。该变量的允许值是以 `/` 开头且不等于 `/` 的字符串。所选目录或卷将被挂载到容器内的 `/mnt/ncdata`。

- Linux 的一个例子是 `--env NEXTCLOUD_DATADIR="/mnt/ncdata"`。⚠️ 请注意：如果您应该使用挂载到 `/mnt/ncdata` 的外部 BTRFS 驱动器，请确保选择一个子文件夹，例如 `/mnt/ncdata/nextcloud` 作为数据目录，因为根文件夹不适合作为数据目录。请参阅 https://github.com/nextcloud/all-in-one/discussions/2696。
- 在 macOS 上可能是 `--env NEXTCLOUD_DATADIR="/var/nextcloud-data"`
- 对于 Synology 可能是 `--env NEXTCLOUD_DATADIR="/volume1/docker/nextcloud/data"`。
- 在 Windows 上可能是 `--env NEXTCLOUD_DATADIR="/run/desktop/mnt/host/c/ncdata"`。（此路径等效于 Windows 主机上的 `C:\ncdata`，因此您需要相应地转换路径。提示：您输入的路径需要以 `/run/desktop/mnt/host/` 开头。在其后附加 Windows 主机上的确切位置，例如 `c/ncdata`，它等效于 `C:\ncdata`。）⚠️ **请注意**：这不适用于外部驱动器，如 USB 或网络驱动器，仅适用于内部驱动器，如 SATA 或 NVME 驱动器。
- 另一个选项是使用以下命令在此处提供特定的卷名称：`--env NEXTCLOUD_DATADIR="nextcloud_aio_nextcloud_datadir"`。此卷需要由您事先手动创建才能使用。例如，在 Windows 上使用：
    ```
    docker volume create ^
    --driver local ^
    --name nextcloud_aio_nextcloud_datadir ^
    -o device="/host_mnt/e/your/data/path" ^
    -o type="none" ^
    -o o="bind"
    ```
    在这个例子中，它会将 `E:\your\data\path` 挂载到卷中，因此对于不同的位置，您需要相应地调整 `/host_mnt/e/your/data/path`。

### 如何将文件/安装存储在单独的驱动器上？
您可以将整个 docker 库及其所有文件（包括所有 Nextcloud AIO 文件和文件夹）移动到单独的驱动器，方法是首先在主机操作系统中挂载该驱动器（不支持 NTFS，推荐 ext4 作为文件系统），然后按照本教程操作：https://www.guguweb.com/2019/02/07/how-to-move-docker-data-directory-to-another-location-on-ubuntu/<br>
（当然，为此需要先安装 docker。）

⚠️ 如果您在 Nextcloud 日志中遇到 richdocuments 的错误，请在您的 Collabora 容器中检查是否出现消息 "Capabilities are not set for the coolforkit program."。如果是，请按照以下步骤操作：

1. 从 AIO 界面停止所有容器。
2. 转到终端并删除 Collabora 容器 (`docker rm nextcloud-aio-collabora`) 和 Collabora 镜像 (`docker image rm nextcloud/aio-collabora`)。
3. 您可能还需要清理您的 Docker (`docker system prune -a`)（不会丢失数据）。
4. 从 AIO 界面重新启动您的容器。

这应该可以解决问题。

### 如何允许 Nextcloud 容器访问主机上的目录？
默认情况下，Nextcloud 容器受到限制，无法访问主机操作系统上的目录。当您计划在 Nextcloud 中使用本地外部存储来将某些文件存储在数据目录之外时，您可能希望更改此设置，您可以通过在主容器的 docker run 命令中添加环境变量 `NEXTCLOUD_MOUNT` 来实现此目的（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）。该变量的允许值是以 `/` 开头且不等于 `/` 的字符串。

- Linux 的两个例子是 `--env NEXTCLOUD_MOUNT="/mnt/"` 和 `--env NEXTCLOUD_MOUNT="/media/"`。
- 在 macOS 上可能是 `--env NEXTCLOUD_MOUNT="/Volumes/your_drive/"`
- 对于 Synology 可能是 `--env NEXTCLOUD_MOUNT="/volume1/"`。
- 在 Windows 上可能是 `--env NEXTCLOUD_MOUNT="/run/desktop/mnt/host/d/your-folder/"`。（此路径等效于 Windows 主机上的 `D:\your-folder`，因此您需要相应地转换路径。提示：您输入的路径需要以 `/run/desktop/mnt/host/` 开头。在其后附加 Windows 主机上的确切位置，例如 `d/your-folder/`，它等效于 `D:\your-folder`。）⚠️ **请注意**：这不适用于外部驱动器，如 USB 或网络驱动器，仅适用于内部驱动器，如 SATA 或 NVME 驱动器。

使用此选项后，请确保对要在 Nextcloud 中使用的目录应用正确的权限。例如，在 Linux 上，如果您使用了 `--env NEXTCLOUD_MOUNT="/mnt/"`，`sudo chown -R 33:0 /mnt/your-drive-mountpoint` 和 `sudo chmod -R 750 /mnt/your-drive-mountpoint` 应该可以使其工作。在 Windows 上，您可以使用 `docker exec -it nextcloud-aio-nextcloud chown -R 33:0 /run/desktop/mnt/host/d/your-folder/` 和 `docker exec -it nextcloud-aio-nextcloud chmod -R 750 /run/desktop/mnt/host/d/your-folder/` 来执行此操作。

然后，您可以导航到 `https://your-nc-domain.com/settings/apps/disabled`，激活外部存储应用，导航到 `https://your-nc-domain.com/settings/admin/externalstorages` 并添加一个本地外部存储目录，该目录将在容器内可访问，位置与您输入的相同。例如，`/mnt/your-drive-mountpoint` 将被挂载到容器内的 `/mnt/your-drive-mountpoint` 等。

但请注意，这些位置不会被内置备份解决方案覆盖 - 但您可以在初始备份完成后添加更多您想要备份的 Docker 卷和主机路径。

> [!NOTE]  
> 如果在外部存储管理选项中看不到 "本地存储" 类型，可能需要从 AIO 界面重新启动容器。

### 如何调整 Talk 端口？
默认情况下，talk 容器将使用端口 `3478/UDP` 和 `3478/TCP` 进行连接。这应该设置为高于 1024 的值！您可以通过在主容器的 docker run 命令中添加例如 `--env TALK_PORT=3478`（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）并将端口调整为您想要的值来调整端口。最好使用 1024 以上的端口，例如 3479，以避免遇到以下问题：https://github.com/nextcloud/all-in-one/discussions/2517

### 如何调整 Nextcloud 的上传限制？
默认情况下，Nextcloud 的公共上传限制为最大 16G（已登录用户可以使用 Web 界面或移动/桌面客户端上传更大的文件，因为在这种情况下使用了分块）。您可以通过向主容器的 docker run 命令提供 `--env NEXTCLOUD_UPLOAD_LIMIT=16G`（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）并根据您的需要自定义该值来调整上传限制。它必须以数字开头并以 `G` 结尾，例如 `16G`。

### 如何调整 Nextcloud 的最大执行时间？
默认情况下，Nextcloud 的上传限制为最大 3600 秒。您可以通过向主容器的 docker run 命令提供 `--env NEXTCLOUD_MAX_TIME=3600`（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）并根据您的需要自定义该值来调整上传时间限制。它必须是一个数字，例如 `3600`。

### 如何调整 Nextcloud 的 PHP 内存限制？
默认情况下，Nextcloud 容器中的每个 PHP 进程限制为最大 512 MB。您可以通过向主容器的 docker run 命令提供 `--env NEXTCLOUD_MEMORY_LIMIT=512M`（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）并根据您的需要自定义该值来调整内存限制。它必须以数字开头并以 `M` 结尾，例如 `1024M`。

### 如何更改在首次启动时安装的 Nextcloud 应用？
您可能希望调整在 Nextcloud 容器首次启动时安装的 Nextcloud 应用。您可以通过在主容器的 docker run 命令中添加 `--env NEXTCLOUD_STARTUP_APPS="deck twofactor_totp tasks calendar contacts notes"`（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）并根据您的需要自定义该值来实现。它必须是一个包含小写字母 a-z、0-9、空格和连字符或下划线的字符串。您可以通过在应用 ID 前添加连字符来禁用默认已启用的应用。例如 `-contactsinteraction`。

### 如何永久地向 Nextcloud 容器添加 OS 包？
一些 Nextcloud 应用需要额外的外部依赖项，这些依赖项必须捆绑在 Nextcloud 容器中才能正常工作。由于我们不能将所有应用的所有依赖项都放入容器中（因为这会使项目很快变得难以维护），我们提供了一种官方方式，您可以通过这种方式向 Nextcloud 容器添加额外的依赖项。但是请注意，由于我们不测试需要外部依赖项的 Nextcloud 应用，因此不建议这样做。

您可以通过在主容器的 docker run 命令中添加 `--env NEXTCLOUD_ADDITIONAL_APKS="imagemagick dependency2 dependency3"`（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）并根据您的需要自定义该值来实现。它必须是一个包含小写字母 a-z、数字 0-9、空格、点和连字符或下划线的字符串。您可以在这里找到可用的包：https://pkgs.alpinelinux.org/packages?branch=v3.22。默认情况下添加了 `imagemagick`。如果您想保留它，也需要指定它。

### 如何永久地向 Nextcloud 容器添加 PHP 扩展？
一些 Nextcloud 应用需要额外的 PHP 扩展，这些扩展必须捆绑在 Nextcloud 容器中才能正常工作。由于我们不能将所有应用的所有依赖项都放入容器中（因为这会使项目很快变得难以维护），我们提供了一种官方方式，您可以通过这种方式向 Nextcloud 容器添加额外的 PHP 扩展。但是请注意，由于我们不测试需要额外 PHP 扩展的 Nextcloud 应用，因此不建议这样做。

您可以通过在主容器的 docker run 命令中添加 `--env NEXTCLOUD_ADDITIONAL_PHP_EXTENSIONS="imagick extension1 extension2"`（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）并根据您的需要自定义该值来实现。它必须是一个包含小写字母 a-z、数字 0-9、空格、点和连字符或下划线的字符串。您可以在这里找到可用的扩展：https://pecl.php.net/packages.php。默认情况下添加了 `imagick`。如果您想保留它，也需要指定它。

### 用于人脸识别应用的 pdlib PHP 扩展如何处理？
[人脸识别应用](https://apps.nextcloud.com/apps/facerecognition) 需要安装 pdlib PHP 扩展。不幸的是，它在 PECL 或 PHP 核心中不可用，因此目前无法将其添加到 AIO 中。但是，您可以使用[这个社区容器](https://github.com/nextcloud/all-in-one/tree/main/community-containers/facerecognition)来运行人脸识别。

### 如何为 Nextcloud 启用硬件加速？
一些容器可以使用 GPU 加速来提高性能，例如 [memories 应用](https://apps.nextcloud.com/apps/memories) 允许为视频启用硬件转码。

#### 使用适用于 AMD、Intel 的开源驱动 MESA 以及适用于 Nvidia 的**新**驱动 `Nouveau`

> [!WARNING]  
> 这仅在主机上存在 `/dev/dri` 设备时才有效！如果您的主机上不存在，请不要继续，否则 Nextcloud 容器将无法启动！如果您对此不确定，最好不要继续执行以下说明。确保您的驱动程序在主机上配置正确。

支持的设备列表可以在 [MESA 3D 文档](https://docs.mesa3d.org/systems.html) 中找到。

此方法使用 [Direct Rendering Infrastructure](https://dri.freedesktop.org/wiki/)，并访问 `/dev/dri` 设备。

要使用它，您需要在主容器的 docker run 命令中添加 `--env NEXTCLOUD_ENABLE_DRI_DEVICE=true`（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它），这将把 `/dev/dri` 设备挂载到容器中。


#### 使用适用于 Nvidia 的专有驱动程序 :warning: 测试版

> [!WARNING]
> 这仅在主机上安装了 Nvidia Toolkit 并且启用了 NVIDIA GPU 时才有效！确保它在主机上配置正确。如果您的主机上不存在，请不要继续，否则 Nextcloud 容器将无法启动！如果您对此不确定，最好不要继续执行以下说明。
> 
> 此功能处于测试阶段。由于是专有驱动程序，使用专有驱动程序的用户不多，我们无法保证此功能的稳定性。欢迎提供反馈。

此方法使用带有 nvidia 运行时的 [Nvidia Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html)。

要使用它，您需要在主容器的 docker run 命令中添加 `--env NEXTCLOUD_ENABLE_NVIDIA_GPU=true`（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它），这将启用 nvidia 运行时。

如果您使用 WSL2 并想使用 NVIDIA 运行时，请按照说明在 WSL 中[安装 NVIDIA Container Toolkit 元版本](https://docs.nvidia.com/cuda/wsl-user-guide/index.html#cuda-support-for-wsl-2)。

### 如何保留已禁用的应用？
在某些情况下，您可能希望保留在 AIO 界面中禁用的 Nextcloud 应用，如果它们应该在 Nextcloud 中安装，则不要卸载它们。您可以通过在主容器的 docker run 命令中添加 `--env NEXTCLOUD_KEEP_DISABLED_APPS=true`（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）来实现。
> [!WARNING]  
> 如果一个需要外部依赖的应用仍然安装但外部依赖不存在，这样做可能会在 Nextcloud 中导致意外问题。

### 如何信任用户定义的证书颁发机构（CA）？
> [!NOTE]
> 请注意，此功能仅用于使具有自签名证书的 LDAPS 连接正常工作。它不会使不同容器之间的其他互连正常工作，因为它们需要有效的公开信任证书，如 Let's Encrypt 的证书。

对于某些应用程序，可能需要与另一个使用由默认不受信任的证书颁发机构颁发的证书的主机/服务器建立安全连接。例如，可以配置 LDAPS 以连接到组织的域控制器（Active Directory 或基于 Samba 的）。

您可以通过向主容器的 docker run 命令提供环境变量 `NEXTCLOUD_TRUSTED_CACERTS_DIR`（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）来使 Nextcloud 容器信任任何证书颁发机构。该变量的值应设置为主机上包含一个或多个证书颁发机构证书的目录的绝对路径。您应该使用 Base64 编码的 X.509 证书。（其他格式可能有效，但尚未测试！）目录中的所有证书都将被信任。

使用 `docker run` 时，可以使用 `--env NEXTCLOUD_TRUSTED_CACERTS_DIR=/path/to/my/cacerts` 设置环境变量。

为了使值有效，路径应以 `/` 开头，不以 `/` 结尾，并指向一个**存在的目录**。将变量直接指向证书**文件**将不起作用，还可能导致问题。

### 如何禁用 Collabora 的 Seccomp 功能？
Collabora 容器默认启用 Seccomp，这是 Linux 内核的一项安全功能。在没有启用此内核功能的系统上，您需要在初始 docker run 命令中提供 `--env COLLABORA_SECCOMP_DISABLED=true` 才能使其工作。如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它。

### 如何调整全文搜索的 Java 选项？
全文搜索的 Java 选项默认设置为 `-Xms512M -Xmx512M`，这在某些系统上可能不够。您可以通过在初始 docker run 命令中添加例如 `--env FULLTEXTSEARCH_JAVA_OPTIONS="-Xms1024M -Xmx1024M"` 来调整此设置。如果它已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它。

## 指南

### 如何在 macOS 上运行 AIO？
在 macOS 上，与 Linux 相比只有一点不同：不是使用 `--volume /var/run/docker.sock:/var/run/docker.sock:ro`，而是需要使用 `--volume /var/run/docker.sock.raw:/var/run/docker.sock:ro` 来运行它，前提是您已经安装了 [Docker Desktop](https://www.docker.com/products/docker-desktop/)（如果需要，不要忘记[启用 ipv6](https://github.com/nextcloud/all-in-one/blob/main/docker-ipv6-support.md)）。除此之外，它应该与 Linux 上的工作方式相同。

此外，您可能有兴趣调整 Nextcloud 的 Datadir 以将文件存储在主机系统上。有关如何执行此操作，请参阅[此文档](https://github.com/nextcloud/all-in-one#how-to-change-the-default-location-of-nextclouds-datadir)。

### 如何在 Windows 上运行 AIO？
在 Windows 上，安装 [Docker Desktop](https://www.docker.com/products/docker-desktop/)（如果需要，不要忘记[启用 ipv6](https://github.com/nextcloud/all-in-one/blob/main/docker-ipv6-support.md)）并在命令提示符中运行以下命令：

```
docker run ^
--init ^
--sig-proxy=false ^
--name nextcloud-aio-mastercontainer ^
--restart always ^
--publish 80:80 ^
--publish 8080:8080 ^
--publish 8443:8443 ^
--volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config ^
--volume //var/run/docker.sock:/var/run/docker.sock:ro ^
ghcr.io/nextcloud-releases/all-in-one:latest
```

此外，您可能有兴趣调整 Nextcloud 的 Datadir 以将文件存储在主机系统上。有关如何执行此操作，请参阅[此文档](https://github.com/nextcloud/all-in-one#how-to-change-the-default-location-of-nextclouds-datadir)。

> [!NOTE]  
> 此项目文档中的几乎所有命令都使用 `sudo docker ...`。由于 Windows 上不提供 `sudo`，您只需从命令中删除 `sudo` 即可，它们应该可以正常工作。

### 如何在 Synology DSM 上运行 AIO？
在 Synology 上，与 Linux 相比有两点不同：不是使用 `--volume /var/run/docker.sock:/var/run/docker.sock:ro`，而是需要使用 `--volume /volume1/docker/docker.sock:/var/run/docker.sock:ro` 来运行它。您还需要在主容器的 docker run 命令中添加 `--env WATCHTOWER_DOCKER_SOCKET_PATH="/volume1/docker/docker.sock"`（但在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前）。除此之外，它应该与 Linux 上的工作方式相同。显然，Synology Docker GUI 不适用于此，因此您需要使用 SSH 或在任务计划程序中创建用户定义的脚本任务作为 'root' 用户来运行该命令。

> [!NOTE]  
> docker socket 在您的 Synology 上可能位于 `/var/run/docker.sock`，就像 Linux 上的默认位置一样。然后您可以直接使用 Linux 命令，无需更改任何内容 - 当您尝试启动容器时，它会说绑定挂载失败，您会注意到这一点。例如 `docker: Error response from daemon: Bind mount failed: '/volume1/docker/docker.sock' does not exists.`

此外，您可能有兴趣调整 Nextcloud 的 Datadir 以将文件存储在主机系统上。有关如何执行此操作，请参阅[此文档](https://github.com/nextcloud/all-in-one#how-to-change-the-default-location-of-nextclouds-datadir)。

您还需要调整 Synology 的防火墙，请参阅下面：

<details>
<summary>点击此处展开</summary>

Synology DSM 的开放端口和登录界面容易受到攻击，因此始终建议设置防火墙。如果防火墙已激活，则需要为端口 80、443、包含 Nextcloud 容器的 docker 桥接的子网、您的公共静态 IP（如果您不使用 DDNS）以及（如适用）您的 NC-Talk 端口 3478 TCP+UDP 设置例外：

![Screenshot 2023-01-19 at 14 13 48](https://user-images.githubusercontent.com/70434961/213677995-71a9f364-e5d2-49e5-831e-4579f217c95c.png)

如果您的 NAS 设置在本地网络上（这是最常见的情况），您需要设置 Synology DNS 以便能够通过其域名从您的网络访问 Nextcloud。也不要忘记将新的 DNS 添加到您的 DHCP 服务器和固定 IP 设置：
 
![Screenshot 2023-01-20 at 12 13 44](https://user-images.githubusercontent.com/70434961/213683295-0b39a2bd-7a26-414c-a408-127dd4f07826.png)
</details>

### 如何使用 Portainer 运行 AIO？
在 Linux 上使用 Portainer 运行它的最简单方法是使用 Portainer 的堆栈功能并使用[这个 docker-compose 文件](./compose.yaml)来正确启动 AIO。

### 我可以在 TrueNAS SCALE 上运行 AIO 吗？
随着 Truenas Scale Release 24.10.0（于 2024 年 10 月 29 日作为稳定版本正式发布），IX Systems 放弃了 Kubernetes 集成并实现了完全工作的 docker 环境。

有关更完整的指南，请参阅 @zybster 的指南：https://github.com/nextcloud/all-in-one/discussions/5506

在具有 Kubernetes 环境的旧版 TrueNAS SCALE 上，有两种方法可以运行 AIO。首选方法是在 VM 内运行 AIO。这是必要的，因为它们不会为主机上的容器公开 docker socket，因此您也不能在其上使用 docker-compose，也不能运行未明确为 TrueNAS SCALE 编写的自定义 helm-charts。

另一种未经测试的方法是从 https://truecharts.org/charts/stable/portainer/installation-notes 在您的 TrueNAS SCALE 上安装 Portainer，然后按照 https://docs.portainer.io/user/kubernetes/helm 在 Portainer 中添加 Helm-chart 存储库 https://nextcloud.github.io/all-in-one/。有关 AIOs Helm Chart 的更多文档可在此处找到：https://github.com/nextcloud/all-in-one/tree/main/nextcloud-aio-helm-chart#nextcloud-aio-helm-chart。

### 如何运行 `occ` 命令？
只需运行以下命令：`sudo docker exec --user www-data -it nextcloud-aio-nextcloud php occ your-command`。当然，`your-command` 需要替换为您要运行的命令。**请注意**：如果您没有服务器的 CLI 访问权限，您现在可以通过使用这个社区容器在 Web 会话中运行 docker 命令：https://github.com/nextcloud/all-in-one/tree/main/community-containers/container-management

### 如何解决初始安装后 "安全与设置警告" 显示 "缺少默认电话区域" 的问题？
只需运行以下命令：`sudo docker exec --user www-data nextcloud-aio-nextcloud php occ config:system:set default_phone_region --value="yourvalue"`。当然，您需要根据您的位置修改 `yourvalue`。例如 `DE`、`US` 和 `GB`。有关更多代码，请参阅此列表：https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements **请注意**：如果您没有服务器的 CLI 访问权限，您现在可以通过使用这个社区容器在 Web 会话中运行 docker 命令：https://github.com/nextcloud/all-in-one/tree/main/community-containers/container-management

### 如何在一台服务器上运行多个 AIO 实例？
请参阅 [multiple-instances.md](./multiple-instances.md) 了解有关此主题的一些文档。

### 暴力破解保护常见问题
Nextcloud 具有内置的暴力破解保护，可能会被触发并阻止 IP 地址或禁用用户。您可以通过运行 `sudo docker exec --user www-data -it nextcloud-aio-nextcloud php occ security:bruteforce:reset <ip-address>` 来解除阻止 IP 地址，并通过运行 `sudo docker exec --user www-data -it nextcloud-aio-nextcloud php occ user:enable <name of user>` 来启用被禁用的用户。有关更多信息，请参阅 https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/occ_command.html#security。**请注意**：如果您没有服务器的 CLI 访问权限，您现在可以通过使用这个社区容器在 Web 会话中运行 docker 命令：https://github.com/nextcloud/all-in-one/tree/main/community-containers/container-management

### 如何更新容器？
如果我们将新容器推送到 `latest`，您会在 AIO 界面的 `containers` 部分下方看到找到了新的容器更新。在这种情况下，只需按 `停止容器` 和 `启动并更新容器` 以更新容器。不过，主容器有其自己的更新过程。见下文。在再次启动容器之前，不要忘记使用内置的备份解决方案备份您实例的当前状态！否则，如果在更新过程中出现问题，您将无法轻松还原实例。

如果找到了新的 `主容器` 更新，您会在 `停止容器` 按钮下方看到一个注释，允许显示更新日志。如果您点击该按钮并且容器已停止，您将看到一个新的按钮，允许更新主容器。执行此操作后，更新完成后，您将再次有 `启动并更新容器` 的选项。建议在点击 `启动并更新容器` 按钮之前创建备份。

此外，每天运行一次的 cronjob 会检查容器和主容器的更新，如果发现新的更新，会向所有 Nextcloud 管理员发送通知。

### 如何轻松登录到 AIO 界面？
如果您的 Nextcloud 正在运行，并且您以管理员身份登录到 Nextcloud，您可以通过打开 `https://yourdomain.tld/settings/admin/overview` 轻松登录到 AIO 界面，该界面顶部会显示一个按钮，您只需点击此按钮即可登录到 AIO 界面。

> [!Note]
> 您可以通过简单地停止容器，从正确和所需的域名/IP 地址/端口访问 AIO 界面，并点击一次 `启动容器` 来更改按钮的域名/IP 地址/端口。

### 如何更改域名？
> [!NOTE]  
> 手动编辑 configuration.json 并犯错误可能会破坏您的实例，因此请先创建备份！

如果您设置了一个新的 AIO 实例，您需要输入一个域名。目前无法从 AIO 界面更改此域名。因此，要更改它，您需要使用 `sudo docker run -it --rm --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config:rw alpine sh -c "apk add --no-cache nano && nano /mnt/docker-aio-config/data/configuration.json"` 手动编辑 configuration.json，将您旧域名的每次出现替换为新域名，然后保存并写出文件。之后从 AIO 界面重新启动容器，如果新域名配置正确，一切应该按预期工作。<br>
如果您在 Web 服务器或反向代理（如 Apache、Nginx、Caddy、Cloudflare Tunnel 等）后面运行 AIO，您显然还需要在反向代理配置中更改域名。

此外，重新启动容器后，您需要打开管理员设置并手动更新一些无法自动更改的值。以下是一些已知的位置列表：
- `https://your-nc-domain.com/settings/admin/talk` 用于 Turn/Stun 服务器和 Signaling 服务器，如果您通过 AIO 界面启用了 Talk
- `https://your-nc-domain.com/settings/admin/theming` 用于主题 URL
- `https://your-nc-domain.com/settings/admin/app_api` 用于部署守护程序，如果您通过 AIO 界面启用了 App API

### 如何正确重置实例？
如果在初始安装期间出现意外情况，您可能希望重置 AIO 安装以便能够从头开始。

> [!NOTE]  
> 如果您已经运行它并且实例上有数据，则不应遵循这些说明，因为它将删除与您的 AIO 实例相关的所有数据。

以下是正确重置 AIO 实例的方法：
1. 如果容器正在运行，从 AIO 界面停止所有容器
1. 使用 `sudo docker stop nextcloud-aio-mastercontainer` 停止主容器
1. 如果 domaincheck 容器仍在运行，请使用 `sudo docker stop nextcloud-aio-domaincheck` 停止它
1. 通过运行 `sudo docker ps --format {{.Names}}` 检查没有 AIO 容器在运行。如果没有列出 `nextcloud-aio` 容器，您可以继续执行以下步骤。如果应该有一些，您需要使用 `sudo docker stop <container_name>` 停止它们，直到不再列出任何容器。
1. 检查哪些容器已停止：`sudo docker ps --filter "status=exited"`
1. 现在使用 `sudo docker container prune` 删除所有这些已停止的容器
1. 使用 `sudo docker network rm nextcloud-aio` 删除 docker 网络
1. 使用 `sudo docker volume ls --filter "dangling=true"` 检查哪些卷是悬空的
1. 现在删除所有这些悬空卷：`sudo docker volume prune --filter all=1`（在 Windows 上，您可能需要手动删除一些卷，使用 `docker volume rm nextcloud_aio_backupdir`、`docker volume rm nextcloud_aio_nextcloud_datadir`）。 
1. 如果您已将 `NEXTCLOUD_DATADIR` 配置为主机上的路径而不是默认卷，您还需要清理该路径。（例如，通过简单地删除目录）。
1. 使用 `sudo docker volume ls --format {{.Name}}` 确保没有剩余卷。如果没有列出 `nextcloud-aio` 卷，您可以继续执行以下步骤。如果应该有一些，您需要使用 `sudo docker volume rm <volume_name>` 删除它们，直到不再列出任何卷。
1. 可选：您可以使用 `sudo docker image prune -a` 删除所有 docker 镜像。
1. 完成！现在可以使用推荐的 docker run 命令重新开始！

### 我可以使用 CIFS/SMB 共享作为 Nextcloud 的数据目录吗？
当然可以。将此添加到主机系统的 `/etc/fstab` 文件中：<br>
`<your-storage-host-and-subpath> <your-mount-dir> cifs rw,mfsymlinks,seal,credentials=<your-credentials-file>,uid=33,gid=0,file_mode=0770,dir_mode=0770 0 0`<br>
（当然，您需要为您的具体情况修改 `<your-storage-host-and-subpath>`、`<your-mount-dir>` 和 `<your-credentials-file>`。）

一个示例可能如下所示：<br>
`//your-storage-host/subpath /mnt/storagebox cifs rw,mfsymlinks,seal,credentials=/etc/storage-credentials,uid=33,gid=0,file_mode=0770,dir_mode=0770 0 0`<br>
并添加到 `/etc/storage-credentials` 中：
```
username=<smb/cifs username>
password=<password>
```
（当然，您需要为您的具体情况修改 `<smb/cifs username>` 和 `<password>`。）

现在，您可以使用 `/mnt/storagebox` 作为 Nextcloud 的数据目录，如本节上面所述。

### 我可以使用 Docker swarm 运行这个吗？
是的。为此，您需要使用并遵循[手动安装文档](./manual-install/)。

### 我可以使用 Kubernetes 运行这个吗？
是的。为此，您需要使用并遵循[helm-chart 文档](./nextcloud-aio-helm-chart/)。

### 如何使用 Docker rootless 运行这个？
您也可以使用 docker rootless 运行 AIO。如何做到这一点记录在这里：[docker-rootless.md](https://github.com/nextcloud/all-in-one/blob/main/docker-rootless.md)

### 我可以使用 Podman 而不是 Docker 运行这个吗？
由于 Podman 与 Docker API 不是 100% 兼容，因此不支持 Podman（因为这会增加维护者需要测试的另一个平台）。但是，您可以使用并遵循[手动安装文档](./manual-install/)来让 AIO 的容器与 Podman 一起运行，或者使用 Docker rootless，如上面的部分所述。另外，现在有这个：https://github.com/nextcloud/all-in-one/discussions/3487

### 手动访问/编辑 Nextcloud 文件/文件夹
您添加到 Nextcloud 的文件和文件夹默认存储在以下 docker 目录中：`nextcloud_aio_nextcloud:/mnt/ncdata/`（通常在 linux 主机系统上是 `/var/lib/docker/volumes/nextcloud_aio_nextcloud_data/_data/`）。如果需要，您可以在那里修改/添加/删除文件/文件夹，但**注意**：这样做时要非常小心，因为您可能会损坏您的 AIO 安装！最好在编辑/更改那里的文件/文件夹之前使用内置的备份解决方案创建备份，因为这样您就可以将实例还原到备份状态。

完成修改/添加/删除文件/文件夹后，不要忘记通过运行 `sudo docker exec nextcloud-aio-nextcloud chown -R 33:0 /mnt/ncdata/` 和 `sudo docker exec nextcloud-aio-nextcloud chmod -R 750 /mnt/ncdata/` 应用正确的权限，并使用 `sudo docker exec --user www-data -it nextcloud-aio-nextcloud php occ files:scan --all` 重新扫描文件。**请注意**：如果您没有服务器的 CLI 访问权限，您现在可以通过使用这个社区容器在 Web 会话中运行 docker 命令：https://github.com/nextcloud/all-in-one/tree/main/community-containers/container-management

### 如何使用文本编辑器编辑 Nextcloud 的 config.php 文件？
您可以直接从主机使用您喜欢的文本编辑器编辑 Nextcloud 的 config.php 文件。例如，像这样：`sudo docker run -it --rm --volume nextcloud_aio_nextcloud:/var/www/html:rw alpine sh -c "apk add --no-cache nano && nano /var/www/html/config/config.php"`。但是请确保不要破坏文件，否则可能会损坏您的 Nextcloud 实例。最好在编辑文件之前使用内置的备份解决方案创建备份。**请注意**：如果您没有服务器的 CLI 访问权限，您现在可以通过使用这个社区容器在 Web 会话中运行 docker 命令：https://github.com/nextcloud/all-in-one/tree/main/community-containers/container-management

### 如何通过创建自定义骨架目录更改默认文件？
所有用户都看到一组由 Nextcloud 配置指定的[默认文件和文件夹](https://docs.nextcloud.com/server/latest/admin_manual/configuration_files/default_files_configuration.html)。要更改这些默认文件和文件夹，必须首先创建一个自定义骨架目录；这可以通过复制您的骨架文件 `sudo docker cp --follow-link /path/to/nextcloud/skeleton/ nextcloud-aio-nextcloud:/mnt/ncdata/skeleton/`，使用 `sudo docker exec nextcloud-aio-nextcloud chown -R 33:0 /mnt/ncdata/skeleton/` 和 `sudo docker exec nextcloud-aio-nextcloud chmod -R 750 /mnt/ncdata/skeleton/` 应用正确的权限，并使用 `sudo docker exec --user www-data -it nextcloud-aio-nextcloud php occ config:system:set skeletondirectory --value="/mnt/ncdata/skeleton"` 设置骨架目录选项来完成。在 Nextcloud 文档中可以找到有关[骨架目录配置参数](https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/config_sample_php_parameters.html#skeletondirectory)的更多信息。

### 如何调整版本保留策略和回收站保留策略？
默认情况下，AIO 将 `versions_retention_obligation` 和 `trashbin_retention_obligation` 都设置为 `auto, 30`，这意味着版本和回收站中的项目在 30 天后会被删除。如果您想更改此设置，请参阅 https://docs.nextcloud.com/server/latest/admin_manual/configuration_files/file_versioning.html。

### 如何在不事先创建备份的情况下启用自动更新？
如果您有外部备份解决方案，您可能希望启用自动更新而不先创建备份。但是请注意，不建议这样做，因为您将无法再轻松地从 AIO 界面创建和还原备份，并且您需要确保在创建备份之前正确关闭所有容器，例如，首先从 AIO 界面停止它们。

但无论如何，这里有一个指南，可以帮助您自动化整个过程：

<details>
<summary>点击此处展开</summary>

```bash
#!/bin/bash

# 停止容器
docker exec --env STOP_CONTAINERS=1 nextcloud-aio-mastercontainer /daily-backup.sh

# 如果您在 VM 中运行 AIO，以下是可选的，它将在之后关闭 VM
# poweroff

```

</details>

您可以简单地将脚本复制并粘贴到一个文件中，例如命名为 `shutdown-script.sh`，例如：`/root/shutdown-script.sh`。

之后使用 `sudo chown root:root /root/shutdown-script.sh` 和 `sudo chmod 700 /root/shutdown-script.sh` 应用正确的权限。然后您可以创建一个 cronjob，让它按计划运行，例如每天 `04:00` 运行脚本，如下所示：
1. 使用 `sudo crontab -u root -e` 打开 cronjob（如果尚未完成，请选择您的编辑器。我推荐 nano）。
2. 如果不存在，将以下新行添加到 cronjob 中：`0 4 * * * /root/shutdown-script.sh`，这将每天 04:00 运行脚本。
3. 保存并关闭 cronjob（使用 nano 时，快捷键是 `Ctrl + o`，然后按 `Enter` 保存，然后使用 `Ctrl + x` 关闭编辑器）。

**完成后，您应该从备份解决方案中安排一个备份，在 AIO 正确关闭后创建备份。提示：如果您的备份在同一主机上运行，请确保至少备份所有 docker 卷，以及 Nextcloud 的数据目录（如果它未存储在 docker 卷中）。**

**之后，您可以创建第二个脚本，自动更新容器：**

<details>
<summary>点击此处展开</summary>

```bash
#!/bin/bash

# 运行一次容器更新
if ! docker exec --env AUTOMATIC_UPDATES=1 nextcloud-aio-mastercontainer /daily-backup.sh; then
    while docker ps --format "{{.Names}}" | grep -q "^nextcloud-aio-watchtower$"; do
        echo "等待 watchtower 停止"
        sleep 30
    done

    while ! docker ps --format "{{.Names}}" | grep -q "^nextcloud-aio-mastercontainer$"; do
        echo "等待主容器启动"
        sleep 30
    done

    # 再次运行容器更新，确保所有容器都已正确更新。
    docker exec --env AUTOMATIC_UPDATES=1 nextcloud-aio-mastercontainer /daily-backup.sh
fi

```

</details>

您可以简单地将脚本复制并粘贴到一个文件中，例如命名为 `automatic-updates.sh`，例如：`/root/automatic-updates.sh`。

之后使用 `sudo chown root:root /root/automatic-updates.sh` 和 `sudo chmod 700 /root/automatic-updates.sh` 应用正确的权限。然后您可以创建一个 cronjob，让它每天 `05:00` 运行，如下所示：

### 自动更新脚本配置
1. 使用`sudo crontab -u root -e`打开cron作业（如果尚未选择编辑器，请选择您喜欢的编辑器。推荐使用nano）。
2. 在crontab中添加以下新行（如果尚未存在）：`0 5 * * * /root/automatic-updates.sh`，这将每天05:00运行脚本。
3. 保存并关闭crontab（使用nano时，快捷键是`Ctrl + o`然后按`Enter`保存，使用`Ctrl + x`关闭编辑器）。

### 保护AIO界面免受未授权的ACME挑战
[根据设计](https://github.com/nextcloud/all-in-one/discussions/4882#discussioncomment-9858384)，在主容器内运行的Caddy（负责处理端口8443上AIO界面的自动TLS证书生成）配置为接受任何有效域的流量，以使AIO界面尽可能方便使用。然而，由于这一点，它容易受到来自互联网上任何人的任意主机名的DNS挑战。虽然这不会危及服务器的安全性，但可能会导致日志混乱和由于速率限制滥用而拒绝证书续订尝试。为减轻此问题，建议将AIO界面置于VPN后面和/或限制其公开暴露。

### 如何从已有的Nextcloud安装迁移到Nextcloud AIO？
请参阅以下文档：[migration.md](https://github.com/nextcloud/all-in-one/blob/main/migration.md)

## 备份
Nextcloud AIO提供基于[BorgBackup](https://github.com/borgbackup/borg#what-is-borgbackup)的备份解决方案。这些备份作为安装损坏时的恢复点。通过使用此工具，备份是增量的、差异的、压缩的和加密的——因此只有第一次备份会花费一些时间。后续备份应该很快，因为只考虑更改的部分。

建议在任何容器更新之前创建备份。通过这样做，您将在更新期间遇到任何可能的并发症时安全，因为您基本上可以一键恢复整个实例。

对于本地备份，恢复过程应该相当快，因为rsync用于恢复选定的备份，只传输更改的文件并删除额外的文件。对于远程borg备份，整个备份归档从远程提取，这取决于`borg extract`的智能程度，可能需要下载整个归档。

如果您将外部驱动器连接到主机，并选择备份目录位于该驱动器上，您也可以在一定程度上防止存储docker卷的驱动器发生故障。

<details>
<summary>如何逐步完成上述操作</summary>

1. 使用内置功能或udev规则或您喜欢的任何方式将外部/备份HDD挂载到主机操作系统。（例如，观看此视频：https://www.youtube.com/watch?v=2lSyX4D3v_s）并最好将驱动器挂载在`/mnt/backup`中。
2. 如果尚未完成，启动docker容器并按照指南设置Nextcloud。
3. 现在打开AIO界面。
4. 在备份部分下，添加外部磁盘挂载点作为备份目录，例如`/mnt/backup`。
5. 点击`创建备份`，这应该在外部磁盘上创建第一个备份。

</details>

如果您想直接备份到远程borg存储库：

<details>
<summary>如何逐步完成上述操作</summary>

1. 在远程创建您的borg存储库。记下存储库URL以供以后使用。
2. 打开AIO界面
3. 在备份部分下，保留本地路径为空，并填写您之前记下的borg存储库的URL。
4. 点击`创建备份`，这将创建一个ssh密钥对并失败，因为远程不信任此密钥。复制AIO中显示的公钥并将其添加到远程的authorized keys中。
5. 再次尝试创建备份，这次应该成功。

</details>

可以在AIO界面中使用`创建备份`和`恢复选定的备份`按钮创建和恢复备份。此外，还提供了备份检查功能，用于检查备份的完整性，但在大多数情况下不需要。

备份本身使用在AIO界面中显示给您的加密密钥进行加密。请将其保存在安全的地方，因为没有此密钥，您将无法从备份中恢复。

初始备份完成后，可以启用每日备份。启用此功能还允许启用一个选项，允许自动更新所有容器、Nextcloud及其应用程序。

请注意，此解决方案不会备份使用外部存储应用程序挂载到Nextcloud的文件和文件夹——但您可以在初始备份完成后添加更多您想要备份的Docker卷和主机路径。

---

### AIO的备份解决方案会备份什么？
将备份Nextcloud AIO实例的所有重要数据，这些数据是恢复实例所需的，如数据库、文件以及主容器和其他组件的配置文件。使用外部存储应用程序挂载到Nextcloud的文件和文件夹不会被备份。目前无法排除数据目录，因为这需要像运行files:scan这样的黑客操作，并会使备份解决方案更加不可靠（因为数据库和文件/文件夹需要保持同步）。如果您仍然不希望备份数据目录，请参阅https://github.com/nextcloud/all-in-one#how-to-enable-automatic-updates-without-creating-a-backup-beforehand获取选项（其中提示了需要按什么顺序备份什么）。

### 如何调整borg的保留策略？
内置的基于borg的备份解决方案默认保留策略为`--keep-within=7d --keep-weekly=4 --keep-monthly=6`。请参阅https://borgbackup.readthedocs.io/en/stable/usage/prune.html了解这些值的含义。您可以通过为主容器的docker run命令提供`--env BORG_RETENTION_POLICY="--keep-within=7d --keep-weekly=4 --keep-monthly=6"`来调整保留策略（但要在最后一行`ghcr.io/nextcloud-releases/all-in-one:latest`之前！如果已经启动，您需要停止主容器，将其删除（不会丢失数据），然后使用您最初使用的docker run命令重新创建它），并根据您的需要自定义该值。⚠️请确保此值有效，否则备份清理将出现问题！

### 如何从AIO迁移到AIO？
如果您启用了borg备份功能，您可以将其复制到新主机并从备份中恢复。本指南假设新安装的数据目录将位于`/mnt/datadir`，如果在其他位置，您可以调整步骤。

1. 如果适用，将DNS条目设置为60秒TTL
2. 在当前安装上，使用AIO界面：
    1. 更新AIO和所有容器
    1. 停止所有容器（从现在开始，您的云服务将关闭）
    1. 创建当前的borg备份
    1. 记下备份存储的路径和加密密码
3. 导航到备份文件夹
4. 创建备份的存档以便于复制：`tar -czvf borg.tar.gz borg`
5. 将存档复制到新主机：`scp borg.tar.gz user@new.host:/mnt`。确保将`user`替换为您的实际用户，`new.host`替换为实际主机的IP或域名。您也可以使用其他方式复制存档。
6. 切换到新主机
7. 转到您放置备份存档的文件夹，并使用`tar -xf borg.tar.gz`提取它
8. 按照安装指南创建新的aio实例，但尚未启动容器（`docker run`或`docker compose up -d`命令）
9. 将DNS条目更改为新主机的IP
10. 如果使用反向代理，请配置它
11. 启动AIO容器并在浏览器中打开新的AIO界面
12. 确保保存新生成的密码短语并在下一步输入
13. 选择"从备份恢复以前的AIO实例"选项，并输入旧备份的加密密码和提取的`borg`文件夹所在的路径（不包括borg部分），然后点击`提交位置和密码`
14. 在下拉菜单中选择最新的备份，然后点击`恢复选定的备份`
15. 等待备份恢复完成
16. 在AIO界面中启动容器

### 是否支持远程borg备份？
支持直接备份到远程borg存储库。这避免了必须存储备份的本地副本，支持append-only borg密钥以对抗勒索软件，并允许使用AIO界面管理您的备份。

一些不具备上述所有优点的替代方案：

- 将网络文件系统（如SSHFS、SMB或NFS）挂载到您在AIO中输入为备份目录的目录中
- 使用rsync或rclone将AIO在本地创建的borg备份存档同步到远程目标（确保在开始同步前正确锁定备份存档；搜索"aio-lockfile"；您可以在这里找到本地示例脚本：https://github.com/nextcloud/all-in-one#sync-local-backups-regularly-to-another-drive）
- 您可以在此处找到一个写得很好的指南，该指南使用rclone和例如BorgBase进行远程备份：https://github.com/nextcloud/all-in-one/discussions/2247
- 这里有另一个利用borgmatic和BorgBase进行远程备份的指南：https://github.com/nextcloud/all-in-one/discussions/4391
- 使用脚本和borg、borgmatic或任何其他备份工具创建自己的备份解决方案，以备份到远程目标（确保按照https://github.com/nextcloud/all-in-one#how-to-enable-automatic-updates-without-creating-a-backup-beforehand正确停止和启动AIO容器）

---

### LXC容器中备份容器的故障
如果您在LXC容器中运行AIO，您需要确保在LXC容器设置中启用了FUSE。此外，如果使用Alpine Linux作为主机操作系统，请确保通过`apk add fuse`添加fuse。否则，备份容器将无法启动，因为它需要FUSE才能工作。

---

### 如何在Windows上创建备份卷？
如AIO界面中所述，可以使用docker卷作为备份目标。在使用之前，您需要先创建它。以下是在Windows上创建一个卷的示例：
```
docker volume create ^
--driver local ^
--name nextcloud_aio_backupdir ^
-o device="/host_mnt/e/your/backup/path" ^
-o type="none" ^
-o o="bind"
```
在此示例中，它将`E:\your\backup\path`挂载到卷中，因此对于不同的位置，您需要相应地调整`/host_mnt/e/your/backup/path`。之后在AIO界面中输入`nextcloud_aio_backupdir`作为备份位置。

---

### 专业提示：备份归档访问
您可以通过以下步骤在主机上打开BorgBackup归档：<br>
（适用于Ubuntu Desktop的说明）

或者，现在有一个社区容器允许您在Web会话中访问您的备份：https://github.com/nextcloud/all-in-one/tree/main/community-containers/borgbackup-viewer。

- `START_CONTAINERS` 如果设置为 `1`，它将在脚本结束时自动启动容器，而不更新它们。由 `DAILY_BACKUP=1` 隐含。
- `CHECK_BACKUP` 如果设置为 `1`，它将开始检查 AIO 制作的所有 borg 备份的完整性。请注意，备份检查是非阻塞的，因此容器可以在检查期间保持运行。这意味着您不能同时传递 `DAILY_BACKUP=1`。检查的输出可以在容器 `nextcloud-aio-borgbackup` 的日志中找到。

一个执行备份的示例是 `sudo docker exec -it --env DAILY_BACKUP=1 nextcloud-aio-mastercontainer /daily-backup.sh`，您可以通过 cron 作业运行它或将其放入脚本中。

同样，执行备份检查的命令是 `sudo docker exec --env DAILY_BACKUP=0 --env CHECK_BACKUP=1 --env STOP_CONTAINERS=0 nextcloud-aio-mastercontainer /daily-backup.sh`。

> [!NOTE]  
> 这些选项都不返回错误代码。因此，您需要自己检查正确的结果。

### 如何禁用备份部分？
如果您已经有备份解决方案，可以隐藏备份部分。为此，您可以在主容器的 docker run 命令中添加 `--env AIO_DISABLE_BACKUP_SECTION=true`（但要放在最后一行 `ghcr.io/nextcloud-releases/all-in-one:latest` 之前！如果主容器已经启动，则需要停止主容器，删除它（不会丢失数据），然后使用您最初使用的 docker run 命令重新创建它）。

## 附加组件

### Fail2ban
您可以配置服务器使用 fail2ban 作为暴力破解保护来阻止某些 IP 地址。设置方法如下：https://docs.nextcloud.com/server/stable/admin_manual/installation/harden_server.html#setup-fail2ban。AIO 的日志路径默认为 `/var/lib/docker/volumes/nextcloud_aio_nextcloud/_data/data/nextcloud.log`。不要忘记在您的 nextcloud 监狱配置（`nextcloud.local`）中添加 `chain=DOCKER-USER`，否则即使 IP 被禁止，运行在 docker 上的 nextcloud 服务仍然可以被访问。此外，您可以更改被阻止的端口以覆盖所有 AIO 端口：默认是 `80,443,8080,8443,3478`（参见[此链接](https://github.com/nextcloud/all-in-one#explanation-of-used-ports)）。除此之外，现在有一个社区容器可以添加到 AIO 堆栈中：https://github.com/nextcloud/all-in-one/tree/main/community-containers/fail2ban

### LDAP
可以连接到现有的 LDAP 服务器。您需要确保 LDAP 服务器可以从 Nextcloud 容器访问。然后您可以启用 LDAP 应用并在 Nextcloud 中手动配置 LDAP。如果您还没有 LDAP 服务器，建议使用此 docker 容器：https://hub.docker.com/r/nitnelave/lldap。同样，请确保 Nextcloud 可以与 LDAP 服务器通信。最简单的方法是将 LDAP docker 容器添加到 docker 网络 `nextcloud-aio`。然后您可以从 Nextcloud 容器通过其名称连接到 LDAP 容器。现在有一个社区容器可以轻松地将 LLDAP 添加到 AIO：https://github.com/nextcloud/all-in-one/tree/main/community-containers/lldap

### Netdata
Netdata 允许您使用 GUI 监控服务器。您可以按照 https://learn.netdata.cloud/docs/agent/packaging/docker#create-a-new-netdata-agent-container 进行安装。除此之外，现在社区可以添加容器：https://github.com/nextcloud/all-in-one/discussions/392#discussioncomment-7133563

### USER_SQL
如果您想使用 user_sql 应用，最简单的方法是创建一个额外的数据库容器并将其添加到 docker 网络 `nextcloud-aio`。然后 Nextcloud 容器应该能够使用其名称与数据库容器通信。

### phpMyAdmin、Adminer 或 pgAdmin
可以安装其中任何一个来获取 AIO 数据库的 GUI。推荐使用 pgAdmin 容器。您可以在此处获取一些文档：https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html。要使容器连接到 aio-database，您需要将容器连接到 docker 网络 `nextcloud-aio`，并使用 `nextcloud-aio-database` 作为数据库主机，`oc_nextcloud` 作为数据库用户名，以及通过运行 `sudo docker exec nextcloud-aio-nextcloud grep dbpassword config/config.php` 获得的密码作为密码。除此之外，现在社区可以添加容器：https://github.com/nextcloud/all-in-one/discussions/3061#discussioncomment-7307045 **请注意：** 如果您没有服务器的 CLI 访问权限，现在可以通过使用此社区容器通过 Web 会话运行 docker 命令：https://github.com/nextcloud/all-in-one/tree/main/community-containers/container-management

### 邮件服务器
您可以使用以下四个推荐项目之一自行配置：[Docker Mailserver](https://github.com/docker-mailserver/docker-mailserver/#docker-mailserver)、[Mailu](https://github.com/Mailu/Mailu)、[Maddy Mail Server](https://github.com/foxcpp/maddy#maddy-mail-server)、[Mailcow](https://github.com/mailcow/mailcow-dockerized#mailcow-dockerized-------) 或 [Stalwart](https://stalw.art/)。现在有一个社区容器可以轻松地将 Stalwart 邮件服务器添加到 AIO：https://github.com/nextcloud/all-in-one/tree/main/community-containers/stalwart

## 其他

### 集成新容器的要求
对于集成新容器，它们必须通过特定要求才能被考虑集成到 AIO 本身。即使不被考虑，我们也可能添加一些关于它的文档。现在还有这个：https://github.com/nextcloud/all-in-one/tree/main/community-containers#community-containers

要求是什么？
1. 新容器必须与 Nextcloud 相关。相关意味着添加此容器必须为 Nextcloud 添加一个功能。
2. 必须可选择性安装。从 AIO 界面禁用和启用容器必须有效，并且不会产生任何意外的副作用。
3. 通过添加容器到 Nextcloud 中添加的功能必须由 Nextcloud GmbH 维护。
4. 必须能够在没有大问题的情况下在 docker 容器内运行该容器。大问题例如需要更改能力或安全选项。
5. 容器不应将主机的目录挂载到容器中：只能使用 docker 卷。
6. 该容器必须可供超过 90% 的用户使用（例如，不是过高的系统要求等）
7. 添加容器后不需要额外设置 - 它应该完全开箱即用。
8. 如果容器需要被暴露，仅支持子文件夹。因此，容器不应要求自己的（子）域名，并且必须能够在子文件夹中运行。

### 更新策略
此项目重视稳定性而非新功能。这意味着当引入新的 Nextcloud 主要更新时，我们将至少等到第一个补丁版本，例如 `24.0.1` 发布后才升级到它。此外，我们将等到所有重要的应用程序都与新的主要版本兼容后再升级。Nextcloud 和所有依赖项以及所有容器的次要或补丁版本将尽快更新到新版本，但我们尝试在推送所有更新之前先对它们进行良好的测试。这意味着新的更新可能需要大约 2 周时间才能到达 `latest` 频道。如果您想帮助测试，可以通过遵循[此文档](#how-to-switch-the-channel)切换到 `beta` 频道，这也会让您更早获得更新。

### 更新通知发送频率如何？
AIO 提供自己的更新通知实现。它检查是否有容器更新可用。如果有，它会在周六向属于 `admin` 组的 Nextcloud 用户发送标题为 `Container updates available!` 的通知。如果 Nextcloud 容器镜像应该超过 90 天（约 3 个月）并且因此严重过时，AIO 会向所有 Nextcloud 用户发送标题为 `AIO is outdated!` 的通知。因此，管理员应确保至少每 3 个月更新一次容器镜像，以确保实例尽快获得所有安全漏洞修复。

### 大型 docker 日志
如果您遇到大型 docker 日志的问题，可以按照 https://docs.docker.com/config/containers/logging/local/#usage 调整日志大小。但是，对于包含的 AIO 容器，这通常不需要，因为几乎所有容器的日志级别都设置为警告，因此它们不应产生太多日志。

```bash
# 在主机上安装borgbackup
sudo apt update && sudo apt install borgbackup

# 在任何使用borg的shell中，您必须首先导出此变量
# 如果您使用默认备份位置 /mnt/backup/borg
export BORG_REPO='/mnt/backup/borg'
# 或者如果您使用远程存储库
export BORG_REPO='user@host:/path/to/repo'

# 列出所有归档（如果您使用默认备份位置 /mnt/backup/borg）
sudo borg list

# 成功输入存储库密钥后，您现在应该看到所有备份归档的列表
# 示例备份归档可能名为 20220223_174237-nextcloud-aio
# 然后您可以简单地使用以下命令删除归档：
sudo borg delete --stats --progress "::20220223_174237-nextcloud-aio"

# 如果安装了borg 1.2.0或更高版本，则需要运行borg compact以清理释放的空间
sudo borg --version
# 如果上面命令的版本号高于1.2.0，则需要运行以下命令：
sudo borg compact

```

完成后，请确保更新AIO界面中的备份归档列表！<br>
您可以通过点击`检查备份完整性`按钮或`创建备份`按钮来完成此操作。

---

### 定期将本地备份同步到另一个驱动器
为了提高备份安全性，您可以考虑定期将本地备份存储库同步到另一个驱动器。

为此，首先将驱动器添加到`/etc/fstab`中，以便能够自动挂载，然后创建一个自动执行所有操作的脚本。以下是此类脚本的示例：

<details>
<summary>点击此处展开</summary>

```bash
#!/bin/bash

# 请根据您的需要修改下面的所有变量：
SOURCE_DIRECTORY="/mnt/backup/borg"
DRIVE_MOUNTPOINT="/mnt/backup-drive"
TARGET_DIRECTORY="/mnt/backup-drive/borg"

########################################
# 请不要修改下面的任何内容！            #
########################################

if [ "$EUID" -ne 0 ]; then 
    echo "请以root用户运行"
    exit 1
fi

if ! [ -d "$SOURCE_DIRECTORY" ]; then
    echo "源目录不存在。"
    exit 1
fi

if [ -z "$(ls -A "$SOURCE_DIRECTORY/")" ]; then
    echo "源目录为空，这是不允许的。"
    exit 1
fi

if ! [ -d "$DRIVE_MOUNTPOINT" ]; then
    echo "驱动器挂载点必须是现有目录"
    exit 1
fi

if ! grep -q "$DRIVE_MOUNTPOINT" /etc/fstab; then
    echo "在fstab文件中找不到驱动器挂载点。您是否已将其添加到那里？"
    exit 1
fi

if ! mountpoint -q "$DRIVE_MOUNTPOINT"; then
    mount "$DRIVE_MOUNTPOINT"
    if ! mountpoint -q "$DRIVE_MOUNTPOINT"; then
        echo "无法挂载驱动器。它已连接吗？"
        exit 1
    fi
fi

if [ -f "$SOURCE_DIRECTORY/lock.roster" ]; then
    echo "无法运行脚本，因为备份归档当前正在更改。请稍后再试。"
    exit 1
fi

mkdir -p "$TARGET_DIRECTORY"
if ! [ -d "$TARGET_DIRECTORY" ]; then
    echo "无法创建目标目录"
    exit 1
fi

if [ -f "$SOURCE_DIRECTORY/aio-lockfile" ]; then
    echo "由于aio-lockfile已存在，不继续执行。"
    exit 1
fi

touch "$SOURCE_DIRECTORY/aio-lockfile"

if ! rsync --stats --archive --human-readable --delete "$SOURCE_DIRECTORY/" "$TARGET_DIRECTORY"; then
    echo "无法将备份存储库同步到目标目录。"
    exit 1
fi

rm "$SOURCE_DIRECTORY/aio-lockfile"
rm "$TARGET_DIRECTORY/aio-lockfile"

umount "$DRIVE_MOUNTPOINT"

if docker ps --format "{{.Names}}" | grep "^nextcloud-aio-nextcloud$"; then
    docker exec nextcloud-aio-nextcloud bash /notify.sh "Rsync备份成功！" "成功同步了备份存储库。"
else
    echo "成功同步了备份存储库。"
fi

```

</details>

您可以简单地将脚本复制并粘贴到一个文件中，例如命名为`backup-script.sh`，例如：`/root/backup-script.sh`。不要忘记根据您的要求修改变量！

之后使用`sudo chown root:root /root/backup-script.sh`和`sudo chmod 700 /root/backup-script.sh`应用正确的权限。然后您可以创建一个cron作业，例如每周日20:00运行，如下所示：
1. 使用`sudo crontab -u root -e`打开cron作业（如果尚未选择编辑器，请选择您喜欢的编辑器。我推荐nano）。
2. 如果不存在，将以下新行添加到cron作业中：`0 20 * * 7 /root/backup-script.sh`，这将每周日20:00运行脚本。
3. 保存并关闭cron作业（使用nano时，快捷键是`Ctrl + o`然后按`Enter`，并使用`Ctrl + x`关闭编辑器）。

### 如何从备份中排除Nextcloud的数据目录或预览文件夹？
为了加快备份速度并保持备份归档较小，您可能希望从备份中排除Nextcloud的数据目录或其预览文件夹。

> [!警告]
> 但是请注意，如果数据库与数据目录或预览文件夹不同步，您将遇到问题。**因此，只有在您有数据目录的额外外部备份的情况下才继续阅读！**例如，请参阅[本指南](#how-to-enable-automatic-updates-without-creating-a-backup-beforehand)。

> [!提示]
> 更好的选择是在Nextcloud内部使用外部存储应用程序，因为通过外部存储应用程序连接的数据不会被AIO的备份解决方案备份。有关如何配置该应用程序，请参阅[此文档](https://docs.nextcloud.com/server/latest/admin_manual/configuration_files/external_storage_configuration_gui.html)。

如果您仍然想继续，可以通过简单地在指定的`NEXTCLOUD_DATADIR`目标的根目录中创建一个`.noaiobackup`文件来排除数据目录。同样的逻辑也适用于位于数据目录内部、`appdata_*/preview`文件夹内的预览文件夹。因此，如果您想排除预览文件夹，只需在那里创建一个`.noaiobackup`文件。

通过AIO界面进行恢复后，由于数据目录和数据库不同步，您可能会遇到问题。您可以通过运行`occ files:scan --all`、`occ maintenance:repair`和`occ files:scan-app-data`来修复此问题。请参阅https://github.com/nextcloud/all-in-one#how-to-run-occ-commands。如果只排除了预览文件夹，则应使用命令`occ files:scan-app-data preview`。

### 如何从外部脚本停止/启动/更新容器或触发每日备份？
> [!警告]
> 下面的脚本仅在AIO初始设置后工作。因此，您总是需要首先访问AIO界面，输入您的域名并首次启动容器，或者从其borg备份恢复旧的AIO实例，然后才能使用该脚本。

您可以通过运行存储在主容器中的`/daily-backup.sh`脚本来实现这一点。它接受以下环境变量：
- `AUTOMATIC_UPDATES`如果设置为`1`，它将自动停止容器，更新它们并启动它们，包括主容器。如果主容器得到更新，此脚本的执行将在主容器停止后立即停止。然后您可以等待它再次启动，并再次使用此标志运行脚本，以便之后正确更新所有容器。
- `DAILY_BACKUP`如果设置为`1`，它将自动停止容器并创建备份。如果您想之后再次启动它们，您可以查看`START_CONTAINERS`选项。
- `STOP_CONTAINERS`如果设置为`1`，它将在脚本开始时自动停止容器。由`DAILY_BACKUP=1`隐含。

```bash
# 在主机上安装borgbackup
sudo apt update && sudo apt install borgbackup

# 在任何使用borg的shell中，您必须首先导出此变量
# 如果您使用默认备份位置 /mnt/backup/borg
export BORG_REPO='/mnt/backup/borg'
# 或者如果您使用远程存储库
export BORG_REPO='user@host:/path/to/repo'

# 将归档挂载到 /tmp/borg
sudo mkdir -p /tmp/borg && sudo borg mount "$BORG_REPO" /tmp/borg

# 成功输入存储库密钥后，您应该能够访问/tmp/borg中的所有归档
# 现在您可以做任何您想做的事情，例如使用rsync将它们同步到不同的地方或做其他事情
# 例如，您可以通过运行以下命令在该位置打开文件管理器：
xhost +si:localuser:root && sudo nautilus /tmp/borg

# 完成后，只需关闭文件管理器并运行以下命令卸载备份归档：
sudo umount /tmp/borg
```

---

### 手动删除备份归档
您可以通过以下步骤在主机上手动删除BorgBackup归档：<br>
（适用于基于Debian的操作系统如Ubuntu的说明）

或者，现在有一个社区容器允许您在Web会话中访问您的备份：https://github.com/nextcloud/all-in-one/tree/main/community-containers/borgbackup-viewer。
