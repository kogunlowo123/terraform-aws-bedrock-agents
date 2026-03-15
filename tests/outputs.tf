output "agent_id" {
  description = "The unique identifier of the Bedrock Agent"
  value       = module.bedrock_agents.agent_id
}

output "agent_arn" {
  description = "The ARN of the Bedrock Agent"
  value       = module.bedrock_agents.agent_arn
}

output "knowledge_base_id" {
  description = "The unique identifier of the knowledge base"
  value       = module.bedrock_agents.knowledge_base_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for the knowledge base"
  value       = module.bedrock_agents.s3_bucket_arn
}
