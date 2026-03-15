################################################################################
# Bedrock Agents - Complete Example
################################################################################

module "bedrock_agent" {
  source = "../../"

  agent_name        = "customer-support-agent"
  agent_description = "AI-powered customer support agent with knowledge base and action groups"
  foundation_model  = "anthropic.claude-3-sonnet-20240229-v1:0"
  instruction       = <<-EOT
    You are a customer support agent for an e-commerce platform. You help customers
    with order inquiries, returns, product information, and general support questions.
    Always be polite and professional. Use the knowledge base to find relevant product
    information and company policies. Use the available action groups to look up orders
    and process returns when requested.
  EOT

  idle_session_ttl = 900
  prepare_agent    = true

  knowledge_base_name        = "product-catalog-kb"
  knowledge_base_description = "Product catalog and company policy documents"
  s3_bucket_name             = "acme-corp-bedrock-kb-documents"
  s3_data_source_prefix      = "knowledge-base/"

  embedding_model             = "amazon.titan-embed-text-v2:0"
  vector_store_type           = "OPENSEARCH_SERVERLESS"
  opensearch_collection_name  = "bedrock-agent-vectors"
  vector_index_name           = "product-catalog-index"
  vector_field_name           = "embedding"
  text_field                  = "text"
  metadata_field              = "metadata"

  action_groups = [
    {
      name               = "OrderManagement"
      description        = "Look up and manage customer orders"
      api_schema_s3_key  = "schemas/order-management-api.json"
      lambda_runtime     = "python3.12"
      lambda_handler     = "index.handler"
      lambda_timeout     = 30
      lambda_memory_size = 256
    },
    {
      name               = "ReturnProcessing"
      description        = "Process customer return requests"
      api_schema_s3_key  = "schemas/return-processing-api.json"
      lambda_runtime     = "python3.12"
      lambda_handler     = "index.handler"
      lambda_timeout     = 60
      lambda_memory_size = 512
    }
  ]

  tags = {
    Project     = "customer-support-ai"
    Environment = "production"
    Team        = "ai-platform"
  }
}
