Write-Output "Start creating/updating security groups"

[string]$ActiveDirectories = Get-VstsInput -Name ActiveDirectories -Require
[string]$ExeFileName = Get-VstsInput -Name ExeFileName -Require

$activeDirectoriesHashtable = $ActiveDirectories | ConvertFrom-Json

foreach($activeDirectoryHashtable in $activeDirectoriesHashtable)
{
    Write-Output `n  
    Write-Output "Creating security groups to $($activeDirectoryHashtable.DomainController) in  $($activeDirectoryHashtable.OrganizationalUnit)"
    Write-Output `n

    $proc = new-object System.Diagnostics.Process
    $procinfo = new-object System.Diagnostics.ProcessStartInfo
    $procinfo.FileName = $ExeFileName
    $procinfo.Arguments = "$($activeDirectoryHashtable.OrganizationalUnit) $($activeDirectoryHashtable.DomainController) $($activeDirectoryHashtable.Username) $($activeDirectoryHashtable.Password) $($activeDirectoryHashtable.envPrefix)"
    $procinfo.UseShellExecute = $false
    $procinfo.RedirectStandardOutput = $true
    $procinfo.RedirectStandardError = $true
    $procinfo.CreateNoWindow = $false
    $proc.StartInfo = $procinfo
    [void]$proc.Start()

    $output = $proc.StandardOutput.ReadToEnd()
    $outputError = $proc.StandardError.ReadToEnd()

	Write-Output "output $($output)"
    if($proc.ExitCode -ne 0)
    {
            Write-Output "output error $($outputError)"
            $LASTEXITCODE = 1
            exit $LASTEXITCODE        
    }
}

Write-Output "Security groups created/updated"
