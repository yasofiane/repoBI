#############################################################################################################################################################
###                             The below code is to assign permissions to user(s)/group(s) on ADLS under one resource group                              ###
#############################################################################################################################################################
param(
    [Parameter(Position=0, Mandatory = $True, HelpMessage='Specify the App name.')]
	[String] $AppName,
	[Parameter(Position=1, Mandatory = $True, HelpMessage='Specify the Environment.')]
	[String] $Environment,
	[Parameter(Position=2, Mandatory = $True, HelpMessage='Specify the Resource Group Location.')]
	[String] $RGLocation,
	[Parameter(Position=3, Mandatory = $True, HelpMessage='Specify the Resource Number.')]
	[String] $ResourceNumber,
	[Parameter(Position=4, Mandatory = $False, HelpMessage = "The folders file. Uses adls-folders.json in the script folder as default.")]
    [String]$parameterFileForFolders = "adls-folders.json"        
)

$adlsName = $RGLocation+$AppName+"adls"+$Environment+$ResourceNumber
$adlsName = $adlsName.Replace("-","")
Write-Verbose "adls name: $adlsName"

function Set-FolderPermissions {
    param
    (
        [string] $adlStoreName,
        [object] $folder
    )    
    $path = $folder.Path
    Write-Verbose "Set-FolderPermissions for path $path"
    foreach ($objP in $folder.Permissions) {
                
        $granteeId = $objP.ObjectId
		#$userId = (Get-AzureRmADServicePrincipal -SearchString  $objP.Name).Id
        #Write-Verbose "userId:  $userId"
        #$granteeId = $userId.Guid
        #Write-Verbose "user guid:  $userId.Guid"
        $granteeName = $objP.Name
        $permission = $objP.Permissions
        $aceType = $objP.AceType

        Write-Verbose "Granting $aceType $granteeName with Id $granteeId permissions $permission to folder $path with default value $($objP.Default)"
        if ($objP.Default -eq "true") {
            Set-AzureRmDataLakeStoreItemAclEntry -Account $adlStoreName -Path $path -AceType $aceType -Id $granteeId -Permissions $permission -Default -WarningAction SilentlyContinue
        } else {
            Set-AzureRmDataLakeStoreItemAclEntry -Account $adlStoreName -Path $path -AceType $aceType -Id $granteeId -Permissions $permission -WarningAction SilentlyContinue
        }        
    }
}

$adls = $adlsName

$folderParameterFile = $parameterFileForFolders
Write-Verbose "folderParameterFile: $folderParameterFile"
#Below code is to replace the PowerShell folder with ADLS folder in the path to make sure param file is picked up from correct folder
$scriptRoot = (Get-Item -Path $PSScriptRoot).FullName
$folderParameterFileFullPath = "{0}\{1}" -f $scriptRoot.Replace("PowerShell", "ADLS"), $folderParameterFile
$folderParameters = Get-Content -Path $folderParameterFileFullPath -Raw | ConvertFrom-JSON

Write-Verbose "Setting folder permissions"
#Iterate over the JSON
foreach ($env in $folderParameters.Envionments)
{
	#Iterate over the Environments
    foreach ($envName in $env.Name)
    {
		Write-Verbose "The environment in iteration is $envName"            
        if ($envName -eq $Environment) 
		{
			Write-Verbose "The environment is macthed with ...$Environment"
			#Iterate over folders of current environment
			foreach ($obj in $env.Folders) {
				if ($obj.Path -eq "/") {
					Write-Verbose "Setting root path permission"
					# This is the adls root
					Set-FolderPermissions -adlStoreName $adls -folder $obj
				}
				else {
					Try {
						# Create the folder so long as it doesn't already exist.
						if (!(Get-AzureRmDataLakeStoreItem -AccountName $adls -Path $obj.Path -ErrorAction Ignore)) {
							New-AzureRmDataLakeStoreItem -Folder -AccountName $adls -Path $obj.Path
						}            
						Write-Verbose "Setting $($obj.Path) path permission"
						Set-FolderPermissions -adlStoreName $adls -folder $obj
					} Catch {
						Write-Error $_.Exception.Message
					}
				}
			}
		}
	}
}