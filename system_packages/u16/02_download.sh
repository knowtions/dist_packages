#!/bin/bash
set -e

basedir=$(readlink -f $(dirname $0))
cd $basedir
source /etc/os-release

rm -rf /etc/apt/apt.conf.d/docker-*

apt-get update
apt-get -y install lsb-core

os_ver=$(echo $ID | sed -e 's/^"//;s/"$//;s/centos/rhel/')$(echo $VERSION| sed -e 's/^"//' | awk -F '.' '{print $1}' | awk '{print $1}')
distribution=${ID}${VERSION_ID}
codename=$(lsb_release -sc)  # VERSION_CODENAME in /etc/os-release
codename=${VERSION_CODENAME} # $(lsb_release -sc)

echo "os_ver=${os_ver}, distribution=${distribution}"

# Adding repos
# nvidia
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# docker
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# postgresql 10
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/PostgreSQL.list'

sudo apt install -y gcc-5

echo "================================================================"
echo "start to download"
echo "================================================================"
# clean and update apt metadata
# sudo apt clean
sudo apt update

# set up package info
package_list_file="apt.txt"
package_list_without_p36=$(cat ${package_list_file} | grep -v \# | grep -v python3.6 | xargs)
package_list_with_p36=$(cat ${package_list_file} | grep -v \# | grep python3.6 | xargs)

echo "=== package_list_without_p36 ==="
sudo apt-get install -y --download-only ${package_list_without_p36}
echo "=== package_list_with_p36 ==="
sudo apt-get install -y --download-only ${package_list_with_p36}

# apt-get --no-install-recommends [...COMMAND]
# apt-get --install-suggests  [...COMMAND]

# sudo apt-get install -y nvidia-container-toolkit
# sudo systemctl restart docker

# create offline repo package
mkdir -p ${build_dir}/${os_ver}
cd ${build_dir}

tar -zcf ${os_ver}/apt_meta.tar.gz /etc/apt /var/lib/apt /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin
cd /var/cache/apt
tar -zcf ${basedir}/${os_ver}/apt_archives.tar.gz archives/
cd

# done
echo "Job done"
