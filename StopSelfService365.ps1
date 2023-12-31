Install-Module -Name MSCommerce ## Install MSCommerce first, then run the rest of the script
Import-Module -Name MSCommerce
Connect-MSCommerce ## Enter the sites M365 credentials from ITGlue after being prompted

$productIDs = (
    "CFQ7TTC0LH2H", "CFQ7TTC0LH3L", "CFQ7TTC0LSGZ", "CFQ7TTC0H6RP",
    "CFQ7TTC0H9MP", "CFQ7TTC0HDB1", "CFQ7TTC0HDB0", "CFQ7TTC0J1FV",
    "CFQ7TTC0RM8K", "CFQ7TTC0HD33", "CFQ7TTC0HD32", "CFQ7TTC0PW0V",
    "CFQ7TTC0HHS9", "CFQ7TTC0J203", "CFQ7TTC0HX99", "CFQ7TTC0LH05",
    "CFQ7TTC0LH3N", "CFQ7TTC0LHWP", "CFQ7TTC0LHVK", "CFQ7TTC0LHWM"
)
## This list of product IDs changes regularly and Microsofts own documentation isn't accurate - check with "Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase"

foreach($productID in $productIDs){
    Update-MSCommerceProductPolicy -PolicyId AllowSelfServicePurchase -ProductId $productID -Enabled $False
}

## Now run "Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase" and confirm there's nothing still enabled
