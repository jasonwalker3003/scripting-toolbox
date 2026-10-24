# scripting-toolbox

Small scripts for looking after Linux servers on Azure, written in Bash and again in PowerShell with the Az modules. Lab work from week 4 of my Azure and DevOps training.

## Bash
- vm-health.sh: disk, memory, load and failed services. The exit code is the number of problems.
- log-cleanup.sh: deletes .log files older than N days. It only lists them unless given --apply.
- deploy-app.sh: installs a Spring Boot jar as a systemd service and waits for it to answer.

They run on the server. From my PC, without copying them there: ssh jason@IP 'sudo bash -s' < deploy-app.sh

## PowerShell (PowerShell 7 and the Az modules)
- Get-LabVmHealth.ps1: the power state of each VM in a resource group, then vm-health.sh inside each running one through Azure Run Command.
- Deploy-LabApp.ps1: runs deploy-app.sh on a VM through Run Command, with no SSH.
- Remove-OldLogs.ps1: the log clean-up, with -WhatIf for a dry run.

## Tested on
An Ubuntu 24.04 VM built from my Bicep file (azure-linux-vm-bicep), and Ubuntu 26.04 on WSL.

## What I learned
- 
- 
- 
