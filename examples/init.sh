#! /usr/bin/env zsh
# Global configuration or initialization for all Claude In A Box projects
# can be implemented in $HOME/.claude-in-a-box/init.sh. If the file exists
# and is executable, it will be executed after ZSH starts in the
# Claude In A Box container.
#
# This global settings directory is mounted read-only so the file cannot
# be changed from the Claude In A Box container.
#
# Check the docker/Dockerfile.base if you're curious how this works,
# it modifies .zshrc so the is executed during ZSH initialization inside
# the Claude In A Box container.
#
# 💡 This is just an example and shows how you could:
#
# - Set up credentials for GitHub (to access the repository and use the GitHub CLI)
# - Automatically sync any new skills you put into the global settings folder
#
# Make sure to adopt the GitHub user name below after you copied
# the script!

set -euo pipefail

token=""
indent="   "

# This script is run inside the container at startup to set up git credentials,
# so $HOME is not your home directory...
if [[ -s $HOME/.gh_token ]]; then
  token=$(cat ~/.gh_token)
  export GH_TOKEN="${token}"
elif [[ -n "${GH_TOKEN:-}" ]]; then
  token="${GH_TOKEN}"
fi

if [[ -n "${token}" ]]; then
  # 👇 Adopt the username after copying the script!
  echo "https://your_github_username:${token}@github.com" >~/.git-credentials
  chmod 600 ~/.git-credentials
  git config --global credential.helper store
  echo -e "${indent}✅ Git credentials configured successfully"
fi

if [[ -d $HOME/.claude-in-a-box/skills ]]; then
  # Ensure target directory exists
  mkdir -p "$HOME/.claude/skills"
  skills_synced=0
  for skill in "$HOME/.claude-in-a-box/skills"/*; do
    # Skip if no files matched
    [[ -e "$skill" ]] || continue
    skill_name=$(basename "$skill")
    if [[ ! -d "$HOME/.claude/skills/$skill_name" ]]; then
      cp -r "$skill" "$HOME/.claude/skills/"
      skills_synced=$((skills_synced + 1))
    fi
  done
  if [[ $skills_synced -gt 0 ]]; then
    echo -e "${indent}✅ Synced $skills_synced skills from claude-in-a-box"
  else
    echo -e "${indent}ℹ️ No new skills to sync from \$HOME/.claude/skills"
  fi
fi
