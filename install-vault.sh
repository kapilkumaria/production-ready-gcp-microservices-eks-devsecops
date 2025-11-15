#!/bin/bash
# -----------------------------------------------------------------------------
# HashiCorp Vault Bootstrap Script (safe for public use)
# - Installs Vault (raft, tcp listener, no TLS by default)
# - Initializes (if needed), saves unseal keys & root token securely
# - Unseals (if sealed), logs in
# - Enables AppRole, writes a Jenkins policy, and seeds fake secrets
# - Exports ROLE_ID/SECRET_ID along with VAULT_TOKEN/UNSEAL_KEY into vault-output.env
# -----------------------------------------------------------------------------

set -euo pipefail
umask 077

VAULT_ADDR_DEFAULT="http://127.0.0.1:8200"
KEYS_FILE="/root/vault-keys.json"
ENV_FILE="vault-output.env"
POLICY_FILE="jenkins-policy.hcl"
VAULT_SERVICE="vault"
DEBIAN_FRONTEND=noninteractive

log() { echo "[$(date +'%H:%M:%S')] $*"; }

log "[INFO] Updating system and installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y gnupg curl unzip jq lsb-release

log "[INFO] Adding HashiCorp GPG key and repository (idempotent)..."
if [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
fi

if [ ! -f /etc/apt/sources.list.d/hashicorp.list ]; then
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
fi

log "[INFO] Installing Vault..."
sudo apt-get update -y
sudo apt-get install -y vault

log "[INFO] Creating Vault directories and setting permissions..."
sudo mkdir -p /etc/vault.d /opt/vault/data
sudo chown -R vault:vault /opt/vault /etc/vault.d
sudo chmod -R 750 /opt/vault

log "[INFO] Creating Vault configuration..."
cat <<'EOF' | sudo tee /etc/vault.d/vault.hcl >/dev/null
disable_mlock = true

storage "raft" {
  path    = "/opt/vault/data"
  node_id = "raft_node_1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr     = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"
ui = true
EOF

log "[INFO] Enabling and starting Vault service..."
sudo systemctl daemon-reload
sudo systemctl enable "${VAULT_SERVICE}"
sudo systemctl restart "${VAULT_SERVICE}"

export VAULT_ADDR="${VAULT_ADDR_DEFAULT}"

# Optional pre-flight port wait (helps on slow boots)
if ! ss -lnt | grep -q ':8200'; then
  log "[INFO] Waiting for TCP 8200 to open..."
  for _ in {1..30}; do ss -lnt | grep -q ':8200' && break || sleep 1; done
fi

log "[INFO] Waiting for Vault API (accepting 200/429/472/473/501/503)..."
for i in {1..60}; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "${VAULT_ADDR}/v1/sys/health" || true)
  if [[ "$code" =~ ^(200|429|472|473|501|503)$ ]]; then
    log "[INFO] Vault health endpoint responding with HTTP $code"
    break
  fi
  sleep 1
done

echo ""
cat <<'TIP'
Use these commands later to update real secrets:
--------------------------------------------------------------
echo "vault login <your-root-token>"
echo "export VAULT_ADDR='http://127.0.0.1:8200'"
echo "vault kv put secrets/jenkins/github/creds username=<your-gh-username> password=<your-gh-password>"
echo "vault kv put secrets/jenkins/aws/ecr access_key=<your-aws-key> secret_key=<your-aws-secret>"
echo "vault kv put secrets/jenkins/jfrog/creds username=<your-jfrog-user> password=<your-jfrog-pass>"
echo "vault kv put secrets/jenkins/sonarqube/token token=<your-sonarqube-token>"

echo "vault kv put -address=http://127.0.0.1:8200 secrets/jenkins/github/creds username=xxx password=xxx"
echo "vault kv put -address=http://127.0.0.1:8200 secrets/jenkins/aws/ecr access_key=<your-aws-access-key> secret_key=<your-aws-secret-key>"
echo "vault kv put -address=http://127.0.0.1:8200 secrets/jenkins/jfrog/creds username=<your-jfrog-username> password=<your-jfrog-password>"
echo "use the below command . . .  ."
echo "vault kv put -address=http://127.0.0.1:8200 secrets/jenkins/jfrog/creds @<(echo '{"username":"xxxxxxx", "password":"xxxxxxxxxxxx"}')"
echo "vault kv put -address=http://127.0.0.1:8200 secrets/jenkins/sonarqube/token token=<your-sonarqube-token>"
--------------------------------------------------------------
TIP
echo ""

# Helper: Retrieve .initialized and .sealed without failing the script
vault_status_json() {
  vault status -format=json 2>/dev/null || echo '{}'
}

initialized=$(vault_status_json | jq -r '.initialized // false')
sealed=$(vault_status_json | jq -r '.sealed // true')

UNSEAL_KEY=""
ROOT_TOKEN=""

if [[ "${initialized}" != "true" ]]; then
  log "[INFO] Initializing Vault (1 key share, threshold 1)..."
  INIT_OUTPUT=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)

  # Save full payload securely (includes ALL unseal keys + root token)
  echo "${INIT_OUTPUT}" | sudo tee "${KEYS_FILE}" >/dev/null
  sudo chmod 600 "${KEYS_FILE}"

  UNSEAL_KEY=$(echo "${INIT_OUTPUT}" | jq -r '.unseal_keys_b64[0]')
  ROOT_TOKEN=$(echo "${INIT_OUTPUT}" | jq -r '.root_token')

  log "[INFO] Unsealing Vault with generated key..."
  vault operator unseal "${UNSEAL_KEY}"
  sealed="false"
else
  log "[INFO] Vault is already initialized."

  # If we have saved keys, load them to assist with unseal/login
  if [ -f "${KEYS_FILE}" ]; then
    UNSEAL_KEY=$(jq -r '.unseal_keys_b64[0]' "${KEYS_FILE}" || true)
    ROOT_TOKEN=$(jq -r '.root_token' "${KEYS_FILE}" || true)
  fi
fi

# If sealed, try to unseal using stored key if available
if [[ "${sealed}" == "true" ]]; then
  if [[ -n "${UNSEAL_KEY}" && "${UNSEAL_KEY}" != "null" ]]; then
    log "[INFO] Vault is sealed; attempting unseal with stored key..."
    vault operator unseal "${UNSEAL_KEY}"
  else
    log "[WARN] Vault is sealed and no UNSEAL_KEY is available. Manual unseal required."
  fi
fi

# Try to login: prefer ROOT_TOKEN; otherwise try env file if present
if [[ -n "${ROOT_TOKEN:-}" && "${ROOT_TOKEN}" != "null" ]]; then
  log "[INFO] Logging in with root token..."
  export VAULT_TOKEN="${ROOT_TOKEN}"
  vault login "${ROOT_TOKEN}" >/dev/null
else
  if [ -f "${ENV_FILE}" ]; then
    # shellcheck disable=SC1090
    source "${ENV_FILE}" || true
    export VAULT_TOKEN="${VAULT_TOKEN:-}"
  fi
  if [[ -z "${VAULT_TOKEN:-}" ]]; then
    log "[ERROR] VAULT_TOKEN not set and no root token available. Exiting."
    exit 1
  fi
fi

# --- Auth methods, policies, secrets ------------------------------------------------

log "[INFO] Enabling AppRole auth method..."
vault auth enable approle 2>/dev/null || log "[WARN] AppRole already enabled."

log "[INFO] Creating Jenkins Vault policy..."
cat <<'POL' > "${POLICY_FILE}"
path "secrets/creds/*" {
  capabilities = ["read"]
}

path "secrets/jenkins/*" {
  capabilities = ["read"]
}
POL
vault policy write jenkins "${POLICY_FILE}" >/dev/null

log "[INFO] Creating AppRole for Jenkins..."
vault write auth/approle/role/jenkins-role \
  token_num_uses=0 \
  secret_id_num_uses=0 \
  policies="jenkins" >/dev/null

log "[INFO] Enabling KV v1 at 'secrets/' path..."
vault secrets enable -path=secrets -version=1 kv 2>/dev/null || log "[WARN] KV already enabled."

log "[INFO] Writing fake secrets (safe for GitHub)..."
vault kv put secrets/creds/vagrant username=vagrant password=vagrant >/dev/null
vault kv put secrets/jenkins/github/creds username=gh-user password=gh-pass >/dev/null
vault kv put secrets/jenkins/aws/ecr access_key=abc123 secret_key=xyz789 >/dev/null
vault kv put secrets/jenkins/jfrog/creds username=admin password=admin123 >/dev/null
vault kv put secrets/jenkins/sonarqube/token token=sq-token-456 >/dev/null

log "[INFO] Retrieving AppRole credentials..."
ROLE_ID=$(vault read -field=role_id auth/approle/role/jenkins-role/role-id)
SECRET_ID=$(vault write -f -field=secret_id auth/approle/role/jenkins-role/secret-id)

# --- Write env file ONCE (includes unseal key) --------------------------------------

# If UNSEAL_KEY empty but keys file exists, try to pull it again
if [[ -z "${UNSEAL_KEY}" || "${UNSEAL_KEY}" == "null" ]]; then
  if [ -f "${KEYS_FILE}" ]; then
    UNSEAL_KEY=$(jq -r '.unseal_keys_b64[0]' "${KEYS_FILE}" || true)
  fi
fi

log "[INFO] Writing ${ENV_FILE} (includes UNSEAL_KEY, VAULT_TOKEN, ROLE_ID, SECRET_ID)..."
cat > "${ENV_FILE}" <<EOF
# Vault Environment Variables (generated)
VAULT_ADDR=${VAULT_ADDR_DEFAULT}
VAULT_TOKEN=${VAULT_TOKEN}
UNSEAL_KEY=${UNSEAL_KEY}
ROLE_ID=${ROLE_ID}
SECRET_ID=${SECRET_ID}

# Commands to update real secrets manually:
vault login <your-root-token>
vault kv put secrets/jenkins/github/creds username=<your-gh-username> password=<your-gh-password>
vault kv put secrets/jenkins/aws/ecr access_key=<your-aws-access-key> secret_key=<your-aws-secret-key>
vault kv put secrets/jenkins/jfrog/creds username=<your-jfrog-username> password=<your-jfrog-password>
vault kv put secrets/jenkins/sonarqube/token token=<your-sonarqube-token>

vault kv put -address=http://127.0.0.1:8200 secrets/jenkins/github/creds username=xxx password=xxx
vault kv put -address=http://127.0.0.1:8200 secrets/jenkins/aws/ecr access_key=<your-aws-access-key> secret_key=<your-aws-secret-key>
vault kv put -address=http://127.0.0.1:8200 secrets/jenkins/jfrog/creds username=<your-jfrog-username> password=<your-jfrog-password>
vault kv put -address=http://127.0.0.1:8200 secrets/jenkins/jfrog/creds @<(echo '{"username":"xxxxxxx", "password":"xxxxxxxxxxxx"}')
vault kv put -address=http://127.0.0.1:8200 secrets/jenkins/sonarqube/token token=<your-sonarqube-token>
EOF
chmod 600 "${ENV_FILE}"

echo ""
echo "Vault setup completed successfully!"
echo "---------------------------------------------"
echo "VAULT_ADDR = ${VAULT_ADDR_DEFAULT}"
echo "ROLE_ID    = <REDACTED>"
echo "SECRET_ID  = <REDACTED>"
echo "VAULT_TOKEN= <REDACTED>"
echo "UNSEAL_KEY = <REDACTED>"
echo "${ENV_FILE} generated; full init payload stored at ${KEYS_FILE}"
echo "---------------------------------------------"
