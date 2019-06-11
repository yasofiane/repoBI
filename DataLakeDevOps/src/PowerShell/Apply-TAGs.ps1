#############################################################################################################################################################
###                             The below code is to assign TAGs to differnet components of under one resource group                              ###
#############################################################################################################################################################
param(
	[Parameter(Position=0, Mandatory = $True, HelpMessage='Specify the Ressource Group name.')]
	[String] $RG_Name,
	[Parameter(Position=1, Mandatory = $True, HelpMessage='Specify the App name.')]
	[String] $AppName,
	[Parameter(Position=2, Mandatory = $True, HelpMessage='Specify the Environment.')]
	[String] $Environment,
	[Parameter(Position=5, Mandatory = $False, HelpMessage = "The parameter file ADLS. Uses parameters.json in the script folder as default.")]
	[String]$parameter = "tags.json"
)


$scriptRoot = (Get-Item -Path $PSScriptRoot).FullName
#Below code is to replace the PowerShell folder with ADLS folder in the path to make sure param file is picked up from correct folder
$parameterFileFullPath = "{0}\{1}" -f $scriptRoot.Replace("PowerShell", "Main"), $parameter
$parameterFile = Get-Content -Path $parameterFileFullPath -Raw | ConvertFrom-JSON
$CostCenter = "Cx"
$Owner = "Chris Cook"

$groups = Get-AzureRmResourceGroup -Name $RG_Name
Write-Verbose "finding all resource types in the resource group"
$t=(Find-AzureRmResource -ResourceGroupNameEquals $groups.ResourceGroupName).ResourceType

$datafactoryrole = $parameterFile.tags.'Microsoft.DataFactory/datafactories'.role
$datafactoryrolev2 = $parameterFile.tags.'Microsoft.DataFactory/factories'.role
$dataLakeAnalyticsrole = $parameterFile.tags.'Microsoft.DataLakeAnalytics/accounts'.role
$dataLakeStorerole = $parameterFile.tags.'Microsoft.DataLakeStore/accounts'.role
$keyVaultrole = $parameterFile.tags.'Microsoft.KeyVault/vaults'.role
$storagerole = $parameterFile.tags.'Microsoft.Storage/storageAccounts'.role
$defaultrole = $parameterFile.tags.'Default'.role

foreach($object in $t)
{
	switch($object)
	{
		'Microsoft.DataFactory/datafactories'
		{		
			$tags = @{ Role="$datafactoryrole"; Environment="$Environment"; Application="$AppName"; CostCenter="$CostCenter"; Owner="$Owner" }
			$Resource = Get-AzureRmResource -ResourceType "Microsoft.DataFactory/datafactories" -ResourceGroupName "$RG_Name"
			foreach ($x in $Resource)
			{
				Write-Verbose "Setting tags for DataFactory"
				Set-AzureRmResource -Tag $tags -ResourceId $x.ResourceId -Force
			}	
		}
		'Microsoft.DataFactory/factories'
		{		
			$tags = @{ Role="$datafactoryrolev2"; Environment="$Environment"; Application="$AppName"; CostCenter="$CostCenter"; Owner="$Owner" }
			$Resource = Get-AzureRmResource -ResourceType "Microsoft.DataFactory/factories" -ResourceGroupName "$RG_Name"
			foreach ($x in $Resource)
			{
				Write-Verbose "Setting tags for DataFactoryV2"
				Set-AzureRmResource -Tag $tags -ResourceId $x.ResourceId -Force
			}	
		}
		'Microsoft.DataLakeAnalytics/accounts'
		{		
			$tags = @{ Role="$dataLakeAnalyticsrole"; Environment="$Environment"; Application="$AppName"; CostCenter="$CostCenter"; Owner="$Owner" }
			$Resource = Get-AzureRmResource -ResourceType "Microsoft.DataLakeAnalytics/accounts" -ResourceGroupName "$RG_Name"
			foreach ($x in $Resource)
			{
				Write-Verbose "Setting tags for DataLakeAnalytics"
				Set-AzureRmResource -Tag $tags -ResourceId $x.ResourceId -Force
			}	
		}
		'Microsoft.DataLakeStore/accounts'
		{		
			$tags = @{ Role="$dataLakeStorerole"; Environment="$Environment"; Application="$AppName"; CostCenter="$CostCenter"; Owner="$Owner" }
			$Resource = Get-AzureRmResource -ResourceType "Microsoft.DataLakeStore/accounts" -ResourceGroupName "$RG_Name"
			foreach ($x in $Resource)
			{
				Write-Verbose "Setting tags for DataLakeStore"
				Set-AzureRmResource -Tag $tags -ResourceId $x.ResourceId -Force
			}	
		}
		'Microsoft.KeyVault/vaults'
		{		
			$tags = @{ Role="$keyVaultrole"; Environment="$Environment"; Application="$AppName"; CostCenter="$CostCenter"; Owner="$Owner" }
			$Resource = Get-AzureRmResource -ResourceType "Microsoft.KeyVault/vaults" -ResourceGroupName "$RG_Name"
			foreach ($x in $Resource)
			{
				Write-Verbose "Setting tags for KeyVault"
				Set-AzureRmResource -Tag $tags -ResourceId $x.ResourceId -Force
			}	
		}
		'Microsoft.Storage/storageAccounts'
		{		
			$tags = @{ Role="$storagerole"; Environment="$Environment"; Application="$AppName"; CostCenter="$CostCenter"; Owner="$Owner" }
			$Resource = Get-AzureRmResource -ResourceType "Microsoft.Storage/storageAccounts" -ResourceGroupName "$RG_Name"
			foreach ($x in $Resource)
			{
				Write-Verbose "Setting tags for Storage"
				Set-AzureRmResource -Tag $tags -ResourceId $x.ResourceId -Force
			}		
		}
		default 
		{		
			$tags = @{ Role="$object"; Environment="$Environment"; Application="$AppName"; CostCenter="$CostCenter"; Owner="$Owner" }
			$Resource = Get-AzureRmResource -ResourceType $object -ResourceGroupName "$RG_Name"
			foreach ($x in $Resource)
			{
				Write-Verbose "Setting tags for Default"
				Set-AzureRmResource -Tag $tags -ResourceId $x.ResourceId -Force
			}	
		}		
	}
}