targetScope = 'subscription'

@description('Name of the resource group')
param rgName string

@description('Location for the resource group')
param rgLocation string

@description('Name of the AKS cluster')
param clusterName string = 'myAKSCluster'

@description('Name of the Virtual Network')
param vnetName string = 'aksVNet'

@description('Owner email address (must be a Neudesic.com address)')
param ownerEmail string

// 1. Deploy Resource Group (at subscription scope)
module rgModule 'rg.bicep' = {
  name: 'resourceGroupDeployment'
  scope: subscription()
  params: {
    rgName: rgName
    rgLocation: rgLocation
    ownerEmail: ownerEmail
  }
}

// 2. Deploy network (after RG is created)
module networkModule 'network.bicep' = {
  name: 'networkDeployment'
  scope: resourceGroup(rgName)
  dependsOn: [rgModule]
  params: {
    location: rgLocation
    vnetName: vnetName
    ownerEmail: ownerEmail
  }
}

// 3. Deploy AKS (after network is created)
module aksCluster 'aks.bicep' = {
  name: 'aksDeployment'
  scope: resourceGroup(rgName)
  params: {
    clusterName: clusterName
    location: rgLocation
    subnetId: networkModule.outputs.aksSubnetId
    ownerEmail: ownerEmail
  }
}

output resourceGroupId string = rgModule.outputs.resourceGroupId
output vnetName string = networkModule.outputs.vnetName
output aksClusterName string = aksCluster.outputs.clusterName
