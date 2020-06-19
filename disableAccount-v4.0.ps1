##############################Display Action#############################

Write-Host "--------------- DISABLING ACCOUNTS ---------------" -ForegroundColor Cyan

##############################Connect Office 365#############################

. .\connectO365.ps1 $args[0]

##########################Verify user on Office 365##########################

if ($USERS -ne $null) {    
    ForEach ($user in $USERS) {           
        $CMNN = (Get-AzureADUser -Filter "MailNickName eq '$user'")
        $CUPN = $CMNN.UserPrincipalName
        $CDN = $CMNN.DisplayName
        $CMail = $CMNN.Mail
        $CObjID = $CMNN.ObjectID

        if ($CObjID -eq $null) {
            Write-Host "User $user not found" -ForegroundColor Yellow }
        else {

#############################################################################
################# ACTION - Disable account / Show result ####################

            Write-Host "$CDN | $CUPN"
            Set-AzureADUser -ObjectId $CObjID -AccountEnabled $False
                        
        }
        Get-AzureADUser -ObjectId $CObjID | Select DisplayName, UserPrincipalName, AccountEnabled
    }    
}
