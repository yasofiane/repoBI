#
# kv_SetSecrets.ps1
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
[Parameter(Position=4, Mandatory = $True, HelpMessage='Specify the Integration Runtimes host name.')]
[Security.SecureString] $IRHost,
[Parameter(Position=5, Mandatory = $True, HelpMessage='Specify the Integration Runtimes username.')]
[Security.SecureString] $IRUserName,
[Parameter(Position=6, Mandatory = $True, HelpMessage='Specify the Integration Runtimes password.')]
[Security.SecureString] $IRPassword,
[Parameter(Position=7, Mandatory = $True, HelpMessage='Specify the ADLS for ADF secret.')]
[Security.SecureString] $ADLSForADFSecret
)

$KVName = -join($RGLocation, "-", $AppName, "-kv-", $Environment, $ResourceNumber)

$IRHostSecretName = -join($KVName, "-irhost-secret-", $ResourceNumber)
$IRHostUserIdSecretName = -join($KVName, "-iruserid-secret-", $ResourceNumber)
$IRHostPasswordSecretName = -join($KVName, "-irpassword-secret-", $ResourceNumber)
$ADLSForADFSecretName = -join($KVName, "-adlsforadf-secret-", $ResourceNumber)

# If the Integration runtime file share secret doesnt exist, create it.
$IRHostSecret = Get-AzureKeyVaultSecret -VaultName $KVName -Name $IRHostSecretName
if ($IRHostSecret -eq $null)
{
	Set-AzureKeyVaultSecret -VaultName $KVName -Name $IRHostSecretName -SecretValue $IRHost
}

# If the Integration runtime username secret doesnt exist, create it.
$IRHostUserIdSecret = Get-AzureKeyVaultSecret -VaultName $KVName -Name $IRHostUserIdSecretName
if ($IRHostUserIdSecret -eq $null)
{
	Set-AzureKeyVaultSecret -VaultName $KVName -Name $IRHostUserIdSecretName -SecretValue $IRUserName
}

# If the Integration runtime password secret doesnt exist, create it.
$IRHostPasswordSecret = Get-AzureKeyVaultSecret -VaultName $KVName -Name $IRHostPasswordSecretName
if ($IRHostPasswordSecret -eq $null)
{
	Set-AzureKeyVaultSecret -VaultName $KVName -Name $IRHostPasswordSecretName -SecretValue $IRPassword
}

# If the ADLS for ADF secret doesnt exist, create it.
$ADLSForADFSPNSecret = Get-AzureKeyVaultSecret -VaultName $KVName -Name $ADLSForADFSecretName
if ($ADLSForADFSPNSecret -eq $null)
{
	Set-AzureKeyVaultSecret -VaultName $KVName -Name $ADLSForADFSecretName -SecretValue $ADLSForADFSecret
}