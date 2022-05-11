#!/bin/bash

# Host setup:
# 1. Install and enable nginx:
# dnf -y install @nginx
# systemctl enable --now nginx
# 2. (optional) Configure firewall:
# firewall-cmd --add-service=http --permanent
# firewall-cmd --reload
# 3. Allow nginx to access NFS shares:
# setsebool -P httpd_use_nfs 1
# alternatively:
# semanage fcontext -a -t httpd_sys_content_t "/data/repos(/.*)?"
# restorecon -Rv /data/repos
# 4. Configure hosting:
# cp mirror.conf /etc/nginx/conf.d/
# systemctl enable --now nginx

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

base_dir="/srv/mirror"

rsync_opts=""
rsync_opts="${rsync_opts} --archive" # archive mode; equals -rlptgoD (no -H,-A,-X)
				     # -r recurse into directories
				     # -l copy symlinks as symlinks 
				     # -p preserve permissions
				     # -t preserve modification times
				     # -g preserve group
				     # -o preserve owner (super-user only)
				     # -D same as --devices --specials
				     #    --devices preserve device files (super-user only)
				     #    --specials preserve special files
rsync_opts="${rsync_opts} --verbose" # increase verbosity
rsync_opts="${rsync_opts} --sparse"  # handle sparse files efficiently
rsync_opts="${rsync_opts} --hard-links" # preserve hard links
rsync_opts="${rsync_opts} --partial" # keep partially transferred files
rsync_opts="${rsync_opts} --progress" # show progress during transfer

case "$1" in
    "check")
	rsync_opts="${rsync_opts} --checksum"
        rsync_opts_sync="--delete --delete-excluded"
	;;
    "dry-run")
	echo "DRY RUN"
	rsync_opts="${rsync_opts} --dry-run --stats"
	;;
    "*")
        #default, sync
        rsync_opts_sync="--delete --delete-excluded"
esac

for sync_job in ${SCRIPTPATH}/sync.d/*.sh; do
    export base_dir
    export rsync_opts
    export rsync_opts_sync
    /bin/flock -n ${sync_job}.lock ${sync_job} || echo "${sync_job} is already running"
done

# ensure the sync jobs are executed periodically
cat > /etc/cron.hourly/sync.sh << EOF
#!/bin/sh
${SCRIPTPATH}/sync.sh
EOF
chmod +x /etc/cron.hourly/sync.sh
