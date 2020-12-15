#!/bin/bash -e
image_repo="registry.redhat.io/rhel7.8"
image_tag="latest"
docker_image="${image_repo}:${image_tag}"
container_name="r7_test"
