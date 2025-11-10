# Azure AD Federated Identity Credential Setup for GitHub Actions Environments

This guide explains how to configure Azure AD federated identity credentials to support GitHub Actions environments for OIDC authentication.

## Prerequisites

- Azure AD App Registration (Service Principal) with Client ID: `6ab6e4fa-8e13-4200-b063-b47272dcb70e`
- Access to Azure Portal with permissions to manage App Registrations
- GitHub repository: `rkravihhh/aks-acr-sqlserver-sqldb`

## Step-by-Step Instructions

### Option 1: Using Azure Portal (GUI)

1. **Navigate to Azure Portal**
   - Go to [Azure Portal](https://portal.azure.com)
   - Sign in with an account that has permissions to manage App Registrations

2. **Open Azure Active Directory**
   - Search for "Azure Active Directory" or "Microsoft Entra ID" in the search bar
   - Click on it to open

3. **Navigate to App Registrations**
   - In the left menu, click on "App registrations"
   - Search for your app registration using the Client ID: `6ab6e4fa-8e13-4200-b063-b47272dcb70e`
   - Click on the app registration to open it

4. **Open Certificates & secrets**
   - In the left menu, click on "Certificates & secrets"
   - Click on the "Federated credentials" tab

5. **Add Federated Credential for Dev Environment**
   - Click "Add credential" or "+ Add"
   - Select "GitHub Actions deploying Azure resources" as the credential type
   - Fill in the following details:
     - **Name**: `github-actions-dev-environment` (or any descriptive name)
     - **Organization**: `rkravihhh`
     - **Repository**: `aks-acr-sqlserver-sqldb`
     - **Entity type**: Select "Environment"
     - **Environment name**: `dev`
     - **Issuer**: `https://token.actions.githubusercontent.com`
     - **Audience**: `api://AzureADTokenExchange` (default)
   - Click "Add"

6. **Add Federated Credential for Prod Environment** (if needed)
   - Repeat step 5 with:
     - **Name**: `github-actions-prod-environment`
     - **Entity type**: "Environment"
     - **Environment name**: `prod`

7. **Verify the Configuration**
   - You should see both federated credentials listed
   - The subject claim format should be: `repo:rkravihhh/aks-acr-sqlserver-sqldb:environment:dev`

### Option 2: Using Azure CLI

If you prefer using the command line, you can use Azure CLI to add the federated identity credential:

```bash
# Login to Azure
az login

# Set your variables
RESOURCE_GROUP="your-resource-group"
APP_ID="6ab6e4fa-8e13-4200-b063-b47272dcb70e"
ORGANIZATION="rkravihhh"
REPOSITORY="aks-acr-sqlserver-sqldb"
ENVIRONMENT="dev"

# Add federated credential for dev environment
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-actions-dev-environment",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$ORGANIZATION'/'$REPOSITORY':environment:'$ENVIRONMENT'",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions OIDC for dev environment"
  }'

# For prod environment (if needed)
ENVIRONMENT="prod"
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-actions-prod-environment",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$ORGANIZATION'/'$REPOSITORY':environment:'$ENVIRONMENT'",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions OIDC for prod environment"
  }'
```

### Option 3: Using Terraform

You can also manage federated identity credentials using Terraform. Here's an example:

```hcl
resource "azuread_application_federated_identity_credential" "github_dev" {
  application_id = "6ab6e4fa-8e13-4200-b063-b47272dcb70e"
  display_name   = "github-actions-dev-environment"
  description    = "GitHub Actions OIDC for dev environment"
  audiences     = ["api://AzureADTokenExchange"]
  issuer        = "https://token.actions.githubusercontent.com"
  subject       = "repo:rkravihhh/aks-acr-sqlserver-sqldb:environment:dev"
}

resource "azuread_application_federated_identity_credential" "github_prod" {
  application_id = "6ab6e4fa-8e13-4200-b063-b47272dcb70e"
  display_name   = "github-actions-prod-environment"
  description    = "GitHub Actions OIDC for prod environment"
  audiences     = ["api://AzureADTokenExchange"]
  issuer        = "https://token.actions.githubusercontent.com"
  subject       = "repo:rkravihhh/aks-acr-sqlserver-sqldb:environment:prod"
}
```

## Subject Claim Formats

The subject claim format varies based on what you're protecting:

- **Repository-level**: `repo:ORG/REPO:ref:refs/heads/BRANCH`
- **Environment-level**: `repo:ORG/REPO:environment:ENVIRONMENT_NAME`
- **Pull Request**: `repo:ORG/REPO:pull_request`
- **Tag**: `repo:ORG/REPO:ref:refs/tags/TAG_NAME`

For your workflow, since you're using `environment: dev`, the subject must be:
```
repo:rkravihhh/aks-acr-sqlserver-sqldb:environment:dev
```

## Verify the Setup

After configuring the federated identity credential:

1. **Check GitHub Environment**
   - Go to your GitHub repository
   - Navigate to Settings → Environments
   - Ensure the `dev` environment exists (and `prod` if needed)
   - You can configure protection rules, secrets, and deployment branches here

2. **Test the Workflow**
   - Run your GitHub Actions workflow
   - The Azure login step should now succeed
   - Check the logs to verify the subject claim matches

## Troubleshooting

### Error: AADSTS700213
**Problem**: No matching federated identity record found

**Solutions**:
- Verify the subject claim exactly matches what's configured in Azure AD
- Check that the issuer is `https://token.actions.githubusercontent.com`
- Ensure the audience is `api://AzureADTokenExchange`
- Verify the environment name matches exactly (case-sensitive)

### Error: AADSTS7000215
**Problem**: Invalid client secret

**Solution**: This shouldn't occur with OIDC, but verify you're using the correct client ID

### Common Issues
1. **Case sensitivity**: Environment names are case-sensitive
2. **Repository name**: Must match exactly including organization name
3. **Multiple credentials**: You can have multiple federated credentials for different environments/branches

## Additional Resources

- [Microsoft Learn: Workload identity federation](https://learn.microsoft.com/entra/workload-id/workload-identity-federation)
- [GitHub Actions: Using OIDC with Azure](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [Azure/login Action Documentation](https://github.com/Azure/login#readme)

