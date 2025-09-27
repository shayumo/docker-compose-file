# Docker rootless

**请注意**：由于Collabora中的一个bug，目前Collabora容器在rootless模式下无法正常工作。请参阅 https://github.com/CollaboraOnline/online/issues/2800。在这种情况下，如果您想使用此功能，需要自己运行一个单独的Collabora实例。以下标志将很有用 https://github.com/nextcloud/all-in-one#how-to-keep-disabled-apps。

您可以按照以下步骤在docker rootless模式下运行AIO。

0. 如果已经安装了docker，您应该考虑先禁用它：(`sudo systemctl disable --now docker.service docker.socket`)
1. 按照官方文档安装docker rootless：https://docs.docker.com/engine/security/rootless/#install。最简单的方法是**不使用包管理器**进行安装(`curl -fsSL https://get.docker.com/rootless | sh`)。同一网站上还讨论了其他限制、特定发行版的提示等。另外，不要忘记启用systemd服务，它默认可能不会一直启用。请参阅 https://docs.docker.com/engine/security/rootless/#usage。(`systemctl --user enable docker`)
2. 如果您需要ipv6支持，应该按照 https://github.com/nextcloud/all-in-one/blob/main/docker-ipv6-support.md 启用它。
3. 不要忘记设置提到的环境变量`PATH`和`DOCKER_HOST`，最好按照所示将它们添加到您的`~/.bashrc`文件中！
4. 也不要忘记运行`loginctl enable-linger USERNAME`（并将USERNAME替换为正确的用户名），以确保用户服务在每次重启后自动启动。
5. 按照 https://docs.docker.com/engine/security/rootless/#exposing-privileged-ports 暴露特权端口。(`sudo setcap cap_net_bind_service=ep $(which rootlesskit); systemctl --user restart docker`)。如果您需要正确的源IP，必须通过`/etc/sysctl.conf`暴露它们，[请参见下面的注释](#note-regarding-docker-network-driver)。
6. 使用官方的AIO启动命令，但使用`--volume $XDG_RUNTIME_DIR/docker.sock:/var/run/docker.sock:ro`代替`--volume /var/run/docker.sock:/var/run/docker.sock:ro`，并在初始容器启动时添加`--env WATCHTOWER_DOCKER_SOCKET_PATH=$XDG_RUNTIME_DIR/docker.sock`（这对于mastercontainer更新正常工作是必需的）。当您使用Portainer部署AIO时，变量`$XDG_RUNTIME_DIR`不可用。在这种情况下，必须手动将路径（例如`/run/user/1000/docker.sock`）添加到Docker compose文件中，以替换`$XDG_RUNTIME_DIR`变量。如果您不确定如何获取路径，可以在主机上运行：`echo $XDG_RUNTIME_DIR`。
7. 现在一切应该像没有docker rootless一样工作。您可以考虑使用docker-compose或在反向代理后面运行它。基本上，在安装docker rootless后，始终需要在启动命令或compose.yaml文件中调整的只有第3点中提到的内容。
8. ⚠️ **重要**：请通读下面的所有注释！

### 关于文档中的sudo的注释
此项目文档中的几乎所有命令都使用`sudo docker ...`。由于在docker rootless情况下不需要`sudo`，您只需从命令中删除`sudo`，它们应该就能工作。

### 关于权限的注释
容器外的所有文件都会以运行docker守护程序的用户或其子uid创建、写入和访问。因此，为了内置备份正常工作，您需要允许该用户写入目标目录。例如，使用`sudo chown -R USERNAME:GROUPNAME /mnt/backup`。同样适用于通过NEXTCLOUD_DATADIR更改Nextcloud的数据目录。例如，`sudo chown -R USERNAME:GROUPNAME /mnt/ncdata`。当您想使用NEXTCLOUD_MOUNT选项进行本地外部存储时，您需要调整所选文件夹的权限，使其可被用户ID `100032:100032`访问/写入（如果作为运行docker守护程序的用户运行`grep ^$(whoami): /etc/subuid`返回100000作为第一个值）。


### 关于docker网络驱动程序的注释
默认情况下，rootless docker使用`slirp4netns` IP驱动程序和`builtin`端口驱动程序。正如[文档](https://docs.docker.com/engine/security/rootless/#networking-errors)中提到的，这种组合不提供"源IP传播"。这意味着Apache和Nextcloud将看到所有连接都来自docker网关（例如172.19.0.1），这可能导致Nextcloud暴力破解保护阻止所有连接尝试。要公开正确的源IP，您需要配置docker也使用`slirp4netns`作为端口驱动程序（另请参阅[本指南](https://rootlesscontaine.rs/getting-started/docker/#changing-the-port-forwarder)）。
如文档中所述，此更改可能会导致网络吞吐量下降。您应该在完成设置后尝试传输大文件来测试这一点，如果吞吐量太慢，则恢复为`builtin`端口驱动程序。
* 将`net.ipv4.ip_unprivileged_port_start=80`添加到`/etc/sysctl.conf`。编辑此文件需要root权限。（使用功能在这里不起作用；请参见[此问题](https://github.com/rootless-containers/slirp4netns/issues/251#issuecomment-761415404)）。
* 运行`sudo sysctl --system`传播更改。
* 创建`~/.config/systemd/user/docker.service.d/override.conf`
  内容如下：
  ```
  [Service]
  Environment="DOCKERD_ROOTLESS_ROOTLESSKIT_NET=slirp4netns"
  Environment="DOCKERD_ROOTLESS_ROOTLESSKIT_PORT_DRIVER=slirp4netns"
  ```
* 重启docker守护程序
  ```
  systemctl --user restart docker
  ```