# Schemas Makefile
# Manages model generation from YAML schemas

.PHONY: all gen gen-python gen-typescript clean help

all: gen

# Generate all models (Python + TypeScript)
gen: gen-python gen-typescript

# Generate Python models from schemas
gen-python:
	@echo "Generating Python models from schemas..."
	@chmod +x ./regenerate_models.sh
	./regenerate_models.sh python
	@echo "Python model generation complete"

# Generate TypeScript types from schemas
gen-typescript:
	@echo "Generating TypeScript types from schemas..."
	@chmod +x ./regenerate_models.sh
	./regenerate_models.sh typescript
	@echo "TypeScript type generation complete"

# Generate all code (proto + models)
gen-all:
	@echo "Generating all code..."
	@chmod +x ./build.sh
	./build.sh
	@echo "All code generation complete"

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf ./generated/
	@find . -name "*.py" -path "*/models/*" -not -path "*/.venv/*" -not -path "*/node_modules/*" -delete 2>/dev/null || true
	@find . -name "*.ts" -path "*/types/*" -not -path "*/node_modules/*" -delete 2>/dev/null || true
	@echo "Clean complete"

# Validate schema files
validate:
	@echo "Validating schemas..."
	@for schema in $$(find ./schemas -name "*.yaml"); do \
		echo "  Checking $$schema..."; \
		python -c "import yaml; yaml.safe_load(open('$$schema'))" || exit 1; \
	done
	@echo "All schemas are valid"

# Help
help:
	@echo "Schemas Repository Makefile"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  gen          - Generate all models (Python + TypeScript)"
	@echo "  gen-python   - Generate Python models only"
	@echo "  gen-typescript - Generate TypeScript types only"
	@echo "  gen-all      - Generate all code including proto"
	@echo "  clean        - Remove generated files"
	@echo "  validate     - Validate schema files"
	@echo "  help         - Show this help message"