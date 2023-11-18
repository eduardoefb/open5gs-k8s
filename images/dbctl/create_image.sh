#!/bin/bash

podman login ${REGISTRY_URL} 
buildah bud -f Dockerfile -t ${REGISTRY_URL}/${DBCTL_IMAGE_NAME}
podman push ${REGISTRY_URL}/${DBCTL_IMAGE_NAME}

