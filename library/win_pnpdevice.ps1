#!powershell

#Requires -Module Ansible.ModuleUtils.ArgvParser
#Requires -Module Ansible.ModuleUtils.CommandUtil
#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

$params = Parse-Args -arguments $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false
$instances = Get-AnsibleParam -obj $params -name "instance" -type "list"
$class = Get-AnsibleParam -obj $params -name "class" -type "list" -failifempty $false
$present = Get-AnsibleParam -obj $params -name "present" -type "bool" -default $true
$status = Get-AnsibleParam -obj $params -name "status" -type "list"
$state = Get-AnsibleParam -obj $params -name "state"  -type "str" -validateset "enabled", "disabled"
$friendlyname = Get-AnsibleParam -obj $params -name "friendlyname" -type "list"

# Create a new result object
$result = @{
    changed       = $false
    ansible_facts = @{
        devices = @()
    }
}

<#
Get-PnpDevice
[[-InstanceId] <String[]>]
[-Class <String[]>]
[-PresentOnly]
[-Status <String[]>]

Disable-PnPDevice
Enable-PnpDevice
      [-InstanceId] <String[]>
      [-WhatIf]
#>

# Execution parameters
$parameters_do = @{"Confirm" = $false}
# Search parameters
$parameters_search = @{}
if ($check_mode) {
    $parameters_do.Add("WhatIf", $true)
}
if ($present) {
    $parameters_search.Add("PresentOnly", $true)
}

# Didn't specify instances, let's find them
if (!$instances -And ($friendlyname -Or $class -Or $status)) {
    if ($friendlyname) {
        $parameters_search.Add("FriendlyName", $friendlyname)
    }

    if ($class) {
        $parameters_search.Add("Class", $class)
    }

    if ($status) {
        $parameters_search.Add("Status", $status)
    }
    $instances = @(Get-PnpDevice @parameters_search).InstanceID
} else {
    Write-Error "No devices selected, specify by instance, class or status"
}


foreach ($instance in $instances)
{
    $current = Get-PnpDevice -InstanceID $instance
    if ($current.Status -eq "Error" -and $state -eq "enabled")
    {
        try
        {
            $result.res = Enable-PnPDevice @parameters_do
            $result.changed = $true
        }
        catch
        {
            Write-Error $_.exception.message
        }
    }
    elseif ($current.Status -eq "OK" -and $state -eq "disabled")
    {
        try
        {
            $result.res = Disable-PnPDevice @parameters_do
            $result.changed = $true
        }
        catch
        {
            Write-Error $_.exception.message
        }
    }
}

$result.ansible_facts.devices = @(Get-PnpDevice @parameters_search)

Exit-Json -obj $result
