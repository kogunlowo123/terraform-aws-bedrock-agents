# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-01

### Added

- Initial release of the terraform-aws-bedrock-agents module.
- Bedrock Agent resource with configurable foundation model and instruction prompt.
- Knowledge Base with OpenSearch Serverless vector store integration.
- S3 data source for knowledge base document ingestion.
- Action group support with Lambda function execution.
- Agent alias for versioned deployments.
- IAM roles and policies following least-privilege principles.
- S3 bucket with versioning, encryption, and public access block.
- OpenSearch Serverless collection with encryption, network, and data access policies.
- Comprehensive variable validation and defaults.

## [0.1.0] - 2024-10-15

### Added

- Pre-release module scaffolding and initial resource definitions.
- Basic Bedrock Agent and Knowledge Base support.
