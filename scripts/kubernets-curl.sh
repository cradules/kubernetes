#!/usr/bin/env bash

######################### Overview ######################################################################################################
#Using the Kubernetes API,kubectlmakes API calls for you. With the appropriate TLS keys you could run curl as well use a golang client.
#Calls to the kube-apiserverget or set a PodSpec, or desired state.  If the request represents a new state the Kubernetes
#Control Plane will update the cluster until the current state matches the specified state.Some end states may require multiple requests.
#For example, to delete a ReplicaSet, you would first set the number of replicas to zero, then delete the ReplicaSet.
#An API request must pass information as JSON. kubectl converts .yaml to JSON when making an API request onyour behalf.
#The API request has many settings, but must includea piVersion, kind and metadata, and spec settings to declare what kind of container to deploy.
#The specfields depend on the object being created.
#############################################################################################################################################

set -x

SERVER=$(grep server "$HOME"/.kube/config | awk '{print $2}')
CERT_PATH="$HOME/kube-cert"

function usage() {
     echo $"Usage: $0 {-get-endpoints|-gse|-create}"
}

if [[ ! -d $CERT_PATH ]]
  then
  #Read Cluster information from kube config
  CLIENT=$(grep client-cert "$HOME"/.kube/config |cut -d" " -f 6)
  KEY=$(grep client-key-data "$HOME"/.kube/config |cut -d " " -f 6)
  AUTH=$(grep certificate-authority-data "$HOME"/.kube/config |cut -d " " -f 6)

  #Create pem files
  mkdir "$CERT_PATH"
  echo "$CLIENT" | base64 -d - > "$CERT_PATH/client.pem"
  echo "$KEY" | base64 -d - > "$CERT_PATH/client-key.pem"
  echo "$AUTH" | base64 -d - > "$CERT_PATH/ca.pem"
fi


case $1 in
    -get-endpoints)
            curl  --cert "$CERT_PATH/client.pem" \
              --key "$CERT_PATH/client-key.pem" \
              --cacert "$CERT_PATH/ca.pem" \
              "$SERVER"
        ;;
    -gse)
            curl --cert "$CERT_PATH/client.pem" \
              --key "$CERT_PATH/client-key.pem" \
              --cacert "$CERT_PATH/ca.pem" \
              "$SERVER""$2"
        ;;
    -create)
            curl --cert "$CERT_PATH/client.pem" \
              --key "$CERT_PATH/client-key.pem" \
              --cacert "$CERT_PATH/ca.pem" \
              "$SERVER""$2" -XPOST -H'Content-Type: application/json'\
              -d@"$3"
        ;;
      *)
        usage
        ;;
esac