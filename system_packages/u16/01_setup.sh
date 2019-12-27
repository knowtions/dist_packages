#!/bin/bash
set -e

source /etc/os-release

os_ver=$(echo $ID | sed -e 's/^"//;s/"$//;s/centos/rhel/')$(echo $VERSION| sed -e 's/^"//' | awk -F '.' '{print $1}' | awk '{print $1}')
distribution=${ID}${VERSION_ID}
codename=${VERSION_CODENAME} # $(lsb_release -sc)

echo "os_ver=${os_ver}, distribution=${distribution}"

# python3.6
sudo add-apt-repository -y ppa:jonathonf/python-3.6

# nvidia driver
curl http://us.download.nvidia.com/tesla/410.129/NVIDIA-Linux-x86_64-410.129-diagnostic.run \
    -o NVIDIA-Linux-x86_64-410.129-diagnostic.run
sudo apt install -y gcc dkms linux-headers-$(uname -r)
sudo bash NVIDIA-Linux-x86_64-410.129-diagnostic.run -s \
    --kernel-source-path /usr/src/linux-headers-$(uname -r)

# distro="ubuntu1604"
# architecture="x86_64"
# sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/${distro}/${architecture}/7fa2af80.pub

# nvidia-docker-toolkit
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/${distribution}/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt install -y nvidia-container-toolkit nvidia-container-runtime

# docker-ce
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo mkdir -p /etc/docker
sudo chmod 777 /etc/docker
echo > /etc/docker/daemon.json <<EOF
{
  "runtimes": {"nvidia": {"path": "/usr/bin/nvidia-container-runtime", "runtimeArgs": []}},
  "insecure-registries" : ["repo.myknowtions.com:5000"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
sudo apt-get install docker-ce docker-ce-cli containerd.io
sudo systemctl restart docker

# pgpool2 & postgresql 10
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ ${VERSION_CODENAME}-pgdg main"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# ceph
release_name="luminous"
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
sudo apt-add-repository "deb https://download.ceph.com/debian-${release_name}/ ${codename} main"


sudo apt clean
sudo apt-get update

# for apt repo creation 
# sudo apt-get install dpkg-dev



# sudo apt-get install -y nvidia-container-toolkit
# sudo systemctl restart docker


# docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
