#Define some package metadata
$packageName = 'visualstudio'
$fileType = 'exe'
$checksum = '4E1F4D8389A3565DFCFDA6AEB1F2FA4364E96D20A2C3B3CB6D12B7146EA1E978'
$checksumType = 'sha256'
$url = 'http://nexus.fabrikam.com:8081/repository/installers/vslayout.iso'

#define where to store the ISO on disk once downloaded
$isoFile = Split-Path $url -Leaf

$downloadPath = "$env:TEMP\$env:ChocolateyPackageName\$env:CHocolateyPackageVersion"

if(-not (Test-Path $downloadPath)){
    $null = New-Item $downloadPath -ItemType Directory
}

$isoPath = Join-Path $downloadPath $isoFile

#Set arguments and call Get-ChocolateyWebFile. Splatting FTW!
$downloadArgs = @{
    PackageName = $packageName
    FileFullPath = $isoPath
    Url = $url
    Checksum = $checksum
    ChecksumType = $checksumType
}

Get-ChocolateyWebFile @downloadArgs

#Mount Downloaded ISO, Gather drive latter, Set our shell location, and collect setup file
$null = Mount-DiskImage -ImagePath $isoPath
$installPath = ((Get-Volume -FileSystemLabel 'vslayout').DriveLetter) + ":"
Push-Location $installPath
$installer = Join-Path $installPath 'vs_setup.exe'

#Install all the certificates for Visual Studio. It's just PowerShell in here, you can do any PowerShell-y things you want.

<# One way to do it:
start-process .\certmgr.exe -ArgumentList '-add -c certificates\manifestSignCertificates.p12 -n "Microsoft Code Signing PCA 2011" -s -r LocalMachine CA' -Wait -NoNewWindow
start-process .\certmgr.exe -ArgumentList '-add -c certificates\manifestSignCertificates.p12 -n "Microsoft Root Certificate Authority" -s -r LocalMachine root' -Wait -NoNewWindow
start-process .\certmgr.exe -ArgumentList '-add -c certificates\manifestCounterSignCertificates.p12 -n "Microsoft Time-Stamp PCA 2010" -s -r LocalMachine CA' -Wait -NoNewWindow
start-process .\certmgr.exe -ArgumentList '-add -c certificates\manifestCounterSignCertificates.p12 -n "Microsoft Root Certificate Authority" -s -r LocalMachine root' -Wait -NoNewWindow
start-process .\certmgr.exe -ArgumentList '-add -c certificates\vs_installer_opc.SignCertificates.p12 -n "Microsoft Code Signing PCA" -s -r LocalMachine CA' -Wait -NoNewWindow
start-process .\certmgr.exe -ArgumentList '-add -c certificates\vs_installer_opc.SignCertificates.p12 -n "Microsoft Root Certificate Authority" -s -r LocalMachine root' -Wait -NoNewWindow
#>

@(
    @{
        ArgumentList = '-add -c certificates\manifestSignCertificates.p12 -n "Microsoft Code Signing PCA 2011" -s -r LocalMachine CA'
        Wait = $true
        NoNewWindow = $true
    },
    @{
        ArgumentList = '-add -c certificates\manifestSignCertificates.p12 -n "Microsoft Root Certificate Authority" -s -r LocalMachine root'
        Wait = $true
        NoNewWindow = $true

    },
    @{
        ArgumentList = '-add -c certificates\manifestCounterSignCertificates.p12 -n "Microsoft Time-Stamp PCA 2010" -s -r LocalMachine CA'
        Wait = $true
        NoNewWindow = $true

    },
    @{
        ArgumentList = '-add -c certificates\manifestCounterSignCertificates.p12 -n "Microsoft Root Certificate Authority" -s -r LocalMachine root'
        Wait = $true
        NoNewWindow = $true

    },
    @{
        ArgumentList = '-add -c certificates\vs_installer_opc.SignCertificates.p12 -n "Microsoft Code Signing PCA" -s -r LocalMachine CA'
        Wait = $true
        NoNewWindow = $true

    },
    @{
        ArgumentList = '-add -c certificates\vs_installer_opc.SignCertificates.p12 -n "Microsoft Root Certificate Authority" -s -r LocalMachine root'
        Wait = $true
        NoNewWindow = $true
    }
) | ForEach-Object { Start-Process .\certmgr.exe @$_}

#All that, and we can _finally_ install Visual Studio
$installerArgs = @{
    statements = '--noweb --passive --wait --norestart'
    exe2run = $installer
}

Start-ChocolateyProcessAsAdmin @installerArgs

#Give us our shell back, and cleanup
Pop-Location
Dismount-DiskImage -ImagePath $isoPath
Remove-Item $downloadPath -Recurse -Force