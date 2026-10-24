# Remove-OldLogs.ps1: deletes .log files older than -Days days under -Path.
# Add -WhatIf to see what it would delete without deleting anything.
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string] $Path,

    [int] $Days = 7
)

$cutoff = (Get-Date).AddDays(-$Days)
$old = @(Get-ChildItem -Path $Path -Filter '*.log' -File -Recurse |
    Where-Object LastWriteTime -lt $cutoff)

foreach ($file in $old) {
    if ($PSCmdlet.ShouldProcess($file.FullName, 'Delete')) {
        Remove-Item -LiteralPath $file.FullName
    }
}

Write-Output "$($old.Count) file(s) older than $Days days in $Path"
