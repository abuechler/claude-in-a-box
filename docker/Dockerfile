# From https://github.com/anthropics/claude-code/blob/main/.devcontainer/Dockerfile
FROM node:20


ARG TZ
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest

# Use bash instead of sh
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ARG CLAUDE_CODE_VERSION=latest

# Install basic development tools and iptables/ipset
RUN apt-get update && apt-get install -y --no-install-recommends \
  less \
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
  vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

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
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Set the default editor and visual
ENV EDITOR=nano
ENV VISUAL=nano

# Default powerline10k theme
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Install Claude
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}


# Copy and set up firewall script
COPY init-firewall.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/init-firewall.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall
USER node


## Customized parts below ##
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

# Install SDKMAN and GraalVM, this needs to happen after the powerline10k setup to ensure zshrc changes are not overwritten.
USER node
COPY --chmod=0755 sdkman.sh /home/node/.sdkman-install.sh
RUN <<EOF
    /home/node/.sdkman-install.sh
    # Disable sdkman interactive prompts
    sed -i 's/sdkman_auto_answer=false/sdkman_auto_answer=true/' /home/node/.sdkman/etc/config
    source /home/node/.sdkman/bin/sdkman-init.sh
    echo '[[ -s "/home/node/.gh_token" ]] && export GH_TOKEN="$(cat /home/node/.gh_token)"' >> /home/node/.zshrc
    echo '#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!' >> /home/node/.zshrc
    echo '[[ -s "/home/node/.sdkman/bin/sdkman-init.sh" ]] && source "/home/node/.sdkman/bin/sdkman-init.sh"' >> /home/node/.zshrc
    sdk install java 24.0.2-graalce
    sdk install java 21.0.8-tem
    sdk install quarkus 3.29.0
    sdk default java 24.0.2-graalce
    # Re-enable sdkman interactive prompts
    sed -i 's/sdkman_auto_answer=true/sdkman_auto_answer=false/' /home/node/.sdkman/etc/config
EOF