## Exivity Functions
# Authentication
function Connect-XVTYExivity {
    [CmdletBinding()]

    param (
        [string[]]$ComputerName,
        [string[]]$UserName,
        [string[]]$Key,
        [string[]]$IgnoreSSL
    )
    
    if ($IgnoreSSL -eq $true) {
        Disable-SSL
    }

    $Uri = "https://$ComputerName/v1/auth/token"

    $Headers = @{
        'Content-Type' = 'application/x-www-form-urlencoded'
        'Accept' = 'application/json'
    }

    $Body = @{
        username = "$UserName"
        password = "$Key"
    }

    Write-Debug -Message "Attempt to connect to Exivity on $ComputerName using Uri: $Uri"
    (Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $Body).token
    Write-Verbose -Message "Connected to Exivity on $ComputerName!"
}
function Disconnect-XVTYExivity {
    [CmdletBinding()]

    param (
        [string[]]$ComputerName,
        [string[]]$Token
    )

    $Uri = "https://$ComputerName/v1/auth/token"

    $Headers = @{
        Authorization="Bearer $Token"
    }

    Write-Debug -Message "Disconnecting from Exivity on $ComputerName using Uri: $Uri Token: $Token"
    Invoke-RestMethod -Uri $Uri -Method Delete -Headers $Headers
    Write-Verbose -Message "Disconnected from Exivity on $ComputerName!"
}

# Reports
function Get-XVTYReportDefinition {
    [CmdletBinding()]

    param (
        [string[]]$ComputerName,
        [string[]]$Token,
        [string[]]$Id
    )

    if ($null -eq $Id) {
        $Uri = "https://$ComputerName/v1/reports"
    } else {
        $Uri = "https://$ComputerName/v1/reports/$Id"
    }

    $Headers = @{
        Authorization="Bearer $Token"
    }

    Write-Debug -Message "Retrieving ReportDefinitions from Exivity on $ComputerName using Uri: $Uri Token: $Token"
    (Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers).data
    Write-Verbose -Message "Got Report Definitions from Exivity on $ComputerName!"
}
function Get-XVTYReport {
    [CmdletBinding()]

    param (
        [string[]]$ComputerName,
        [string[]]$Token,
        [string[]]$Id,
        [string[]]$StartDate,
        [string[]]$EndDate
    )

    $Uri = "https://$ComputerName/v1/reports/$Id/run?start=$StartDate&end=$EndDate"

    $Headers = @{
        Authorization="Bearer $Token"
    }

    Write-Debug -Message "Running Report: $Id From $StartDate till $EndDate at Exivity on $ComputerName using Uri: $Uri Token: $Token"
    (Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers).report
    Write-Verbose -Message "Got Report from Exivity on $ComputerName!"
}

# Services
function Get-XVTYServiceCategory {
    [CmdletBinding()]

    param (
        [string[]]$ComputerName,
        [string[]]$Token,
        [string[]]$Id
    )

    if ($null -eq $Id) {
        $Uri = "https://$ComputerName/v1/servicecategories?page[limit]=999999"
    } else {
        $Uri = "https://$ComputerName/v1/servicecategories/$Id"
    }

    $Headers = @{
        Authorization="Bearer $Token"
    }

    Write-Debug -Message "Retrieving ServiceCategorie(s) from Exivity on $ComputerName using Uri: $Uri Token: $Token"
    (Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers).data
    Write-Verbose -Message "Got ServiceCategorie(s) from Exivity on $ComputerName!"
}
function Get-XVTYService {
    [CmdletBinding()]

    param (
        [string[]]$ComputerName,
        [string[]]$Token,
        [string[]]$Id
    )

    if ($null -eq $Id) {
        $Uri = "https://$ComputerName/v1/services?page[limit]=999999"
    } else {
        $Uri = "https://$ComputerName/v1/services/$Id"
    }

    $Headers = @{
        Authorization="Bearer $Token"
    }

    Write-Debug -Message "Retrieving Service(s) from Exivity on $ComputerName using Uri: $Uri Token: $Token"
    (Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers).data
    Write-Verbose -Message "Got Service(s) from Exivity on $ComputerName!"
}

# Supporting Functions
function Disable-SSL {
    add-type -TypeDefinition  @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@

    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

# Export Functions
Export-ModuleMember -Function Connect-XVTYExivity,Disconnect-XVTYExivity,Get-XVTYReportDefinition,Get-XVTYReport,Get-XVTYServiceCategory,Get-XVTYService