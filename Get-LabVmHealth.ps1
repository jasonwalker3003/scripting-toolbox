# Get-LabVmHealth.ps1: shows the power state of every VM in a resource group, then runs
# vm-health.sh inside each running one through Azure Run Command, with no SSH.
param(
    [Parameter(Mandatory)]
    [string] $ResourceGroup
)

$healthScript = Join-Path $PSScriptRoot 'vm-health.sh'

foreach ($vm in Get-AzVM -ResourceGroupName $ResourceGroup -Status) {
    Write-Output "$($vm.Name): $($vm.PowerState)"
    if ($vm.PowerState -ne 'VM running') {
        continue
    }

    $run = @{
        ResourceGroupName = $ResourceGroup
        VMName            = $vm.Name
        CommandId         = 'RunShellScript'
        ScriptPath        = $healthScript
    }
    try {
        $result = Invoke-AzVMRunCommand @run
        Write-Output $result.Value[0].Message
    }
    catch {
        Write-Output "Run Command failed: $($_.Exception.Message)"
    }
}
