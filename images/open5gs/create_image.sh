#!/bin/bash

podman login ${REGISTRY_URL} 
ulimit -n 65535 && buildah bud -f Dockerfile -t${REGISTRY_URL}/${OPEN5GS_IMAGE_NAME}
podman push ${REGISTRY_URL}/${OPEN5GS_IMAGE_NAME}

