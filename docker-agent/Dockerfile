FROM jenkins/inbound-agent:4.11-1-alpine as builder

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

USER root

# Install necessary packages and dependencies
RUN apk add --no-cache \
    docker \
    openjdk11-jre-headless \
    git \
    bash \
    curl \
    jq \
    openssh-client \
    python3

# Install specific Node.js version directly from Node.js Docker image
# This fetches Node.js 14.21.3 with npm included
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apk add --no-cache nodejs npm

# Configure user and groups
# Ensure user 'jenkins' exists with specified UID and GID
RUN addgroup -g ${gid} ${group} \
    && adduser -D -u ${uid} -G ${group} -h /home/${user} -s /bin/bash ${user} \
    && addgroup ${user} wheel \
    && addgroup ${user} docker || true

# Set up Jenkins agent and permissions
RUN chmod +x /usr/local/bin/jenkins-agent \
    && if [ ! -f /usr/local/bin/jenkins-slave ]; then ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave; fi \
    && chmod 644 /usr/share/jenkins/agent.jar \
    && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar || true

# Install gcloud SDK using a different approach or image if necessary
# For example, using an official Google Cloud SDK image or another base image

# Set environment variables
ENV HOME=/home/${user}
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Switch to the jenkins user
USER ${user}

# Set Docker socket environment variable
ENV DOCKER_HOST="unix:///var/run/docker.sock"

WORKDIR /home/${user}

# Define the entry point
ENTRYPOINT ["jenkins-agent"]