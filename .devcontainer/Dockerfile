# Use the x86_64 Microsoft Ubuntu Noble base image
FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:noble

# Update and install gnupg
RUN apt-get update \
    && apt-get install -y gnupg \
    && rm -rf /var/lib/apt/lists/*

# Add D language apt repository
RUN wget https://netcologne.dl.sourceforge.net/project/d-apt/files/d-apt.list -O /etc/apt/sources.list.d/d-apt.list \
    && apt-get update --allow-insecure-repositories \
    && apt-get -y --allow-unauthenticated install --reinstall d-apt-keyring

# Install dmd and dub
RUN apt-get update && apt-get install -y dmd-compiler dub

# Install gdb and lldb for debugging
RUN apt-get install -y gdb lldb