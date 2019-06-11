#
# KV_SetAccessPolicies.ps1
#
Param(
[Parameter(Position=0, Mandatory = $True, HelpMessage='Specify the App name.')]
[String] $AppName,
[Parameter(Position=1, Mandatory = $True, HelpMessage='Specify the Environment.')]
[String] $Environment,
[Parameter(Position=2, Mandatory = $True, HelpMessage='Specify the Resource Group Location.')]
[String] $RGLocation,
[Parameter(Position=3, Mandatory = $True, HelpMessage='Specify the Resource Number.')]
[String] $ResourceNumber
)

$ServicePrincipalName = (Get-AzureRmContext).Account.Id

$KVName = -join($RGLocation, "-", $AppName, "-kv-", $Environment, $ResourceNumber)

$Id = (Get-AzureRmADServicePrincipal -ServicePrincipalName $ServicePrincipalName).Id
$ObjectId = $Id.Guid

Set-AzureRmKeyVaultAccessPolicy -VaultName $KVName -ObjectId $ObjectId -PermissionsToKeys get,list,create,update,delete -PermissionsToSecrets get,list,set,delete
