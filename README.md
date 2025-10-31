<div align="center">
  <img src="https://raw.githubusercontent.com/abuechler/claude-in-a-box/refs/heads/main/docs/claudeinabox-logo.svg" alt="Claude In A Box Logo" width="350" />
</div>

<br />

# Claude In A Box

A custom Docker environment for running [Claude Code](https://github.com/anthropics/claude-code) with enhanced security,
Java development tools (GraalVM), and Quarkus framework support.

## Features

- **🤖 Claude Code CLI** - Official Anthropic AI coding assistant
- **☕ GraalVM Support** - Multiple Java versions (21 LTS & 24 CE) with native-image compilation
- **🚀 Quarkus Framework** - Pre-installed Quarkus 3.29.0 for supersonic subatomic Java
- **🔒 Enhanced Security** - Network firewall restricting outbound access to approved domains only
- **🎨 ZSH with Powerline10k** - Beautiful and functional shell environment
- **📦 Development Tools** - Includes git, gh CLI, fzf, vim, nano, and more
- **🔧 SDKMAN Integration** - Manage multiple SDK versions easily
- **📊 Git Delta** - Syntax-highlighted git diffs for better code review
- **🗂️ Per-Project Isolation** - Separate Claude settings and GitHub tokens per project
- **💾 Command History** - Persistent bash/zsh history across sessions

## Prerequisites

Before using this Docker environment, ensure you have the following installed:

- **Docker** - [Install Docker](https://docs.docker.com/get-docker/) for your platform
- **ZSH** - The `clc` launcher script requires ZSH shell
- **GitHub Token** (optional) - For using the `gh` CLI tool

## Installation and Usage

### 1. Clone the Repository

```zsh
git clone https://github.com/abuechler/claude-in-a-box.git
cd claude-in-a-box
```

### 2. Add the `clc` Script to Your PATH

For ZSH users, add the script directory to your PATH by adding this line to your `~/.zshrc`:

```zsh
# Add claude-code clc script to PATH
export PATH="$PATH:/path/to/claude-in-a-box"
```

Replace `/path/to/claude-in-a-box` with the actual absolute path where you cloned this repository.

After editing `~/.zshrc`, reload your shell configuration:

```zsh
source ~/.zshrc
```

### 3. Run Claude Code

Navigate to any project directory and run:

```zsh
clc
```

The first time you run `clc`, it will:
- Automatically build the Docker image (this may take several minutes)
- Create per-project settings in `~/.claude_project_settings/<project-name>/`
- Launch a ZSH shell inside the Docker container with your project mounted

### 4. GitHub Token Configuration (Optional)

To use the `gh` CLI tool, create a GitHub fine-grained token and save it to:

```zsh
~/.claude_project_settings/<project-name>/.gh_token
```

The token will be automatically loaded when you start the container.

### 5. Initialize Firewall (Optional)

Inside the container, you can initialize the network firewall to restrict outbound access:

```zsh
sudo /usr/local/bin/init-firewall.sh
```

This limits network access to approved domains (GitHub, npm, Anthropic APIs, etc.) for enhanced security.

