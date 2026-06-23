#!/bin/bash
set -e

# CLI UI Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0;0m'

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}    Professional Kubernetes User Asset Creator    ${NC}"
echo -e "${BLUE}==================================================${NC}"

# 1. Ask for Username (Mandatory)
read -p "Enter Kubernetes Username (CN): " K8S_USER
if [ -z "$K8S_USER" ]; then
    echo -e "\033[0;31mError: Username cannot be empty.\033[0;0m"
    exit 1
fi

# 2. Ask for Group (Optional)
SUBJ_GROUPS=""
read -p "Do you want to assign a Kubernetes Group (O)? (y/N): " ATTACH_GROUP

if [[ "$ATTACH_GROUP" =~ ^[Yy]$ ]]; then
    read -p "Enter Group Name: " GROUP_NAME
    if [ ! -z "$GROUP_NAME" ]; then
        SUBJ_GROUPS="/O=$GROUP_NAME"
    fi
fi

# 3. Setup Directory
OUTPUT_DIR="./k8s_users/$K8S_USER"
mkdir -p "$OUTPUT_DIR"

# 4. Generate Cryptographic Keys in Background
echo -e "\n${YELLOW}Generating assets in background...${NC}"

# Private Key Generation
openssl genrsa -out "$OUTPUT_DIR/${K8S_USER}.key" 2048 2>/dev/null
chmod 600 "$OUTPUT_DIR/${K8S_USER}.key"

# CSR Generation (Maps perfectly to K8s RBAC via CN and O)
openssl req -new \
    -key "$OUTPUT_DIR/${K8S_USER}.key" \
    -out "$OUTPUT_DIR/${K8S_USER}.csr" \
    -subj "/CN=${K8S_USER}${SUBJ_GROUPS}"

echo -e "${GREEN}Task Completed Successfully!${NC}"
echo -e "Files saved at: $OUTPUT_DIR/\n"

# 5. Dynamic Minimal Line Diagram showing what was accomplished
echo -e "${BLUE}==================================================${NC}"
echo -e "${GREEN}         VISUAL FLOW OF WORK COMPLETED            ${NC}"
echo -e "${BLUE}==================================================${NC}"
echo -e "   [INPUTS]  -->  Username: ${GREEN}$K8S_USER${NC}"
if [ ! -z "$GROUP_NAME" ]; then
echo -e "                  Group:    ${GREEN}$GROUP_NAME${NC}"
else
echo -e "                  Group:    ${YELLOW}None (Skipped)${NC}"
fi
echo -e "                     │"
echo -e "                     ▼ (Background Cryptography)"
echo -e "   [OUTPUTS] -->  ${BLUE}${K8S_USER}.key${NC} (Secure Private Key)"
echo -e "                  ${BLUE}${K8S_USER}.csr${NC} (Certificate Request)"
echo -e "                     │"
echo -e "                     ▼ (How K8s RBAC Maps This)"
echo -e "   [RBAC MAP] ->  ${GREEN}User${NC} in RoleBinding  == ${BLUE}CN (${K8S_USER})${NC}"
if [ ! -z "$GROUP_NAME" ]; then
echo -e "                  ${GREEN}Group${NC} in RoleBinding == ${BLUE}O (${GROUP_NAME})${NC}"
fi
echo -e "${BLUE}==================================================${NC}"
