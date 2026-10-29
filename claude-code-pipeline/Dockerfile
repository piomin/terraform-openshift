FROM registry.access.redhat.com/ubi9/nodejs-22

USER 0

RUN dnf install -y git jq tar gzip \
    && dnf clean all

RUN npm install -g @anthropic-ai/claude-code

# GitHub CLI z oficjalnego archiwum
ARG GH_VERSION=2.83.2
RUN curl -fsSL \
    "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" \
    -o /tmp/gh.tar.gz \
    && tar -xzf /tmp/gh.tar.gz -C /tmp \
    && cp /tmp/gh_${GH_VERSION}_linux_amd64/bin/gh /usr/local/bin/gh \
    && rm -rf /tmp/gh*

USER 1001
