#
# Set_Diagnostic.ps1
#
Param(
[Parameter(Position=0, Mandatory = $True, HelpMessage='Specify the App name.')]
[String] $AppName,
[Parameter(Position=1, Mandatory = $True, HelpMessage='Specify the Environment.')]
[String] $Environment,
[Parameter(Position=2, Mandatory = $True, HelpMessage='Specify the Resource Group Location.')]
[String] $RGLocation,
[Parameter(Position=3, Mandatory = $True, HelpMessage='Specify the Resource Number.')]
[String] $ResourceNumber,
[Parameter(Position=4, Mandatory = $True, HelpMessage='Specify the Resource Group Name.')]
[String] $ResourceGroupName,
[Parameter(Position=4, Mandatory = $True, HelpMessage='Specify the Diagnostic Retention days.')]
[int16] $RetentionDays,
[Parameter(Position=5, Mandatory = $True, HelpMessage='Specify the Diagnostic Resource Group.')]
[string] $DiagnosticResourceGroupName,
[Parameter(Position=6, Mandatory = $True, HelpMessage='Specify the Diagnostic Storage Account.')]
[string] $DiagnosticStorageAccount
)

$SubscriptionId = (Get-AzureRmContext).Subscription.Id
$ADLSAccountName = -join ($RGLocation, $AppName, "adls", $Environment, $ResourceNumber) -replace "-", ""
$ADLAAccountName = -join ($RGLocation, $AppName, "adla", $Environment, $ResourceNumber) -replace "-", ""
$StorageAccountName = -join ($RGLocation, $AppName, "sac", $Environment, $ResourceNumber) -replace "-", ""

# Set diagnostic settings for Azure Data Lake Store.
Set-AzureRmDiagnosticSetting -ResourceId "/subscriptions/$SubscriptionId/ResourceGroups/$ResourceGroupName/providers/Microsoft.DataLakeStore/accounts/$ADLSAccountName" -Enabled $true -RetentionEnabled $true -RetentionInDays $RetentionDays -StorageAccountId "/subscriptions/$SubscriptionId/ResourceGroups/$DiagnosticResourceGroupName/providers/Microsoft.Storage/storageAccounts/$DiagnosticStorageAccount"

# Set diagnostic settings for Azure Data Lake Analytics.
Set-AzureRmDiagnosticSetting -ResourceId "/subscriptions/$SubscriptionId/ResourceGroups/$ResourceGroupName/providers/Microsoft.DataLakeAnalytics/accounts/$ADLAAccountName" -Enabled $true -RetentionEnabled $true -RetentionInDays $RetentionDays -StorageAccountId "/subscriptions/$SubscriptionId/ResourceGroups/$DiagnosticResourceGroupName/providers/Microsoft.Storage/storageAccounts/$DiagnosticStorageAccount"

# Set logging and metrics for Storage Account.
$StorageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName).Value[0]
$Context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
Set-AzureStorageServiceLoggingProperty -ServiceType Blob -Context $Context -LoggingOperations All -RetentionDays $RetentionDays
Set-AzureStorageServiceMetricsProperty -ServiceType Blob -Context $Context -MetricsType Hour -MetricsLevel ServiceAndApi -RetentionDays $RetentionDays