# Azure Infrastructure for ZavaStorefront

This directory contains Bicep templates for deploying the ZavaStorefront web application infrastructure to Azure using Azure Developer CLI (azd).

## Architecture

The infrastructure includes the following Azure resources:

- **Resource Group**: All resources are deployed to a single resource group in westus3 region
- **Azure Container Registry (ACR)**: Stores Docker container images (Basic SKU)
- **App Service Plan**: Linux-based hosting plan for containers (Basic B1 SKU)
- **App Service**: Web App for Containers configured to pull images from ACR
- **Application Insights**: Application monitoring and telemetry
- **Log Analytics Workspace**: Centralized logging for all resources
- **Microsoft Foundry (AI Hub & Project)**: AI services for GPT-4 and Phi models
- **RBAC Role Assignment**: System-assigned managed identity with AcrPull role

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- An Azure subscription with permissions to create resources

## Deployment

### Initialize AZD

```bash
azd init
```

Follow the prompts to:
- Scan the current directory (default option)
- Confirm the .NET application in the `src` folder
- Confirm the port configuration

### Preview Infrastructure

Before deploying, preview the resources that will be created:

```bash
azd provision --preview
```

You will be prompted for:
- **Environment name**: A unique name for this deployment environment
- **Azure subscription**: Select your target subscription
- **Resource group**: Select existing or create new
- **Region**: westus3 (or your preferred region)

### Deploy Infrastructure and Application

Deploy all resources and the application:

```bash
azd up
```

This command will:
1. Package the application source code
2. Provision all Azure resources using Bicep templates
3. Build the Docker image using `az acr build` (no local Docker required)
4. Deploy the container to App Service

### Deploy Application Only

To deploy just the application code without re-provisioning infrastructure:

```bash
azd deploy
```

## Security Features

- **No Password Authentication**: App Service uses system-assigned managed identity to pull images from ACR
- **RBAC-based Access**: AcrPull role assigned to App Service managed identity
- **HTTPS Only**: App Service configured to require HTTPS
- **Minimum TLS 1.2**: Enhanced security for connections
- **FTPS Disabled**: Secure deployment only

## Container Image Build

The infrastructure is designed to work **without local Docker installation**. Container images are built using:

```bash
az acr build --registry <ACR_NAME> --image <IMAGE_NAME> .
```

Or via GitHub Actions using the Azure Container Registry Build task.

## Monitoring

Application Insights is automatically configured with:
- Connection string injected as environment variable
- Application Insights agent enabled
- Integration with Log Analytics workspace

Access monitoring data in the Azure Portal under the Application Insights resource.

## Microsoft Foundry (AI Hub & Project)

The deployment includes Azure AI services configured for:
- GPT-4 model access
- Phi model access
- westus3 region for model availability

## Clean Up

To remove all deployed resources:

```bash
azd down
```

This will delete the resource group and all contained resources.

## Cost Considerations

This is a **development environment** using minimal-cost SKUs:
- Container Registry: Basic
- App Service Plan: B1 (Basic)
- Application Insights: Pay-as-you-go
- Log Analytics: Pay-as-you-go

For production workloads, consider upgrading to Standard or Premium SKUs.

## Troubleshooting

### Provisioning Errors

If you encounter errors during `azd up` or `azd provision`:

1. Review the error message carefully
2. Use GitHub Copilot or Azure CLI to diagnose: "Can you explain and fix this error?"
3. Re-run the command after making corrections
4. Check Azure Portal for partially created resources

### Container Image Issues

If the App Service cannot pull the container image:

1. Verify the managed identity is assigned: Check App Service > Identity
2. Verify RBAC role assignment: Check ACR > Access Control (IAM)
3. Verify image exists in ACR: `az acr repository list --name <ACR_NAME>`

### AI Hub/Project Deployment

Microsoft Foundry requires:
- Specific region support (westus3 recommended)
- Subscription quota for AI services
- May take longer to provision than other resources

## File Structure

```
infra/
├── main.bicep                          # Main orchestration template
├── main.bicepparam                     # Parameters file
├── abbreviations.json                  # Resource naming abbreviations
├── modules/
│   ├── acr.bicep                      # Azure Container Registry
│   ├── appService.bicep               # App Service (Web App)
│   ├── appServicePlan.bicep           # App Service Plan
│   ├── appInsights.bicep              # Application Insights
│   ├── logAnalytics.bicep             # Log Analytics Workspace
│   ├── acrPullRoleAssignment.bicep    # RBAC role assignment
│   ├── aiHub.bicep                    # AI Hub
│   └── aiProject.bicep                # AI Project
└── README.md                           # This file
```

## Additional Resources

- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Web App for Containers](https://learn.microsoft.com/azure/app-service/quickstart-custom-container)
- [Azure Container Registry](https://learn.microsoft.com/azure/container-registry/)
- [Microsoft Foundry](https://learn.microsoft.com/azure/ai-foundry/)
