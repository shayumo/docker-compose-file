# 手动升级

如果您长时间不更新Nextcloud AIO（6个月以上），当您最终在AIO界面中更新时，您会发现Nextcloud不再工作。这是由于nextcloud容器内的PHP版本不兼容造成的。
不幸的是，如果您长期不升级，从维护者的角度来看，无法修复这个问题。

您这边解决此问题的唯一方法是定期升级（例如，通过启用每日备份，这也会自动升级所有容器），并按照以下步骤恢复到正常状态：

---

## 方法1：使用`assaflavie/runlike`

> [!警告]
> 请注意，此方法目前显然已损坏。请参阅https://help.nextcloud.com/t/manual-upgrade-keeps-failing/217164/10
> 因此，请参考方法2：使用Portainer。

1. 从AIO界面启动所有容器
    - 现在，它会报告Nextcloud正在重启，因为由于上述问题它无法启动
    - #### 不要点击`停止容器`，因为您需要它们继续运行，详见下文
2. 通过运行`sudo docker exec nextcloud-aio-nextcloud cat lib/versioncheck.php`找出您安装的Nextcloud兼容的PHP版本。
    - 在那里您会找到有关最大支持的PHP版本的信息
    - **记住这个信息**
3. 通过运行以下命令停止Nextcloud容器和Apache容器：
    ```bash
        sudo docker stop nextcloud-aio-nextcloud && sudo docker stop nextcloud-aio-apache
    ```
4. 运行以下命令以逆向工程Nextcloud容器：
    ```bash
        sudo docker pull assaflavie/runlike
        echo '#!/bin/bash' > /tmp/nextcloud-aio-nextcloud
        sudo docker run --rm -v /var/run/docker.sock:/var/run/docker.sock assaflavie/runlike -p nextcloud-aio-nextcloud >> /tmp/nextcloud-aio-nextcloud
        sudo chown root:root /tmp/nextcloud-aio-nextcloud
    ```
5. 现在用文本编辑器打开`/tmp/nextcloud-aio-nextcloud`，并编辑容器标签：

| 要更改的内容                              | 替换为                                        |
|----------------------------------------|-----------------------------------------------------|
| `ghcr.io/nextcloud-releases/aio-nextcloud:latest`       | `ghcr.io/nextcloud-releases/aio-nextcloud:php{version}-latest`       |
| `ghcr.io/nextcloud-releases/aio-nextcloud:latest-arm64` | `ghcr.io/nextcloud-releases/aio-nextcloud:php{version}-latest-arm64` |


 - 例如：`ghcr.io/nextcloud-releases/aio-nextcloud:php8.0-latest` 或 `ghcr.io/nextcloud-releases/aio-nextcloud:php8.0-latest-arm64`
 - 但是，如果您不确定，请检查ghcr.io（https://github.com/nextcloud-releases/all-in-one/pkgs/container/aio-nextcloud/versions?filters%5Bversion_type%5D=tagged）和docker hub：https://hub.docker.com/r/nextcloud/aio-nextcloud/tags?name=php
 - 使用nano和方向键导航：
  - `sudo nano /tmp/nextcloud-aio-nextcloud` 进行上述更改，然后按 `[Ctrl]+[o]` -> `[Enter]` 和 `[Ctrl]+[x]` 保存并退出。
6. 接下来，停止并删除当前容器：
    ```bash
        sudo docker stop nextcloud-aio-nextcloud
        sudo docker rm nextcloud-aio-nextcloud
    ```
7. 现在通过简单地运行`sudo bash /tmp/nextcloud-aio-nextcloud`来启动带有新标签的Nextcloud容器，这应该会在启动时自动将Nextcloud升级到更新的版本。如果没有，请确保Nextcloud数据目录中没有`skip.update`文件。如果有这样的文件，只需删除该文件并再次重启容器。<br>
**信息**：您可以使用`sudo docker logs -f nextcloud-aio-nextcloud`打开Nextcloud容器日志。
8. Nextcloud容器启动后（您可以通过查看日志来判断），只需使用`sudo docker restart nextcloud-aio-nextcloud`再次重启容器，直到它在容器启动时不再安装新的Nextcloud更新。
9. 现在，您应该能够再次使用AIO界面，只需停止AIO容器并再次启动它们，这最终应该会再次启动您的实例。
10. 如果没有，并且您再次遇到相同的错误，您可以从开头重复该过程，直到您的Nextcloud版本最终更新到最新版本。
11. 现在，如果一切最终恢复正常运行，建议创建备份以保存当前状态。如果定期升级对您来说很麻烦，请考虑启用每日备份。

---

## 方法2：使用Portainer
#### *如果方法1对您不起作用，可以使用portainer* 

先决条件：AIO界面中的所有容器都在运行。

##### 1. 如果未安装portainer，请安装：
```bash
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
```
- 如果您有反向代理
    - 您可以使用域名设置和导航。
- 对于**标准**AIO安装
    - 在防火墙中打开端口9443
    - 导航到`https://<server-ip>:9443`
- 接受不安全的自签名证书并设置管理员密码
- 如果提示添加环境
    - 添加local

##### 2. 在本地portainer环境中，导航到**containers**选项卡
- 在这里您应该能看到所有运行中的各种容器

##### 3. 现在我们需要停止`nextcloud-aio-nextcloud`和`nextcloud-aio-apache`容器

- 这可以通过选中容器名称旁边的复选框并点击顶部的**Stop**按钮来完成
    - 或者您可以点击进入各个容器并在那里停止它们

##### 4. 找出与运行中的nextcloud容器兼容的PHP版本
- 导航到```nextcloud-aio-nextcloud```并点击```logs```，您应该会看到类似以下内容：
```logs
This version of nextcloud is not compatible with >=php 8.2, you are currently running php 8.2.18
```
记录下兼容的版本，四舍五入到小数点后1位。
 - 在这个例子中，我们需要php 8.1，因为8.2或更高版本不兼容

##### 5. 找到正确的容器版本
一般来说，它应该是```ghcr.io/nextcloud-releases/aio-nextcloud:php8.x-latest-arm64```或`ghcr.io/nextcloud-releases/aio-nextcloud:php8.x-latest`，将`x`替换为您需要的版本。
但是，如果您不确定，请检查ghcr.io（https://github.com/nextcloud-releases/all-in-one/pkgs/container/aio-nextcloud/versions?filters%5Bversion_type%5D=tagged）和docker hub：https://hub.docker.com/r/nextcloud/aio-nextcloud/tags?name=php

##### 6. 替换容器
- 在portainer中导航到```nextcloud-aio-nextcloud```容器
- 点击```Duplicate/Edit```
- 在image中，将其更改为步骤5中的正确版本
- 点击```Deploy the container```
    - 如果提示强制重新拉取镜像，请点击滑块并按pull image

*导航到nextcloud-aio-nextcloud日志，您将看到容器正在更新*

一旦您在日志中看不到更多活动或看到类似```NOTICE: ready to handle connections```的消息，我们就完成了！

#### 现在您可以通过AIO管理界面处理所有事情，并正常停止和重启容器。

---

##### 7. 最后一步是如果您不想保留portainer，就删除它

```bash
docker stop portainer
docker rm portainer
docker volume rm portainer_data
```
- 确保关闭防火墙中的端口9443并删除所有必要的反向代理主机。