targetScope = 'subscription'

@description('Name of the resource group')
param rgName string

@description('Location for the resource group')
param rgLocation string

@description('Owner email address')
param ownerEmail string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: rgLocation
  tags: {
    environment: 'production'
    project: 'demo'
    owner: ownerEmail
  }
}

output resourceGroupId string = resourceGroup.id
