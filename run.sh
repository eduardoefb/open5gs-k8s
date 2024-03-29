#!/bin/bash

# Define the images and tags in the format: <image_name>:<image_tag>
export UERAMSIM_IMAGE_NAME="ueramsim:0.0.2"
export INIT_IMAGE_NAME="init:0.0.2"
export OPEN5GS_IMAGE_NAME="open5gs:0.0.2"
export DBCTL_IMAGE_NAME="dbctl:0.0.2"
export DEBUG_IMAGE_NAME="debug:0.0.2"
export TEST_IMAGE_NAME="testpod:0.0.2"

# Define the registry fqdn:
export REGISTRY_URL="registry.kube.int/open5gs"

# Other variables:
export PREFIX="open5gs"
export NAMESPACE="open5gs"
export REGISTRY_SECRET_NAME="registry"
export MCC="724"
export MNC="17"
export TAC="100"
export ISTIO_DOMAIN="${NAMESPACE}.int"
export INSTALLATION_NAME="open5gs"
export IMAGE_VERSION="0.0.2"
export HELM_VERSION="0.0.2"

function build(){  
  max_attempts=10  
  cwd=`pwd`
  for image_dir in images/*; do
    cd ${cwd}
    cd ${image_dir}
    attempts=0
    while :; do      
      if ! bash create_image.sh; then
        echo " ${image_dir} build error!"
        if [ ${attempts} -gt ${max_attempts} ]; then 
          set +x
          exit 1
        fi
      else
        break
      fi
      attempts=$((${attempts}+1))
    done
  done
}

function deploy(){
  cwd=`pwd`  
  kubectl delete namespace ${NAMESPACE} >/dev/null 2>&1
  kubectl create namespace ${NAMESPACE}
  kubectl config set-context --current --namespace=${NAMESPACE}
  kubectl label namespace ${NAMESPACE} istio-injection=enabled

  kubectl delete secret ${REGISTRY_SECRET_NAME}  >/dev/null 2>&1
  kubectl create secret generic ${REGISTRY_SECRET_NAME} \
      --from-file=.dockerconfigjson=${XDG_RUNTIME_DIR}/containers/auth.json \
      --type=kubernetes.io/dockerconfigjson
  kubectl get secret ${REGISTRY_SECRET_NAME}


  # HNET keys:
  tmp_dir=`mktemp -d`
  cd ${tmp_dir}
  mkdir hnet
  cd hnet

  # Create curve25519 keys:
  for i in 1 3 5; do openssl genpkey -algorithm X25519 -out curve25519-${i}.key; done

  # Generate ec keys:
  for i in 2 4 6; do
    openssl ecparam -name secp256k1 -out secp256k1.pem
    openssl ecparam -name prime256v1 -in secp256k1.pem -genkey -noout -out secp256k1-key.pem    
    cat secp256k1.pem > secp256r1-${i}.key
    cat secp256k1-key.pem >> secp256r1-${i}.key
    rm sec*.pem
  done

  cd ${tmp_dir}
  kubectl create secret generic  hnet --from-file=hnet/
  cd ${cwd}  

  # Install open5gs
  helm install ${INSTALLATION_NAME} helm/open5gs -f values.yaml --wait --debug --timeout 6000s

}

function usage(){
  echo "Usage:"
  echo "${0} <build>|<deploy>"
  exit 1
}

if [ -z "${1}" ]; then
  usage
fi

if [ "${1}" == "build" ]; then
  cat /dev/null
elif [ "${1}" == "deploy" ]; then
  cat /dev/null
else
  usage
fi

cwd=`pwd`

echo "Enter the retistry url: Default: ${REGISTRY_URL}"
read r
if [ ! -z "${r}" ]; then 
  REGISTRY_URL=${r}
fi
echo ${REGISTRY_URL} > REGISTRY_URL

podman login ${REGISTRY_URL}

## Create .values file:

storageclass_name=`kubectl get storageclass -o=jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{end}'`
if [ -z "${storageclass_name}" ]; then 
  use_pvc="False"
else
  use_pvc="True"
fi
export use_pvc
export storageclass_name
envsubst < values.yaml.template > values.yaml

cd ${cwd}
if [ "${1}" == "build" ]; then
  build
elif [ "${1}" == "deploy" ]; then
  deploy
else
  usage
fi

