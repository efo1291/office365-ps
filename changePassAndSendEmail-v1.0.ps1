#############################################################################
###########################Define Variables##################################
$adminAcc = 'admino365@contoso.com' #<< Admin account credentials

#$FromAddress = 'Sidath@Contoso.com' #<< Mail from address
$FromAddress = 'admino365@contoso.com' #<< Mail from address
$MailSubject = "Acesso Office 365 - Contoso"
$MailSignature = "Contoso - Suporte"
#$SmtpPServer = 'smtp.office365.com'
$SmtpPServer = 'smtp.gmail.com'
$SmtpPort = '587'

#############################################################################
#Write-Warning "Have you updated the variables and PasswordChangeList.csv file? (if not close this window and do it first)"
#pause

#Install AzureAD module if it's not available
#If ((Get-Module AzureADPreview) -eq $null) {
#If ((Get-Module AzureAD) -eq $null) {
#    Write-Warning "Installing module AzureAD.. [Note: To install this module you must run this script with admin priviledges]"
#    Install-Module AzureADPreview
#    }

#Connect to O365 tenant
$cred = Get-Credential -credential $adminAcc
$o365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri  https://ps.outlook.com/powershell -Credential $cred -Authentication Basic -AllowRedirection
Connect-AzureAD -Credential $cred
Import-PSSession $o365Session -AllowClobber

#$ImprtLst = Import-Csv "$FilePath\PasswordChangeList.csv"
$ImportList = (Get-AzureADUser -Filter "userPrincipalName eq 'lab1@contoso.com'")

If ($adminAcc -ne $FromAddress) {
    $credMail = Get-Credential -credential $FromAddress
    }
Else {$credMail = $cred}


$Error.Clear()
$CUPN = 'lab1@contoso.com'
$CPW = 'L@b012345'
$CDN = 'Lab1 Teste'
$CMail = 'lab1@contoso.com'
$CPWS = ConvertTo-SecureString -String $CPW -AsPlainText -Force

#Write-Host "reseting the password of: $CUPN" -ForegroundColor Magenta -BackgroundColor Black

$CObjID = (Get-AzureADUser -Filter "UserPrincipalName eq '$CUPN'").objectID
Set-AzureADUserPassword -ObjectId $CObjID -Password $CPWS -ForceChangePasswordNextLogin $true -EnforceChangePasswordPolicy:$false

#Error logging
If ($Error -ne $null) {
    $Error | Out-File $FilePath\ErrorLog.txt
        }

#Generate message body
$MsgBody = "Oi $CDN,"
#$MsgBody += ",</br> </br> <p> Following are your new Office 365 Credentials. </p>"
$MsgBody += "</br> </br> <p> Voce solicitou redefinicao da senha Office 365. </p>"
$MsgBody += "Utilize esta senha temporaria e redefina na tela de login"
$MsgBody += "https://contoso.com/"
$MsgBody += "</br> <table border=0> <tr> <th> User </th> <th> Password </th> <tr>"
$MsgBody += "<tr> <td> $CUPN </td> <td> $CPW </td> </tr> </table>"


Write-Host "Sending the password to: $CMail"
Send-MailMessage -From $FromAddress -To $CMail -Subject $MailSubject -Body $MsgBody -Priority High -SmtpServer $SmtpPServer -Credential $credMail -UseSsl -BodyAsHtml

Get-PSSession | Remove-PSSession
