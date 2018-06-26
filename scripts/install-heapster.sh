#!/bin/bash


#################################################
#Install monitoring tool, Heapster on kubernetes#
#################################################


CONTROLLER="../templates/heapster-controller.yaml"
RBACG="../templates/heapster-rbac.yaml"


#Install controler and 
kubectl create -f $CONTROLLER
kubectl creat -f $RBACG
