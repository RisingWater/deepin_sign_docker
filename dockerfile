# Use ubuntu:18.04 as the base image (supports multi-architecture)
FROM ubuntu:18.04

# Set environment variable to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Define build argument for target architecture, default is amd64
ARG TARGET_ARCH=amd64

# Update package index and install required packages
RUN apt-get update && \
    apt-get install -y \
    libpcsclite1 \
    libsqlite3-0 \
    libssl1.1 \
    fakeroot \
    libccid \
    pcscd \
    opensc \
    gawk \
    binutils \
    # Install dpkg dependency
    dpkg \
    vim-common \
    # Install dependencies for deepin-elf-signverify-common
    libc6 \
    libgcc1 \
    libstdc++6 && \
    # Clean up cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create target directory for Info.plist
RUN mkdir -p /usr/lib/pcsc/drivers/ifd-ccid.bundle/Contents/

# Copy the architecture-specific deb files to the container
COPY deepin-elf-sign-tool_1.3.23.1-1_amd64.deb /tmp/
COPY deepin-elf-signverify-common_1.3.23.1-1_all.deb /tmp/
COPY deepin-elf-sign-tool_1.2.16-2+u1_arm64.deb /tmp/
COPY Info.plist /usr/lib/pcsc/drivers/ifd-ccid.bundle/Contents/

# Install the deb files based on the target architecture
RUN if [ "$TARGET_ARCH" = "amd64" ]; then \
        dpkg -i /tmp/deepin-elf-sign-tool_1.3.23.1-1_amd64.deb && \
        dpkg -i /tmp/deepin-elf-signverify-common_1.3.23.1-1_all.deb; \
    elif [ "$TARGET_ARCH" = "arm64" ]; then \
        dpkg -i /tmp/deepin-elf-sign-tool_1.2.16-2+u1_arm64.deb; \
    else \
        echo "Unsupported architecture: $TARGET_ARCH"; \
        exit 1; \
    fi && \
    # Fix potential dependency issues
    apt-get update && apt-get install -f -y && \
    # Clean up temporary files
    rm -f /tmp/*.deb

# Copy the startup script to the container
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Ensure /usr/bin/cp exists
RUN ln -sf /bin/cp /usr/bin/cp

# Set the working directory
WORKDIR /app

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/start.sh"]