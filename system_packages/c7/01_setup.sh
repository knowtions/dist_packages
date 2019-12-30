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
    pigz \
    sudo \
    wget \
    yum-utils \
    createrepo
    # device-mapper-persistent-data \
    # lvm2 \
    # https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# nvidia-container-toolkit == nvidia runtime
RUN wget https://nvidia.github.io/nvidia-docker/centos7/nvidia-docker.repo -O /etc/yum.repos.d/nvidia-docker.repo
RUN yum clean all
RUN yum update -y

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
# Required by Nvidia driver and runtime
# http://vault.centos.org/7.0.1406/os/x86_64/Packages/elfutils-libelf-0.158-3.el7.x86_64.rpm
# http://vault.centos.org/7.0.1406/os/x86_64/Packages/elfutils-libelf-devel-0.158-3.el7.x86_64.rpm
# http://vault.centos.org/7.1.1503/os/x86_64/Packages/elfutils-libelf-0.160-1.el7.x86_64.rpm
# http://vault.centos.org/7.1.1503/os/x86_64/Packages/elfutils-libelf-devel-0.160-1.el7.x86_64.rpm
# http://vault.centos.org/7.2.1511/os/x86_64/Packages/elfutils-libelf-0.163-3.el7.x86_64.rpm
# http://vault.centos.org/7.2.1511/os/x86_64/Packages/elfutils-libelf-devel-0.163-3.el7.x86_64.rpm
# http://vault.centos.org/7.3.1611/os/x86_64/Packages/elfutils-libelf-0.166-2.el7.x86_64.rpm
# http://vault.centos.org/7.3.1611/os/x86_64/Packages/elfutils-libelf-devel-0.166-2.el7.x86_64.rpm
# http://vault.centos.org/7.4.1708/os/x86_64/Packages/elfutils-libelf-0.168-8.el7.x86_64.rpm
# http://vault.centos.org/7.4.1708/os/x86_64/Packages/elfutils-libelf-devel-0.168-8.el7.x86_64.rpm
# http://vault.centos.org/7.5.1804/os/x86_64/Packages/elfutils-libelf-0.170-4.el7.x86_64.rpm
# http://vault.centos.org/7.5.1804/os/x86_64/Packages/elfutils-libelf-devel-0.170-4.el7.x86_64.rpm
# http://vault.centos.org/7.6.1810/os/x86_64/Packages/elfutils-libelf-0.172-2.el7.x86_64.rpm
# http://vault.centos.org/7.6.1810/os/x86_64/Packages/elfutils-libelf-devel-0.172-2.el7.x86_64.rpm
# http://mirror.centos.org/centos-7/7.7.1908/os/x86_64/Packages/elfutils-libelf-0.176-2.el7.x86_64.rpm
# http://mirror.centos.org/centos-7/7.7.1908/os/x86_64/Packages/elfutils-libelf-devel-0.176-2.el7.x86_64.rpm
"
dl_links=()
while read -r line; do
   if [[ $line != "#"* ]]; then
       dl_links+=("$line")
   fi
done <<< "$dl_list"

kernel_packages=$(cat kernel_packages_list.txt | xargs)

RUN mkdir -p download
RUN cd download
for url in ${dl_links[@]}; do
    RUN wget -N ${url} &
done

for url in ${kernel_packages}; do
    RUN wget -N ${url} &
done

RUN wait
RUN cd ..

repo_dir="offline_repo"
repo_path="./builddir/${repo_dir}"
all_pkgs_wi_py3=$(grep -v '^#' yum.txt | grep "^python3" | xargs)
all_pkgs_wo_py3=$(grep -v '^#' yum.txt | grep -v "^python3" | xargs)
RUN rm -rf ${repo_path}.bak
RUN mkdir -p ${repo_path}
RUN mv -f ${repo_path} ${repo_path}.bak
RUN mkdir -p ${repo_path}
cp -rf download/*.rpm ${repo_path}
RUN yumdownloader --resolve --destdir ${repo_path} ${all_pkgs_wi_py3}
RUN yumdownloader --resolve --destdir ${repo_path} ${all_pkgs_wo_py3}
RUN createrepo ${repo_path}
RUN cd "${repo_path}/.."
RUN chmod -R 755 .
RUN chown -R $(whoami) .
tar -cf - ${repo_dir} | pigz > yum_archives.tar.gz
echo All Done!
