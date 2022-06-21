Import-Module pspulumiyaml.azurenative.resources

New-PulumiYamlFile {

    $TestRG = New-AzureNativeResourcesResourceGroup -pulumiid testrg -resourceGroupName test-rg

    $Props = @{
        pulumiid          = "sa"
        accountName       = "pspulumitest"
        ResourceGroupName = $resourceGroup.reference("name")
        location          = "norwayeast"
        Kind              = "StorageV2"
        Sku               = @{
          Name = "Standard_LRS"
        }
      }
      $storageAccount = azure_native_storage_storageaccount @Props

}
