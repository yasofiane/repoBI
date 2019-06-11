#
# DeployAzure_MainTemplate.ps1
#

Param(
[Parameter(Position=0, Mandatory = $True, HelpMessage='Specify the Ressource Group name.')]
[String] $RG_Name,
[Parameter(Position=1, Mandatory = $True, HelpMessage='Specify the App name.')]
[String] $AppName,
[Parameter(Position=2, Mandatory = $True, HelpMessage='Specify the Environment.')]
[String] $Environment,
[Parameter(Position=3, Mandatory = $True, HelpMessage='Specify the Resource Group Location.')]
[String] $RGLocation,
[Parameter(Position=4, Mandatory = $True, HelpMessage='Specify the Storage Account Uri.')]
[String] $storageUri,
[Parameter(Position=5, Mandatory = $True, HelpMessage='Specify the Storage Account SAS Token.')]
[String] $storageToken,
[Parameter(Position=6, Mandatory = $True, HelpMessage='Specify the Resource Number.')]
[String] $ResourceNumber,
[Parameter(Position=7, Mandatory = $True, HelpMessage='Specify the Service Principal ID for ADF.')]
[String] $adfServicePrincipalID
)

$url = "$storageUri"+"/Main/main-template.json"
$token = "$storageToken"
Write-Host "Url : $url + $token"
$SecSasToken = ConvertTo-SecureString $token -AsPlainText -Force
New-AzureRmResourceGroupDeployment -ResourceGroupName $RG_Name -TemplateUri ($url + $token) -appName $AppName -environment $Environment -blobStorageCommonSasToken $SecSasToken -location $RGLocation -resourceNumber $ResourceNumber -adfServicePrincipalID $adfServicePrincipalID -Verbose