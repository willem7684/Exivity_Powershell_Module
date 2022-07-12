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

    $uri = "https://$ComputerName/v1/auth/token"
    $headers = @{
        'Content-Type' = 'application/x-www-form-urlencoded'
        'Accept' = 'application/json'
    }
    $body = @{
        username = "$UserName"
        password = "$Key"
    }
    Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body
}

function Disconnect-Exivity {
    param (
        [string[]]$ComputerName,
        [string[]]$Token
    )
    $uri = "https://$ComputerName/v1/auth/token"
    $headers = @{
        Authorization="Bearer $token"
    }
    Invoke-RestMethod -Uri $uri -Method Delete -Headers $headers
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