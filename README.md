Win_PnPDevice
=========

This role gives an interface into the Plug-and-Play aspects of Windows allowing you to enable/disable certain devices

Requirements
------------

Ansible setup to connect to Windows hosts
Client needs to be Windows 8 or later with PowerShell

Role Variables
--------------

    instance:
      An instance ID or list of instance IDs (specific hardware) to operate on
    
    state:
      enabled or disabled whether or not to enable/disable the device
      
   
  This module supports the Ansible check mode. 
  If no instance is provided, you can specify one or more of the following search parameters

    class
      A class or list of device classes (eg. USB)
      
    present
      Whether or not the devices found should be currently present

    status
      A status or list of statuses (OK, ERROR, UNKNOWN or DEGRADED)
      
    friendlyname:
      The Friendly Name of a Device (eg. Generic USB Hub)

Dependencies
------------

None

Example Playbook
----------------

Example: Collect ALL Windows hardware information into the facts and disable a specific piece of hardware

    - hosts: windows
      roles:
         - guruevi.win_pnpdevice
    - tasks:
      - win_pnpdevice_facts:
      - win_pnpdevice:
          instance: 
            - "PCI\VEN_8086&DEV_1C20&SUBSYS_047E1028&REV_04\3&11583659&0&D8"
          state: disabled
        
License
-------

GPLv3

Author Information
------------------

Evi Vanoost (evi.vanoost@gmail.com)