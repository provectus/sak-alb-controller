locals {
  argocd_enabled = length(var.argocd) > 0 ? 1 : 0
  namespace      = coalescelist(kubernetes_namespace.this, [{ "metadata" = [{ "name" = var.namespace }] }])[0].metadata[0].name
}

locals {
  vpc_id        = var.vpc_id
  repository    = "https://aws.github.io/eks-charts"
  name          = "alb"
  chart         = "aws-load-balancer-controller"
  chart_version = var.chart_version
  conf          = merge(local.conf_defaults, var.conf)
  conf_defaults = {
    "resources.limits.cpu"      = "100m",
    "resources.limits.memory"   = "128Mi",
    "resources.requests.cpu"    = "50m",
    "resources.requests.memory" = "64Mi",
    "region"                    = data.aws_region.current.name
    "serviceAccount.create"     = false,
    "serviceAccount.name"       = local.name,
    "clusterName" : data.aws_eks_cluster.this.name,
    "ingressClass" : "alb",
    "disableIngressClassAnnotation" : false,
    "createIngressClassResource" : true,
    "vpcId" : local.vpc_id

  }
  application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.repository
        "targetRevision" = local.chart_version
        "chart"          = local.chart
        "helm" = {
          "parameters" = values({
            for key, value in local.conf :
            key => {
              "name"  = key
              "value" = tostring(value)
            }
          })
        }
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }
}