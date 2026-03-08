output "agent_id" {
  description = "The unique identifier of the Bedrock Agent"
  value       = aws_bedrockagent_agent.this.agent_id
}

output "agent_arn" {
  description = "The ARN of the Bedrock Agent"
  value       = aws_bedrockagent_agent.this.agent_arn
}

output "agent_alias_id" {
  description = "The unique identifier of the agent alias"
  value       = aws_bedrockagent_agent_alias.this.agent_alias_id
}

output "knowledge_base_id" {
  description = "The unique identifier of the knowledge base"
  value       = aws_bedrockagent_knowledge_base.this.id
}

output "knowledge_base_arn" {
  description = "The ARN of the knowledge base"
  value       = aws_bedrockagent_knowledge_base.this.arn
}

output "action_group_ids" {
  description = "Map of action group names to their IDs"
  value       = { for k, v in aws_bedrockagent_agent_action_group.this : k => v.action_group_id }
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for the knowledge base"
  value       = aws_s3_bucket.knowledge_base.arn
}

output "opensearch_collection_arn" {
  description = "The ARN of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.this.arn
}

output "opensearch_collection_endpoint" {
  description = "The endpoint of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.this.collection_endpoint
}

output "agent_role_arn" {
  description = "The ARN of the IAM role used by the Bedrock Agent"
  value       = aws_iam_role.bedrock_agent.arn
}

output "knowledge_base_role_arn" {
  description = "The ARN of the IAM role used by the Knowledge Base"
  value       = aws_iam_role.knowledge_base.arn
}
