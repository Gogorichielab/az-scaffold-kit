# Minimum deployment

The smallest thing the scaffold will build: a resource group and a Static Web App on the Free tier. No storage, no compute, no monitoring.

Deploys:

- Azure Resource Group
- Azure Static Web App — `Free` / `Free`

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # then edit
az login
terraform init
terraform plan
terraform apply
```

## Cost

Nothing, on the always-free tier. The Static Web App Free tier covers 100 GB bandwidth, 0.5 GB storage per app, and 2 custom domains — see the [free services cheat sheet](../../docs/free-azure-services.md).

## Notes

The Static Web App Free tier is only offered in a subset of Azure regions. If apply fails on region grounds, try `eastus2`, `westus2`, `centralus`, `westeurope`, or `eastasia`.

To add the Function App stack, see [`../function-app`](../function-app).
