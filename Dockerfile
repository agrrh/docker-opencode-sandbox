FROM ubuntu:24.04

LABEL org.opencontainers.image.title="opencode-sandbox" \
      org.opencontainers.image.description="Sandbox environment for opencode AI agents" \
      org.opencontainers.image.source="https://github.com/agrrh/docker-opencode-sandbox" \
      org.opencontainers.image.licenses="WTFPL"

# Configure user

RUN mv /home/ubuntu /home/opencode \
  && sed -Ei '/^ubuntu/d' /etc/passwd \
  && echo "opencode:x:1000:1000:Opencode:/home/opencode:/bin/bash" >> /etc/passwd \
  && sed -Ei '/^ubuntu/d' /etc/group \
  && echo "opencode:x:1000:" >> /etc/group

ENV HOME="/home/opencode"

# Install basic packages

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bc \
    ca-certificates \
    curl \
    dnsutils \
    g++ \
    git \
    golang \
    jq \
    less \
    lsof \
    make \
    man-db \
    procps \
    psmisc \
    python3 \
    ripgrep \
    rsync \
    socat \
    unzip

# Install nodejs

RUN cd /tmp \
  && curl -L https://raw.githubusercontent.com/mklement0/n-install/v0.6.5/bin/n-install \
    | bash -s -- -y 24

# Ensure default dirs exist

RUN mkdir -p /work \
  && chown opencode:opencode /work \
  && mkdir -p /home/opencode \
  && chown -R opencode:opencode /home/opencode \
  && mkdir -p /opt/npm-extras \
  && chown -R opencode:opencode /opt/npm-extras

# Cleanup

RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install opencode

USER 1000

ENV PATH="${PATH}:/home/opencode/n/bin"
ENV OPENCODE_VERSION=1.19.4

WORKDIR /home/opencode

RUN npm install opencode-ai@${OPENCODE_VERSION} \
  && npm cache clean --force

ENV PATH="${PATH}:/home/opencode/node_modules/.bin"

# Start

WORKDIR /work

CMD ["opencode", "--auto"]
