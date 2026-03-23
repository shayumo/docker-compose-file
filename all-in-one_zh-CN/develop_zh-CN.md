## 开发者通道
如果您想切换到开发者通道，只需停止并删除mastercontainer，然后创建一个新的容器，并将标签更改为develop：
```shell
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
ghcr.io/nextcloud-releases/all-in-one:develop
```
完成后，它也会自动为所有其他容器选择开发者通道。

## 如何发布新版本？
只需使用 https://github.com/nextcloud/all-in-one/issues/180 作为模板。

## 如何将现有实例更新到新的Nextcloud主要版本？
只需使用 https://github.com/nextcloud/all-in-one/issues/6198 作为模板。

## 如何构建新容器
前往 https://github.com/nextcloud-releases/all-in-one/actions/workflows/repo-sync.yml 并运行该工作流，它将首先同步仓库，然后构建新容器，这些容器将自动发布到`develop`和`develop-arm64`。

## 如何正确测试事物？
测试前，请确保至少amd64容器已成功构建，可以通过检查此处的最后一个工作流来确认：https://github.com/nextcloud-releases/all-in-one/actions/workflows/build_images.yml。

AIO的维护者可以使用一个测试VM，允许在发布新版本之前进行一些最终测试。有关详细信息，请参阅[此文档](https://cloud.nextcloud.com/apps/collectives/Nextcloud%20Handbook/Technical/AIO%20testing%20VM?fileId=6350152)。

此外，现在还有E2E测试可用，可以通过 https://github.com/nextcloud/all-in-one/actions/workflows/playwright.yml 运行。

## 如何将构建从develop晋升到beta
1. 确认此处没有正在运行的作业：https://github.com/nextcloud-releases/all-in-one/actions/workflows/build_images.yml
2. 前往 https://github.com/nextcloud-releases/all-in-one/actions/workflows/promote-to-beta.yml，点击`Run workflow`。

## 在哪里可以找到VPS和其他构建？
这在 https://github.com/nextcloud-releases/all-in-one/tree/main/.build 中有记录。

## 如何将构建从beta晋升到latest

1. 确认GitHub服务运行正常：https://www.githubstatus.com/
2. 确认此处没有正在运行的作业：https://github.com/nextcloud-releases/all-in-one/actions/workflows/promote-to-beta.yml
3. 前往 https://github.com/nextcloud-releases/all-in-one/actions/workflows/promote-to-latest.yml，点击`Run workflow`。

## 如何连接到数据库？
只需运行`sudo docker exec -it nextcloud-aio-database psql -U oc_nextcloud nextcloud_database`，您应该就能进入数据库。

## 如何本地构建和测试对mastercontainer的更改
1. 确保按照上面的说明使用开发者通道。
2. 从项目根目录使用以下命令构建mastercontainer镜像：
```
docker buildx build --file Containers/mastercontainer/Dockerfile --tag ghcr.io/nextcloud-releases/all-in-one:develop --load .
```
3. 使用上面构建的镜像启动一个容器。
4. 由于本地构建的镜像的哈希与最新发布的mastercontainer不匹配，它会提示必须更新。要临时绕过更新，请在URL后添加`?bypass_mastercontainer_update`。例如：`https://localhost:8080/containers?bypass_mastercontainer_update`

## 如何使用bypass_container_update参数本地构建和测试对其他容器的更改
1. 确保按照上面的说明使用开发者通道。
2. 从项目根目录使用以下命令构建容器镜像：
```
# 对于"nextcloud"容器
docker buildx build --file Containers/nextcloud/Dockerfile --tag ghcr.io/nextcloud-releases/aio-nextcloud:develop --load .

# 对于所有其他容器
docker buildx build --file Containers/{container}/Dockerfile --tag ghcr.io/nextcloud-releases/aio-{container}:develop --load Containers/{container}
```
3. 使用AIO管理界面停止容器。
4. 使用`bypass_container_update`参数重新加载AIO管理界面，以避免覆盖您的本地更改，例如`https://localhost:8080/containers?bypass_container_update`。
5. 点击"启动和更新容器"并测试您的更改。尽管按钮文本如此，但容器将不会更新。