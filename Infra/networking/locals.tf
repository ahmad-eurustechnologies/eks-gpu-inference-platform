locals {
  folder_array = split("/", abspath("."))

  created_by = join("/", ["https://github.com/ahmadkaleem2"], slice(local.folder_array, index(local.folder_array, "EKS-GPU-Inference-Platform"), length(local.folder_array)))

  # created_by = join("/", ["https://github.com/ahmadkaleem2"], slice(local.folder_array, index(local.folder_array, "EKS-GPU-Inference-Platform"), length(local.folder_array)))
}