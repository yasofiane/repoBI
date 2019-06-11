#############################################################################################################################################################
###                             The below code is to assign firewall rules to differnet resources                              ###
#############################################################################################################################################################
param(
    [Parameter(Position=0, Mandatory = $True, HelpMessage='Specify the App name.')]
	[String] $AppName,
	[Parameter(Position=1, Mandatory = $True, HelpMessage='Specify the Environment.')]
	[String] $Environment,
	[Parameter(Position=2, Mandatory = $True, HelpMessage='Specify the Resource Group Location.')]
	[String] $RGLocation,
	[Parameter(Position=3, Mandatory = $True, HelpMessage='Specify the Resource Number.')]
	[String] $ResourceNumber ,
	[Parameter(Position=4, Mandatory = $False, HelpMessage = "The parameter file for ADLA. Uses parameters.json in the script folder as default.")]
    [String]$parameterFileADLA = "adla-firewallrules.json",
	[Parameter(Position=5, Mandatory = $False, HelpMessage = "The parameter file ADLS. Uses parameters.json in the script folder as default.")]
    [String]$parameterFileADLS = "adls-firewallrules.json"
)

$adlaName = $RGLocation+$AppName+"adla"+$Environment+$ResourceNumber
$adla= $adlaName.Replace("-","")
Write-Verbose "adla name: $adla"

$adlsName = $RGLocation+$AppName+"adls"+$Environment+$ResourceNumber
$adls= $adlsName.Replace("-","")
Write-Verbose "adls name: $adls"

#$scriptRoot = "$(System.DefaultWorkingDirectory)\CH Azure Infrastructure Build-CI-DEV\arm template\arm\PowerShell"
#Below code is to replace the PowerShell folder with ADLA folder in the path to make sure param file is picked up from correct folder
$scriptRoot = (Get-Item -Path $PSScriptRoot).FullName
$parameterFileFullPathForADLA = "{0}\{1}" -f $scriptRoot.Replace("PowerShell", "ADLA"), $parameterFileADLA
$parametersADLA = Get-Content -Path $parameterFileFullPathForADLA -Raw | ConvertFrom-JSON
$parametersADLA = $parametersADLA.$Environment
$parameterFileFullPathForADLS = "{0}\{1}" -f $scriptRoot.Replace("PowerShell", "ADLS"), $parameterFileADLS
$parametersADLS = Get-Content -Path $parameterFileFullPathForADLS -Raw | ConvertFrom-JSON
$parametersADLS = $parametersADLS.$Environment
#Enable the Firewall for ADLA
Set-AzureRmDataLakeAnalyticsAccount -Name $adla -FirewallState Enabled
Set-AzureRmDataLakeAnalyticsAccount -Name $adla -AllowAzureIpState Enabled

#Enable the Firewall for ADLS
Set-AzureRmDataLakeStoreAccount -Name $adls -FirewallState Enabled
Set-AzureRmDataLakeStoreAccount -Name $adls -AllowAzureIpState Enabled


#Assign IP Addresses' range to ADLA
foreach ($obj in $parametersADLA) {
    
	Write-Verbose "Setting firewall rules for ADLA"
	Add-AzureRmDataLakeAnalyticsFirewallRule -Account $adla -Name $obj.name -StartIpAddress $obj.Start -EndIpAddress $obj.End
}

#Assign IP Addresses' range to ADLS
foreach ($obj in $parametersADLS) {
	Write-Verbose "Setting firewall rules for ADLS"
	Add-AzureRmDataLakeStoreFirewallRule  -Account $adls -Name $obj.name -StartIpAddress $obj.Start -EndIpAddress $obj.End
}        
    
