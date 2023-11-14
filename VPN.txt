## Variables
$vpnName = "EyeSpecialtyGroup"
$hostName "ridge-hq-gnzgzgnbkwjc.dynamic-m.com"
$vpnPsk = "HV4VDTvWrK9^2E#c"

## Things
Add-VpnConnection -Name "$vpnName" -ServerAddress "$hostName" -TunnelType "L2TP" -L2tpPsk "$vpnPsk" -AuthenticationMethod "Eap" -Force -RememberCredential 