# RDCB Services
[array]$services = 'RDMS', 'TScPubRPC', 'Tssdis'

# Restart the Services in order
foreach($Service in $services) {
    
    Restart-Service -Name $Service -Force -Verbose

}