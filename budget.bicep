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
param teams int = 63

var abbrs = loadJsonContent('./abbreviations.json')
var tags = { 'env-name': 'environmentName' }

// Organize resources in a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = [for index in range(0, teams):{
  name: !empty(resourceGroupName) ? '${resourceGroupName}${index+1}' : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}]

module budget './module-budget.bicep' = [for index in range(0, teams):{
  name: !empty(resourceGroupName) ? '${resourceGroupName}${index+1}' : '${abbrs.resourcesResourceGroups}{environmentName}'
  scope: resourceGroup[index]
  dependsOn: [
    resourceGroup[index]
  ]
  params: {
    name: '${resourceGroupName}${index+1}'
    properties: {
      category: 'Cost'
      amount: 1500
      timeGrain: 'Monthly'
      timePeriod: {
        startDate: '2024-01-01T00:00:00Z'
        endDate: '2024-12-31T00:00:00Z'
      }
      notifications: {
        NotificationForExceededBudget1: {
          enabled: true
          operator: 'GreaterThan'
          threshold: 99
          contactEmails: [
            'tran.duc.thang@sun-asterisk.com'
          ]
        }
      }
    }
  }
}]
