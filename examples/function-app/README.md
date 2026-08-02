# Function-enabled deployment

The full scaffold: the Static Web App baseline plus a Flex Consumption function app, its storage, and its monitoring. Also turns on the optional user-assigned managed identity.

Deploys:

- Azure Resource Group
- Azure Static Web App — `Free` / `Free`
- Storage Account — `Standard_LRS`, `StorageV2`
- Blob container for the function deployment package
- Linux App Service Plan — `FC1` (Flex Consumption)
- Flex Consumption Function App
- Log Analytics Workspace
- Application Insights
- Action Group
- Failure Anomalies smart detector — `Sev3`, `PT1M`
- User-assigned Managed Identity

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # then edit
az login
terraform init
terraform plan
terraform apply
```

## Cost

Not free. The Static Web App stays on the Free tier, but the storage account, Log Analytics workspace, and Application Insights all bill on consumption, and the Flex Consumption plan bills per execution beyond its included grant. Run `terraform destroy` when you're done live-coding.

## Notes

**Storage authentication.** The default is `StorageAccountConnectionString`, which puts a storage access key in Terraform state. To keep the key out of state, set `storage_authentication_type = "UserAssignedIdentity"` on the module block — this example already enables the managed identity that requires.

**Role assignments.** The module creates the managed identity but assigns it no roles, because it cannot know what your functions need. Grant roles yourself using the `managed_identity_principal_id` output:

```hcl
resource "azurerm_role_assignment" "blob" {
  scope                = module.scaffold.storage_account_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = module.scaffold.managed_identity_principal_id
}
```

**Function code.** This provisions infrastructure only. Deploy code separately with `func azure functionapp publish <name>` or the Azure Functions GitHub Action.
