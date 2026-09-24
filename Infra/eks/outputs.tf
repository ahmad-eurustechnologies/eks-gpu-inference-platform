output "cluster_name" {
  value = module.eks.cluster_name
}

output "eks_managed_node_groups_iam_role_name" {
  value = module.eks.eks_managed_node_groups["${keys(module.eks.eks_managed_node_groups)[0]}"].iam_role_name
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}