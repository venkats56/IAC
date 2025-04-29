@description('Location for the VNet')
param location string

@description('Name of the Virtual Network')
param vnetName string

@description('VNet address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('AKS subnet address prefix')
param aksSubnetPrefix string = '10.0.0.0/24'


resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'aksSubnet'
        properties: {
          addressPrefix: aksSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output aksSubnetId string = vnet.properties.subnets[0].id
