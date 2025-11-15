#!/bin/bash

set -e

echo "🔧 Starting DevOps tool installation..."

# Update OS
echo "..................Updating OS.................."
sleep 2
sudo apt update -y && sudo apt upgrade -y
echo "..................Updated OS.................."
sleep 2

# Basic CLI tools
echo "..................Installing CLI Tools.................."
sleep 2
sudo apt install -y tree unzip curl wget git jq htop net-tools lsb-release ca-certificates gnupg software-properties-common
echo "..................Installed CLI Tools.................."
sleep 2

# Java (OpenJDK 17)
echo "..................Installing Java.................."
sleep 2
sudo apt install -y openjdk-17-jdk
echo $(java -version)
echo "..................Installed Java.................."
sleep 2

# Maven
echo "..................Installing Maven.................."
sleep 2
sudo apt install -y maven
mvn -version
echo "..................Installed Maven.................."
sleep 2

# Docker
if ! command -v docker &> /dev/null
then
    echo "�� Installing Docker..."
    sudo apt install -y docker.io
    sudo usermod -aG docker $USER    
fi
echo "👉 To use Docker without sudo, log out and back in or reboot."
echo "..................Installing Docker.................."
sleep 2
echo "..................Installed Docker.................."
sleep 2

# AWS CLI Latest Version
echo "..................Installing AWS-CLI.................."
sleep 2
if ! command -v aws &> /dev/null
then
    echo ".....Installing AWS CLI latest...."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -o awscliv2.zip
    sudo ./aws/install
fi
echo "..................Installed AWS-CLI.................."
sleep 2

# kubectl
echo "..................Installing Kubectl.................."
if ! command -v kubectl &> /dev/null
then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl version --client
    kubectl version --client --output=yaml
fi
echo "..................Installed Kubectl.................."
sleep 2

# kOps
echo "..................Installing KOPS.................."
sleep 2
if ! command -v kops &> /dev/null
then
    echo "☸️ Installing kOps..."
    curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
    chmod +x kops
    sudo mv kops /usr/local/bin/kops    
fi
echo "..................Installed KOPS.................."
sleep 2

# Helm
echo "..................Installing Helm.................."
sleep 2
# Step: Install Helm (v3 latest stable)
echo "[INFO] Installing Helm..."

# Check if Helm is already installed
if ! command -v helm &> /dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  echo "[INFO] Helm installed successfully."
else
  echo "[INFO] Helm is already installed. Skipping..."
fi

helm version
echo "..................Installed Helm.................."
sleep 2

# Jenkins (optional - for controller machine)
if ! command -v java &> /dev/null
then
    echo "☕ Java is required for Jenkins, but not found"
    exit 1
fi
echo "..................Installing Jenkins.................."
sleep 2
if ! systemctl is-active --quiet jenkins; then
    echo "⚙️ Installing Jenkins..."
    sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y jenkins
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
fi
echo "..................Installed Jenkins.................."
sleep 2

# Trivy
echo "..................Installing Trivy.................."
sleep 2
if ! command -v trivy &> /dev/null
then
    echo "🔍 Installing Trivy..."
    sudo apt-get install -y wget apt-transport-https gnupg lsb-release
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update
    sudo apt-get install -y trivy
    trivy --version
fi
echo "..................Installed Trivy.................."
sleep 2

# JFrog CLI (optional but helpful)
echo "..................Installing Jfrog CLI.................."
sleep 2
if ! command -v jfrog &> /dev/null
then
    echo "Installing JFrog CLI..."
    curl -fL https://getcli.jfrog.io | sh && sudo mv jfrog /usr/local/bin/
fi
echo "..................Installed Jfrog CLI.................."
sleep 2

# Terraform
echo "..................Installing Terraform.................."
sleep 2
if ! command -v terraform &> /dev/null
then
    echo "Installing Terraform..."

    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

    curl -fsSL https://apt.releases.hashicorp.com/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

    sudo apt update && sudo apt install -y terraform
fi

terraform -version
echo "..................Installed Terraform.................."
sleep 2


# Install Syft for all users
echo "..................Installing Syft.................."
sleep 2
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sudo sh -s -- -b /usr/local/bin
echo "..................Installed Syft.................."
sleep 2


# Add aliases
echo "..................Adding helpful aliases.................."
sleep 2

# Append aliases to ~/.bashrc if not already present
if ! grep -q "alias k='kubectl'" ~/.bashrc; then
  cat <<'EOF' >> ~/.bashrc

# DevOps Aliases
alias c='clear'
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias kgs='kubectl get svc'
alias kd='kubectl describe'
alias t='tree'
alias kl='kubectl logs'
alias kctx='kubectl config current-context'
alias kconf='kubectl config view'
EOF
  echo "Aliases added to ~/.bashrc"
else
  echo "⚠️  Aliases already exist in ~/.bashrc — skipping"
fi
echo "..................Added helpful aliases.................."
sleep 2

echo "All tools installed successfully."
echo "-----------------------------------------------------------"
sleep 2
echo "👉 Please run 'source ~/.bashrc' or restart your terminal to activate aliases."
echo "👉 To use Docker without sudo, log out and back in or reboot."
echo "source ~/.bashrc"
