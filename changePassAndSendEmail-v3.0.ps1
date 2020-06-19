###########################Define Variables##################################

$adminO365 = 'admin@contoso.com'

$FromAddress = 'admin@contoso.com'
$MailSubject = "Acesso Office 365 - Contoso"
$MailSignature = "Contoso - Suporte"
$SmtpPServer = 'smtp.gmail.com'
$SmtpPort = '587'

################################Display Action###############################

Write-Host "--------------- CHANGING PASS AND SEND E-MAIL ---------------" -ForegroundColor Cyan

##############################Connect Office 365#############################

. .\connectO365.ps1 $args[0]

##########################Verify user on Office 365##########################

if ($USERS -ne $null) {    
    ForEach ($user in $USERS) {           
        $UMNN = (Get-AzureADUser -Filter "MailNickName eq '$user'")
        $UUPN = $UMNN.UserPrincipalName
        $UDN = $UMNN.DisplayName
        $UMail = $UMNN.Mail
        $UObjID = $UMNN.ObjectID

        if ($UObjID -eq $null) {
            Write-Host "User $user not found" -ForegroundColor Yellow }
        else {
        
############################Send pass by E-mail##############################
            
            # Call script
            . .\generatePass.ps1
                        
            $MsgBody = "Oi $UDN,<br><br>"
            $MsgBody += "Voce solicitou redefinição da senha Office 365.<br>"
            $MsgBody += "Utilize esta senha temporária e redefina na tela de login.<br>"
            $MsgBody += "https://contoso.com<br><br>"
            $MsgBody += "<table border=0> <tr> <th> User </th> <th> Password </th> <tr>"
            $MsgBody += "<tr> <td> $UUPN </td> <td> $UPW </td> </tr> </table>"
                        
            Write-Host "Reseting the password of: $UUPN | $UPW" -ForegroundColor Magenta -BackgroundColor Black
            Set-AzureADUserPassword -ObjectId $UObjID -Password $UPWS -ForceChangePasswordNextLogin $true

            Write-Host "Sending the password to: $UMail"
            Send-MailMessage -From $FromAddress -To $UMail -Subject $MailSubject -Body $MsgBody -Priority High `
            -SmtpServer $SmtpPServer -Credential $cred -UseSsl -BodyAsHtml -encoding ([System.Text.Encoding]::UTF8)
            # $credMail CASO UTUILIZE E-MAIL DIFERENTE DO ADMIN MICROSOFT
        }
    }
}
