#!/bin/bash

podman login ${REGISTRY_URL} 
buildah bud -f Dockerfile -t ${REGISTRY_URL}/${UERAMSIM_IMAGE_NAME}
podman push ${REGISTRY_URL}/${UERAMSIM_IMAGE_NAME}

