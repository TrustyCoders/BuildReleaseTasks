Write-Output "Start searching for the youngest certs"

[string]$HostHeaders = Get-VstsInput -Name HostHeader -Require
[string]$FriendlyName = Get-VstsInput -Name FriendlyName -Require
[string]$Resultname = Get-VstsInput -Name ResultName

$youngestCertsThumbprints= @{}
$certs = Get-ChildItem -Path Cert:\LocalMachine\My

if ($HostHeaders -eq $null){
    $HostHeaders='';
}

$HostHeaderArray = $HostHeaders.Split(",")
if ($HostHeaderArray.Count -gt 0){
    $HostHeaderArray | ForEach-Object {
        $hostHeader=$_.Trim()
        $youngestCert = $null
        $certAge = [System.DateTime]::MinValue
        $dateTimeMinValue=[System.DateTime]::MinValue

        foreach($singleCert in $certs)
        {
            $allExtensions =  $singleCert.Extensions
            foreach($singleExtension in $allExtensions)
            {
                if($singleExtension.Oid.FriendlyName -eq $FriendlyName)
                {
                    if($singleExtension.Format(1).Contains("DNS Name=$hostHeader") -or $singleCert.Subject.Contains("CN=$hostHeader"))
                    {
                        If($certAge -lt $singleCert.NotBefore -or $certAge -eq $dateTimeMinValue)
                        {
                            $youngestCert=$singleCert
                            $certAge = $singleCert.NotBefore
                        }
                    }
                }
            }
        }
        $youngestCertsThumbprints+= @{$hostHeader = $youngestCert.Thumbprint}
        Write-Output "HostHeader: $hostHeader"
        $youngestCertThumbprint=$youngestCert.Thumbprint
        Write-Output "Thumbprint: $youngestCertThumbprint"
    }
}


$youngestCertsThumbprintsJson = $youngestCertsThumbprints | ConvertTo-Json

Write-Host "##vso[task.setvariable variable=$ResultName]$youngestCertsThumbprintsJson"

    