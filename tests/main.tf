module "bedrock_agents" {
  source = "../"

  agent_name       = "test-bedrock-agent"
  agent_description = "Test Bedrock Agent for validation"
  foundation_model = "anthropic.claude-3-sonnet-20240229-v1:0"
  instruction      = "You are a helpful assistant that answers questions based on the knowledge base."

  idle_session_ttl = 600
  prepare_agent    = false

  knowledge_base_name        = "test-knowledge-base"
  knowledge_base_description = "Test knowledge base for validation"
  s3_bucket_name             = "test-bedrock-kb-documents"
  s3_data_source_prefix      = "documents/"

  embedding_model    = "amazon.titan-embed-text-v2:0"
  vector_store_type  = "OPENSEARCH_SERVERLESS"
  vector_index_name  = "bedrock-knowledge-base-index"
  vector_field_name  = "embedding"
  text_field         = "text"
  metadata_field     = "metadata"

  action_groups = []

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}
