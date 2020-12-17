function New-OpenSSLCsr {
    <#
    .SYNOPSIS
    Use OpenSSL to generate CSRs with private keys for requesting new certificates
    
    .DESCRIPTION
    Use OpenSSL to generate CSRs with private keys for requesting new certificates. This is useful when you need to convert from some format to pfx
    
    .PARAMETER CsrName
    The name of the CSR
    
    .PARAMETER KeyName
    The name of the private key
    
    .PARAMETER OutputDirectory
    The directory to store the CSR and private key
    
    .EXAMPLE
    New-OpenSSLCsr -CsrName MyNew.csr -KeyName private.key
    
    .NOTES
    General notes
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]
        $CsrName,

        [Parameter(Mandatory)]
        [String]
        $KeyName,

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

        $opensslArgs = @('req','-out', "$CsrName",'-new','-newkey','rsa:2048','-nodes','-keyout',"$KeyName")
        & openssl @opensslArgs

        Pop-Location

    }
}