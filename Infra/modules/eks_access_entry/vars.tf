variable "role_name" {
  description = "Name of an existing IAM role to grant EKS access to."
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster to grant access to."
  type        = string
}

variable "namespaces" {
  description = "Namespaces to scope the AmazonEKSEditPolicy access to. Empty list scopes access to the whole cluster."
  type        = list(string)
  default     = []
}
