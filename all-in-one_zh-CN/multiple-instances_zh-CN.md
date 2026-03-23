# 在同一服务器上运行多个 Nextcloud AIO 实例

本文档介绍了如何在同一服务器上运行多个 Nextcloud AIO 实例。

## 方法 1：使用 Docker rootless 模式

此方法使用户能够在同一物理服务器上运行多个 AIO 实例，而无需使用虚拟机。这可能是最简单的方法，但请注意，如果您想要使用 Talk 功能，可能会遇到一些限制（请参见最后关于 Talk 的说明）。

### 步骤：

1. 首先，创建两个 Linux 用户（在这个例子中，我们创建 `user1` 和 `user2`）：
   ```shell
   useradd -m user1 -s /bin/bash
   useradd -m user2 -s /bin/bash
   
   # 设置密码
   passwd user1
   passwd user2
   ```

2. 现在，您需要为每个用户安装 Docker rootless：
   ```shell
   # 首先为 user1 安装 Docker rootless
   su - user1
   curl -fsSL https://get.docker.com/rootless | sh
   
   # 按照输出的说明操作，将所需的环境变量添加到 .bashrc 文件中
   # 例如（根据实际输出调整）：
   echo 'export PATH=/home/user1/bin:$PATH' >> ~/.bashrc
   echo 'export DOCKER_HOST=unix:///run/user/1001/docker.sock' >> ~/.bashrc
   source ~/.bashrc
   
   # 退出 user1 的会话
   exit
   
   # 现在为 user2 安装 Docker rootless
   su - user2
   curl -fsSL https://get.docker.com/rootless | sh
   
   # 同样，按照输出的说明操作
   # 例如（根据实际输出调整，注意 UID 会不同）：
   echo 'export PATH=/home/user2/bin:$PATH' >> ~/.bashrc
   echo 'export DOCKER_HOST=unix:///run/user/1002/docker.sock' >> ~/.bashrc
   source ~/.bashrc
   
   # 退出 user2 的会话
   exit
   ```

3. 配置系统以允许非特权端口绑定：
   ```shell
   # 允许非特权用户绑定到小于 1024 的端口
   echo 'net.ipv4.ip_unprivileged_port_start=80' > /etc/sysctl.d/50-unprivileged-ports.conf
   sysctl --system
   ```

4. 配置 Docker rootless 以支持 IPv6（可选但推荐）：
   ```shell
   # 对于 user1
   su - user1
   nano ~/.config/docker/daemon.json
   
   # 添加以下内容（如果文件不存在，则创建它）：
   {
     "ipv6": true,
     "fixed-cidr-v6": "fd00::/80"
   }
   
   # 保存并退出
   # 重启 Docker rootless 服务
   systemctl --user restart docker
   
   # 退出 user1 的会话
   exit
   
   # 对于 user2，重复相同的步骤
   su - user2
   nano ~/.config/docker/daemon.json
   
   # 添加相同的内容：
   {
     "ipv6": true,
     "fixed-cidr-v6": "fd00::/80"
   }
   
   # 保存并退出
   # 重启 Docker rootless 服务
   systemctl --user restart docker
   
   # 退出 user2 的会话
   exit
   ```

5. 确保 Docker rootless 服务在系统重启后自动启动：
   ```shell
   # 对于 user1
   su - user1
   loginctl enable-linger $UID
   exit
   
   # 对于 user2
   su - user2
   loginctl enable-linger $UID
   exit
   ```

6. 为每个用户配置 AIO 实例，使用不同的端口：
   ```shell
   # 对于 user1
   su - user1
   
   # 注意：我们使用不同的端口（8080 和 3478）
   docker run \
   --init \
   --sig-proxy=false \
   --name nextcloud-aio-mastercontainer \
   --restart always \
   --publish 8080:8080 \
   --env APACHE_PORT=11000 \
   --env APACHE_IP_BINDING=0.0.0.0 \
   --env TALK_PORT=3478 \
   --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
   --volume /home/user1/docker-aio/nextcloud/data:/mnt/ncdata \
   --volume /run/user/$(id -u)/docker.sock:/var/run/docker.sock:ro \
   ghcr.io/nextcloud-releases/all-in-one:latest
   
   # 让这个容器启动，然后按 Ctrl+C 退出
   exit
   
   # 对于 user2
   su - user2
   
   # 注意：我们使用不同的端口（8081 和 3479）
   docker run \
   --init \
   --sig-proxy=false \
   --name nextcloud-aio-mastercontainer \
   --restart always \
   --publish 8081:8080 \
   --env APACHE_PORT=11001 \
   --env APACHE_IP_BINDING=0.0.0.0 \
   --env TALK_PORT=3479 \
   --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
   --volume /home/user2/docker-aio/nextcloud/data:/mnt/ncdata \
   --volume /run/user/$(id -u)/docker.sock:/var/run/docker.sock:ro \
   ghcr.io/nextcloud-releases/all-in-one:latest
   
   # 让这个容器启动，然后按 Ctrl+C 退出
   exit
   ```

7. 安装 Caddy 作为反向代理：
   ```shell
   apt update -y
   apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
   apt update -y
   apt install -y caddy
   ```

8. 配置 Caddy 反向代理：
   ```shell
   nano /etc/caddy/Caddyfile
   ```
   替换文件内容为：
   ```
   # 第一个实例 - example1.com
   https://example1.com:8443 {
       reverse_proxy https://localhost:8080 {
           transport http {
               tls_insecure_skip_verify
           }
       }
   }
   https://example1.com {
       reverse_proxy localhost:11000
   }
   
   # 第二个实例 - example2.com
   https://example2.com:8443 {
       reverse_proxy https://localhost:8081 {
           transport http {
               tls_insecure_skip_verify
           }
       }
   }
   https://example2.com {
       reverse_proxy localhost:11001
   }
   ```
   保存并退出，然后重启 Caddy：
   ```shell
   systemctl restart caddy
   ```

9. 现在，您可以通过访问 `https://example1.com:8443` 和 `https://example2.com:8443` 来设置和访问您的两个 Nextcloud AIO 实例。

### 关于 Talk 的说明

如果您想要使用 Nextcloud Talk，请注意以下几点：

1. 您需要为每个实例配置不同的 Talk 端口（我们在上面使用了 3478 和 3479）。
2. 您需要在路由器上为这些端口设置端口转发。
3. 在每个实例的管理界面中，您需要正确配置 STUN/TURN 设置。

有关更多详细信息，请参阅 [Nextcloud AIO 讨论区](https://github.com/nextcloud/all-in-one/discussions/2517)。

## 方法 2：使用独立虚拟机

此方法使用虚拟机在同一物理服务器上运行多个 AIO 实例。这是一种更隔离的方法，但需要更多的系统资源。

### 步骤：

1. 准备您的物理服务器：
   ```shell
   # 安装必要的包
   apt update -y
   apt install -y qemu-kvm libvirt-clients libvirt-daemon-system virtinst bridge-utils cpu-checker
   
   # 验证虚拟化支持
   kvm-ok
   
   # 将您的用户添加到 libvirt 组
   usermod -aG libvirt $USER
   newgrp libvirt
   ```

2. 创建 VM：
   
   <details><summary><strong>下载 ISO 镜像（Ubuntu Server）</strong></summary>
   访问 <a href="https://ubuntu.com/download/server">Ubuntu Server 下载页面</a> 并获取最新的 LTS ISO 镜像。您可以使用 wget 直接下载：
   ```shell
   wget https://releases.ubuntu.com/22.04/ubuntu-22.04.2-live-server-amd64.iso
   ```
   </details>
   
   <details><summary><strong>创建 VM（Ubuntu Server）</strong></summary>
   创建 Ubuntu Server VM（别忘了替换 [VM_NAME]）：
   ```shell
   virt-install \
   --name [VM_NAME] \
   --virt-type kvm \
   --cdrom ./ubuntu-22.04.2-live-server-amd64.iso \
   --os-variant ubuntu22.04 \
   --disk size=32 \
   --memory 2048 \
   --vcpus 2 \
   --graphics none \
   --console pty,target_type=serial \
   --network network=default,model=virtio \
   --extra-args "console=ttyS0" \
   --autostart
   ```
   </details>
   
   <details><summary><strong>创建 VM（Debian）</strong></summary>
   创建 Debian VM（别忘了替换 [VM_NAME]）：
   ```shell
   # 如果 os-variant "debian12" 未知，尝试使用 "debiantesting"
   virt-install \
   --name [VM_NAME] \
   --virt-type kvm \
   --location http://deb.debian.org/debian/dists/bookworm/main/installer-amd64/ \
   --os-variant debian12 \
   --disk size=32 \
   --memory 2048 \
   --graphics none \
   --console pty,target_type=serial \
   --extra-args "console=ttyS0" \
   --autostart \
   --boot uefi
   ```
   </details>

3. 完成文本模式安装。大多数选项可以保持默认，但以下是一些提示：
   
   <details><summary><strong>Ubuntu Server 安装程序</strong></summary>
   当被问及 "安装类型" 时，您可以保持默认的 "Ubuntu Server" 而不选择第三方驱动。您可以留空 HTTP 代理信息。在 "配置文件" 部分，您可以将 "服务器名称"（主机名）设置为与您为 VM 提供的名称相同的值（例如 "example1-com"）。安装程序只允许您创建一个非 root 用户。请记住您在此处使用的密码！您可以跳过启用 Ubuntu Pro。您可以允许分区工具使用整个磁盘，这只会使用您在上面步骤 2 中定义的虚拟磁盘。最终，您将获得安装额外软件的选项。虽然这里列出了 "Nextcloud"，但您几乎肯定 <strong>不</strong> 想选择此选项，因为您正在设置 Nextcloud AIO。您会被问及是否安装 "SSH 服务器"，这完全是可选的（这让您将来可以轻松 SSH 进入 VM 进行任何维护，但即使您不安装 SSH 服务器，您仍然可以使用 "virsh console" 命令登录）。最后，忽略 "[FAILED] Failed unmounting /cdrom." 消息，然后按回车。
   </details>
   
   <details><summary><strong>Debian 安装程序</strong></summary>
   当被问及，您可以将主机名设置为与您为 VM 提供的名称相同的值（例如 "example1-com"）。您可以留空域名和 HTTP 代理信息。允许安装程序创建 root 和非 root 用户。请记住您在此处使用的密码！您可以允许分区工具使用整个磁盘，这只会使用您在上面步骤 2 中定义的虚拟磁盘。当 tasksel（软件选择）运行并询问您是否要安装额外软件时，使用空格键和箭头键取消选中 "Debian 桌面环境" 和 "GNOME" 选项。"SSH 服务器" 选项完全是可选的（这让您将来可以轻松 SSH 进入 VM 进行任何维护，但即使您不安装 SSH 服务器，您仍然可以使用 "virsh console" 命令登录）。确保 "标准系统工具" 也被选中。按 Tab 选择 "继续"。最后，忽略关于 GRUB 的警告，允许它安装到您的 "主驱动器"（同样，它只是虚拟的，这仅适用于 VM - 这不会影响您主机物理机器的启动配置）并选择 "/dev/vda" 作为可启动设备。
   </details>

4. 配置您的新 VM：
   
   安装完成后，VM 将重新启动并显示登录提示。对于 Debian，只需使用 `root` 作为用户名，并输入您在安装过程中选择的密码。Ubuntu 限制 root 账户访问，因此您需要首先使用您的非 root 用户登录，然后运行 `sudo su -` 提升您的权限。
   
   现在我们将运行一些命令来安装 docker 并在反向代理模式下安装 AIO！与任何其他命令一样，在运行它们之前仔细阅读并尽力理解它们。
   
   **每次您到达此步骤并运行下面的 `docker run` 命令时，您需要递增 `TALK_PORT` 值。例如：3478、3479 等... 您可以使用其他值，只要它们不冲突，并确保它们[大于 1024](https://github.com/nextcloud/all-in-one/discussions/2517)。请务必记下您分配给此 VM/AIO 实例的 Talk 端口号。如果您决定启用 Nextcloud Talk，稍后会需要它。**
   
   运行这些命令（**在 VM 上**）：
   ```shell
   apt install -y curl
   
   curl -fsSL https://get.docker.com | sh
   
   # 确保每次运行此命令时递增 TALK_PORT 值！
   docker run \
   --init \
   --sig-proxy=false \
   --name nextcloud-aio-mastercontainer \
   --restart always \
   --publish 8080:8080 \
   --env APACHE_PORT=11000 \
   --env APACHE_IP_BINDING=0.0.0.0 \
   --env TALK_PORT=3478 \
   --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
   --volume /var/run/docker.sock:/var/run/docker.sock:ro \
   ghcr.io/nextcloud-releases/all-in-one:latest
   ```
   最后一个命令可能需要几分钟时间。完成后，您应该会看到一条成功消息，显示 "Initial startup of Nextcloud All-in-One complete!"。现在使用 `Ctrl + [c]` 退出控制台会话。这就完成了这个特定 VM 的设置。

5. 继续按照步骤 1-4 再次设置第二个 VM。完成后，继续执行步骤 6。（注意：如果您下载了 Ubuntu .ISO 镜像并且不再需要它，您现在可以删除它。）

6. 差不多完成了！剩下的就是配置您的反向代理。为此，您首先需要[安装它](https://caddyserver.com/docs/install#debian-ubuntu-raspbian)。运行（**在主机物理机器上**）：
   ```shell
   apt update -y
   apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
   apt update -y
   apt install -y caddy
   ```
   这些命令将确保您的系统是最新的，并通过其官方二进制源安装最新稳定版本的 Caddy。

7. 要配置 Caddy，您需要知道分配给每个 VM 的 IP 地址。运行（**在主机物理机器上**）：
   ```shell
   virsh net-dhcp-leases default
   ```
   这将显示您设置的 VM，以及每个 VM 对应的 IP 地址。记下每个 IP 和对应的主机名。
   最后，您将使用这些信息配置 Caddy。使用文本编辑器打开默认的 Caddyfile：
   ```shell
   nano /etc/caddy/Caddyfile
   ```
   用以下配置替换此文件中的所有内容。别忘了编辑此示例配置并代入您自己的域名和 IP 地址。`[DOMAIN_NAME_*]` 应该是像 `example1.com` 这样的域名，`[IP_ADDRESS_*]` 应该是像 `192.168.122.225` 这样的本地 IPv4 地址。
   ```shell
   # 虚拟机 #1 - "example1-com"
   https://[DOMAIN_NAME_1]:8443 {
       reverse_proxy https://[IP_ADDRESS_1]:8080 {
           transport http {
               tls_insecure_skip_verify
           }
       }
   }
   https://[DOMAIN_NAME_1]:443 {
       reverse_proxy [IP_ADDRESS_1]:11000
   }
   
   # 虚拟机 #2 - "example2-com"
   https://[DOMAIN_NAME_2]:8443 {
       reverse_proxy https://[IP_ADDRESS_2]:8080 {
           transport http {
               tls_insecure_skip_verify
           }
       }
   }
   https://[DOMAIN_NAME_2]:443 {
       reverse_proxy [IP_ADDRESS_2]:11000
   }
   
   # （如果您设置了两个以上的 VM，请在此处添加更多配置！）
   ```
   进行此更改后，您需要重启 Caddy：
   ```shell
   systemctl restart caddy
   ```

8. 就是这样！现在，剩下的就是通过浏览器访问 `https://example1.com:8443` 和 `https://example2.com:8443`，像往常一样通过 AIO 界面设置您的实例。完成每个设置后，您可以通过它们的域名简单地访问您的新实例。只要您有足够的系统资源，您可以通过这种方式托管任意数量的实例和任意数量的域名。享受吧！

   <details><summary><strong>管理此设置的一些额外提示</strong></summary>
       <ul>
           <li>您可以使用此命令轻松连接到 VM 进行维护（**在主机物理机器上**）：<pre><code>virsh console --domain [VM_NAME]</code></pre></li>
           <li>如果您选择安装 SSH 服务器，您可以使用此命令 SSH 进入（**在主机物理机器上**）：<pre><code>ssh [NONROOT_USER]@[IP_ADDRESS] # 默认情况下，OpenSSH 不允许以 root 身份登录</code></pre></li>
           <li>如果您搞乱了 VM 的配置，您可能希望完全删除它并使用新的 VM 重新开始。<strong>这将删除与 VM 相关的所有数据，包括您 AIO DATADIR 中的任何内容！</strong>如果您确定要这样做，请运行（**在主机物理机器上**）：<pre><code>virsh destroy --domain [VM_NAME] ; virsh undefine --nvram --domain [VM_NAME] && rm -rfi /var/lib/libvirt/images/[VM_NAME].qcow2</code></pre></li>
           <li>使用 Nextcloud Talk 需要一些额外的配置。当您设置 VM 时，它们默认配置为 NAT，这意味着它们位于自己的子网中。VM 必须各自改为桥接模式，以便您的路由器可以直接 "看到" 它们（就像它们是网络上真正的物理设备一样），并且每个 VM 内的每个 AIO 实例都必须配置不同的 Talk 端口（如 3478、3479 等）。您应该已经设置了这些端口号（当您在上面的步骤 4 中首次配置 VM 时），但如果您仍然需要设置（或想要更改）这些值，您可以删除 mastercontainer 并使用修改后的 Talk 端口重新运行初始的 "docker run" 命令<a href="https://github.com/nextcloud/all-in-one#how-to-adjust-the-talk-port">如下</a>。然后，每个实例的 Talk 端口需要在路由器的设置中直接转发到托管该实例的 VM（完全绕过您的主机物理机器/反向代理）。最后，在每个实例的管理员权限账户（如默认的 "admin" 账户）中，您必须访问 <strong>https://[DOMAIN_NAME]/settings/admin/talk</strong>，然后找到 STUN/TURN 设置，并从那里设置适当的值。如果这太复杂，使用公共 STUN/TURN 服务器可能会更容易，但我尚未测试任何这些，我只是分享我到目前为止发现的内容（更多信息可在<a href="https://github.com/nextcloud/all-in-one/discussions/2517">这里</a>找到）。如果您已经解决了这个问题，或者如果任何这些信息不正确，请编辑此部分！</li>
           <li>使用此设置配置每日自动备份稍微复杂一些。但对于偶尔的手动 borg 备份，您可以通过便宜的 USB SATA 适配器/底座将物理 SSD/HDD 连接到主机物理机器上的空闲 USB 端口，然后使用这些命令将磁盘传递到您选择的 VM（**在主机物理机器和 VM 上**）：<pre><code>virsh attach-device --live --domain [VM_NAME] --file [USB_DEVICE_DEFINITION.xml]
   virsh console --domain [VM_NAME]
   # （以 root 权限登录到 VM）
   mkdir -p /mnt/[MOUNT_NAME]
   mount /dev/disk/by-label/[DISK_NAME] /mnt/[MOUNT_NAME]</code></pre></li>
           要创建 XML 设备定义文件，请参阅<a href="https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/sect-managing_guest_virtual_machines_with_virsh-attaching_and_updating_a_device_with_virsh">此简短指南</a>。建议使用 SSD/HDD，但如果您真的想测试，没有什么能阻止您使用像闪存驱动器这样简单的东西。最后，要实际执行手动备份，请确保您的磁盘已正确挂载，然后只需使用 AIO 界面执行备份。
           <li>如果您想在重启主机物理机器时减少大约 8-10 秒的总启动时间，一个简单的技巧是将 GRUB_TIMEOUT 从默认的五秒降低到一秒，在主机物理机器和每个 VM 上。您也可以消除延迟，但通常至少保留一秒钟更安全。（编辑 GRUB 配置时，请务必格外小心，尤其是在主机物理机器上，因为不正确的配置可能会阻止您的设备启动！）</li>
       </ul>
   </details>