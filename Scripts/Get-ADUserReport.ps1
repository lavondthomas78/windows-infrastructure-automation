<#
.SYNOPSIS
    Generates an Active Directory user account report.

.DESCRIPTION
    Queries Active Directory for user accounts and exports selected
    account information to a CSV report for administrative review.

.AUTHOR
    LaVon Thomas

.PROJECT
    Windows Infrastructure Automation Toolkit
#>

Import-Module ActiveDirectory

$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$ReportPath = "C:\Infrastructure-Automation\Reports\AD-User-Report_$Timestamp.csv"
$DisabledReportPath = "C:\Infrastructure-Automation\Reports\Disabled-Accounts_$Timestamp.csv"

try {
$Users = Get-ADUser -Filter * -Properties DisplayName, Enabled, EmailAddress, Department, Title, LastLogonDate -ErrorAction Stop
}
catch {
    Write-Error "Failed to query Active Directory: $($_.Exception.Message)"
    exit 1
}
$DisabledUsers = $Users | Where-Object { $_.Enabled -eq $false }
$DisabledUsers | Select-Object Name, SamAccountName, Enabled, LastLogonDate |
    Export-Csv -Path $DisabledReportPath -NoTypeInformation
Write-Host "Disabled accounts found: $($DisabledUsers.Count)"
$UserReport = $Users | Select-Object `
    Name,
    SamAccountName,
    Enabled,
    EmailAddress,
    Department,
    Title,
    LastLogonDate

$UserReport | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host "Active Directory reports generated successfully."
Write-Host "Full user report: $ReportPath"
Write-Host "Disabled accounts report: $DisabledReportPath"
