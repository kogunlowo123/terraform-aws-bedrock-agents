variable "agent_name" {
  description = "Name of the Bedrock Agent"
  type        = string
}

variable "foundation_model" {
  description = "Foundation model identifier for the agent"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

variable "instruction" {
  description = "Instruction prompt that defines the agent's behavior and capabilities"
  type        = string
}

variable "idle_session_ttl" {
  description = "Idle session TTL in seconds for the agent"
  type        = number
  default     = 600
}

variable "knowledge_base_name" {
  description = "Name of the knowledge base associated with the agent"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for knowledge base documents"
  type        = string
}

variable "embedding_model" {
  description = "Embedding model ARN for the knowledge base vector store"
  type        = string
  default     = "amazon.titan-embed-text-v2:0"
}

variable "vector_store_type" {
  description = "Type of vector store for the knowledge base (OPENSEARCH_SERVERLESS or PINECONE)"
  type        = string
  default     = "OPENSEARCH_SERVERLESS"

  validation {
    condition     = contains(["OPENSEARCH_SERVERLESS", "PINECONE"], var.vector_store_type)
    error_message = "vector_store_type must be either OPENSEARCH_SERVERLESS or PINECONE."
  }
}

variable "action_groups" {
  description = "List of action groups to attach to the agent"
  type = list(object({
    name                  = string
    description           = string
    api_schema_s3_key     = optional(string)
    api_schema_payload    = optional(string)
    lambda_function_name  = optional(string)
    lambda_runtime        = optional(string, "python3.12")
    lambda_handler        = optional(string, "index.handler")
    lambda_source_dir     = optional(string)
    lambda_timeout        = optional(number, 30)
    lambda_memory_size    = optional(number, 256)
    skip_resource_in_use_check = optional(bool, false)
  }))
  default = []
}

variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "agent_description" {
  description = "Description of the Bedrock Agent"
  type        = string
  default     = ""
}

variable "prepare_agent" {
  description = "Whether to prepare the agent after creation"
  type        = bool
  default     = true
}

variable "knowledge_base_description" {
  description = "Description of the knowledge base"
  type        = string
  default     = "Knowledge base for Bedrock Agent"
}

variable "s3_data_source_prefix" {
  description = "S3 key prefix for knowledge base data source inclusion"
  type        = string
  default     = ""
}

variable "opensearch_collection_name" {
  description = "Name for the OpenSearch Serverless collection"
  type        = string
  default     = ""
}

variable "vector_index_name" {
  description = "Name of the vector index in the vector store"
  type        = string
  default     = "bedrock-knowledge-base-index"
}

variable "vector_field_name" {
  description = "Name of the vector field in the index"
  type        = string
  default     = "embedding"
}

variable "text_field" {
  description = "Name of the text field in the index"
  type        = string
  default     = "text"
}

variable "metadata_field" {
  description = "Name of the metadata field in the index"
  type        = string
  default     = "metadata"
}
