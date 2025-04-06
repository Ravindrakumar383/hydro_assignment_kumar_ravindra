output "node_group_name" {
  description = "Name of the EKS node group"
  value       = aws_eks_node_group.dagster_nodes.node_group_name
}

output "node_role_arn" {
  description = "ARN of the IAM role used by the EKS node group"
  value       = aws_iam_role.eks_node.arn
}