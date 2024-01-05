param name string
param properties object

resource budget 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: name
  properties: properties
}
