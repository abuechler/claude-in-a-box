#! /usr/bin/env zsh
set -euo pipefail

token=""

if [[ -s $HOME/.gh_token ]]; then
  token=$(cat ~/.gh_token)
elif [[ -n "${GH_TOKEN:-}" ]]; then
  token="${GH_TOKEN}"
fi

if [[ -n "${token}" ]]; then
  echo "https://abuechler:${token}@github.com" >~/.git-credentials
  chmod 600 ~/.git-credentials
  git config --global credential.helper store
  echo -e "\t✅ Git credentials configured successfully"
else
  echo -e "\t⚠️ Unable to set up credentials helper for git!"
  echo -e "\tPlease set GH_TOKEN environment variable or create ~/.gh_token file"
fi
