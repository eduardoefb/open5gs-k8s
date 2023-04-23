
export REGISTRY_SECRET_NAME="open5gs-secret"
export REGISTRY_URL="registry.kube.int/open5gs"
echo "Enter the retistry url: Default: ${REGISTRY_URL}"

read r
if [ ! -z "${r}" ]; then 
   REGISTRY_URL=${r}
fi

echo "Enter your registry username:"
read reg_user

while :; do
    echo "Enter your registry pass:"
    read -s reg_pass
    echo "Re-enter your registry pass:"
    read -s rereg_pass
    if [ "${reg_pass}" == "${rereg_pass}" ]; then
        break
    fi
    echo "Passwords don't match!"
done

REGISTRY_CREDENTIALS="${reg_user}:${reg_pass}"
cat << EOF > /tmp/secret.json
{
   "auths": {
      "registry.kube.int": {
         "auth": "`echo -n "${reg_user}:${reg_pass}" | base64`"
      }
   }
}
EOF

kubectl delete secret ${REGISTRY_SECRET_NAME}
kubectl create secret generic ${REGISTRY_SECRET_NAME} \
    --from-file=.dockerconfigjson=/tmp/secret.json \
    --type=kubernetes.io/dockerconfigjson
kubectl get secret ${REGISTRY_SECRET_NAME}
rm /tmp/secret.json

# HNET keys:
cwd=`pwd`
tmp_dir=`mktemp d`
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

