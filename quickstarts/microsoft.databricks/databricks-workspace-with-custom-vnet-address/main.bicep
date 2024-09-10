@description('Specifies whether to deploy Azure Databricks workspace with Secure Cluster Connectivity (No Public IP) enabled or not')
param disablePublicIp bool = true

@description('The name of the Azure Databricks workspace to create.')
param workspaceName string

@description('The pricing tier of workspace.')
@allowed([
  'standard'
  'premium'
])
param pricingTier string = 'premium'

@description('The first 2 octets of the virtual network /16 address range (e.g., \'10.139\' for the address range 10.139.0.0/16).')
param vnetAddressPrefix string = '10.139'

@description('Location for all resources.')
param location string = resourceGroup().location

var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'
var trimmedMRGName = substring(managedResourceGroupName, 0, min(length(managedResourceGroupName), 90))
var managedResourceGroupId = '${subscription().id}/resourceGroups/${trimmedMRGName}'

resource workspace 'Microsoft.Databricks/workspaces@2024-05-01' = {
  name: workspaceName
  location: location
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: managedResourceGroupId
    parameters: {
      vnetAddressPrefix: {
        value: vnetAddressPrefix
      }
      enableNoPublicIp: {
        value: disablePublicIp
      }
    }
  }
}

output workspace object = workspace.properties
