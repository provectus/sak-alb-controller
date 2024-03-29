## Overview

[AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) is a controller to help manage Elastic Load Balancers for a Kubernetes cluster.

When you create a Kubernetes ingress, an AWS Application Load Balancer (ALB) is provisioned that load balances application traffic. To learn more, see [What is an Application Load Balancer?](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) in the _Application Load Balancers User Guide_ and [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) in the Kubernetes documentation. ALBs can be used with pods that are deployed to nodes or to AWS Fargate. You can deploy an ALB to public or private subnets.

- **Application Load Balancer** - It satisfies Kubernetes [Ingress resources](https://kubernetes.io/docs/concepts/services-networking/ingress/) by provisioning [Application Load Balancers](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- **Network Load Balancer** - It satisfies Kubernetes [Service resources](https://kubernetes.io/docs/concepts/services-networking/service/) by provisioning [Network Load Balancers](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html).

## How it works (Application Load Balancer)

- **The following diagram details the AWS components this controller creates. It also demonstrates the route ingress traffic takes from the ALB to the Kubernetes cluster.**

![alt text](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/assets/images/controller-design.png)

## Example manifest to provision a load balancer (kubectl apply -f example_below.yaml)

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-2048
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: app-2048
  replicas: 1
  template:
    metadata:
      labels:
        app.kubernetes.io/name: app-2048
    spec:
      containers:
      - image: public.ecr.aws/l6m2t8p7/docker-2048:latest
        imagePullPolicy: Always
        name: app-2048
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: service-2048
spec:
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: NodePort
  selector:
    app.kubernetes.io/name: app-2048
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-2048
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: service-2048
              port:
                number: 80
```

## Requirements

```
terraform >= 1.1
```

## Providers

| Name       | Version |
| ---------- | ------- |
| aws        | >= 3.0  |
| helm       | >= 1.0  |
| kubernetes | >= 1.11 |

## Inputs

| Name              | Description                                                   | Type          | Default          | Required |
| ----------------- | ------------------------------------------------------------- | ------------- | ---------------- | :------: |
| argocd            | A set of values for enabling deployment through ArgoCD        | `map(string)` | `{}`             |    no    |
| cluster_name      | The name of the cluster the charts will be deployed to        | `string`      | n/a              |   yes    |
| conf              | A set of parameters to pass to Nginx Ingress Controller chart | `map`         | `{}`             |    no    |
| module_depends_on | A list of explicit dependencies for the module                | `list`        | `[]`             |    no    |
| namespace         | A name of the existing namespace                              | `string`      | `"kube-system"`  |    no    |
| namespace_name    | A name of namespace for creating                              | `string`      | `"external-dns"` |    no    |
| tags              | A tags for attaching to new created AWS resources             | `map(string)` | `{}`             |    no    |
| vpc_id            | An ID of the VPC                                              | `string`      | `""`             |   yes    |

## Outputs

| Name        | Description          |
| ----------- | -------------------- |
| alb_ingress | ALB ingress resource |

## Example

This example demonstrates how you can use alb controller.

```hcl
module "alb-ingress" {
  depends_on   = [module.argocd]
  source       = "github.com/provectus/sak-alb-controller"
  cluster_name = module.eks.cluster_id
  vpc_id       = module.network.vpc_id
  argocd       = module.argocd.state
}
```
