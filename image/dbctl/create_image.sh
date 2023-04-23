#!/bin/bash

podman login ${REGISTRY_URL} 
buildah bud -f Dockerfile -t ${DBCTL_IMAGE_NAME}:${IMAGE_TAG}
podman tag localhost/${DBCTL_IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY_URL}/${DBCTL_IMAGE_NAME}:${IMAGE_TAG}
podman push ${REGISTRY_URL}/${DBCTL_IMAGE_NAME}:${IMAGE_TAG}

