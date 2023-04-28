#!/bin/bash

podman login ${REGISTRY_URL} 
buildah bud -f Dockerfile -t ${UERAMSIM_IMAGE_NAME}:${IMAGE_TAG}
podman tag localhost/${UERAMSIM_IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY_URL}/${UERAMSIM_IMAGE_NAME}:${IMAGE_TAG}
podman push ${REGISTRY_URL}/${UERAMSIM_IMAGE_NAME}:${IMAGE_TAG}

