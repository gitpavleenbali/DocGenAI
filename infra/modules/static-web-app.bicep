@description('Environment name')
param environmentName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Resource token for unique naming')
param resourceToken string

@description('Tags to apply to all resources')
param tags object = {}

@description('API Container App URL for backend connection')
param apiContainerAppUrl string

// Import abbreviations
var abbrs = loadJsonContent('../abbreviations.json')

// Static Web App
resource staticWebApp 'Microsoft.Web/staticSites@2024-04-01' = {
  name: '${abbrs.webStaticSites}${environmentName}-${resourceToken}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    buildProperties: {
      appLocation: 'webapp'
      outputLocation: 'dist'
      appBuildCommand: 'npm run build'
      skipGithubActionWorkflowGeneration: true
    }
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    publicNetworkAccess: 'Enabled'
    enterpriseGradeCdnStatus: 'Disabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// App settings for static web app
resource staticWebAppSettings 'Microsoft.Web/staticSites/config@2024-04-01' = {
  parent: staticWebApp
  name: 'appsettings'
  properties: {
    REACT_APP_API_BASE_URL: apiContainerAppUrl
    REACT_APP_ENVIRONMENT: 'production'
  }
}

// Outputs
@description('Static Web App name')
output staticWebAppName string = staticWebApp.name

@description('Static Web App default hostname')
output staticWebAppDefaultHostname string = staticWebApp.properties.defaultHostname

@description('Static Web App URL')
output staticWebAppUrl string = 'https://${staticWebApp.properties.defaultHostname}'

@description('Static Web App resource ID')
output staticWebAppId string = staticWebApp.id
