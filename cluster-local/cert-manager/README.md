# Cert Manager
cert-manager runs within your Kubernetes cluster as a series of deployment resources. It utilizes [CustomResourceDefinitions](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources) to configure Certificate Authorities and request certificates.

It is deployed using regular YAML manifests, like any other application on Kubernetes.

Once cert-manager has been deployed, you must configure Issuer or ClusterIssuer resources which represent certificate authorities. More information on configuring different Issuer types can be found in the [respective configuration guides](https://cert-manager.io/docs/configuration/).

## Installing with Helm 
### Prerequisites
- Helm v3 installed

## Steps

- Create the namespace for cert-manager:
```bash
kubectl create namespace cert-manager
```
- Add the Jetstack Helm repository:
   
 ***Warning: It is important that this repository is used to install cert-manager. The version residing in the helm stable repository is deprecated and should not be used.
To automatically install and manage the CRDs as part of your Helm release, you must add the --set installCRDs=true flag to your Helm installation command.***

```bash
helm repo add jetstack https://charts.jetstack.io
```

- Update your local Helm chart repository cache:
```bash
helm repo update
```

- Install the cert-manager Helm chart
```bash
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.0.1 \
  --set installCRDs=true
```

## Verifying the installation
Once you’ve installed cert-manager, you can verify it is deployed correctly by checking the cert-manager namespace for running pods:
```bash
kubectl get pods --namespace cert-manager

NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-5c6866597-zw7kh               1/1     Running   0          2m
cert-manager-cainjector-577f6d9fd7-tr77l   1/1     Running   0          2m
cert-manager-webhook-787858fcdb-nlzsq      1/1     Running   0          2m
```
You should see the cert-manager, cert-manager-cainjector, and cert-manager-webhook pod in a Running state. It may take a minute or so for the TLS assets required for the webhook to function to be provisioned. This may cause the webhook to take a while longer to start for the first time than other pods. If you experience problems, please check the FAQ guide.

The following steps will confirm that cert-manager is set up correctly and able to issue basic certificate types.

Create an Issuer to test the webhook works okay.
```bash
 cat <<EOF > test-resources.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager-test
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: test-selfsigned
  namespace: cert-manager-test
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: selfsigned-cert
  namespace: cert-manager-test
spec:
  dnsNames:
    - example.com
  secretName: selfsigned-cert-tls
  issuerRef:
    name: test-selfsigned
EOF
```

- Create the test resources.
```bash
kubectl apply -f test-resources.yaml
```

- Check the status of the newly created certificate. You may need to wait a few seconds before cert-manager processes the certificate request.
```bash
kubectl describe certificate -n cert-manager-test

...
Spec:
  Common Name:  example.com
  Issuer Ref:
    Name:       test-selfsigned
  Secret Name:  selfsigned-cert-tls
Status:
  Conditions:
    Last Transition Time:  2019-01-29T17:34:30Z
    Message:               Certificate is up to date and has not expired
    Reason:                Ready
    Status:                True
    Type:                  Ready
  Not After:               2019-04-29T17:34:29Z
Events:
  Type    Reason      Age   From          Message
  ----    ------      ----  ----          -------
  Normal  CertIssued  4s    cert-manager  Certificate issued successfully
```

- Clean up the test resources.
```bash
kubectl delete -f test-resources.yaml
```

For installing the Issuer please check [ClusterIssuer doc](./docs/ClusterIssuer.md)

[Source](https://cert-manager.io/docs/installation/kubernetes/)

