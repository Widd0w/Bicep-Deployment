@description('Name der Action Group')
param actionGroupName string

@description('E-Mail-Adresse des Empfaengers')
param emailAddress string

@description('Name der Alert Rule')
param alertRuleName string

@description('Standort der Ressourcen')
param location string = resourceGroup().location

// Action Group
resource actionGroup 'Microsoft.Insights/actionGroups@2022-06-15' = {
  name: actionGroupName
  location: location
  properties: {
    groupShortName: 'SvcHlth'
    enabled: true
    emailReceivers: [
      {
        name: 'PrimaryEmail'
        emailAddress: emailAddress
        status: 'Enabled'
      }
    ]
  }
}

// Alert Rule
resource serviceHealthAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: alertRuleName
  location: location
  properties: {
    description: 'Benachrichtigung bei Azure-Dienstausfaellen'
    severity: 3
    enabled: true
    scopes: [
      subscription().id
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      '@odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'ServiceHealthEvent'
          metricName: 'ServiceHealthEvents'
          metricNamespace: 'microsoft.insights/serviceHealth'
          operator: 'GreaterThan'
          threshold: 0
          timeAggregation: 'Total'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
    autoMitigate: false
  }
}
