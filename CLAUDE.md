# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in the llmmllab-schemas repository.

## Overview

Central YAML schema definitions for all data models used across the llmmllab microservices. This is the single source of truth for data contracts.

## Submodule Consumers

This repo is consumed as a git submodule in:
- **llmmllab-proto** (`llmmllab-schemas/`) — used to generate proto messages (`make messages`)
- **llmmllab-server** (`llmmllab-schemas/`) — used to generate Pydantic models (`make models`)
- **llmmllab-composer** (`llmmllab-schemas/`) — used to generate Pydantic models (`make models`)
- **llmmllab-runner** (`llmmllab-schemas/`) — used to generate Pydantic models (`make models`)

## Update Workflow

After changing a schema:

1. Commit and push to main in this repo
2. In `llmmllab-proto`: `git submodule update --init --recursive --remote && make messages` — commit and push
3. In each service (`server`, `composer`, `runner`): `git submodule update --init --recursive --remote && make models && make proto` — commit and push

Push to main between each step. Each downstream repo depends on the previous being updated.

## Important Rules

- **Never edit generated files** in downstream repos (`models/*.py`, `gen/python/**/*.py`)
- All model changes must originate here
- The `schema2code` tool (in `build.sh`) generates Pydantic models from these YAML files
