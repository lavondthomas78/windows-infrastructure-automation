<#
.SYNOPSIS
    Generates an Active Directory computer inventory report.

.DESCRIPTION
    Queries Active Directory for computer objects and generates
    an inventory report containing system identification,
    operating system, account status, and logon information.

.AUTHOR
    LaVon Thomas

.PROJECT
    Windows Infrastructure Automation Toolkit
#>

Import-Module ActiveDirectory
$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$ReportPath = "C:\Infrastructure-Automation\Reports\Computer-Inventory_$Timestamp.csv"

$Computers = Get-ADComputer -Filter * -Properties OperatingSystem, OperatingSystemVersion, Enabled, LastLogonDate
$ComputerInventory = $Computers | Select-Object `
    Name,
    DNSHostName,
    OperatingSystem,
    OperatingSystemVersion,
    Enabled,
    LastLogonDate
$ComputerInventory | Export-Csv -Path $ReportPath -NoTypeInformation
Write-Host "Computer inventory report generated successfully."
Write-Host "Computers found: $($ComputerInventory.Count)"
Write-Host "Report saved to: $ReportPath"

$Computers | Select-Object Name, OperatingSystem, OperatingSystemVersion, Enabled, LastLogonDate | Format-Table -AutoSize