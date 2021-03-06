#!/bin/bash
set -euo pipefail

## installing using helm
##

##creating namespace
if ! kubectl get namespace $CONJUR_NAMESPACE > /dev/null
then
    kubectl create namespace "$CONJUR_NAMESPACE"

fi

helm init
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller --upgrade

helm repo add cyberark https://cyberark.github.io/helm-charts
helm repo update

sleep 5

helm install cyberark/conjur-oss \
    --set ssl.hostname=$CONJUR_HOSTNAME_SSL,dataKey="$(docker run --rm cyberark/conjur data-key generate)",authenticators="authn-k8s/dev\,authn" \
    --namespace "$CONJUR_NAMESPACE" \
    --name "$CONJUR_APP_NAME"

#helm install cyberark/conjur-oss \
#    --set ssl.hostname=$CONJUR_HOSTNAME_SSL,dataKey="$(docker run --rm cyberark/conjur data-key generate)",authenticators="authn-k8s/dev\,authn",serviceAccount.name=$CONJUR_SERVICEACCOUNT_NAME,serviceAccount.create=false \
#    --namespace "$CONJUR_NAMESPACE" \
#    --name "$CONJUR_APP_NAME"

echo "press crtl-c when the External IP appears... "
kubectl get svc -w conjur-oss-ingress -n $CONJUR_NAMESPACE