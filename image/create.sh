#!/bin/bash

export UERAMSIM_IMAGE_NAME="ueramsim"
export INIT_IMAGE_NAME="init"
export OPEN5GS_IMAGE_NAME="open5gs"
export IMAGE_TAG="0.0.1"
export REGISTRY_URL="registry.kube.int/open5gs"


cwd=`pwd`
# Clear images
podman rmi --all -f

# Build open5gs image
cd open5gs
if ! bash create_image.sh; then
  echo " open5gs image build error!"
  exit 1
fi

cd ${cwd}

# Build ueramsim image
cd ueramsim
if ! bash create_image.sh; then 
  echo " ueramsim image build error!"
  exit 1
fi

cd ${cwd}

# Build init image
cd init
if ! bash create_image.sh; then 
  echo " init image build error!"
  exit 1
fi
