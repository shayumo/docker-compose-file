# 如何从现有Nextcloud安装迁移到Nextcloud AIO？

从现有Nextcloud安装迁移到Nextcloud AIO基本上有三种方法（如果您已经在之前的安装上运行过AIO，可以按照[这些步骤](https://github.com/nextcloud/all-in-one#how-to-migrate-from-aio-to-aio)操作）：

1. 仅迁移文件，这是最简单的方法（这不包括日历数据等）
2. 迁移文件和数据库，这要复杂得多（并且在之前的snap安装上不起作用）
3. 使用user_migration应用，它允许将用户数据从旧实例迁移到新实例，但需要为每个用户手动操作

## 仅迁移文件
**请注意**：如果您之前使用了groupfolders或加密了文件，则您也需要恢复数据库！（这也不包括日历数据等）

仅迁移文件的步骤如下：
1. 备份您的旧实例（尤其是您的数据目录，请查看`config.php`中的`'datadirectory'`）
2. 在新服务器/ Linux安装上安装Nextcloud AIO，输入您的域名，等待所有容器运行
3. 重新创建您旧安装上存在的所有用户
4. 使用Nextcloud AIO的内置备份解决方案进行备份（以便您可以轻松地再次恢复到此状态）（注意：这将停止所有容器，这是预期的：此时不要再次启动容器！）
5. 恢复您旧实例的数据目录：对于`/path/to/old/nextcloud/data/`，运行`sudo docker cp --follow-link /path/to/old/nextcloud/data/. nextcloud-aio-nextcloud:/mnt/ncdata/` 注意：末尾的`/.`和`/`是必需的。
6. 接下来，运行`sudo docker run --rm --volume nextcloud_aio_nextcloud_data:/mnt/ncdata:rw alpine chown -R 33:0 /mnt/ncdata/`和`sudo docker run --rm --volume nextcloud_aio_nextcloud_data:/mnt/ncdata:rw alpine chmod -R 750 /mnt/ncdata/`以应用正确的权限。（或者如果提供了`NEXTCLOUD_DATADIR`，请将`chown -R 33:0`和`chmod -R 750`应用于所选路径。）
7. 再次启动容器，等待所有容器运行
8. 运行`sudo docker exec --user www-data -it nextcloud-aio-nextcloud php occ files:scan-app-data && sudo docker exec --user www-data -it nextcloud-aio-nextcloud php occ files:scan --all`以扫描数据目录中的所有文件。
9. 如果恢复的数据比您想要继续同步的任何客户端都旧，例如，如果服务器在迁移期间停机了一段时间，您可能需要查看下面的[迁移后与客户端同步](/migration.md#synchronising-with-clients-after-migration)。

## 迁移文件和数据库
**请注意**：这比仅迁移文件复杂得多，也不是那么万无一失，所以请做好准备！此外，这在之前的snap安装上不起作用，因为snap是只读的，因此您无法安装必要的`pdo_pgsql` PHP扩展。因此，如果从snap迁移，您需要使用其他方法之一。但是，您可以尝试询问snap维护者是否可以在此处添加这个小的PHP扩展：https://github.com/nextcloud-snap/nextcloud-snap/issues，这将允许轻松迁移。

迁移文件和数据库的步骤如下：
1. 确保您的旧实例与Nextcloud AIO中使用的版本完全相同。（例如23.0.0）您可以在此处找到使用的版本：[点击此处](https://github.com/nextcloud/all-in-one/search?l=Dockerfile&q=NEXTCLOUD_VERSION&type=)。如果不是，只需将您的旧安装升级到该版本，或者等待Nextcloud AIO中使用的版本更新到与您的旧安装相同的版本，或者反之亦然。
2. 首先，在旧实例上，通过应用管理站点将所有Nextcloud应用更新到最新版本（这对以后的恢复很重要）。然后备份您的旧实例（尤其是您的数据目录和数据库）。
3. 如果您的旧安装尚未使用Postgresql，您现在需要将旧安装临时转换为使用Postgresql作为数据库（以便能够执行pg_dump）：
    1. 在您的旧安装上安装Postgresql：在基于Debian的操作系统上，以下命令应该有效：
        ```
        sudo apt update && sudo apt install postgresql -y
        ```
    2. 通过运行以下命令创建一个新数据库：
        ```
        export PG_USER="ncadmin" # 这是为dump创建的临时用户，但稍后会被正确的用户覆盖
        export PG_PASSWORD="my-temporary-password"
        export PG_DATABASE="nextcloud_db"
        sudo -u postgres psql <<END
        CREATE USER $PG_USER WITH PASSWORD '$PG_PASSWORD' CREATEDB;
        CREATE DATABASE $PG_DATABASE WITH OWNER $PG_USER TEMPLATE template0 ENCODING 'UTF8';
        GRANT ALL PRIVILEGES ON DATABASE $PG_DATABASE TO $PG_USER;
        GRANT ALL PRIVILEGES ON SCHEMA public TO $PG_USER;
        END
        ```
    3. 运行以下命令开始转换：
        ```
        occ db:convert-type --all-apps --password "$PG_PASSWORD" pgsql "$PG_USER" 127.0.0.1 "$PG_DATABASE"
        ```
        **请注意**：您可能需要更改ip地址`127.0.0.1`并根据您的确切安装调整occ命令（`occ`）。有关转换的更多信息可在此处获得：https://docs.nextcloud.com/server/stable/admin_manual/configuration_database/db_conversion.html#converting-database-type<br>
        **故障排除**：如果您收到找不到转换驱动程序的错误，您很可能需要安装PHP扩展`pdo_pgsql`。
    4. 希望转换成功完成。如果没有，只需从备份恢复您的旧Nextcloud安装。如果成功，您现在应该登录到您的Nextcloud并测试一切是否正常工作，以及所有数据是否已成功转换。
    5. 如果一切正常，请继续执行以下步骤。
4. 现在，运行pg_dump以获取当前数据库的导出。类似以下命令应该有效：
    ```
    sudo -Hiu postgres pg_dump "$PG_DATABASE"  > ./database-dump.sql
    ```
    **请注意**：数据库导出文件的确切名称很重要！（`database-dump.sql`）<br>
    当然，您需要使用Postgresql数据库具有的正确名称进行导出（如果`$PG_DATABASE`不能直接工作）。
5. 此时，您终于可以在新服务器/Linux安装上安装Nextcloud AIO，在AIO界面中输入您的域名（使用与您在旧安装上使用的相同域名），等待所有容器运行。然后，您应该通过运行`sudo docker inspect nextcloud-aio-nextcloud | grep NEXTCLOUD_VERSION`检查包含的Nextcloud版本。在AIO界面上，使用密码短语连接到您新创建的Nextcloud实例的管理员帐户。在那里，安装所有在旧Nextcloud安装上安装的Nextcloud应用。如果不这样做，迁移将显示它们已安装，但它们将无法工作。
6. 接下来，使用Nextcloud AIO的内置备份解决方案进行备份（以便您可以轻松地再次恢复到此状态）。完成后，所有容器会自动停止，这是预期的：**此时不要再次启动容器！**
7. 现在，在容器仍然停止的情况下，我们开始导入您的文件和数据库。首先，您需要修改存储在数据库导出中的数据目录：
    1. 通过例如打开config.php文件并查看值`datadirectory`，找出旧Nextcloud安装的目录是什么。
    2. 现在，创建数据库文件的副本，以便如果您在编辑时出错，可以简单地恢复它：`cp database-dump.sql database-dump.sql.backup`
    3. 接下来，使用例如nano打开数据库导出：`nano database-dump.sql`
    4. 按`[CTRL] + [w]`打开搜索
    5. 输入`local::/your/old/datadir/`，这应该会显示您需要修改路径的准确行，改为使用Nextcloud AIO中使用的路径。
    6. 将其更改为如下所示：`local::/mnt/ncdata/`。
    7. 现在保存文件，按`[CTRL] + [o]`然后`[ENTER]`，按`[CTRL] + [x]`关闭nano
    8. 为了确保一切正常，您现在可以运行`grep "/your/old/datadir" database-dump.sql`，这不应该显示更多结果。<br>
    9. **请注意**：不幸的是，无法导入来自前数据库所有者名为`nextcloud`的数据库转储。您可以使用此命令检查是否是这种情况：`grep "Name: oc_appconfig; Type: TABLE; Schema: public; Owner:" database-dump.sql | grep -oP 'Owner:.*$' | sed 's|Owner:||;s| ||g'`。如果返回`nextcloud`，则需要手动在转储文件中重命名所有者。类似以下命令应该有效，但是请注意，它可能会覆盖错误的行。因此，您可以首先使用`grep "Owner: nextcloud$" database-dump.sql`检查它将更改哪些行。如果只返回看起来正确的行，可以使用`sed -i 's|Owner: nextcloud$|Owner: ncadmin|' database-dump.sql`更改它们。
对于第二个语句，使用`grep " OWNER TO nextcloud;$" database-dump.sql`检查，然后使用`sed -i 's| OWNER TO nextcloud;$| OWNER TO ncadmin;|' database-dump.sql`替换。
8. 接下来，将数据库转储复制到正确的位置，并准备数据库容器，该容器将在下次容器启动时自动从数据库转储导入：
    ```
    sudo docker run --rm --volume nextcloud_aio_database_dump:/mnt/data:rw alpine rm /mnt/data/database-dump.sql
    sudo docker cp database-dump.sql nextcloud-aio-database:/mnt/data/
    sudo docker run --rm --volume nextcloud_aio_database_dump:/mnt/data:rw alpine chmod 777 /mnt/data/database-dump.sql
    sudo docker run --rm --volume nextcloud_aio_database_dump:/mnt/data:rw alpine rm /mnt/data/initial-cleanup-done
    ```
9. 如果上面的命令执行成功，将旧实例的数据目录恢复到您的数据目录：`sudo docker run --rm --volume nextcloud_aio_nextcloud_data:/mnt/ncdata:rw alpine sh -c "rm -rf /mnt/ncdata/*"`和`sudo docker cp --follow-link /path/to/nextcloud/data/. nextcloud-aio-nextcloud:/mnt/ncdata/` 注意：末尾的`/.`和`/`是必需的。（或者如果提供了`NEXTCLOUD_DATADIR`，首先删除那里的文件，然后将文件复制到所选路径。）
10. 接下来，运行`sudo docker run --rm --volume nextcloud_aio_nextcloud_data:/mnt/ncdata:rw alpine chown -R 33:0 /mnt/ncdata/`和`sudo docker run --rm --volume nextcloud_aio_nextcloud_data:/mnt/ncdata:rw alpine chmod -R 750 /mnt/ncdata/`以在数据目录上应用正确的权限。（或者如果提供了`NEXTCLOUD_DATADIR`，请将`chown -R 33:0`和`chmod -R 750`应用于所选路径。）
11. 使用`sudo docker run -it --rm --volume nextcloud_aio_nextcloud:/var/www/html:rw alpine sh -c "apk add --no-cache nano && nano /var/www/html/config/config.php"`编辑Nextcloud AIO config.php文件，仅修改`passwordsalt`，`secret`，`instanceid`并将其设置为您在旧安装上使用的旧值。如果您有勇气，可以修改更多值，例如添加旧的LDAP配置或S3存储配置。（某些内容如邮件服务器配置可以稍后使用Nextcloud的Web界面添加回来。）
12. 当您完成并保存对文件的更改后，最后再次启动容器，等待所有容器运行。

现在整个Nextcloud实例应该再次工作。<br>
如果没有，请随时从备份恢复AIO实例，并从步骤8重新开始。

如果恢复的数据比您想要继续同步的任何客户端都旧，例如，如果服务器在迁移期间停机了一段时间，您可能需要查看下面的[迁移后与客户端同步](/migration.md#synchronising-with-clients-after-migration)。

## 使用user_migration应用
自Nextcloud更新到24以来，一种新方法是使用新的[user_migration应用](https://apps.nextcloud.com/apps/user_migration#app-gallery)。它允许在一个实例上导出最重要的数据并在另一个Nextcloud实例上导入它。为此，您需要在旧实例上安装并启用user_migration应用，为用户触发导出，在新实例上创建用户，使用该用户登录，并导入在导出期间创建的存档。然后需要为您要迁移的每个用户执行此操作。

如果恢复的数据比您想要继续同步的任何客户端都旧，例如，如果服务器在迁移期间停机了一段时间，您可能需要查看下面的[迁移后与客户端同步](/migration.md#synchronising-with-clients-after-migration)。

# 迁移后与客户端同步
#### 来自https://docs.nextcloud.com/server/latest/admin_manual/maintenance/restore.html#synchronising-with-clients-after-data-recovery
默认情况下，Nextcloud服务器被视为数据的权威来源。如果服务器和客户端上的数据不同，客户端将默认从服务器获取数据。

如果恢复的备份已过时，客户端的状态可能比服务器的状态更新。在这种情况下，还请确保之后运行`sudo docker exec --user www-data -it nextcloud-aio-nextcloud php occ maintenance:data-fingerprint`命令。它更改同步算法的逻辑，以尝试恢复尽可能多的数据。因此，服务器上缺少的文件将从客户端恢复，并且在内容不同的情况下，将询问用户。

>[!注意]
>使用maintenance:data-fingerprint可能会导致冲突对话框和在客户端上删除文件的困难。因此，仅在备份已过时以防止数据丢失时才建议使用。

如果您运行多个应用服务器，则需要确保配置文件在它们之间同步，以便在所有实例上应用更新的数据指纹。