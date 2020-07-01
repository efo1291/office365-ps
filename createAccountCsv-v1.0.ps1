###########################Define Variables##################################

$PathCsv = 'C:\users\user\Desktop\LabCSV.csv'
$ImportCSV = Import-Csv $PathCsv

##############################Display Action#############################

Write-Host "--------------- CREATING ACCOUNTS ---------------" -ForegroundColor Cyan

##############################Connect Office 365#############################

. .\connectO365Csv.ps1

######################Create account by file CSV############################
 
$ImportCSV | ForEach-Object { 
    #Write-Host "DISABLING ACCOUNT:" $_.UserPrincipalName "|" $_.DisplayName
    #Set-AzureADUser -ObjectId $_.ObjectId -AccountEnabled $True }
    
    # Call script
    . .\generatePass.ps1
    
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = $UPW

    New-AzureADUser -DisplayName $_.DisplayName -GivenName $_.GivenName -Surname $_.Surname -UserPrincipalName $_.UserPrincipalName -UsageLocation $_.UsageLocation -MailNickName $_.MailNickName -AccountEnabled $_.AccountEnabled -PasswordProfile $PasswordProfile
    #New-AzureADUser -DisplayName "Lab5 Teste" -GivenName "Lab5" -Surname "Teste" -UserPrincipalName "lab5@cin.ufpe.br" -UsageLocation "BR" -MailNickName "lab5" -AccountEnabled $True -PasswordProfile $PasswordProfile
    
    #ForEach ($user in $USERS) {           
    $UMNN = (Get-AzureADUser -Filter "MailNickName eq '$_.MailNickName'")
    #$UMNN = (Get-AzureADUser -Filter "MailNickName eq 'lab5'")
    $UUPN = $UMNN.UserPrincipalName
    $UDN = $UMNN.DisplayName        
    $UMail = $UMNN.Mail
    $UObjID = $UMNN.ObjectID

    if ($UObjID -eq $null) {
        Write-Host "User $user not found" -ForegroundColor Yellow }
    else {

############################Set License##############################
                       
            # Create the objects we'll need to add and remove licenses
        $value = "STANDARDWOFFPACK_STUDENT"
        $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        # Find the SkuID of the license we want to add - in this example we'll use the O365_BUSINESS_PREMIUM license
        $license.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $value -EQ).SkuID
        # Set the Office license as the license we want to add in the $licenses object
        $licenses.AddLicenses = $license

            #Write-Host "Setting License: $value" -ForegroundColor Magenta -BackgroundColor Black
            #Write-Host $UObjID
        Set-AzureADUserLicense -ObjectId $UObjID -AssignedLicenses $licenses
            
        $UMNN = (Get-AzureADUser -Filter "MailNickName eq 'lab5'")                        
        $UMail = $UMNN.Mail

            #Write-Host $UMail
                    
############################Send pass by E-mail##############################
            
            # Call script
            #. .\generatePass.ps1
                        
        $MsgBody = "Oi $UDN,<br><br>"
        $MsgBody += "Sua conta Office 365 foi criada.<br>"
        $MsgBody += "Utilize esta senha temporária e redefina na tela de login.<br>"
        $MsgBody += "https://contoso.com<br><br>"
        $MsgBody += "<table border=0> <tr> <th> User </th> <th> Password </th> <tr>"
        $MsgBody += "<tr> <td> $UUPN </td> <td> $UPW </td> </tr> </table>"
                        
            #Write-Host "Setting the password of: $UUPN | $UPW" -ForegroundColor Magenta -BackgroundColor Black
            #Set-AzureADUserPassword -ObjectId $UObjID -Password $UPWS -ForceChangePasswordNextLogin $true

        Write-Host "Sending the password to: $UMail"
        Send-MailMessage -From $FromAddress -To $UMail -Subject $MailSubject -Body $MsgBody -Priority High `
        -SmtpServer $SmtpPServer -Credential $cred -UseSsl -BodyAsHtml -encoding ([System.Text.Encoding]::UTF8)
            # $credMail CASO UTUILIZE E-MAIL DIFERENTE DO ADMIN MICROSOFT
    }
    #}
}
    