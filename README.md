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
- **🎨 ZSH with Powerline10k** - Beautiful and functional shell environment
- **📦 Development Tools** - Includes git, gh CLI, fzf, vim, nano, and more
- **🔧 SDKMAN Integration** - Manage multiple SDK versions easily
- **🎭 Playwright Testing** - Pre-configured Playwright with Firefox for E2E testing
- **🔒 Enhanced Security** - Network firewall restricting outbound access to approved domains only
- **📊 Git Delta** - Syntax-highlighted git diffs for better code review
- **🗂️ Per-Project Isolation** - Separate Claude settings and GitHub tokens per project
- **💾 Command History** - Persistent bash/zsh history across sessions

## Prerequisites

Before using this Docker environment, ensure you have the following ready:

- **Docker** - [Install Docker](https://docs.docker.com/get-docker/) for your platform
- [**A fine-grained GitHub Token
  **](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token) (
  optional) - For using the `gh` CLI tool

## Installation and Usage

### 1. Clone the Repository

```zsh
git clone https://github.com/abuechler/claude-in-a-box.git
cd claude-in-a-box
```

### 2. Add the `clc` Script to Your PATH

For ZSH users, add the script directory to your PATH by adding this line to your `~/.zshrc`:

```zsh
# Add Claude In A Box clc script to PATH
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
- **Now you can run `claude-yolo` which is an alias for `claude --allow-dangerously-skip-permissions`**

> 🧨 Running claude in YOLO mode skips any permission prompts, use it only inside a trusted environment, like inside a
> Docker container. If you want to run claude without YOLO mode, just run `claude` instead of `claude-yolo`. But you
> will note that you cannot let claude do long-running tasks without watching them, because you will certainly miss
> permission prompts.

### 4. Configuration

#### Per-Project Settings

Each project gets its own settings directory at `~/.claude_project_settings/<project-name>/` containing:

- `claude/` - Claude-specific configuration and history
- `claude.json` - Claude settings file
- `.gh_token` - GitHub token for this project (optional)

#### Global Settings

The `~/.claude-in-a-box/` directory (in your $HOME directory) is mounted read-only into all containers. Use this for:

- **Automatic initialization**: Create an executable `init.sh` script that runs at container startup, useful for setting
  up git credentials etc. See the example in [`examples/init.sh`](examples/init.sh).
- **Shared configuration**: Files that should be available across all projects

#### GitHub Token Setup

To use the `gh` CLI tool, create a GitHub fine-grained token and save it to:

```zsh
~/.claude_project_settings/<project-name>/.gh_token
```

The token will be automatically loaded when you start the container.

#### Setting Up Git Credentials

Use the provided example script to set up git credentials automatically:

```zsh
# Copy the example init script to your global settings
# Edit init.sh and replace YOUR_NAME and YOUR_EMAIL with your details
cp examples/init.sh ~/.claude-in-a-box/
chmod +x ~/.claude-in-a-box/init.sh

# Create a GitHub token file (either globally or per-project)
echo "your_github_token" > ~/.gh_token
# OR for per-project:
echo "your_github_token" > ~/.claude_project_settings/<project-name>/.gh_token
```

The init script will configure git credentials automatically when the container starts.

### 5. Initialize Firewall (Optional)

> ⚠️ Although this is optional, this step is highly recommended!

#### Linux

Inside the container, you can initialize the network firewall to restrict outbound access, if your setup allows
modifications of the host's firewall rules.

```zsh
sudo /usr/local/bin/init-firewall.sh
```

This limits network access to approved domains (GitHub, npm, Anthropic APIs, etc.) for enhanced security.

#### macOS

On macOS there is no `iptables` support, a user-friendly way to manage the firewall is by
installing [Little Snitch](https://www.obdev.at/products/littlesnitch/index.html), which is totally worth the money. If
you've installed it, make sure to delete any global allow rule for the Docker binary and then add the rules as needed.
Depending on the mode you run it, it will ask you for every new connection attempt.

### 6. Update Claude In A Box

To update to the latest version and start Claude In A Box. This will build a new Docker image:

```zsh
git pull origin main
clc
```
