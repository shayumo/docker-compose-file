# Nextcloud All-in-One (AIO)

<p align="center">
<a href="https://github.com/nextcloud/all-in-one/actions/workflows/build-images.yml"><img src="https://github.com/nextcloud/all-in-one/actions/workflows/build-images.yml/badge.svg" alt="Build Status"></a>
<a href="https://nextcloud.com"><img src="https://img.shields.io/badge/Nextcloud-%230082c9.svg?style=flat&logo=Nextcloud&logoColor=white" alt="Nextcloud"></a>
<a href="https://hub.docker.com/r/nextcloud/aio-mastercontainer"><img src="https://img.shields.io/docker/pulls/nextcloud/aio-mastercontainer.svg" alt="Docker Pulls"></a>
<a href="https://github.com/nextcloud/all-in-one/discussions"><img src="https://img.shields.io/github/discussions/nextcloud/all-in-one.svg" alt="GitHub Discussions"></a>
<a href="https://github.com/nextcloud/all-in-one/stargazers"><img src="https://img.shields.io/github/stars/nextcloud/all-in-one.svg" alt="GitHub Stars"></a>
</p>

这个项目将Nextcloud服务器及其所有功能（如Office、Talk、Contacts、Calendar等）打包在一个易于部署和维护的容器中。

## 🚀 特点

- **完整的Nextcloud体验**：包含Nextcloud核心、高性能文件后端、Office、Talk、Contacts、Calendar等
- **简易安装和维护**：仅需一个命令即可部署整个Nextcloud生态系统
- **自动更新**：一键更新所有容器、Nextcloud和应用
- **备份功能**：完整的备份和恢复解决方案
- **安全**：包含HTTPS证书自动生成和更新
- **用户友好界面**：通过Web界面管理您的整个Nextcloud实例

## 📋 系统要求

- **操作系统**：Linux（推荐Ubuntu 22.04或更高版本）、macOS或Windows（通过Docker Desktop）
- **Docker**：必须安装Docker（[安装指南](https://docs.docker.com/engine/install/)）
- **资源**：至少2GB RAM（推荐4GB或更多）和2个CPU核心（推荐4个或更多）
- **存储**：至少20GB可用空间（根据用户数量和数据量可能需要更多）
- **网络**：需要开放的端口：80、443、8080、8443和3478（TCP和UDP）

## 🔧 初始安装

### 1. 安装Docker

如果尚未安装Docker，请按照官方文档安装：https://docs.docker.com/engine/install/

### 2. 启动主容器

在Linux上，运行以下命令启动主容器：

```bash
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

### 3. 访问AIO界面

容器启动后，您可以通过以下方式访问AIO界面：

- **使用自签名证书**：https://服务器IP地址:8080（首次访问时需要接受自签名证书）
- **使用有效证书**：如果您已将域名指向服务器，请访问https://您的域名:8443

### 4. 完成安装

在AIO界面中，按照以下步骤操作：

1. 输入您的域名（例如：cloud.yourdomain.com）
2. 选择要启用的功能（如Talk、Office等）
3. 点击"启动容器"按钮
4. 等待所有容器启动完成
5. 访问您的Nextcloud实例（https://您的域名）

## 🌐 网络

### 反向代理支持

Nextcloud AIO支持各种反向代理解决方案。请参阅[reverse-proxy.md](https://github.com/nextcloud/all-in-one/blob/main/reverse-proxy.md)获取详细配置指南。

### 必要开放的端口

在防火墙/路由器中，以下端口需要开放：
- `443/TCP`：用于Apache容器
- `443/UDP`：如果要为Apache容器启用http3
- `3478/TCP`和`3478/UDP`：用于Talk容器

### 使用的端口说明

- `8080/TCP`：带有自签名证书的主容器界面（始终可用，即使只能通过IP地址访问）
- `80/TCP`：重定向到Nextcloud（用于通过ACME http-challenge获取主容器的证书）
- `8443/TCP`：带有有效证书的主容器界面（仅在端口80和8443在防火墙/路由器中开放/转发并且您将域名指向服务器时可用）
- `443/TCP`：稍后将由Apache容器使用，需要在防火墙/路由器中开放/转发
- `443/UDP`：稍后将由Apache容器使用，如果要启用http3，则需要在防火墙/路由器中开放/转发
- `3478/TCP`和`3478/UDP`：将由Talk容器内的Turnserver使用，需要在防火墙/路由器中开放/转发

## 🛠️ 自定义配置

### 如何更改Nextcloud数据目录的默认位置

您可以通过在主容器的docker run命令中添加环境变量`NEXTCLOUD_DATADIR`来配置Nextcloud容器使用主机上的特定目录作为数据目录。例如：

```bash
--env NEXTCLOUD_DATADIR="/mnt/ncdata"
```

### 如何允许Nextcloud容器访问主机上的目录

默认情况下，Nextcloud容器是受限的，无法访问主机OS上的目录。您可以通过在主容器的docker run命令中添加环境变量`NEXTCLOUD_MOUNT`来更改此设置。例如：

```bash
--env NEXTCLOUD_MOUNT="/mnt/"
```

### 如何调整Talk端口

默认情况下，talk容器使用端口`3478/UDP`和`3478/TCP`进行连接。您可以通过添加例如`--env TALK_PORT=3478`到主容器的docker run命令来调整端口。

### 如何调整Nextcloud的上传限制

默认情况下，Nextcloud的公共上传限制为最大16G。您可以通过在主容器的docker run命令中提供`--env NEXTCLOUD_UPLOAD_LIMIT=16G`来调整上传限制。

## 💾 备份

Nextcloud AIO提供基于[BorgBackup](https://github.com/borgbackup/borg#what-is-borgbackup)的备份解决方案。这些备份作为安装损坏时的还原点。使用此工具，备份是增量的、差异的、压缩的和加密的 - 因此只有第一次备份会花费较长时间。后续备份应该很快，因为只考虑更改。

建议在任何容器更新之前创建备份。这样，您将对更新期间可能出现的任何并发症感到安全，因为您将能够通过基本一键还原整个实例。

对于本地备份，还原过程应该相当快，因为使用rsync来还原所选备份，rsync仅传输更改的文件并删除额外的文件。对于远程borg备份，整个备份存档从远程提取，这取决于`borg extract`的智能程度，可能需要下载整个存档。

您可以在AIO界面中使用`创建备份`和`还原选定的备份`按钮来创建和还原备份。此外，还提供了备份检查，用于检查备份的完整性，但在大多数情况下不需要。

备份本身使用在AIO界面中显示给您的加密密钥进行加密。请将其保存在安全的地方，因为没有此密钥您将无法从备份还原。

初始备份完成后，可以启用每日备份。启用此功能还允许启用一个选项，该选项允许自动更新所有容器、Nextcloud及其应用。

## 🔄 更新

如果我们推送新容器到`latest`，您将在AIO界面的`容器`部分下方看到发现了新的容器更新。在这种情况下，只需按`停止容器`和`启动并更新容器`以更新容器。主容器有自己的更新过程。请参见下文。并且在再次启动容器之前，不要忘记使用内置备份解决方案备份实例的当前状态！否则，如果更新期间出现问题，您将无法轻松还原实例。

如果发现新的`主容器`更新，您将在`停止容器`按钮下方看到一条注释，允许显示更改日志。如果您点击该按钮并且容器已停止，您将看到一个新按钮，允许更新主容器。完成后，更新完成，您将再次获得`启动并更新容器`的选项。建议在点击`启动并更新容器`按钮之前创建备份。

此外，每天运行一次cronjob，检查容器和主容器更新，并在发现新更新时向所有Nextcloud管理员发送通知。

## 🔧 常用命令

### 如何运行`occ`命令

只需运行以下命令：`sudo docker exec --user www-data -it nextcloud-aio-nextcloud php occ 您的命令`。当然，`您的命令`需要替换为您要运行的命令。

### 如何解决初始安装后"安全与设置警告显示缺少默认电话区域"的问题

只需运行以下命令：`sudo docker exec --user www-data nextcloud-aio-nextcloud php occ config:system:set default_phone_region --value="您的值"`。当然，您需要根据您的位置修改`您的值`。例如`DE`、`US`和`GB`。

### 如何切换通道

您可以通过停止主容器、移除它（不会丢失数据）并使用与最初创建主容器时相同的命令重新创建容器来切换到不同的通道，例如beta通道或从beta通道切换回latest通道。您只需将最后一行`ghcr.io/nextcloud-releases/all-in-one:latest`更改为`ghcr.io/nextcloud-releases/all-in-one:beta`，反之亦然。

## 🔌 附加组件

### Fail2ban

您可以配置服务器使用fail2ban作为暴力破解保护来阻止某些ip地址。以下是设置方法：https://docs.nextcloud.com/server/stable/admin_manual/installation/harden_server.html#setup-fail2ban。AIO的日志路径默认为`/var/lib/docker/volumes/nextcloud_aio_nextcloud/_data/data/nextcloud.log`。不要忘记将`chain=DOCKER-USER`添加到您的nextcloud jail配置（`nextcloud.local`）中，否则即使IP被禁止，运行在docker上的nextcloud服务仍然可以访问。

### LDAP

可以连接到现有的LDAP服务器。您需要确保LDAP服务器可以从Nextcloud容器访问。然后，您可以启用LDAP应用并在Nextcloud中手动配置LDAP。如果您还没有LDAP服务器，建议使用这个docker容器：https://hub.docker.com/r/nitnelave/lldap。同样，确保Nextcloud可以与LDAP服务器通信。最简单的方法是将LDAP docker容器添加到docker网络`nextcloud-aio`。然后，您可以通过名称从Nextcloud容器连接到LDAP容器。

### 邮件服务器

您可以通过使用以下四个推荐项目之一来配置自己的邮件服务器：[Docker Mailserver](https://github.com/docker-mailserver/docker-mailserver/#docker-mailserver)、[Mailu](https://github.com/Mailu/Mailu)、[Maddy Mail Server](https://github.com/foxcpp/maddy#maddy-mail-server)、[Mailcow](https://github.com/mailcow/mailcow-dockerized#mailcow-dockerized-------)或[Stalwart](https://stalw.art/)。

## 📚 附加文档

- [reverse-proxy.md](https://github.com/nextcloud/all-in-one/blob/main/reverse-proxy.md)：如何在反向代理后面运行AIO
- [migration.md](https://github.com/nextcloud/all-in-one/blob/main/migration.md)：如何从现有Nextcloud安装迁移到Nextcloud AIO
- [local-instance.md](https://github.com/nextcloud/all-in-one/blob/main/local-instance.md)：如何在本地运行Nextcloud（不需要域名）
- [docker-rootless.md](https://github.com/nextcloud/all-in-one/blob/main/docker-rootless.md)：如何使用Docker rootless运行AIO
- [multiple-instances.md](https://github.com/nextcloud/all-in-one/blob/main/multiple-instances.md)：如何在一台服务器上运行多个AIO实例
- [docker-ipv6-support.md](https://github.com/nextcloud/all-in-one/blob/main/docker-ipv6-support.md)：如何启用IPv6支持
- [manual-upgrade.md](https://github.com/nextcloud/all-in-one/blob/main/manual-upgrade.md)：如何手动升级AIO容器

## ❓ 常见问题

### 我在哪里可以找到其他文档？

部分文档可在[GitHub Discussions](https://github.com/nextcloud/all-in-one/discussions/categories/wiki)上找到。

### 它是如何工作的？

Nextcloud AIO的灵感来自于像Portainer这样的项目，这些项目通过直接与docker套接字通信来管理docker守护程序。这个概念允许用户仅通过一个命令安装一个容器，该容器完成创建和管理提供包含大多数功能的Nextcloud安装所需的所有容器的繁重工作。它还使更新变得轻松，并且不再受限于主机系统（及其缓慢的更新），因为一切都在容器中。此外，从用户角度来看，它非常容易处理，因为提供了一个简单的界面来管理您的Nextcloud AIO安装。

### 如何贡献？

请参阅[这个问题](https://github.com/nextcloud/all-in-one/issues/5251)了解需要贡献者帮助的功能请求列表。

### 最多可以有多少用户？

最多100个用户是免费的，更多用户可以通过[Nextcloud Enterprise](https://nextcloud.com/all-in-one/)获得。

### 可以在macOS上运行AIO吗？

在macOS上，与Linux相比只有一件事不同：您需要使用`--volume /var/run/docker.sock.raw:/var/run/docker.sock:ro`而不是`--volume /var/run/docker.sock:/var/run/docker.sock:ro`来运行它，在安装[Docker Desktop](https://www.docker.com/products/docker-desktop/)之后（如果需要，不要忘记[启用ipv6](https://github.com/nextcloud/all-in-one/blob/main/docker-ipv6-support.md)）。除此之外，它应该像在Linux上一样工作和运行。

### 可以在Windows上运行AIO吗？

在Windows上，安装[Docker Desktop](https://www.docker.com/products/docker-desktop/)（如果需要，不要忘记[启用ipv6](https://github.com/nextcloud/all-in-one/blob/main/docker-ipv6-support.md)）并在命令提示符中运行以下命令：

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

### 可以在Synology DSM上运行AIO吗？

在Synology上，与Linux相比有两件事不同：您需要使用`--volume /volume1/docker/docker.sock:/var/run/docker.sock:ro`而不是`--volume /var/run/docker.sock:/var/run/docker.sock:ro`来运行它。您还需要将`--env WATCHTOWER_DOCKER_SOCKET_PATH="/volume1/docker/docker.sock"`添加到主容器的docker run命令中（在最后一行`ghcr.io/nextcloud-releases/all-in-one:latest`之前）。除此之外，它应该像在Linux上一样工作和运行。显然，Synology Docker GUI不适用于此，因此您需要使用SSH或在任务计划程序中以'root'用户身份创建用户定义的脚本任务来运行命令。

### 如何更改域名？

目前无法从AIO界面更改域名。要更改它，您需要使用`sudo docker run -it --rm --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config:rw alpine sh -c "apk add --no-cache nano && nano /mnt/docker-aio-config/data/configuration.json"`手动编辑configuration.json，将旧域名的每次出现替换为新域名，然后保存和写出文件。之后从AIO界面重新启动容器，如果新域名配置正确，一切应该按预期工作。

如果您在Web服务器或反向代理（如Apache、Nginx、Caddy、Cloudflare Tunnel等）后面运行AIO，您显然还需要在反向代理配置中更改域名。

## 🛡️ 安全提示

- **定期更新**：确保定期更新所有容器和Nextcloud应用
- **备份**：定期创建备份并将其存储在安全的位置
- **强密码**：为所有用户使用强密码
- **双因素认证**：启用双因素认证以提高安全性
- **限制访问**：如果可能，限制对Nextcloud实例的访问

## 📝 免责声明

Nextcloud AIO是一个社区驱动的项目，不提供官方支持。如果您需要商业支持，请考虑升级到[Nextcloud Enterprise](https://nextcloud.com/enterprise/)。

## 🤝 贡献

我们欢迎社区贡献！如果您有想法或改进，请在[GitHub](https://github.com/nextcloud/all-in-one)上创建问题或提交拉取请求。

## 📄 许可证

Nextcloud AIO在MIT许可证下发布。有关详细信息，请参阅[LICENSE](https://github.com/nextcloud/all-in-one/blob/main/LICENSE)文件。