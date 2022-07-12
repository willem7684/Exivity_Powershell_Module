# Exivity Functions
function Connect-Exivity {
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
    Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $Body
}

function Disconnect-Exivity {
    param (
        [string[]]$ComputerName,
        [string[]]$Token
    )
    $Uri = "https://$ComputerName/v1/auth/token"
    $Headers = @{
        Authorization="Bearer $Token"
    }
    Invoke-RestMethod -Uri $Uri -Method Delete -Headers $Headers
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

# Export permitted Functions
Export-ModuleMember -Function Connect-Exivity,Disconnect-Exivity