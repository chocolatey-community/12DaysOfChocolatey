#Define some global stuff
$ErrorActionPreference = 'Stop'
$tempDir = new-Item "$env:TEMP\$env:ChocolateyPackageName\$env:ChocolateyPackageVersion" -ItemType Directory
$unzipLocation = "$tempDir"

#Download the zip package
$packageArgs = @{
    PackageName = 'visualstudio'
    Url = 'http://nexus.fabrikam.com:8081/repository/installers/vslayout.zip'
    Checksum = '9c85f1f56630ef163c25d564d8e10e5167e7a0cce7a09f5668a297521fa18462'
    ChecksumType = 'sha256'
    UnzipLocation = $unzipLocation
}

Install-ChocolateyZipPackage @packageArgs

$installer = Join-Path $unzipLocation "vs_setup.exe"

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