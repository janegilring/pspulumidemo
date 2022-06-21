Import-Module pspulumiyaml.azurenative.resources

New-PulumiYamlFile {

    $TestRG = New-AzureNativeResourcesResourceGroup -pulumiid testrg -resourceGroupName test-rg

}
