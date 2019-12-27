#!/bin/bash
set -e

basedir=$(dirname $0)
cd $basedir

function RUN(){
  echo "=========================================================="
  echo RUN command at `date +"%Y-%m-%d %H:%M:%S"`
  echo $@
  echo "----------"
  $@ || (echo "Failed with command -- $@" ; false )
}

RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

RUN rpm --import 'https://download.ceph.com/keys/release.asc'
RUN rpm -Uvh https://download.ceph.com/rpm-luminous/el7/noarch/ceph-release-1-1.el7.noarch.rpm || true

RUN yum clean all
RUN yum-complete-transaction
RUN yum update -y 
RUN yum install -y epel-release
RUN yum install -y \
    vim \
    sudo \
    wget \
    yum-utils \
    createrepo
    # device-mapper-persistent-data \
    # lvm2 \
    # https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# rpm --import 'https://download.ceph.com/keys/release.asc'
# ceph_distro=el7
# ceph_release=luminous
# rpm -Uvh https://download.ceph.com/rpms/${ceph_distro}/x86_64/ceph-${ceph_release}.el7.noarch.rpm

# yum install -y docker-ce docker-ce-cli containerd.io

# yum install -y gcc dkms kernel-devel-$(uname -r) kernel-headers-$(uname -r)

# pgpool repo https://pgpool.net/mediawiki/index.php/Yum_Repository
RUN yum install -y http://www.pgpool.net/yum/rpms/4.1/redhat/rhel-7-x86_64/pgpool-II-release-4.1-1.noarch.rpm || true
# postgresql 10
RUN yum install -y https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-redhat10-10-2.noarch.rpm || true

dl_list="
# kernel packages
http://vault.centos.org/7.0.1406/os/x86_64/Packages/kernel-devel-3.10.0-123.el7.x86_64.rpm
http://vault.centos.org/7.0.1406/os/x86_64/Packages/kernel-debug-devel-3.10.0-123.el7.x86_64.rpm
http://vault.centos.org/7.0.1406/os/x86_64/Packages/kernel-headers-3.10.0-123.el7.x86_64.rpm
http://vault.centos.org/7.1.1503/os/x86_64/Packages/kernel-devel-3.10.0-229.el7.x86_64.rpm
http://vault.centos.org/7.1.1503/os/x86_64/Packages/kernel-debug-devel-3.10.0-229.el7.x86_64.rpm
http://vault.centos.org/7.1.1503/os/x86_64/Packages/kernel-headers-3.10.0-229.el7.x86_64.rpm
http://vault.centos.org/7.2.1511/os/x86_64/Packages/kernel-devel-3.10.0-327.el7.x86_64.rpm
http://vault.centos.org/7.2.1511/os/x86_64/Packages/kernel-debug-devel-3.10.0-327.el7.x86_64.rpm
http://vault.centos.org/7.2.1511/os/x86_64/Packages/kernel-headers-3.10.0-327.el7.x86_64.rpm
http://vault.centos.org/7.3.1611/os/x86_64/Packages/kernel-devel-3.10.0-514.el7.x86_64.rpm
http://vault.centos.org/7.3.1611/os/x86_64/Packages/kernel-debug-devel-3.10.0-514.el7.x86_64.rpm
http://vault.centos.org/7.3.1611/os/x86_64/Packages/kernel-headers-3.10.0-514.el7.x86_64.rpm
http://vault.centos.org/7.4.1708/os/x86_64/Packages/kernel-devel-3.10.0-693.el7.x86_64.rpm
http://vault.centos.org/7.4.1708/os/x86_64/Packages/kernel-debug-devel-3.10.0-693.el7.x86_64.rpm
http://vault.centos.org/7.4.1708/os/x86_64/Packages/kernel-headers-3.10.0-693.el7.x86_64.rpm
http://vault.centos.org/7.5.1804/os/x86_64/Packages/kernel-devel-3.10.0-862.el7.x86_64.rpm
http://vault.centos.org/7.5.1804/os/x86_64/Packages/kernel-debug-devel-3.10.0-862.el7.x86_64.rpm
http://vault.centos.org/7.5.1804/os/x86_64/Packages/kernel-headers-3.10.0-862.el7.x86_64.rpm
http://vault.centos.org/7.6.1810/os/x86_64/Packages/kernel-devel-3.10.0-957.el7.x86_64.rpm
http://vault.centos.org/7.6.1810/os/x86_64/Packages/kernel-debug-devel-3.10.0-957.el7.x86_64.rpm
http://vault.centos.org/7.6.1810/os/x86_64/Packages/kernel-headers-3.10.0-957.el7.x86_64.rpm
http://mirror.centos.org/centos/7.7.1908/os/x86_64/Packages/kernel-devel-3.10.0-1062.el7.x86_64.rpm
http://mirror.centos.org/centos/7.7.1908/os/x86_64/Packages/kernel-debug-devel-3.10.0-1062.el7.x86_64.rpm
http://mirror.centos.org/centos/7.7.1908/os/x86_64/Packages/kernel-headers-3.10.0-1062.el7.x86_64.rpm
# nvidia driver
http://us.download.nvidia.com/tesla/440.33.01/nvidia-driver-local-repo-rhel7-440.33.01-1.0-1.x86_64.rpm
"

dl_links=()
while read -r line; do
   if [[ $line != "#"* ]]; then
       dl_links+=("$line")
   fi
done <<< "$dl_list"

### NVidia driver
# https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&target_distro=CentOS&target_version=7&target_type=rpmlocal
# rpm (local)
# RUN wget -N http://us.download.nvidia.com/tesla/440.33.01/nvidia-driver-local-repo-rhel7-440.33.01-1.0-1.x86_64.rpm
## runfile (local)
# http://us.download.nvidia.com/tesla/410.129/NVIDIA-Linux-x86_64-410.129-diagnostic.run
### cuda driver
# wget http://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda-repo-rhel7-10-2-local-10.2.89-440.33.01-1.0-1.x86_64.rpm
# sudo rpm -i cuda-repo-rhel7-10-2-local-10.2.89-440.33.01-1.0-1.x86_64.rpm
# sudo yum clean all
# sudo yum -y install nvidia-driver-latest-dkms cuda
# sudo yum -y install cuda-drivers

RUN mkdir -p download
RUN cd download
for url in ${dl_links[@]}; do
    RUN wget -N ${url}
done
RUN cd ..

repo_dir="offline_repo"
repo_path="./dest/${repo_dir}"
all_pkgs_wi_py3=$(grep -v '^#' yum.txt | grep "^python3" | xargs)
all_pkgs_wo_py3=$(grep -v '^#' yum.txt | grep -v "^python3" | xargs)
RUN rm -rf ${repo_path}.bak
RUN mv -f ${repo_path} ${repo_path}.bak
RUN mkdir -p ${repo_path}
cp -rf download/*.rpm ${repo_path}
RUN yumdownloader --resolve --destdir ${repo_path} ${all_pkgs_wi_py3}
RUN yumdownloader --resolve --destdir ${repo_path} ${all_pkgs_wo_py3}
RUN createrepo ${repo_path}
RUN chmod -R 555 "${repo_path}/.."
RUN cd "${repo_path}/.."
RUN tar -zcf yum_archives.tar.gz ${repo_dir}
echo All Done!
