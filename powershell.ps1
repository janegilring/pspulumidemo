using module pspulumiyaml.azurenative.compute
Import-Module pspulumiyaml.azurenative.compute
Import-Module pspulumiyaml.azurenative.resources
Import-Module pspulumiyaml.azurenative.storage
Import-Module pspulumiyaml.azurenative.network

New-PulumiYamlFile {

    $TestRG = New-AzureNativeResourcesResourceGroup -pulumiid testrg -resourceGroupName test-rg

    $Props = @{
        pulumiid          = "sa"
        accountName       = "pspulumitest"
        ResourceGroupName = $testrg.reference("name")
        location          = "norwayeast"
        Kind              = "StorageV2"
        Sku               = @{
            Name = "Standard_LRS"
        }
    }
    $storageAccount = azure_native_storage_storageaccount @Props

    $NicProperties = @{
        resourceGroupName    = $testrg.reference("name")
        networkInterfaceName = "jandemovm01-nic"
        pulumiid             = "nic"
        ipConfigurations     = @(
            [pscustomobject]@{
                name            = "ipconfig1"
                subnet          = @{id = "/subscriptions/380d994a-e9b5-4648-ab8b-815e2ef18a2b/resourceGroups/networking-rg/providers/Microsoft.Network/virtualNetworks/norway-vnet/subnets/vm-subnet"}
                #publicIPAddress = @{id = $null}
            }
        )
    }

    $VmNic = New-AzureNativeNetworkNetworkInterface @NicProperties

    $VmProperties = @{
        pulumiid          = "vm"
        resourceGroupName = $testrg.reference("name")
        vmName            = "jandemovm01"
        osProfile         = @{
            "computerName"  = "jandemovm01"
            "adminUsername" = "jandemoadmin"
            "adminPassword" = "!SuperSecret12345!"
            LinuxConfiguration = @{ProvisionVMAgent = $true}
        }
        hardwareProfile   = @{
            "vmSize" = "Standard_D5_v2"
        }
        networkProfile    = @{
            NetworkInterfaces = @{
                id      = $VmNic.reference("id")
                Primary = $true
            }
        }
        storageProfile    = @{
            imageReference = @{
                "offer"     = "UbuntuServer"
                "publisher" = "Canonical"
                "sku"       = "20.04-LTS"
                "version"   = "latest"
            }
            osDisk         = $(
                $t= @{
                    CreateOption = "FromImage"
                    Caching = "ReadWrite"
                    managedDisk = New-AzureNativeTypeComputeManagedDiskParameters -storageAccountType Standard_LRS
                    Name = "jandemovm01OsDisk"
                }
                New-AzureNativeTypeComputeOSDisk @t
            )
        }
    }

    New-AzureNativeComputeVirtualMachine @VmProperties

}
