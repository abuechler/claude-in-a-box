# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude In A Box is a Docker-based development environment that wraps the official Claude Code CLI in a secure container
with specialized development tooling. The key architectural principle: your IDE retains full system access while Claude
Code is sandboxed to the project directory only.

## Key Commands

### Running the Environment

```zsh
clc                    # Main launcher - builds images if needed, starts container
claude                 # Standard Claude Code CLI (inside container)
claude-yolo            # Alias for claude --dangerously-skip-permissions (inside container)
```

### Building Docker Images Manually

```zsh
# Build base image - native architecture (automatic on first run)
docker build --build-arg TZ="$(readlink /etc/localtime | sed 's|.*/zoneinfo/||')" \
  -t claude-in-a-box-base:1.0.2 -f docker/Dockerfile.base docker/

# Build java_quarkus variant - native architecture
docker build --build-arg VERSION=1.0.2 -t claude-in-a-box:java_quarkus-1.0.2 -f docker/Dockerfile.java_quarkus docker/

# Build flutter variant - forces linux/amd64 (required because Flutter lacks ARM Linux binaries)
# On ARM hosts, also build base with: --platform linux/amd64 -t claude-in-a-box-base:1.0.2-amd64
docker build --platform linux/amd64 --build-arg VERSION=1.0.2-amd64 -t claude-in-a-box:flutter-1.0.2 -f docker/Dockerfile.flutter.amd64 docker/
```

## Architecture

### Docker Image Layers

1. **Base Layer** (`docker/Dockerfile.base`): Node 20, git, gh, zsh/Powerline10k, Playwright (Firefox), Claude Code CLI
2. **Variant Layers**:
    - `docker/Dockerfile.java_quarkus`: Adds SDKMAN, GraalVM, Java 21/24/25, Quarkus
    - `docker/Dockerfile.flutter.amd64`: Extends java_quarkus, adds Flutter SDK (forces linux/amd64 on ARM hosts)
    - `docker/Dockerfile.devops`: Adds Helm

### Key Files

- `clc`: Main ZSH launcher script - handles config, image building, and container launch
- `docker/init-firewall.sh`: Optional iptables-based network restrictions
- `init_config/`: Template files for initial project configuration (settings.json, claude.json, mcp.json)

### Mount Structure (Inside Container)

| Host Path                                        | Container Path                 | Purpose                                       |
|--------------------------------------------------|--------------------------------|-----------------------------------------------|
| `$PROJECT/`                                      | `/workspace/`                  | Project source code (rw)                      |
| `~/.claude_project_settings/<project>/claude/`   | `/home/node/.claude/`          | Per-project Claude settings                   |
| `~/.claude_project_settings/<project>/.gh_token` | `/home/node/.gh_token`         | GitHub token (ro)                             |
| `~/.claude-in-a-box/`                            | `/home/node/.claude-in-a-box/` | Global settings like init script, skills (ro) |

### Configuration Files

- `.claude_in_a_box`: Project config (project_name, image_variant)
- `.mcp.json`: MCP Server config (Playwright enabled by default)
- `~/.claude_project_settings/<project>/`: Per-project settings directory

## Coding Conventions

### Shell Scripts

- Use `set -euo pipefail` for error handling
- Use `#!/usr/bin/env zsh` shebang
- Use `local` keyword for function variables

### Docker

- Use `# syntax=docker/dockerfile:1` directive
- Use heredoc-style RUN instructions for multi-line commands
- Build args for version parameterization (VERSION, TZ, etc.)

### Git Commits

Follow conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `security:`

## Interaction Style

- **One decision at a time**: When presenting multiple suggestions, questions, or options, go through them ONE BY ONE
- **Always offer choices**: Present options for the user to pick from rather than making assumptions
- **Wait for confirmation**: Get user input before moving to the next decision point
