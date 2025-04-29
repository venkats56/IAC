targetScope = 'subscription'

@description('Name of the resource group')
param rgName string

@description('Location for the resource group')
param rgLocation string

@description('Name of the AKS cluster')
param clusterName string = 'myAKSCluster'

@description('Name of the Virtual Network')
param vnetName string = 'aksVNet'



// 1. Deploy Resource Group (at subscription scope)
module rgModule 'modules/rg.bicep' = {
  name: 'resourceGroupDeployment'
  scope: subscription()
  params: {
    rgName: rgName
    rgLocation: rgLocation

  }
}

// 2. Deploy network (after RG is created)
module networkModule 'modules/network.bicep' = {
  name: 'networkDeployment'
  scope: resourceGroup(rgName)
  dependsOn: [rgModule]
  params: {
    location: rgLocation
    vnetName: vnetName

  }
}

// 3. Deploy AKS (after network is created)
module aksCluster 'modules/aks.bicep' = {
  name: 'aksDeployment'
  scope: resourceGroup(rgName)
  params: {
    clusterName: clusterName
    location: rgLocation
    subnetId: networkModule.outputs.aksSubnetId

  }
}

output resourceGroupId string = rgModule.outputs.resourceGroupId
output vnetName string = networkModule.outputs.vnetName
output aksClusterName string = aksCluster.outputs.clusterName

