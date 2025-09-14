#!/bin/bash
# scripts/01-setup-service-principal.sh
# Purpose: Create Azure Service Principal for GitHub Actions authentication

# Variables
SUBSCRIPTION_ID="982ddcce-4044-4d23-a1dd-b51205ae5718"
SERVICE_PRINCIPAL_NAME="sp-devops-pipeline-github"
RESOURCE_GROUP="rg-devops-pipeline-state"
STORAGE_ACCOUNT="stterraform$(shuf -i 1000-9999 -n 1)"
LOCATION="uksouth"

echo "=== Azure Service Principal Setup ==="

# Check Azure CLI login
echo "Current subscription:"
az account show --query "{Name:name, ID:id}" --output table

# Create Resource Group for Terraform state storage
echo "Creating Resource Group for Terraform state..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION"

# Create Storage Account for Terraform state
echo "Creating Storage Account for Terraform state backend..."
az storage account create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$STORAGE_ACCOUNT" \
    --sku Standard_LRS \
    --encryption-services blob \
    --access-tier Hot

# Create storage container for Terraform state
echo "Creating storage container..."
az storage container create \
    --name "terraform-state" \
    --account-name "$STORAGE_ACCOUNT" \
    --auth-mode login

# Create Service Principal
echo "Creating Service Principal..."
SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "$SERVICE_PRINCIPAL_NAME" \
    --role "Contributor" \
    --scopes "/subscriptions/$SUBSCRIPTION_ID" \
    --sdk-auth)

# Display Service Principal details
echo "=== Service Principal Created ==="
echo "IMPORTANT: Copy these values to GitHub Secrets!"
echo ""
echo "GitHub Secret Name: AZURE_CREDENTIALS"
echo "Value (copy entire JSON):"
echo "$SP_OUTPUT"
echo ""

# Display additional information needed
echo "Additional GitHub Secrets needed:"
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo "TERRAFORM_STORAGE_ACCOUNT: $STORAGE_ACCOUNT"
echo "TERRAFORM_RESOURCE_GROUP: $RESOURCE_GROUP"

# Save to file for reference
cat > service-principal-info.txt << EOF
=== DevOps Pipeline Setup Information ===
Date: $(date)

GitHub Secrets to Configure:
AZURE_CREDENTIALS: $SP_OUTPUT
AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID  
TERRAFORM_STORAGE_ACCOUNT: $STORAGE_ACCOUNT
TERRAFORM_RESOURCE_GROUP: $RESOURCE_GROUP

Service Principal: $SERVICE_PRINCIPAL_NAME
Storage Account: $STORAGE_ACCOUNT
Resource Group: $RESOURCE_GROUP
EOF

echo "Information saved to: service-principal-info.txt"