#!/bin/bash

rm -f vars.sh 2>/dev/null
cp ../../vars.sh vars.sh 
podman login ${REGISTRY_URL} 
buildah bud -f Dockerfile -t ${REGISTRY_URL}/${INIT_IMAGE_NAME}
podman push ${REGISTRY_URL}/${INIT_IMAGE_NAME}

