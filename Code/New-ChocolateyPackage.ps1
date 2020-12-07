function New-ChocolateyPackage {
    <#
    .SYNOPSIS
    Generates a Chocolatey package from an installer or a URL
    
    .DESCRIPTION
    Quickly create a Chocolatey Package from a file or URL. Requires a Chocolatey For Business license, and the chocolatey.extension package
    
    .PARAMETER File
    The local installer (msi, or exe) to generate a Chococlatey Package from
    
    .PARAMETER Url
    The URL to download a binary to turn into a Chocolatey Package
    
    .PARAMETER OutputDirectory
    The finished Chocolatey Package location
    
    .EXAMPLE
    New-ChocolateyPackage -File C:\installers\7-zip.msi -OutputDirectory C:\ChocolateyPackages

    .EXAMPLE
    New-ChocolateyPackage -File C:\installers\7-zip.msi,C:\installers\npp.exe -OutputDirectory C:\ChocolateyPackages

    New-ChocolateyPackage -File ((Get-ChildItem \\server\installers -INclude *.exe,*.msi).Fullname) -OutputDirectory C:\ChocolateyPackages
    .EXAMPLE
    New-ChocolateyPackage -Url 'https://dl.google.com/ent/googlechrome64.msi' -OutputDirectory C:\ChocolateyPackages
    
    .NOTES
    General notes
    #>
    [cmdletBinding(DefaultParameterSetname="file")]
    Param(
        [Parameter(ParameterSetName="file",Mandatory)]
        [String[]]
        $File,

        [Parameter(ParameterSetName="url",Mandatory)]
        [String[]]
        $Url,

        [Parameter(ParameterSetName="file",Mandatory)]
        [Parameter(ParameterSetName="url",Mandatory)]
        [Parameter(Mandatory)]
        [String]
        $OutputDirectory
    )

    process {

        if(-not (Test-Path $OutputDirectory)){
            $null = New-Item $OutputDirectory -ItemType Directory
        }

        switch($PSCmdlet.ParameterSetName){
            'file' {
                Foreach($f in $File){

                    $chocoArgs = @('new',"--file='$f'",'--build-package',"--output-directory='$OutputDirectory'")
                    & choco @chocoArgs

                }
            }

            'url' {
                foreach($u in $Url){

                    $chocoArgs = @('new',"--url='$u'",'--build-package',"--output-directory='$OutputDirectory'")
                    & choco @chocoArgs
                }

            }
        }
    }
}