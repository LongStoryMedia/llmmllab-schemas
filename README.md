# llmmllab-schemas

YAML schema definitions for the llmmllab system, used for schema-driven code generation.

## Overview

This repository contains JSON Schema (draft-07) definitions that serve as the source of truth for all data contracts. Code generation is performed by `schema2code` to produce:

- Python Pydantic models (`runner/models/`, `composer/models/`, `server/models/`)
- TypeScript types (`ui/src/types/`)

The core schemas (root level) define internal data structures used by the llmmllab system. API-compatible schemas in `anthropic/` and `openai/` are transformed at the server layer.

## Core Schemas

### Request Schemas

| File | Description |
|------|-------------|
| `chat_req.yaml` | Chat completion request (Ollama-compatible) |
| `generate_req.yaml` | Text generation request |
| `image_generation_request.yaml` | Image generation request |

### Response Schemas

| File | Description |
|------|-------------|
| `chat_response.yaml` | Chat completion response |
| `generate_response.yaml` | Generation response |
| `embedding_response.yaml` | Embedding response |
| `image_generation_response.yaml` | Image generation response |

### Entity Schemas

| File | Description |
|------|-------------|
| `conversation.yaml` | Conversation entity (id, user_id, title) |
| `message.yaml` | Message entity (role, content, thoughts, tool_calls) |
| `model.yaml` | Model definition (id, name, provider, task) |
| `model_profile.yaml` | Model profile with parameters and configuration |
| `memory.yaml` | Memory/vector search results |

### Configuration Schemas

| File | Description |
|------|-------------|
| `model_profile.yaml` | Model profile configuration |
| `circuit_breaker_config.yaml` | Circuit breaker configuration |
| `gpu_config.yaml` | GPU configuration |

### Tool Schemas

| File | Description |
|------|-------------|
| `dynamic_tool.yaml` | Dynamic tool implementing LangChain BaseTool interface |

## Anthropic API Schemas

The `anthropic/` subdirectory contains schemas for the Anthropic messages API. These are **not used internally** but are transformed to/from core schemas at the server layer.

### Categories

| Category | Files |
|----------|-------|
| Requests | `create_message_request.yaml`, `create_completion_request.yaml`, `create_batch_request.yaml` |
| Responses | `message_response.yaml`, `completion_response.yaml`, `batch_response.yaml` |
| Content Blocks | `text`, `image`, `document`, `tool_use`, `tool_result`, `thinking`, `redacted_thinking` |
| Tools | `tool.yaml`, `client_tool.yaml`, `server_tool.yaml`, `tool_choice.yaml` |
| Configuration | `cache_control.yaml`, `thinking_config.yaml`, `system_prompt.yaml`, `metadata.yaml` |
| Utilities | `usage.yaml`, `error_*`, `delete_response.yaml`, `model*.yaml`, `file*.yaml` |

### Content Block Types

**Input** (`input_content_block.yaml`): `text`, `image`, `document`, `tool_use`, `tool_result`

**Output** (`output_content_block.yaml`): `text`, `tool_use`, `thinking`, `redacted_thinking`

### Tool Types

- **Client Tools** (`client_tool.yaml`): Type `custom`, defined by client
- **Server Tools** (`server_tool.yaml`): Anthropic-managed (web_search, text_editor, bash, computer)

## OpenAI API Schemas

The `openai/` subdirectory contains schemas for the OpenAI-compatible API (Assistant API, File API, Image API, Embedding API, Batch API, Thread/Message API).

## Usage

### Prerequisites

Install `schema2code`:
```bash
pip install schema2code
```

### Regenerating Models

```bash
# Generate all models
make gen
# or
./regenerate_models.sh

# Generate specific language
make gen-python      # Python models
make gen-typescript  # TypeScript types
# or
./regenerate_models.sh python
./regenerate_models.sh typescript
```

### Output

Generated code is placed in:
- **Python**: `generated/python/`
- **TypeScript**: `generated/typescript/`
- **Proto**: `generated/proto/`

## Architecture

### API Layer Transformation

The server (in llmmllab-server) implements both Anthropic and OpenAI compatible endpoints:

- `routers/anthropic/` - Anthropic messages API
- `routers/openai/` - OpenAI-compatible API

**Flow:**
1. Router receives API-compatible request
2. Transform to core llmmllab schema
3. Pass to composer/runner
4. Transform response back to API format

The database, composer, and runner **only use core schemas** (root level).

## Schema Patterns

- **$ref**: Cross-reference other schema files
- **oneOf**: Union types (content blocks, tools)
- **enum**: Strict type enumeration
- **additionalProperties: false**: Strict validation
- **required**: Mandatory fields

## Repository Structure

```
schemas/      - YAML schema definitions (source of truth)
proto/        - Protocol Buffer definitions
generated/    - Auto-generated code (created by build)
```

## Related Repositories

- **llmmllab-runner** - Model execution service (depends on schemas)
- **llmmllab-composer** - Agent orchestration (depends on schemas)
- **llmmllab-server** - REST API server (depends on schemas)
- **llmmllab-ui** - React frontend (depends on schemas)
