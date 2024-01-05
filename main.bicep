targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Label used to generate a short unique hash used in all resources.')
param environmentName string = 'tw1'

@minLength(1)
@description('Primary location for all resources')
param location string = 'francecentral'

param resourceGroupName string = 'Team'

@description('Number of teams to create')
param teams int = 3

param openAiSkuName string = 'S0'
param openAiSkyCapacity int = 100000
param openAiServiceName string = 'sunhackathon'

param chatGptModelName string = 'gpt-35-turbo-16k'
param chatGptModelVersion string = '0613'
param chatGptDeploymentCapacity int = 20

param chatGptTurboModelName string = 'gpt-35-turbo'
param chatGptTurboVersion string = '0613'
param chatGptTurboDeploymentCapacity int = 20

param textEmbeddingModelName string = 'text-embedding-ada-002'
param textEmbeddingVersion string = '2'
param textEmbeddingDeploymentCapacity int = 20

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'env-name': environmentName }

// Organize resources in a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = [for index in range(0, teams):{
  name: !empty(resourceGroupName) ? '${resourceGroupName}${index+61}' : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}]

module openAi './openai.bicep' = [for index in range(0, teams):{
  name: '${openAiServiceName}${index+61}'
  scope: resourceGroup[index]
  dependsOn: [
    resourceGroup[index]
  ]
  params: {
    name: !empty(openAiServiceName) ? '${openAiServiceName}${index+61}' : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
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
        name: 'GPT35TURBO'
        model: {
          format: 'OpenAI'
          name: chatGptTurboModelName
          version: chatGptTurboVersion
        }
        scaleSettings: {
          scaleType: 'Standard'
        }
        sku: {
          capacity: chatGptTurboDeploymentCapacity
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
  id: openAi[i].outputs.id
  name: openAi[i].outputs.name
  key1: openAi[i].outputs.key1
  key2: openAi[i].outputs.key2
  deployment: openAi[i].outputs.name
}]
