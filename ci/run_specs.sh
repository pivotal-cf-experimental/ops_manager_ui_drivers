#!/bin/bash
set -ex

echo "-----> Running script: $0"

docker run \
  --rm=true \
  --volume=${PWD}:/vm_shepherd \
  --workdir=/ops_manager_ui_drivers \
  ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME} \
  /bin/sh -c 'bundle && bundle exec rake -t'
