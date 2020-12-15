#!/bin/bash -e
#image_repo="centos7-systemd"
#image_tag="latest"
image_repo="centos"
image_tag="7.8.2003"
docker_image="${image_repo}:${image_tag}"
container_name="c7_test"
