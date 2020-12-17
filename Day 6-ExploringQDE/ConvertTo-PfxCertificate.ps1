function ConvertTo-PfxCertificate {
    <#
    .SYNOPSIS
    Convert a certifcate in cer or crt format to pfx format
    
    .DESCRIPTION
    Convert a certificate in cer or crt format to pfx format
    
    .PARAMETER Certificate
    The certificate file to convert
    
    .PARAMETER PrivateKey
    The private key to use to generate the pfx file along with your certificate
    
    .PARAMETER NewCertifcate
    The name of the exported pfx file (Must end in .pfx)
    
    .PARAMETER OutputDirectory
    The path to store the converted certificate
    
    .EXAMPLE
    ConvertTo-PfxCertificate -Certificate C:\cert\cert.cer -PrivateKey C:\cert\private.key -NewCertificate cert.pfx -OutputDirectory C:\newcert
    #>
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateScript({ 
           $validexts = @('.cer','.crt')
            $ext = [IO.Path]::GetExtension($_)
            if($ext -in $validexts){
                return $true
            } else { return $false }
        })]
        [String]
        $Certificate,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_})]
        [String]
        $PrivateKey,

        [Parameter(Mandatory)]
        [String]
        $NewCertifcate,

        [Parameter()]
        [String]
        $OutputDirectory = $PSScriptRoot
    )

    begin {

        if(-not (Get-Command openssl)){
            throw "OpenSSL is required. Please use 'choco install openssl -y -s https://chocolatey.org/api/v2' to install!"
        }

        if(-not (Test-path $OutputDirectory)){
            $null = New-Item $OutputDirectory -ItemType Directory
        }

    }
    process {

        Push-Location $OutputDirectory

        $opensslArgs = @('pkcs12','-export','-in', "$Certificate",'-inkey', "$PrivateKey", '-out', "$NewCertifcate")
        & openssl @opensslArgs

        Pop-Location


    }
}