targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Label used to generate a short unique hash used in all resources.')
param environmentName string = 'tw1'

@minLength(1)
@description('Primary location for all resources')
param location string = 'japaneast'

param resourceGroupName string = 'openai-rg8'

param accounts int = 2

param openAiSkuName string = 'S0'
param openAiSkyCapacity int = 10
param openAiServiceName string = 'openai-gpt35'

param chatGptDeploymentName string = 'chat'
param chatGptModelName string = 'gpt-35-turbo'
param chatGptDeploymentCapacity int = 30

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'env-name': environmentName }

// Organize resources in a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}


module openAi './openai.bicep' = [for index in  range(0, accounts):{
  name: 'openai-for-account-${index}'
  scope: resourceGroup
  params: {
    name: !empty(openAiServiceName) ? '${openAiServiceName}-${index}' : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: openAiSkuName
      capacity: openAiSkyCapacity
    }
    deployments: [
      {
        name: '${chatGptDeploymentName}-${index}'
        model: {
          format: 'OpenAI'
          name: chatGptModelName
          version: '0301'
        }
        scaleSettings: {
          scaleType: 'Standard'
        }
        sku: {
          capacity: chatGptDeploymentCapacity
        }
      }
    ]
  }
}]

// Deployment outputs
output accountEndpoints array = [for i in range(0, accounts): {
  endpoint: openAi[i].outputs.endpoint
  deployment: chatGptDeploymentName
}]
