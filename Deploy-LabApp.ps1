# Deploy-LabApp.ps1: runs deploy-app.sh on a VM through Azure Run Command, with no SSH.
param(
    [Parameter(Mandatory)]
    [string] $ResourceGroup,

    [Parameter(Mandatory)]
    [string] $VMName
)

$run = @{
    ResourceGroupName = $ResourceGroup
    VMName            = $VMName
    CommandId         = 'RunShellScript'
    ScriptPath        = (Join-Path $PSScriptRoot 'deploy-app.sh')
}
$result = Invoke-AzVMRunCommand @run
Write-Output $result.Value[0].Message
