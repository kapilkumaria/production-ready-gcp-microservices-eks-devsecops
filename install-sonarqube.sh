#!/bin/bash

set -e

# Variables
SONARQUBE_VERSION="10.5.1.90531"
SONARQUBE_ZIP="sonarqube-${SONARQUBE_VERSION}.zip"
SONARQUBE_URL="https://binaries.sonarsource.com/Distribution/sonarqube/${SONARQUBE_ZIP}"
INSTALL_DIR="/opt"
SONARQUBE_HOME="${INSTALL_DIR}/sonarqube"
SONARQUBE_USER="sonar"

echo "🔧 Starting SonarQube installation on Ubuntu 24.04..."

# Step 1: Update OS and install dependencies
echo "[+] Updating OS and installing required packages..."
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y openjdk-17-jdk tree unzip curl wget git jq htop net-tools lsb-release ca-certificates gnupg software-properties-common
echo "..................System and CLI tools ready.................."
java -version
sleep 2

# Step 2: Download and extract SonarQube
cd $INSTALL_DIR
if [ ! -f "$SONARQUBE_ZIP" ]; then
  echo "[+] Downloading SonarQube ${SONARQUBE_VERSION}..."
  sudo wget -q $SONARQUBE_URL
else
  echo "[i] ZIP file already exists: $SONARQUBE_ZIP"
fi

if [ -d "$SONARQUBE_HOME" ]; then
  echo "[i] SonarQube directory already exists at $SONARQUBE_HOME"
else
  echo "[+] Extracting SonarQube package..."
  sudo unzip -q $SONARQUBE_ZIP
  sudo rm -f $SONARQUBE_ZIP
  sudo mv "${INSTALL_DIR}/sonarqube-${SONARQUBE_VERSION}" "$SONARQUBE_HOME"
fi

# Step 3: Create sonar user
if id "$SONARQUBE_USER" &>/dev/null; then
    echo "[i] User '$SONARQUBE_USER' already exists."
else
    echo "[+] Creating user '$SONARQUBE_USER'..."
    sudo useradd -m -d /home/$SONARQUBE_USER -s /bin/bash $SONARQUBE_USER
fi

# Step 4: Set permissions
echo "[+] Setting ownership of $SONARQUBE_HOME to user '$SONARQUBE_USER'..."
sudo chown -R $SONARQUBE_USER:$SONARQUBE_USER "$SONARQUBE_HOME"

# Step 5: Optional config — expose on port 9000
SONAR_PROPERTIES="$SONARQUBE_HOME/conf/sonar.properties"
if grep -q "^#sonar.web.port=" "$SONAR_PROPERTIES"; then
  echo "[+] Configuring SonarQube to run on port 9000..."
  sudo sed -i 's/^#sonar.web.port=.*/sonar.web.port=9000/' "$SONAR_PROPERTIES"
fi

# Step 6: Start SonarQube
echo "[+] Starting SonarQube as user '$SONARQUBE_USER'..."
sudo -u $SONARQUBE_USER bash -c "$SONARQUBE_HOME/bin/linux-x86-64/sonar.sh start"

# Step 7: Check status
echo "[+] Checking SonarQube status..."
sudo -u $SONARQUBE_USER bash -c "$SONARQUBE_HOME/bin/linux-x86-64/sonar.sh status"

echo "[✓] SonarQube installation and startup complete!"
echo "    ➤ Access it at: http://<your-server-ip>:9000"
