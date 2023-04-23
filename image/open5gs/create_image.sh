#!/bin/bash

podman login ${REGISTRY_URL} 
ulimit -n 65535 && buildah bud -f Dockerfile -t ${OPEN5GS_IMAGE_NAME}:${IMAGE_TAG}
podman tag localhost/${OPEN5GS_IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY_URL}/${OPEN5GS_IMAGE_NAME}:${IMAGE_TAG}
podman push ${REGISTRY_URL}/${OPEN5GS_IMAGE_NAME}:${IMAGE_TAG}

