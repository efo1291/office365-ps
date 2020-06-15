#v1.0
$User = 'lab1'
$Pass = ConvertTo-SecureString "L@b12345" –AsPlainText -Force
$objectid = (Get-AzureADUser -Filter "userPrincipalName eq '$User@cin.ufpe.br'").objectid
Set-AzureADUserPassword -ObjectId $objectid -Password $Pass -ForceChangePasswordNextLogin $true
