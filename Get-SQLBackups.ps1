param(

    [CmdletBinding()]
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$KeyVaultName,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$StorageAccountName,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$DownloadLocation

)

function Get-KeyVaultAccessToken {

    $Response = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -Method GET -Headers @{Metadata="true"}
    $Content = $response.Content | ConvertFrom-Json
    return $Content.access_token

}

function Get-KeyVaultSecretValue {
    param(

        [CmdletBinding()]
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$KeyVaultName,

        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$KeyVaultToken,

        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$SecretName

    )

    $KeyVaultURI = 'https://' + $KeyVaultName + '.vault.azure.net/secrets/' + $SecretName + '?api-version=2016-10-01'
    $Response = (Invoke-WebRequest -Uri $KeyVaultURI -Method GET -Headers @{Authorization="Bearer $KeyVaultToken"}).content
    $Content = $Response | ConvertFrom-Json
    return $Content.value

}

# Get the Access Token from the Key Vault
$KeyVaultToken = Get-KeyVaultAccessToken

# Get the Storage Account Name
$StorageAccountName = Get-KeyVaultSecretValue -KeyVaultName $KeyVaultName -KeyVaultToken $KeyVaultToken -SecretName $StorageAccountName

# Get the Storage Account Key. Always save the key in the vault as '<storageAccountName>-key1'
$StorageAccountKey = Get-KeyVaultSecretValue -KeyVaultName $KeyVaultName -KeyVaultToken $KeyVaultToken -SecretName $($StorageAccountName + '-key1')

# Check the download path exists
if(!(Test-Path $DownloadLocation)) {

    mkdir $DownloadLocation

}

# PS module for azure
Import-module Az

# Set storage context
$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey 

# Get the container
$Containers = Get-AzStorageContainer -Context $Context

# Iterate through each Container
foreach($Container in $Containers) {

    # Set the time as we only want the backups since the bak file.
    $After = (Get-Date -Hour 23 -Minute 0 -Second 0).AddDays(-1)
    # Get the blobs in the container, but only the ones written after the time we specified. 
    $Blobs = Get-AzStorageBlob -Container $Container.Name -Context $Context | Where-Object {$_.LastModified -gt $After}

    # Download each blob to the Download location
    foreach($Blob in $Blobs) { 

        Get-AzStorageBlobContent -Blob $blob.Name -Container $Container.Name -Context $Context -Destination $DownloadLocation

    }

}

