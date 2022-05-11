#!/bin/bash

repo_dir="centos/8/"
repo_mirror="rsync://ftp.wcss.pl/ftp/linux"
repo_mirror="rsync://ftp.icm.edu.pl/pub/Linux/distributions"

# Create repo directory
mkdir -p "${base_dir}/${repo_dir}"

# Sync CentOS 8 repo
rsync ${rsync_opts} ${rsync_opts_sync} \
    --exclude isos \
    --exclude aarch64 \
    --exclude ppc64le \
    "${repo_mirror}/${repo_dir}" "${base_dir}/${repo_dir}"

# Download CentOS 8 repository key
# wget -P "${centos_8_dir}" wget https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official
(cd "${base_dir}/${repo_dir}" && curl -O -J "https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official")
