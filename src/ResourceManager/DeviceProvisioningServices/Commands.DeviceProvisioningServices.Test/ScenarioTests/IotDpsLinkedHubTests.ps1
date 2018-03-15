﻿# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------


######################################
## Manage IotDps Linked Hub Cmdlets	##
######################################

<#
.SYNOPSIS
Test Iot Hub Device Provisioning Service Linked Hub cmdlets for CRUD operations 
#>

function Test-AzureIotDpsLinkedHubLifeCycle
{
	$Location = Get-Location "Microsoft.Devices" "Device Provisioning Service" 
	$IotDpsName = getAssetName 
	$ResourceGroupName = getAssetName 
	$IotHubName = getAssetName
	$Sku = "S1"

	# Constant variable
	$LinkedHubName = [string]::Format("{0}.azure-devices.net",$IotHubName)
	$ApplyAllocationPolicyValue = $FALSE
	$AllocationWeight = 10

	# Create or Update Resource Group
	$resourceGroup = New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location 

	# Create Iot Hub Device Provisioning Service
	$iotDps = New-AzureRmIoTDps -ResourceGroupName $ResourceGroupName -Name $IotDpsName -Location $Location
	Assert-True { $iotDps.Name -eq $IotDpsName }
	Assert-True { $iotDps.Properties.IotHubs.Count -eq 0 }

	# Create an Iot Hub
	$iotHub = New-AzureRmIoTHub -Name $IotHubName -ResourceGroupName $ResourceGroupName -Location $Location -SkuName $Sku -Units 1
	Assert-True { $iotHub.Name -eq $IotHubName }

	# Link an Iot Hub to an Iot Hub Device Provisioning Service
	$linkedHub = Add-AzureRmIoTDpsHub -ResourceGroupName $ResourceGroupName -Name $IotDpsName -IotHubResourceGroupName $ResourceGroupName -IotHubName $IotHubName
	Assert-True { $linkedHub.Count -eq 1 }
	Assert-True { $linkedHub.Name -eq $LinkedHubName }
	Assert-True { $linkedHub.Location -eq $Location }

	# Update Linked Hub in Iot Hub Device Provisioning Service
	$updatedLinkedHub = Update-AzureRmIoTDpsHub -ResourceGroupName $ResourceGroupName -Name $IotDpsName -LinkedHubName $LinkedHubName -AllocationWeight $AllocationWeight -ApplyAllocationPolicy $ApplyAllocationPolicyValue
	Assert-False { $updatedLinkedHub.ApplyAllocationPolicy }
	Assert-True { $updatedLinkedHub.AllocationWeight -eq $AllocationWeight }

	# Get Linked Hub in Iot Hub Device Provisioning Service
	$linkedHub1 = Get-AzureRmIoTDpsHub -ResourceGroupName $ResourceGroupName -Name $IotDpsName -LinkedHubName $LinkedHubName
	Assert-True { $linkedHub1.Count -eq 1 }
	Assert-True { $linkedHub1.Name -eq $LinkedHubName }
	Assert-True { $linkedHub1.Location -eq $Location }
	Assert-False { $linkedHub1.ApplyAllocationPolicy }
	Assert-True { $linkedHub1.AllocationWeight -eq $AllocationWeight }

	# Remove Linked Hub from Iot Hub Device Provisioning Service
	$result = Remove-AzureRmIoTDpsHub -ResourceGroupName $ResourceGroupName -Name $IotDpsName -LinkedHubName $LinkedHubName -PassThru
	Assert-True { $result }

	# Remove Resource Group
	Remove-AzureRmResourceGroup -Name $ResourceGroupName -force
}
