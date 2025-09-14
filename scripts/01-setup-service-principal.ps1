# scripts/01-setup-service-principal.ps1
# Purpose: Create Azure Service Principal for GitHub Actions authentication

# Variables
$SUBSCRIPTION_ID = "982ddcce-4044-4d23-a1dd-b51205ae5718"
$SERVICE_PRINCIPAL_NAME = "sp-devops-pipeline-github"
$RESOURCE_GROUP = "rg-devops-pipeline-state"
$STORAGE_ACCOUNT = "storageaccountterraform"
$LOCATION = "UK South"

Write-Host "=== Azure Service Principal Setup ===" -ForegroundColor Green

# Check Azure CLI login
Write-Host "Current subscription:" -ForegroundColor Yellow
az account show --query "{Name:name, ID:id}" --output table

# Create Resource Group for Terraform state storage
Write-Host "Creating Resource Group for Terraform state..." -ForegroundColor Yellow
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Storage Account for Terraform state
Write-Host "Creating Storage Account for Terraform state backend..." -ForegroundColor Yellow
az storage account create `
    --resource-group $RESOURCE_GROUP `
    --name $STORAGE_ACCOUNT `
    --sku Standard_LRS `
    --encryption-services blob `
    --access-tier Hot

# Create storage container for Terraform state
az storage container create `
    --name "terraform-state" `
    --account-name $STORAGE_ACCOUNT `
    --auth-mode login

# Create Service Principal
Write-Host "Creating Service Principal..." -ForegroundColor Yellow
$SP_OUTPUT = az ad sp create-for-rbac `
    --name $SERVICE_PRINCIPAL_NAME `
    --role "Contributor" `
    --scopes "/subscriptions/$SUBSCRIPTION_ID" `
    --sdk-auth

# Display Service Principal details
Write-Host "=== Service Principal Created ===" -ForegroundColor Green
Write-Host "IMPORTANT: Copy these values to GitHub Secrets!" -ForegroundColor Red
Write-Host ""
Write-Host "GitHub Secret Name: AZURE_CREDENTIALS" -ForegroundColor Yellow
Write-Host "Value (copy entire JSON):" -ForegroundColor Yellow
Write-Host $SP_OUTPUT -ForegroundColor Cyan
Write-Host ""

# Display additional information needed
Write-Host "Additional GitHub Secrets needed:" -ForegroundColor Yellow
Write-Host "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID" -ForegroundColor Cyan
Write-Host "TERRAFORM_STORAGE_ACCOUNT: $STORAGE_ACCOUNT" -ForegroundColor Cyan
Write-Host "TERRAFORM_RESOURCE_GROUP: $RESOURCE_GROUP" -ForegroundColor Cyan

# Save to file for reference
$INFO = @"
=== DevOps Pipeline Setup Information ===
Date: $(Get-Date)

GitHub Secrets to Configure:
AZURE_CREDENTIALS: $SP_OUTPUT
AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID  
TERRAFORM_STORAGE_ACCOUNT: $STORAGE_ACCOUNT
TERRAFORM_RESOURCE_GROUP: $RESOURCE_GROUP

Service Principal: $SERVICE_PRINCIPAL_NAME
Storage Account: $STORAGE_ACCOUNT
Resource Group: $RESOURCE_GROUP
"@

$INFO | Out-File -FilePath "service-principal-info.txt"
Write-Host "Information saved to: service-principal-info.txt" -ForegroundColor Green