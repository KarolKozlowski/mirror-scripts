#!/bin/bash

repo_dir="epel/8/"
repo_mirror="rsync://ftp.wcss.pl/ftp/linux"
repo_mirror="rsync://ftp.icm.edu.pl/pub/Linux/distributions"

# Create repo directory
mkdir -p "${base_dir}/${repo_dir}"

# Sync CentOS 8 repo
rsync ${rsync_opts} ${rsync_opts_sync} \
    --exclude aarch64 \
    --exclude ppc64le \
    --exclude s390x \
    --exclude SRPMS \
    "${repo_mirror}/${repo_dir}" "${base_dir}/${repo_dir}"

rsync ${rsync_opts} \
    "${repo_mirror}/epel/epel-release-latest-8.noarch.rpm" "${base_dir}/epel/"

# Download repository key
(cd "${base_dir}/${repo_dir}" && curl -O -J "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8")
