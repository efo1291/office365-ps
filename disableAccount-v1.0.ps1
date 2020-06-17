$USER = 'lab2'
# UserPrincipalName Refere-se ao e-mail 
$CMNN = (Get-AzureADUser -Filter "MailNickName eq '$USER'")
$CUPN = $CMNN.UserPrincipalName
$CDN = $CMNN.DisplayName
$CMail = $CMNN.Mail
$CObjID = $CMNN.objectID

Write-Warning "DISABLING ACCOUNT `
$CDN - $CUPN"
Set-AzureADUser -ObjectId $CObjID -AccountEnabled $False
