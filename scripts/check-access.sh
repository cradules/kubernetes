#! /bin/bash

# Check kubernets acess

USER=$1
NAMESPACE=$2

echo "Can I create deployments"
kubectl auth can-i create deployments

echo "Can I create deployments as $USER"
kubectl auth can-i create deployments --as "$USER"

echo "Can i create deployments as $USER in namespace $NAMESPACE"
kubectl auth can-i create deployments --as "$USER" --namespace "$NAMESPACE"