# ZavaStorefront Infrastructure

## Overview

This folder contains the Bicep templates for provisioning the Azure infrastructure for the ZavaStorefront web application using Azure Developer CLI (AZD).

## Architecture

| Resource | Module | Purpose |
|---|---|---|
| Resource Group | main.bicep | Single resource group in westus3 |
| Azure Container Registry | modules/acr.bicep | Store Docker images (Basic SKU) |
| App Service Plan + Web App | modules/appService.bicep | Linux App Service (Web App for Containers) |
| ACR Pull Role Assignment | modules/acrRoleAssignment.bicep | RBAC-based image pull (no passwords) |
| Log Analytics Workspace | modules/logAnalytics.bicep | Log aggregation |
| Application Insights | modules/appInsights.bicep | Application monitoring |
| AI Foundry (Cognitive Services) | modules/aiFoundry.bicep | GPT-4 and Phi model access |

## Deployment

```bash
# Initialize AZD
azd init

# Preview the deployment
azd provision --preview

# Deploy infrastructure
azd up
```

## Key Design Decisions

- **No local Docker required** — images are built in the cloud using `az acr build` or GitHub Actions.
- **RBAC-based ACR pull** — the Web App uses a system-assigned managed identity with the AcrPull role; no admin credentials or passwords are stored.
- **Dev-appropriate SKUs** — Basic ACR and B1 App Service Plan keep costs low for development environments.
- **Single region (westus3)** — all resources co-located for simplicity and to ensure AI model availability.
