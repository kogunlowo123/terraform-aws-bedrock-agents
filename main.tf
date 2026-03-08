data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  account_id               = data.aws_caller_identity.current.account_id
  region                   = data.aws_region.current.name
  partition                = data.aws_partition.current.partition
  opensearch_collection_name = var.opensearch_collection_name != "" ? var.opensearch_collection_name : "${var.agent_name}-vectors"
}

# ------------------------------------------------------------------------------
# IAM Role for Bedrock Agent
# ------------------------------------------------------------------------------
resource "aws_iam_role" "bedrock_agent" {
  name = "${var.agent_name}-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "bedrock_agent_model" {
  name = "${var.agent_name}-model-invocation"
  role = aws_iam_role.bedrock_agent.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = "arn:${local.partition}:bedrock:${local.region}::foundation-model/${var.foundation_model}"
      }
    ]
  })
}

resource "aws_iam_role_policy" "bedrock_agent_kb" {
  name = "${var.agent_name}-kb-access"
  role = aws_iam_role.bedrock_agent.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:Retrieve",
          "bedrock:RetrieveAndGenerate"
        ]
        Resource = aws_bedrockagent_knowledge_base.this.arn
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# IAM Role for Knowledge Base
# ------------------------------------------------------------------------------
resource "aws_iam_role" "knowledge_base" {
  name = "${var.knowledge_base_name}-kb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "knowledge_base_model" {
  name = "${var.knowledge_base_name}-embedding-model"
  role = aws_iam_role.knowledge_base.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = "arn:${local.partition}:bedrock:${local.region}::foundation-model/${var.embedding_model}"
      }
    ]
  })
}

resource "aws_iam_role_policy" "knowledge_base_s3" {
  name = "${var.knowledge_base_name}-s3-access"
  role = aws_iam_role.knowledge_base.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.knowledge_base.arn,
          "${aws_s3_bucket.knowledge_base.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "knowledge_base_opensearch" {
  name = "${var.knowledge_base_name}-opensearch-access"
  role = aws_iam_role.knowledge_base.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aoss:APIAccessAll"
        ]
        Resource = aws_opensearchserverless_collection.this.arn
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# S3 Bucket for Knowledge Base Documents
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "knowledge_base" {
  bucket        = var.s3_bucket_name
  force_destroy = false

  tags = merge(var.tags, {
    Purpose = "bedrock-knowledge-base"
  })
}

resource "aws_s3_bucket_versioning" "knowledge_base" {
  bucket = aws_s3_bucket.knowledge_base.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "knowledge_base" {
  bucket = aws_s3_bucket.knowledge_base.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "knowledge_base" {
  bucket = aws_s3_bucket.knowledge_base.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# OpenSearch Serverless Collection for Vector Store
# ------------------------------------------------------------------------------
resource "aws_opensearchserverless_security_policy" "encryption" {
  name = "${local.opensearch_collection_name}-enc"
  type = "encryption"

  policy = jsonencode({
    Rules = [
      {
        ResourceType = "collection"
        Resource     = ["collection/${local.opensearch_collection_name}"]
      }
    ]
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_security_policy" "network" {
  name = "${local.opensearch_collection_name}-net"
  type = "network"

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection"
          Resource     = ["collection/${local.opensearch_collection_name}"]
        },
        {
          ResourceType = "dashboard"
          Resource     = ["collection/${local.opensearch_collection_name}"]
        }
      ]
      AllowFromPublic = true
    }
  ])
}

resource "aws_opensearchserverless_access_policy" "data" {
  name = "${local.opensearch_collection_name}-access"
  type = "data"

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index"
          Resource     = ["index/${local.opensearch_collection_name}/*"]
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument"
          ]
        },
        {
          ResourceType = "collection"
          Resource     = ["collection/${local.opensearch_collection_name}"]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DescribeCollectionItems",
            "aoss:UpdateCollectionItems"
          ]
        }
      ]
      Principal = [
        aws_iam_role.knowledge_base.arn,
        "arn:${local.partition}:iam::${local.account_id}:root"
      ]
    }
  ])
}

resource "aws_opensearchserverless_collection" "this" {
  name = local.opensearch_collection_name
  type = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network,
    aws_opensearchserverless_access_policy.data
  ]

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Bedrock Knowledge Base
# ------------------------------------------------------------------------------
resource "aws_bedrockagent_knowledge_base" "this" {
  name     = var.knowledge_base_name
  role_arn = aws_iam_role.knowledge_base.arn

  description = var.knowledge_base_description

  knowledge_base_configuration {
    type = "VECTOR"

    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:${local.partition}:bedrock:${local.region}::foundation-model/${var.embedding_model}"
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"

    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.this.arn
      vector_index_name = var.vector_index_name

      field_mapping {
        vector_field   = var.vector_field_name
        text_field     = var.text_field
        metadata_field = var.metadata_field
      }
    }
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Bedrock Data Source (S3)
# ------------------------------------------------------------------------------
resource "aws_bedrockagent_data_source" "this" {
  name                 = "${var.knowledge_base_name}-s3-source"
  knowledge_base_id    = aws_bedrockagent_knowledge_base.this.id

  data_source_configuration {
    type = "S3"

    s3_configuration {
      bucket_arn              = aws_s3_bucket.knowledge_base.arn
      inclusion_prefixes      = var.s3_data_source_prefix != "" ? [var.s3_data_source_prefix] : null
    }
  }
}

# ------------------------------------------------------------------------------
# Bedrock Agent
# ------------------------------------------------------------------------------
resource "aws_bedrockagent_agent" "this" {
  agent_name              = var.agent_name
  agent_resource_role_arn = aws_iam_role.bedrock_agent.arn
  foundation_model        = var.foundation_model
  instruction             = var.instruction
  idle_session_ttl_in_seconds = var.idle_session_ttl
  description             = var.agent_description != "" ? var.agent_description : null
  prepare_agent           = var.prepare_agent

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Lambda Functions for Action Groups
# ------------------------------------------------------------------------------
data "archive_file" "action_group_lambda" {
  for_each = { for idx, ag in var.action_groups : ag.name => ag if ag.lambda_source_dir != null }

  type        = "zip"
  source_dir  = each.value.lambda_source_dir
  output_path = "${path.module}/.build/${each.key}.zip"
}

resource "aws_iam_role" "action_group_lambda" {
  for_each = { for idx, ag in var.action_groups : ag.name => ag }

  name = "${var.agent_name}-${each.key}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "action_group_lambda_basic" {
  for_each = { for idx, ag in var.action_groups : ag.name => ag }

  role       = aws_iam_role.action_group_lambda[each.key].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "action_group" {
  for_each = { for idx, ag in var.action_groups : ag.name => ag }

  function_name = "${var.agent_name}-${each.key}"
  role          = aws_iam_role.action_group_lambda[each.key].arn
  runtime       = each.value.lambda_runtime
  handler       = each.value.lambda_handler
  timeout       = each.value.lambda_timeout
  memory_size   = each.value.lambda_memory_size

  filename         = each.value.lambda_source_dir != null ? data.archive_file.action_group_lambda[each.key].output_path : null
  source_code_hash = each.value.lambda_source_dir != null ? data.archive_file.action_group_lambda[each.key].output_base64sha256 : null

  tags = var.tags
}

resource "aws_lambda_permission" "allow_bedrock" {
  for_each = { for idx, ag in var.action_groups : ag.name => ag }

  statement_id  = "AllowBedrockAgentInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.action_group[each.key].function_name
  principal     = "bedrock.amazonaws.com"
  source_arn    = aws_bedrockagent_agent.this.agent_arn
}

# ------------------------------------------------------------------------------
# Bedrock Agent Action Groups
# ------------------------------------------------------------------------------
resource "aws_bedrockagent_agent_action_group" "this" {
  for_each = { for idx, ag in var.action_groups : ag.name => ag }

  agent_id                    = aws_bedrockagent_agent.this.agent_id
  agent_version               = "DRAFT"
  action_group_name           = each.value.name
  description                 = each.value.description
  skip_resource_in_use_check  = each.value.skip_resource_in_use_check

  action_group_executor {
    lambda = aws_lambda_function.action_group[each.key].arn
  }

  dynamic "api_schema" {
    for_each = each.value.api_schema_payload != null ? [1] : []
    content {
      payload = each.value.api_schema_payload
    }
  }

  dynamic "api_schema" {
    for_each = each.value.api_schema_s3_key != null ? [1] : []
    content {
      s3 {
        s3_bucket_name = aws_s3_bucket.knowledge_base.id
        s3_object_key  = each.value.api_schema_s3_key
      }
    }
  }
}

# ------------------------------------------------------------------------------
# Bedrock Agent Alias
# ------------------------------------------------------------------------------
resource "aws_bedrockagent_agent_alias" "this" {
  agent_id         = aws_bedrockagent_agent.this.agent_id
  agent_alias_name = "${var.agent_name}-live"
  description      = "Live alias for ${var.agent_name}"

  tags = var.tags
}
