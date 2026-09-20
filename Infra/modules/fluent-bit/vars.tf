variable "values" {
  type        = map(string)
  description = "A map of key-value pairs to set on the Fluent Bit deployment."
  default = {

  }
}

variable "namespace" {
  type        = string
  description = "The namespace to install the Fluent Bit into."
  default     = "aws-for-fluent-bit"

}

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "The OIDC issuer URL for the EKS cluster."
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of EKS Cluster"
}