#!/bin/bash

export UERAMSIM_IMAGE_NAME="ueramsim"
export INIT_IMAGE_NAME="init"
export OPEN5GS_IMAGE_NAME="open5gs"
export DBCTL_IMAGE_NAME="dbctl"
export IMAGE_TAG="0.0.3"
export REGISTRY_URL="registry.kube.int/open5gs"

set -x
cwd=`pwd`
podman login ${REGISTRY_URL}
# Clear images
podman rmi --all -f

# Build open5gs image
ulimit -n
ulimit -n 65535
cd open5gs
if ! bash create_image.sh; then
  echo " open5gs image build error!"
  set +x
  exit 1
fi

cd ${cwd}

# Build dbctl image
cd dbctl
if ! bash create_image.sh; then
  echo " dbctl image build error!"
  set +x
  exit 1
fi

cd ${cwd}

# Build ueramsim image
cd ueramsim
if ! bash create_image.sh; then 
  echo " ueramsim image build error!"
  set +x
  exit 1
fi

cd ${cwd}

# Build init image
cd init
if ! bash create_image.sh; then 
  echo " init image build error!"
  set +x
  exit 1
fi
set +x
