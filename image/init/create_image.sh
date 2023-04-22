#!/bin/bash

rm -f vars.sh 2>/dev/null
cp ../../vars.sh vars.sh 
podman login ${REGISTRY_URL} 
buildah bud -f Dockerfile -t ${INIT_IMAGE_NAME}:${IMAGE_TAG}
podman tag localhost/${INIT_IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY_URL}/${INIT_IMAGE_NAME}:${IMAGE_TAG}
podman push ${REGISTRY_URL}/${INIT_IMAGE_NAME}:${IMAGE_TAG}

