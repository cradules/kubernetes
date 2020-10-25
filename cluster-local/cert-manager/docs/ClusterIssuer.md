# Route53
This guide explains how to set up an Issuer, or ClusterIssuer, to use Amazon Route53 to solve [DNS01 ACME challenges](https://cert-manager.io/docs/configuration/acme/dns01/). It’s advised you read the DNS01 Challenge Provider page first for a more general understanding of how cert-manager handles DNS01 challenges.

## Set up an IAM Role
Check the policy applied and attached to cluster by [terraform](https://gitlab.ops.connatix.com/connatix/infra/Connatix.DevOps.Terraform/-/blob/master/aws/platforms/eks/modules/iam-policies/all.json
)

```json
    {
      "Sid": "CertManagerStagingR53Change",
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Sid": "CertManagerStagingR53Set",
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*"
    },
    {
       "Sid": "CertManagerStagingR53List",
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }

```

The permission to cert-manager for interacting with the zone is done by the EKS role that is attache as iam profile with above policy. There is no need to create assume role policy.

The issuer is can be found in same location as README.md and is specific for each environment. 

To apply the issuer for an environment, in out case staging use kubectl command:
```bash
kubectl apply -f cluster-issuer-staging.yaml
```