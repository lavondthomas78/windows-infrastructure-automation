<#
.SYNOPSIS
    Monitors critical Windows infrastructure services.

.DESCRIPTION
    Checks the operational status of selected Windows services
    and generates a report for infrastructure monitoring and
    troubleshooting.

.AUTHOR
    LaVon Thomas

.PROJECT
    Windows Infrastructure Automation Toolkit
#>

$CriticalServices = @(
    "NTDS"
    "DNS"
    "KDC"
    "Netlogon"
    "W32Time"
)

$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$ReportPath = "C:\Infrastructure-Automation\Reports\Service-Health_$env:COMPUTERNAME`_$Timestamp.csv"

$Services = Get-Service -Name $CriticalServices -ErrorAction SilentlyContinue

$ServiceHealth = $Services | ForEach-Object {
    [PSCustomObject]@{
        Name        = $_.Name
        DisplayName = $_.DisplayName
        Status      = $_.Status
        StartType   = $_.StartType
        Health      = if ($_.Status -eq "Running") {
            "HEALTHY"
        }
        else {
            "CRITICAL"
        }
    }
}

$ServiceHealth | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host "Service health report generated successfully."
Write-Host "Report saved to: $ReportPath"

$ServiceHealth | Format-Table -AutoSize

