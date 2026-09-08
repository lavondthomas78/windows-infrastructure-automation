<#
.SYNOPSIS
    Generates an Active Directory domain health report.

.DESCRIPTION
    Checks key Active Directory domain information and domain
    controller health to support infrastructure monitoring
    and troubleshooting.

.AUTHOR
    LaVon Thomas

.PROJECT
    Windows Infrastructure Automation Toolkit
#>
Import-Module ActiveDirectory
$Domain = Get-ADDomain
$DomainControllers = Get-ADDomainController -Filter *
$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$ReportPath = "C:\Infrastructure-Automation\Reports\Domain-Health_$Timestamp.csv"
$DCReportPath = "C:\Infrastructure-Automation\Reports\Domain-Controllers_$Timestamp.csv"
$DomainHealth = [PSCustomObject]@{
    DomainName             = $Domain.DNSRoot
    DomainMode             = $Domain.DomainMode
    PDCEmulator            = $Domain.PDCEmulator
    RIDMaster              = $Domain.RIDMaster
    InfrastructureMaster   = $Domain.InfrastructureMaster
    DomainControllerCount  = $DomainControllers.Count
}
$DCHealth = $DomainControllers | ForEach-Object {
    [PSCustomObject]@{
        Name       = $_.HostName
        IPv4Address = $_.IPv4Address
        Site       = $_.Site
        IsGlobalCatalog = $_.IsGlobalCatalog
    }
}
$DomainHealth | Export-Csv -Path $ReportPath -NoTypeInformation
$DCHealth | Export-Csv -Path $DCReportPath -NoTypeInformation
Write-Host "Domain health reports generated successfully."
Write-Host "Domain controllers found: $($DomainControllers.Count)"
Write-Host "Domain report: $ReportPath"
Write-Host "Domain controller report: $DCReportPath"
$DomainHealth | Format-List
$DCHealth | Format-Table -AutoSize

