# Scripts for creating local mirrors (via rsync)

Currently implemented:

- `centos`
- `epel`

Simply configure global variables in `sync.sh` and trigger it from cron with
your preffered schedule.


## Serving host setup

1. Install and enable nginx:

   ``` sh
   dnf -y install @nginx`
   systemctl enable --now nginx
   ```

2. (optional) Configure firewall:

   ``` sh
   firewall-cmd --add-service=http --permanent
   firewall-cmd --reload
   ```

3. Allow nginx to access NFS shares (if data stored on NFS):

   ``` sh
   setsebool -P httpd_use_nfs 1
   ```

   alternatively:

   ``` sh
   semanage fcontext -a -t httpd_sys_content_t "/data/repos(/.*)?"
   restorecon -Rv /data/repos
   ```

4. Configure hosting:

   ``` sh
   cp mirror.conf /etc/nginx/conf.d/
   systemctl enable --now nginx
   ```