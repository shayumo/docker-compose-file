# 社区容器
此目录包含为AIO构建的容器，这些容器允许非常轻松地添加额外功能。

## 免责声明
此目录中的所有容器均由社区维护，因此保持它们更新和安全的责任在于社区。不能保证将来也是如此。

## 如何使用？
从AIO的v11版本开始，社区容器的管理通过AIO界面完成（它是AIO界面中的最后一个部分，因此只有向下滚动才能看到）。
⚠️⚠️⚠️ 在添加每个容器之前，请查看文件夹中的文档！不首先查看每个容器的文档可能会导致无法启动AIO容器，例如fail2ban仅适用于Linux而不适用于Docker Desktop！**提示：** 如果容器已经在运行，为了实际启动添加的容器，您需要点击`停止容器`，然后点击`更新并启动容器`才能实际启动它。

## 如何添加容器？
只需通过在此目录中创建一个新文件夹来提交PR：https://github.com/nextcloud/all-in-one/tree/main/community-containers，文件夹名称即为您的容器名称。它必须包含一个具有相同名称且语法正确的json文件，以及一个包含附加信息的readme.md文件。您可以从caddy、fail2ban、local-ai、libretranslate、plex、pi-hole或vaultwarden（此目录中的子文件夹）中获得灵感。有关json文件的完整示例，请参见https://github.com/nextcloud/all-in-one/blob/main/php/containers.json。它所验证的json模式可以在此处找到：https://github.com/nextcloud/all-in-one/blob/main/php/containers-schema.json。

### 是否有新社区容器的创意列表？
是的，请参见[此列表](https://github.com/nextcloud/all-in-one/issues/5251)，其中包含已有的新社区容器创意。请随时选择一个，并按照上述说明将其添加到此文件夹中。

## 如何从AIO堆栈中删除容器？
您现在可以通过Web界面删除容器。

删除容器后，服务器上可能会留下一些您可能想要删除的数据。您可以通过首先运行`sudo docker rm nextcloud-aio-container1`（相应地调整`container1`）来删除您删除的每个社区容器的数据。然后运行`sudo docker image prune -a`以删除所有不再使用的镜像。最后，您可以删除存储在卷中的这些容器的持久数据。您可以通过运行`sudo docker volume ls`来检查是否有这样的卷，并查找与您删除的卷匹配的任何卷。如果有，您可以使用`sudo docker volume rm nextcloud_aio_volume-id`来删除它们（当然，您需要调整`volume-id`）。**请注意：** 如果您没有服务器的CLI访问权限，您现在可以通过使用这个社区容器通过Web会话运行docker命令：https://github.com/nextcloud/all-in-one/tree/main/community-containers/container-management