#!/bin/bash -e
source set_vars_r7.sh

# Build docker image by Dockerfile
docker images | grep ${image_repo} | grep ${image_tag} || docker build --rm -t ${image_repo}:${image_tag} .

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
  --hostname docker-rhel7 \
  --network host \
  -v /home/ubuntu/dists/dist_packages/system_packages/c7:/workdir \
  ${docker_image} \
  tail -f /dev/null
fi

# Build Repo
docker exec -it ${container_name} bash /workdir/01_setup_r7.sh
