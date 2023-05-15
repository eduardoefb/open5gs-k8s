#!/bin/bash

podman login ${REGISTRY_URL} 
ulimit -n 65535 && buildah bud -f Dockerfile -t${REGISTRY_URL}/${TEST_IMAGE_NAME}:${IMAGE_TAG}
podman push ${REGISTRY_URL}/${TEST_IMAGE_NAME}:${IMAGE_TAG}

