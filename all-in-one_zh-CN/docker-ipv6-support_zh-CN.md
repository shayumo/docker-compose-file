# Docker IPv6支持

## Linux上的Docker和Docker-rootless
首先，将您的Docker安装升级到v27.0.1或更高版本。
1. 然后编辑`/etc/docker/daemon.json`（对于docker-rootless，编辑`~/.config/docker/daemon.json`），添加以下JSON：

> [!警告]
> 这将默认启用所有新Docker网络的IPv6支持！您也可以通过docker network create命令或compose.yaml手动创建支持IPv6的`nextcloud-aio`网络。

```json
{
    "default-network-opts": {"bridge":{"com.docker.network.enable_ipv6":"true"}}
}
```

保存文件。

2. 重新加载Docker配置文件。

```console
sudo systemctl restart docker
```

3. 通过运行`sudo docker network inspect nextcloud-aio | grep EnableIPv6`确保内部`nextcloud-aio`网络已启用IPv6。对于新实例，此命令应该返回未找到此名称的网络。然后您可以运行`sudo docker network create nextcloud-aio`来创建支持IPv6的网络。但是，如果它找到了网络并且其`EnableIPv6`值设置为false，请确保按照 https://github.com/nextcloud/all-in-one/discussions/4989 重新创建网络并为其启用IPv6。

## Docker Desktop（Windows和macOS）
首先，将您的Docker Desktop安装升级到v4.32.0或更高版本。
然后，在使用Docker Desktop的Windows和macOS上，您需要进入设置，选择`Docker Engine`。您应该会看到当前使用的daemon.json文件。

1. 现在您需要调整此json文件：

> [!警告]
> 这将默认启用所有新Docker网络的IPv6支持！您也可以通过docker network create命令或compose.yaml手动创建支持IPv6的`nextcloud-aio`网络。

```json
"default-network-opts": {"bridge":{"com.docker.network.enable_ipv6":"true"}}
```

2. 将这些值添加到json中，并确保保留其他当前值，并且在点击`Apply & restart`重新启动之前没有看到`Unexpected token in JSON at position ...`错误。
3. 通过运行`sudo docker network inspect nextcloud-aio | grep EnableIPv6`确保内部`nextcloud-aio`网络已启用IPv6。对于新实例，此命令应该返回未找到此名称的网络。然后您可以运行`sudo docker network create nextcloud-aio`来创建支持IPv6的网络。但是，如果它找到了网络并且其`EnableIPv6`值设置为false，请确保按照 https://github.com/nextcloud/all-in-one/discussions/4989 重新创建网络并为其启用IPv6。

---

**注意**：这是原始Docker文档的副本，位于 https://docs.docker.com/config/daemon/ipv6/，该文档似乎不正确。