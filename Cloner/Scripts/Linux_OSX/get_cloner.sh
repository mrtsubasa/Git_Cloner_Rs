#!/bin/bash
if command -v go &> /dev/null; then
    echo "Go is installed: $(go version)"
    go run "$(dirname "$0")/Go/cloner.go"
else
    read -p "Go is not installed. Install or use sh script? [I = Install / S = Shell script]: " resp

    if [ "${resp^^}" == "I" ]; then
        GO_VERSION="1.22.3"
        ARCH=$(uname -m)

        if [ "$ARCH" == "x86_64" ]; then
            ARCH="amd64"
        elif [ "$ARCH" == "aarch64" ]; then
            ARCH="arm64"
        fi

        echo "Downloading Go $GO_VERSION..."
        wget -q "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" -O /tmp/go.tar.gz

        echo "Installing..."
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz

        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        source ~/.bashrc

        echo "Go successfully installed: $(go version)"

    elif [ "${resp^^}" == "S" ]; then
        echo "Starting sh script..."
        bash "$(dirname "$0")/sh/cloner.sh"
    else
        echo "Invalid input. Exiting."
        exit 1
    fi
fi