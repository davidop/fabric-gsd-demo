@description('Optional resource group location for auxiliary demo resources. Fabric capacity/workspace provisioning is intentionally not modeled here.')
param location string = resourceGroup().location

output note string = 'This demo focuses on Fabric item definitions and CI/CD. Provision Fabric workspace/capacity according to your tenant standards.'
