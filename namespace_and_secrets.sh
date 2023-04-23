
export NAMESPACE="open5gs"
export REGISTRY_SECRET_NAME="open5gs-secret"
export REGISTRY_URL="registry.kube.int/open5gs"
echo "Enter the retistry url: Default: ${REGISTRY_URL}"

read r
if [ ! -z "${r}" ]; then 
   REGISTRY_URL=${r}
fi

podman login ${REGISTRY_URL}
kubectl create namespace ${NAMESPACE}
kubectl config set-context --current --namespace=${NAMESPACE}
kubectl label namespace ${NAMESPACE} istio-injection=enabled


kubectl delete secret ${REGISTRY_SECRET_NAME}
kubectl create secret generic ${REGISTRY_SECRET_NAME} \
    --from-file=.dockerconfigjson=${XDG_RUNTIME_DIR}/containers/auth.json \
    --type=kubernetes.io/dockerconfigjson
kubectl get secret ${REGISTRY_SECRET_NAME}


# HNET keys:
cwd=`pwd`
tmp_dir=`mktemp -d`
cd ${tmp_dir}
mkdir hnet
cd hnet

# Create curve25519 keys:
for i in 1 3 5; do openssl genpkey -algorithm X25519 -out curve25519-${i}.key; done

# Generate ec  keys:
for i in 2 4 6; do
openssl ecparam -name secp256k1 -out secp256k1.pem
openssl ecparam -in secp256k1.pem -genkey -noout -out secp256k1-key.pem
cat secp256k1.pem > secp256r1-${i}.key
cat secp256k1-key.pem >> secp256r1-${i}.key
rm sec*.pem
done

cd ${tmp_dir}
kubectl create secret generic  hnet --from-file=hnet/
cd ${cwd}

