pipeline {
    agent any

    parameters {
        string(name: 'RESOURCE_GROUP_NAME', defaultValue: 'BicepResourceGroup',
               description: 'Name of the resource group')
        string(name: 'LOCATION', defaultValue: 'westeurope', description: 'Azure region')
        string(name: 'VNET_NAME', defaultValue: 'BicepAKSVNet', description: 'Name of the VNet')
        string(name: 'CLUSTER_NAME', defaultValue: 'BicepAKSCluster', description: 'Name of the AKS cluster')
    }

    environment {
        AZURE_CLIENT_ID       = credentials('azure-client-id')        // Secret Text
        AZURE_CLIENT_SECRET   = credentials('azure-client-secret')    // Secret Text
        AZURE_TENANT_ID       = credentials('azure-tenant-id')        // Secret Text
        AZURE_SUBSCRIPTION_ID = credentials('azure-subscription-id')  // Secret Text
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/venkats56/IAC']])
            }
        }

        stage('Validate Templates') {
            steps {
                sh '''
                    az login --service-principal \\
                        -u $AZURE_CLIENT_ID \\
                        -p $AZURE_CLIENT_SECRET \\
                        -t $AZURE_TENANT_ID

                    az account set --subscription $AZURE_SUBSCRIPTION_ID

                    az deployment sub validate \\
                        --location "$LOCATION" \\
                        --name "bicepDeployment" \\
                        --template-file main.bicep \\
                        --parameters rgName="$RESOURCE_GROUP_NAME" \\
                                     rgLocation="$LOCATION" \\
                                     vnetName="$VNET_NAME" \\
                                     clusterName="$CLUSTER_NAME"
                '''
            }
        }

        stage('Deploy Resources') {
            steps {
                sh '''
                    az login --service-principal \\
                        -u $AZURE_CLIENT_ID \\
                        -p $AZURE_CLIENT_SECRET \\
                        -t $AZURE_TENANT_ID

                    az account set --subscription $AZURE_SUBSCRIPTION_ID

                    az deployment sub create \\
                        --location "$LOCATION" \\
                        --name "bicepDeployment" \\
                        --template-file main.bicep \\
                        --parameters rgName="$RESOURCE_GROUP_NAME" \\
                                     rgLocation="$LOCATION" \\
                                     vnetName="$VNET_NAME" \\
                                     clusterName="$CLUSTER_NAME"
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    az login --service-principal \\
                        -u $AZURE_CLIENT_ID \\
                        -p $AZURE_CLIENT_SECRET \\
                        -t $AZURE_TENANT_ID

                    az account set --subscription $AZURE_SUBSCRIPTION_ID

                    az aks show \\
                        --resource-group "$RESOURCE_GROUP_NAME" \\
                        --name "$CLUSTER_NAME" \\
                        --output table
                '''
            }
        }
    }

    post {
        always {
            sh 'az logout || true'
        }
    }
}

