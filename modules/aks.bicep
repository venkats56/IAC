@description('The name of the AKS cluster')
param clusterName string

@description('The location for the AKS cluster')
param location string

@description('The ID of the subnet for AKS node pools')
param subnetId string

@description('The size of the Virtual Machine')
param vmSize string = 'Standard_DS2_v2'

@description('The number of nodes for the cluster')
@minValue(1)
@maxValue(100)
param nodeCount int = 1

@description('Kubernetes version')
param kubernetesVersion string = '1.31.7'



resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-01-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
 
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: clusterName
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      serviceCidr: '10.0.1.0/24'
      dnsServiceIP: '10.0.1.10'
      dockerBridgeCidr: '172.17.0.1/16'
    }
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: nodeCount
        vmSize: vmSize
        mode: 'System'
        vnetSubnetID: subnetId
      }
    ]
    // This property is supported
    nodeResourceGroup: 'MC_${resourceGroup().name}_${clusterName}_${location}'
  }
}

output clusterName string = aksCluster.name
output controlPlaneFQDN string = aksCluster.properties.fqdn
