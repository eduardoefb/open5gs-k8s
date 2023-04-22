
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

# HNET:
kubectl create secret generic  hnet --from-file=hnet/
