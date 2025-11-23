FROM node:20-trixie

ARG TZ
ARG CLAUDE_CODE_VERSION=latest
ARG USERNAME=node

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="$TZ"

# Use bash instead of sh
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]


# Install basic development tools and iptables/ipset
RUN <<EOF
  apt-get update -yqq
  apt-get upgrade -yqq
  apt-get install -yqq --no-install-recommends \
    less \
    tree \
    git \
    procps \
    sudo \
    fzf \
    zsh \
    man-db \
    unzip \
    gnupg2 \
    gh \
    iptables \
    ipset \
    iproute2 \
    dnsutils \
    aggregate \
    jq \
    nano \
    vim
  apt-get clean
  rm -rf /var/lib/apt/lists/*
EOF

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share


# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create workspace and config directories and set permissions
RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  sudo dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Set up non-root user
USER ${USERNAME}

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh
ENV HISTFILE=/home/${USERNAME}/.shell_history/.zsh_history

# Set the default editor and visual
ENV EDITOR=nano
ENV VISUAL=nano

# Default powerline10k theme
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN <<EOF \
   sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=${HISTFILE}" \
  -x
EOF

# Install Claude
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}


# Copy and set up firewall script
COPY init-firewall.sh /usr/local/bin/
USER root
RUN <<EOF
  chmod +x /usr/local/bin/init-firewall.sh
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall
  chmod 0440 /etc/sudoers.d/node-firewall
EOF
USER ${USERNAME}


## Customized parts below ##
# Install Playwright MCP Server
USER root
ENV PLAYWRIGHT_BROWSERS_PATH=/home/node/.playwright-browsers
RUN <<EOF
    npx -y playwright install-deps
EOF

USER ${USERNAME}
RUN <<EOF
    npm install -g @playwright/test
    npx -y playwright install firefox
EOF

# Install dependencies for GraalVM native-image
USER root
RUN <<EOF
    apt-get update
    apt-get install -y --no-install-recommends zip curl wget
    # https://www.graalvm.org/latest/getting-started/linux/#prerequisites-for-native-image-on-linux
    apt-get install -y --no-install-recommends build-essential zlib1g-dev
    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF

USER ${USERNAME}
# ZSH customizations and project specific initializations
RUN <<EOF
  echo "[[ -s /home/${USERNAME}/.gh_token ]] && export GH_TOKEN=\"$(cat /home/${USERNAME}/.gh_token)\"" >> /home/${USERNAME}/.oh-my-zsh/custom/vars.zsh
  echo '# The space at the end of the commands makes shell command completion work with an alias"' >> /home/${USERNAME}/.oh-my-zsh/custom/aliases.zsh
  echo 'alias claude-yolo="claude --dangerously-skip-permissions "' >> /home/${USERNAME}/.oh-my-zsh/custom/aliases.zsh
  echo '# Project specific configurations for claude-in-box' >> /home/${USERNAME}/.zshrc
  echo "[[ -x /home/${USERNAME}/.claude-in-a-box/init.sh ]] && /home/${USERNAME}/.claude-in-a-box/init.sh" >> /home/${USERNAME}/.zshrc
EOF

# Install SDKMAN and GraalVM, this needs to happen after the powerline10k setup to ensure zshrc changes are not overwritten.
COPY --chmod=0755 sdkman.sh /home/${USERNAME}/.sdkman-install.sh
RUN <<EOF
    /home/${USERNAME}/.sdkman-install.sh
    # Disable sdkman interactive prompts
    sed -i 's/sdkman_auto_answer=false/sdkman_auto_answer=true/' /home/${USERNAME}/.sdkman/etc/config
    # Cannot be used with 'set -u' enabled
    set +u
    source /home/${USERNAME}/.sdkman/bin/sdkman-init.sh
    echo '#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!' >> /home/${USERNAME}/.zshrc
    echo "[[ -s /home/${USERNAME}/.sdkman/bin/sdkman-init.sh ]] && source /home/${USERNAME}/.sdkman/bin/sdkman-init.sh" >>/home/${USERNAME}/.zshrc
    sdk install java 24.0.2-graalce
    sdk install java 21.0.8-tem
    sdk install quarkus 3.29.0
    sdk default java 24.0.2-graalce
    set -u
    # Re-enable sdkman interactive prompts
    sed -i 's/sdkman_auto_answer=true/sdkman_auto_answer=false/' /home/${USERNAME}/.sdkman/etc/config
EOF

