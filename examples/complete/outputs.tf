output "agent_id" {
  description = "The unique identifier of the Bedrock Agent"
  value       = module.bedrock_agent.agent_id
}

output "agent_arn" {
  description = "The ARN of the Bedrock Agent"
  value       = module.bedrock_agent.agent_arn
}

output "agent_alias_id" {
  description = "The unique identifier of the agent alias"
  value       = module.bedrock_agent.agent_alias_id
}

output "knowledge_base_id" {
  description = "The unique identifier of the knowledge base"
  value       = module.bedrock_agent.knowledge_base_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for the knowledge base"
  value       = module.bedrock_agent.s3_bucket_arn
}

output "opensearch_collection_endpoint" {
  description = "The endpoint of the OpenSearch Serverless collection"
  value       = module.bedrock_agent.opensearch_collection_endpoint
}

output "action_group_ids" {
  description = "Map of action group names to their IDs"
  value       = module.bedrock_agent.action_group_ids
}
