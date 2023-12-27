targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Label used to generate a short unique hash used in all resources.')
param environmentName string = 'tw1'

@minLength(1)
@description('Primary location for all resources')
param location string = 'japaneast'

param resourceGroupName string = 'Team'

@description('Number of teams to create')
param teams int = 1

param openAiSkuName string = 'S0'
param openAiSkyCapacity int = 100000
param openAiServiceName string = 'sunhackathon'

param chatGptModelName string = 'gpt-35-turbo-16k'
param chatGptModelVersion string = '0613'
param chatGptDeploymentCapacity int = 100000

param textEmbeddingModelName string = 'text-embedding-ada-002'
param textEmbeddingVersion string = '2'
param textEmbeddingDeploymentCapacity int = 100000

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'env-name': environmentName }

// Organize resources in a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = [for index in range(0, teams):{
  name: !empty(resourceGroupName) ? '${resourceGroupName}${index+2}' : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}]


module openAi './openai.bicep' = [for index in range(0, teams):{
  name: '${openAiServiceName}-${index+2}'
  scope: resourceGroup[index]
  dependsOn: [
    resourceGroup[index]
  ]
  params: {
    name: !empty(openAiServiceName) ? '${openAiServiceName}-${index+2}' : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: openAiSkuName
      capacity: openAiSkyCapacity
    }
    deployments: [
      {
        name: 'GPT35TURBO16K'
        model: {
          format: 'OpenAI'
          name: chatGptModelName
          version: chatGptModelVersion
        }
        scaleSettings: {
          scaleType: 'Standard'
        }
        sku: {
          capacity: chatGptDeploymentCapacity
          name: 'Standard'
        }
        raiPolicyName: 'Microsoft.Default'
      }
      {
        name: 'ADA'
        model: {
          format: 'OpenAI'
          name: textEmbeddingModelName
          version: textEmbeddingVersion
        }
        scaleSettings: {
          scaleType: 'Standard'
        }
        sku: {
          capacity: textEmbeddingDeploymentCapacity
          name: 'Standard'
        }
        raiPolicyName: 'Microsoft.Default'
      }
    ]
  }
}]

// Deployment outputs
output accountEndpoints array = [for i in range(0, teams): {
  endpoint: openAi[i].outputs.endpoint
  deployment: openAi[i].outputs.name
}]
