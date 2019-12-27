#!/bin/bash -e
image_repo="centos7-systemd"
image_tag="latest"
docker_image="${image_repo}:${image_tag}"
container_name="c7_test"
