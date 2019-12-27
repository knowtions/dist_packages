#!/bin/bash -e
image_repo="centos7-systemd"
image_tag="latest"
docker_image="${image_repo}:${image_tag}"
container_name="c7_test"

# Build docker image by Dockerfile
docker images | grep ${image_repo} | grep | ${image_tag} || docker build --rm -t ${image_repo}:${image_tag} .

# Create container for building repo
if [[ ${1} == "-f" ]] && [[ -n `docker ps --filter "name=${container_name}" -qa` ]]; then
  echo "Remove ${container_name} docker container"
  docker rm -f ${container_name}
fi

if [[ -z `docker ps --filter "name=${container_name}" -qa` ]]; then
docker run \
  -d \
  --name "${container_name}" \
  --privileged=true \
  --hostname docker-centos7 \
  --network host \
  -v /home/ubuntu/dists/dist_packages/system_packages/c7:/workdir \
  ${docker_image}
fi

# Build Repo
docker exec -it ${container_name} bash /workdir/01_setup.sh
docker exec -it ${container_name} bash
