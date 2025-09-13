# Use the Microsoft Ubuntu base image
FROM mcr.microsoft.com/devcontainers/base:noble

# Update
RUN apt-get update && rm -rf /var/lib/apt/lists/*

# Set user to vscode to install dlang there
USER vscode

# Install DMD and LCD compilers
RUN curl https://dlang.org/install.sh | bash -s dmd \
  && curl https://dlang.org/install.sh | bash -s ldc
