param (
    [CmdletBinding()]
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$DomainUsername,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$DomainPassword,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$FileToRun,

    [parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$ScriptParameters

)
# Create the credential object
$Password = ConvertTo-SecureString $DomainPassword -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential $DomainUsername, $Password

# Create the 'command'
$Command = $PSScriptRoot + '\' + $FileToRun + ' ' + $ScriptParameters

# Run it
Invoke-Command -FilePath $Command -Credential $Credential -ComputerName $env:COMPUTERNAME -Verbose