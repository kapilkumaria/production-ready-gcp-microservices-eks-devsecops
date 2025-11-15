#!/bin/bash

set -e

# Variables
ARTIFACTORY_VERSION="7.71.23"
DOWNLOAD_URL="https://releases.jfrog.io/artifactory/bintray-artifactory/org/artifactory/oss/jfrog-artifactory-oss/${ARTIFACTORY_VERSION}/jfrog-artifactory-oss-${ARTIFACTORY_VERSION}-linux.tar.gz"
TAR_FILE="/tmp/jfrog-artifactory-oss-${ARTIFACTORY_VERSION}-linux.tar.gz"
INSTALL_DIR="/opt"
SYMLINK_DIR="/opt/jfrog"
SERVICE_FILE="/etc/systemd/system/artifactory.service"
ARTIFACTORY_HOME="${INSTALL_DIR}/artifactory-oss-${ARTIFACTORY_VERSION}"
JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-amd64"

echo "🔧 Starting Artifactory and SonarQube tools installation..."

# Update OS
sudo apt update -y && sudo apt upgrade -y
echo "..................Updated OS.................."
sleep 2

# Basic CLI tools
sudo apt install -y tree unzip curl wget git jq htop net-tools lsb-release ca-certificates gnupg software-properties-common
echo "..................Installed CLI Tools.................."
sleep 2

# Java (OpenJDK 17)
sudo apt install -y openjdk-17-jdk
echo "..................Installed Java.................."
java -version
sleep 2

# Download and extract Artifactory
echo "[+] Step 1: Downloading JFrog Artifactory OSS $ARTIFACTORY_VERSION..."
sudo wget -q "$DOWNLOAD_URL" -O "$TAR_FILE"

echo "[+] Step 2: Extracting to $INSTALL_DIR..."
sudo tar -xzf "$TAR_FILE" -C "$INSTALL_DIR"

echo "[+] Step 3: Creating symlink $SYMLINK_DIR -> $ARTIFACTORY_HOME"
sudo ln -sfn "$ARTIFACTORY_HOME" "$SYMLINK_DIR"

echo "[+] Step 4: Creating 'artifactory' system user if not present..."
sudo useradd --system --home "$SYMLINK_DIR" --shell /bin/false artifactory || true

echo "[+] Step 5: Setting ownership and permissions for $SYMLINK_DIR"
sudo chown -R artifactory:artifactory "$ARTIFACTORY_HOME"
sudo chown -R artifactory:artifactory "$SYMLINK_DIR"

echo "[+] Step 6: Creating systemd unit file at $SERVICE_FILE..."
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=JFrog Artifactory Service
After=network.target

[Service]
Type=forking
Environment=JAVA_HOME=$JAVA_HOME_PATH
ExecStart=$SYMLINK_DIR/app/bin/artifactory.sh start
ExecStop=$SYMLINK_DIR/app/bin/artifactory.sh stop
User=artifactory
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "[+] Step 7: Reloading systemd and starting Artifactory service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable artifactory
sudo systemctl start artifactory

echo "[✓] Artifactory installation complete and service started successfully."
echo "    To check service status:   sudo systemctl status artifactory"
echo "    Access the Artifactory UI: http://<your-ec2-public-ip>:8081/artifactory"
