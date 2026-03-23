# 本地实例
由于多种原因，您可能不希望或无法将Nextcloud开放到公共互联网。也许您希望直接通过`ip.add.r.ess`访问AIO（不支持）或不使用有效的域名。但是，AIO需要有效的证书才能正常工作。下面讨论如何同时实现这两点：为Nextcloud提供有效的证书并仅在本地使用它。

### 目录
- [1. Tailscale](#1-tailscale)
- [2. 常规方法](#2-常规方法)
- [3. 使用ACME DNS-challenge](#3-使用acme-dns-challenge)
- [4. 使用Cloudflare](#4-使用cloudflare)
- [5. 购买证书并使用](#5-购买证书并使用)

## 1. Tailscale
这是推荐的方法。有关Tailscale的反向代理示例指南，请参阅[@Perseus333](https://github.com/Perseus333)的指南：https://github.com/nextcloud/all-in-one/discussions/6817

## 2. 常规方法
常规方法如下：
1. 正确设置您的域名指向您的家庭网络
2. 按照[反向代理文档](./reverse-proxy.md)设置反向代理，但只开放端口80（这是ACME挑战工作所必需的 - 但没有实际流量会使用此端口）。
3. 设置本地DNS服务器（如pi-hole）并将其配置为整个网络的本地DNS服务器。然后在Pi-hole界面中，为您的域名添加自定义DNS记录，并覆盖A记录（可能还有AAAA记录）以指向反向代理的私有IP地址（请参阅https://github.com/nextcloud/all-in-one#how-can-i-access-nextcloud-locally）
4. 在docker的daemon.json文件中输入本地DNS服务器的IP地址，以确保所有docker容器都使用正确的本地DNS服务器。
5. 现在，在AIO界面中输入域名应该可以正常工作，并允许您继续设置

**提示**：您可以查看[这个视频](https://youtu.be/zk-y2wVkY4c)获取更完整但可能已过时的示例。

## 3. 使用ACME DNS-challenge
您也可以使用ACME DNS-challenge为Nextcloud获取有效证书。以下是如何设置它：https://github.com/nextcloud/all-in-one#how-to-get-nextcloud-running-using-the-acme-dns-challenge

## 4. 使用Cloudflare
如果您对网络没有任何控制权，您可以考虑使用Cloudflare Tunnel为您的Nextcloud获取有效证书。但是，这样它将对公共互联网开放。请参阅https://github.com/nextcloud/all-in-one#how-to-run-nextcloud-behind-a-cloudflare-tunnel了解如何设置。

## 5. 购买证书并使用
如果上述方法都不适合您，您可以简单地从证书颁发机构为您的域名购买证书。然后将证书下载到您的服务器上，在[反向代理模式](./reverse-proxy.md)下配置AIO，并在反向代理配置中为您的域名使用该证书。