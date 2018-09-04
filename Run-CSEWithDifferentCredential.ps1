param (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$DomainUsername,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$DomainPassword,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$FileToRun

)
# Create the credential object
$Password = ConvertTo-SecureString $DomainPassword -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential $DomainUsername, $Password

# Create the 'command'
$Command = $PSScriptRoot + '\' + $FileToRun

# Run it
Invoke-Command -FilePath $Command -Credential $Credential -ComputerName $env:COMPUTERNAME -Verbose