# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "cluster_name" {
  description = "Name of the kubernetes cluster"
}

variable "domains" {
  description = "domain name for ingress"
}

variable "vpc_id" {
  description = "domain name for ingress"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "certificates_arns" {
  type        = list(string)
  description = "List of certificates to attach to ingress"
  default     = []
}

variable "cluster_oidc_url" {
  type = string
}