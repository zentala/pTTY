#!/bin/bash
# Deploy test infrastructure to Oracle Cloud

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"

echo -e "${BLUE}🚀 Deploying tmux-persistent-console test infrastructure${NC}"
echo "=================================================="

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform is not installed. Please install terraform first.${NC}"
    echo "   Visit: https://www.terraform.io/downloads"
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
    echo -e "${YELLOW}⚠️  terraform.tfvars not found${NC}"
    echo "   Please copy terraform.tfvars.example to terraform.tfvars"
    echo "   and fill in your Oracle Cloud credentials."
    echo ""
    echo "   Steps:"
    echo "   1. cp $TERRAFORM_DIR/terraform.tfvars.example $TERRAFORM_DIR/terraform.tfvars"
    echo "   2. Edit terraform.tfvars with your OCI credentials"
    echo "   3. Run this script again"
    exit 1
fi

# Check if SSH key exists
SSH_KEY_PATH=$(grep ssh_public_key_path "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | sed 's|~|'$HOME'|')
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo -e "${YELLOW}⚠️  SSH public key not found at: $SSH_KEY_PATH${NC}"
    echo "   Generating SSH key pair..."

    SSH_DIR=$(dirname "$SSH_KEY_PATH")
    mkdir -p "$SSH_DIR"

    ssh-keygen -t ed25519 -f "${SSH_KEY_PATH%%.pub}" -N "" -C "tmux-console-test"
    echo -e "${GREEN}✅ SSH key pair generated${NC}"
fi

cd "$TERRAFORM_DIR"

echo -e "${YELLOW}🔧 Initializing Terraform...${NC}"
terraform init

echo -e "${YELLOW}📋 Planning deployment...${NC}"
terraform plan

echo ""
echo -e "${YELLOW}❓ Do you want to proceed with deployment? (y/N)${NC}"
read -r CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

echo -e "${YELLOW}🏗️  Deploying infrastructure...${NC}"
if terraform apply -auto-approve; then
    echo ""
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo ""

    # Get outputs
    PUBLIC_IP=$(terraform output -raw instance_public_ip)
    SSH_COMMAND=$(terraform output -raw ssh_connection)

    echo -e "${BLUE}📊 Deployment Information:${NC}"
    echo "   Public IP: $PUBLIC_IP"
    echo "   SSH Command: $SSH_COMMAND"
    echo ""

    echo -e "${BLUE}🔗 Next Steps:${NC}"
    echo "   1. Wait 2-3 minutes for cloud-init to complete"
    echo "   2. Connect via SSH: $SSH_COMMAND"
    echo "   3. Run tests: ./test-tmux-console.sh"
    echo "   4. Test console switching with Ctrl+F1-F10"
    echo ""

    echo -e "${YELLOW}💡 Testing Commands:${NC}"
    echo "   tmux ls                    # List sessions"
    echo "   connect-console           # Interactive menu"
    echo "   tmux attach -t console-1  # Direct connection"
    echo ""

    # Save connection info
    cat > "$SCRIPT_DIR/connection-info.txt" << EOF
# Tmux Persistent Console Test Server
Public IP: $PUBLIC_IP
SSH Command: $SSH_COMMAND

Generated: $(date)
EOF

    echo -e "${GREEN}💾 Connection info saved to: $SCRIPT_DIR/connection-info.txt${NC}"

else
    echo -e "${RED}❌ Deployment failed!${NC}"
    exit 1
fi
