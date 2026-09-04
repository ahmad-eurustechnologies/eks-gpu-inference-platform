variable "istio_base_values" {
    type        = map(string)
    description = "A map of key-value pairs to set on the Istio Base chart."
    default = {

    }
}

variable "istiod_values" {
    type        = map(string)
    description = "A map of key-value pairs to set on the Istiod chart."
    default = {

    }
}


variable "namespace" {
    type        = string
    description = "The namespace to install the ALBC into."
    default     = "istio-system"
  
}

variable "eks_cluster_name" {
  type = string
  description = "Name of EKS Cluster"
}

variable "istio_version" {
  type = string
  default = "1.30.3"
}

variable "domain_name" {
  type = string
  description = "Domain name for the ACM certificate"
  default = "ahmadk.link"
}