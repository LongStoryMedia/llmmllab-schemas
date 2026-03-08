#!/bin/bash

# Schema-to-code generator for llmmllab-schemas
# Generates Python models and TypeScript types from YAML schemas

set -e

# Set the base directories
SCHEMAS_DIR="./schemas"
PROTO_DIR="./proto"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Accept arguments for language-specific generation
LANG_ARG=${1:-"all"}

# Check if schema2code is available
check_schema2code() {
    if ! command -v schema2code &> /dev/null; then
        log_warn "schema2code not found in PATH"
        log_info "Trying python -m src.main..."
        if ! python -m src.main --help &> /dev/null; then
            log_error "schema2code not found. Please install with: pip install schema2code"
            exit 1
        fi
        SCHEMA2CODE_CMD="python -m src.main"
    else
        SCHEMA2CODE_CMD="schema2code"
    fi
    log_info "Using schema2code: $SCHEMA2CODE_CMD"
}

# Generate Python models from schemas
generate_python_models() {
    log_info "Generating Python models..."

    local output_dir="./generated/python"
    mkdir -p "$output_dir"

    for schema_file in "$SCHEMAS_DIR"/*.yaml; do
        if [ -f "$schema_file" ]; then
            base_name=$(basename "$schema_file" .yaml)

            # Skip OpenAI schemas (they're API-compatible, not internal)
            if [[ "$base_name" == openai* ]] || [[ "$base_name" == assistant* ]]; then
                log_warn "Skipping $base_name.yaml (OpenAI API schema)"
                continue
            fi

            output_file="$output_dir/${base_name}.py"
            log_info "Generating $base_name.py"
            $SCHEMA2CODE_CMD "$schema_file" -l python -o "$output_file" 2>&1 || log_warn "Failed to generate $base_name.py"
        fi
    done

    log_info "Python model generation complete: $output_dir"
}

# Generate TypeScript models from schemas
generate_typescript_models() {
    log_info "Generating TypeScript types..."

    local output_dir="./generated/typescript"
    mkdir -p "$output_dir"

    for schema_file in "$SCHEMAS_DIR"/*.yaml; do
        if [ -f "$schema_file" ]; then
            base_name=$(basename "$schema_file" .yaml)

            # Skip OpenAI schemas (they're API-compatible, not internal)
            if [[ "$base_name" == openai* ]] || [[ "$base_name" == assistant* ]]; then
                log_warn "Skipping $base_name.yaml (OpenAI API schema)"
                continue
            fi

            output_file="$output_dir/${base_name}.ts"
            log_info "Generating $base_name.ts"
            $SCHEMA2CODE_CMD "$schema_file" -l typescript -o "$output_file" --package types 2>&1 || log_warn "Failed to generate $base_name.ts"
        fi
    done

    # Generate index.ts
    local index_file="$output_dir/index.ts"
    local exports=""
    for ts_file in "$output_dir"/*.ts; do
        if [ -f "$ts_file" ]; then
            base_name=$(basename "$ts_file" .ts)
            exports+="export * from './${base_name}';"$'\n'
        fi
    done
    echo "$exports" > "$index_file"
    log_info "TypeScript type generation complete: $output_dir"
}

# Generate proto files from schemas
generate_proto() {
    log_info "Generating Protocol Buffer files from schemas..."

    local output_dir="./generated/proto"
    mkdir -p "$output_dir"

    # Key schemas that map to proto messages
    local schemas=(
        "message"
        "message_content"
        "tool_call"
        "thought"
        "intent_analysis"
        "document"
        "model"
        "model_profile"
        "conversation"
        "dynamic_tool"
        "memory"
        "api_key"
    )

    for schema_name in "${schemas[@]}"; do
        schema_file="$SCHEMAS_DIR/${schema_name}.yaml"
        proto_file="$output_dir/${schema_name}.proto"

        if [ -f "$schema_file" ]; then
            log_info "Generating $schema_name.proto"
            $SCHEMA2CODE_CMD "$schema_file" -l proto -o "$proto_file" --package "llmmllab.proto" 2>&1 || log_warn "Failed to generate $schema_name.proto"
        else
            log_warn "Schema file not found: $schema_file"
        fi
    done

    log_info "Proto generation complete: $output_dir"
}

# Main generation process
main() {
    echo "=========================================="
    echo "  llmmllab-schemas Generator"
    echo "=========================================="
    echo ""

    check_schema2code

    case "$LANG_ARG" in
        python)
            generate_python_models
            ;;
        typescript)
            generate_typescript_models
            ;;
        proto)
            generate_proto
            ;;
        all|*)
            generate_python_models
            generate_typescript_models
            generate_proto
            ;;
    esac

    echo ""
    echo "=========================================="
    log_info "Generation complete!"
    echo "=========================================="
}

# Run main
main "$@"