#!/usr/bin/env bash

######################### Overview ######################################################################################################
#Using the Kubernetes API,kubectlmakes API calls for you. With the appropriate TLS keys you could runcurlas welluse agolangclient.
#Calls to thekube-apiserverget or set a PodSpec, or desired state.  If the request representsa new state theKubernetes
#Control Planewill update the cluster until the current state matches the specified state.Some end states may require multiple requests.
#For example, to delete aReplicaSet, you would first set the numberof replicas to zero, then delete theReplicaSet.
#An API request must pass information as JSON.kubectlconverts.yamlto JSON when making an API request onyour behalf.
#The API request has many settings, but must includeapiVersion,kindandmetadata, andspecsettingsto declare what kind of container to deploy.
#hespecfields depend on the object being created.We will begin by configuring remote access to thekube-apiserverthen explore more of the API.
#############################################################################################################################################


#Create pem files
SERVER=$(grep server "$HOME"/.kube/config | awk '{print $2}')
CERT_PATH="$HOME/kube-cert"

if [[ ! -d $CERT_PATH ]]
  then
  #Read Cluster information from kube config
  CLIENT=$(grep client-cert "$HOME"/.kube/config |cut -d" " -f 6)
  KEY=$(grep client-key-data "$HOME"/.kube/config |cut -d " " -f 6)
  AUTH=$(grep certificate-authority-data "$HOME"/.kube/config |cut -d " " -f 6)
  mkdir "$CERT_PATH"
  echo "$CLIENT" | base64 -d - > "$CERT_PATH/client.pem"
  echo "$KEY" | base64 -d - > "$CERT_PATH/client-key.pem"
  echo "$AUTH" | base64 -d - > "$CERT_PATH/ca.pem"
fi


if [[ -z $1 ]]
  then
  curl  --cert "$CERT_PATH/client.pem" \
      --key "$CERT_PATH/client-key.pem" \
      --cacert "$CERT_PATH/ca.pem" \
        "$SERVER"
  else
      curl --cert "$CERT_PATH/client.pem" \
      --key "$CERT_PATH/client-key.pem" \
      --cacert "$CERT_PATH/ca.pem" \
        "$SERVER""$1"
fi