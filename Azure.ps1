
#############################################################################################################

# Authenticate to Azure
$connectionAssetName = "AzureRunAsConnection"
$servicePrincipalConnection = Get-AutomationConnection -Name $connectionAssetName

Connect-AzAccount -ServicePrincipal `
    -TenantId $servicePrincipalConnection.TenantId `
    -ApplicationId $servicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint

Connect-AzAccount -Identity ????

param(
    [string]$resourceGroupName,
    [PSCredential]$credential
)

$vms = Get-AzVM -ResourceGroupName $resourceGroupName

foreach ($vm in $vms) {
    # Restart each VM
    Restart-AzVM -ResourceGroupName $resourceGroupName -Name $vm.Name -Credential $credential
}



$product = Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase | where {$_.ProductName -like 'C*'}
$p = $product
for each ($p in $product){
Update-MSCommerceProductPolicy -PolicyId AllowSelfServicePurchase -ProductId $p.ProductID -Enabled $false}







#############################################################################################################

$productIDs = Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase
foreach ($product in $productIDs){
Update-MSCommerceProductPolicy -PolicyId AllowSelfServicePurchase -ProductID  -Value “Disabled"}

#############################################################################################################
$productIDs = ("CFQ7TTC0LH2H","CFQ7TTC0LH3L","CFQ7TTC0LSGZ","CFQ7TTC0H6RP","CFQ7TTC0H9MP","CFQ7TTC0HDB1","CFQ7TTC0HDB0","CFQ7TTC0J1FV","CFQ7TTC0RM8K","CFQ7TTC0HD33","CFQ7TTC0HD32","CFQ7TTC0PW0V","CFQ7TTC0HHS9","CFQ7TTC0J203","CFQ7TTC0HX99","CFQ7TTC0LH05","CFQ7TTC0LH3N","CFQ7TTC0LHWP","CFQ7TTC0LHVK","CFQ7TTC0LHWM")
Update-MSCommerceProductPolicy -PolicyId AllowSelfServicePurchase -ProductId $productIDs -Enabled $False  




"CFQ7TTC0LH2H","CFQ7TTC0LH3L","CFQ7TTC0LSGZ","CFQ7TTC0H6RP","CFQ7TTC0H9MP","CFQ7TTC0HDB1","CFQ7TTC0HDB0","CFQ7TTC0J1FV","CFQ7TTC0RM8K","CFQ7TTC0HD33","CFQ7TTC0HD32","CFQ7TTC0PW0V","CFQ7TTC0HHS9","CFQ7TTC0J203","CFQ7TTC0HX99","CFQ7TTC0LH05","CFQ7TTC0LH3N","CFQ7TTC0LHWP","CFQ7TTC0LHVK","CFQ7TTC0LHWM"


$productIDs = (
    "CFQ7TTC0LH2H", "CFQ7TTC0LH3L", "CFQ7TTC0LSGZ", "CFQ7TTC0H6RP",
    "CFQ7TTC0H9MP", "CFQ7TTC0HDB1", "CFQ7TTC0HDB0", "CFQ7TTC0J1FV",
    "CFQ7TTC0RM8K", "CFQ7TTC0HD33", "CFQ7TTC0HD32", "CFQ7TTC0PW0V",
    "CFQ7TTC0HHS9", "CFQ7TTC0J203", "CFQ7TTC0HX99", "CFQ7TTC0LH05",
    "CFQ7TTC0LH3N", "CFQ7TTC0LHWP", "CFQ7TTC0LHVK", "CFQ7TTC0LHWM",
    "CFQ7TTC0N8SL", "CFQ7TTC0S3X1", "CFQ7TTC0HVZG", "CFQ7TTC0KXG6"
)

foreach ($productID in $productIDs) {
    Update-MSCommerceProductPolicy -PolicyId AllowSelfServicePurchase -ProductId $productID -Enabled $False
}




## NEED “-Value “Disabled”” 

Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase | where {$_.PolicyValue -Value -eq "Disabled"}