variable "namespace" {
  type        = string
  description = "The namespace to install the ALBC into."
  default     = "k8s-device-plugin"

}

variable "chart_version" {
  type    = string
  default = "0.19.3"
}

variable "values" {
  type        = map(string)
  description = "A map of key-value pairs to set on the Fluent Bit deployment."
  default     = {}
}