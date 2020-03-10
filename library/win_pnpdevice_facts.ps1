#!powershell

#Requires -Module Ansible.ModuleUtils.ArgvParser
#Requires -Module Ansible.ModuleUtils.CommandUtil
#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

$params = Parse-Args -arguments $args -supports_check_mode $false
$instances = Get-AnsibleParam -obj $params -name "instance" -type "list"
$class = Get-AnsibleParam -obj $params -name "class" -type "list"
$present = Get-AnsibleParam -obj $params -name "present" -type "bool" -default $true
$status = Get-AnsibleParam -obj $params -name "status" -type "list"
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
#>

if ($instances) {
    $result.ansible_facts.devices = @(Get-PnpDevice -InstanceId $instances)
} else {
    $parameters_search = @{}
    if ($present) {
        $parameters_search.Add("PresentOnly", $true)
    }

    # Didn't specify instances, let's find them
    if ($friendlyname) {
        $parameters_search.Add("FriendlyName", $friendlyname)
    }

    if ($class) {
        $parameters_search.Add("Class", $class)
    }

    if ($status) {
        $parameters_search.Add("Status", $status)
    }
    $result.ansible_facts.devices = @(Get-PnpDevice @parameters_search)
}

Exit-Json -obj $result
