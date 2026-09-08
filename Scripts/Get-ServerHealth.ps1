<#
.SYNOPSIS
    Generates a Windows Server health report.

.DESCRIPTION
    Collects system health information including uptime, memory,
    disk utilization, and operating system details for administrative
    monitoring and troubleshooting.

.AUTHOR
    LaVon Thomas

.PROJECT
    Windows Infrastructure Automation Toolkit
#>

$OS = Get-CimInstance -ClassName Win32_OperatingSystem

$Disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"

$Uptime = (Get-Date) - $OS.LastBootUpTime

$TotalMemoryGB = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)
$FreeMemoryGB = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)
$UsedMemoryGB = [math]::Round($TotalMemoryGB - $FreeMemoryGB, 2)
$MemoryUsedPercent = [math]::Round(($UsedMemoryGB / $TotalMemoryGB) * 100, 2)
if ($MemoryUsedPercent -ge 90) {
    $MemoryStatus = "CRITICAL"
}
elseif ($MemoryUsedPercent -ge 80) {
    $MemoryStatus = "WARNING"
}
else {
    $MemoryStatus = "HEALTHY"
}
$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$ReportPath = "C:\Infrastructure-Automation\Reports\Server-Health_$env:COMPUTERNAME`_$Timestamp.csv"
$DiskReportPath = "C:\Infrastructure-Automation\Reports\Disk-Health_$env:COMPUTERNAME`_$Timestamp.csv"

$ServerHealth = [PSCustomObject]@{
    ComputerName      = $env:COMPUTERNAME
    OperatingSystem   = $OS.Caption
    OSVersion         = $OS.Version
    LastBootTime      = $OS.LastBootUpTime
    UptimeDays        = [math]::Round($Uptime.TotalDays, 2)
    TotalMemoryGB     = $TotalMemoryGB
    UsedMemoryGB      = $UsedMemoryGB
    FreeMemoryGB      = $FreeMemoryGB
    MemoryUsedPercent = $MemoryUsedPercent
    MemoryStatus      = $MemoryStatus
}
$DiskHealth = $Disks | ForEach-Object {
    [PSCustomObject]@{
        Drive            = $_.DeviceID
        TotalSizeGB      = [math]::Round($_.Size / 1GB, 2)
        FreeSpaceGB      = [math]::Round($_.FreeSpace / 1GB, 2)
        UsedSpaceGB      = [math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2)
        FreeSpacePercent = [math]::Round(($_.FreeSpace / $_.Size) * 100, 2) 
Status = if ((($_.FreeSpace / $_.Size) * 100) -lt 10) {
    "CRITICAL"
}
elseif ((($_.FreeSpace / $_.Size) * 100) -lt 20) {
    "WARNING"
}
else {
    "HEALTHY"
}
    }
}
$ServerHealth | Export-Csv -Path $ReportPath -NoTypeInformation
$DiskHealth | Export-Csv -Path $DiskReportPath -NoTypeInformation
Write-Host "Server health reports generated successfully."
Write-Host "Server report: $ReportPath"
Write-Host "Disk report: $DiskReportPath"
$ServerHealth | Format-List
$DiskHealth | Format-Table -AutoSize



