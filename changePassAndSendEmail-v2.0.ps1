#############################################################################
###########################Define Variables##################################

# Verificar se é Administrator
# Verificar se args possui mais de três caracteres
#$USER = $args[0]

$adminAcc = 'efo2@cin.ufpe.br' #<< Admin account credentials

#$FromAddress = 'Sidath@Contoso.com' #<< Mail from address
$FromAddress = 'efo2@cin.ufpe.br' #<< Mail from address
$MailSubject = "Acesso Office 365 - CIn"
$MailSignature = "CIn - Suporte"
#$SmtpPServer = 'smtp.office365.com'
$SmtpPServer = 'smtp.gmail.com'
$SmtpPort = '587'

#############################################################################
###########################Verify Module AzureAD#############################

#If ((Get-Module AzureADPreview) -eq $null) {
If ((Get-Module AzureAD) -eq $null) {
    Write-Warning "Installing module AzureAD..."
    Install-Module AzureAD
    }

#############################################################################
###########################Connect to Office 365#############################

$cred = Get-Credential -credential $adminAcc
$o365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Connect-AzureAD -Credential $cred
#Import-PSSession $o365Session -AllowClobber

# Possivelmente não vou usar porque o mesmo que acessa o admin Microsoft, enviará o email pelo Gmail
#If ($adminAcc -ne $FromAddress) {
#    $credMail = Get-Credential -credential $FromAddress
#    }
#Else {$credMail = $cred}

#############################################################################
################################Random Pass##################################
  
# Função para gerar os caracteres 
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
 
# Função para embaralhar os caracteres
function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}
 
# Variável para receber os caracteres gerados na função Get-RandomCharacters
$password = Get-RandomCharacters -length 3 -characters 'abcdefghikmnprstuvwxyz'
$password += Get-RandomCharacters -length 2 -characters 'ABCDEFGHKLMNPRSTUVWXYZ'
$password += Get-RandomCharacters -length 2 -characters '23456789'
$password += Get-RandomCharacters -length 1 -characters '!@#$&'
 
# Variável para embaralhar na função Scramble-String
$password = Scramble-String $password
 
# Exibir password
Write-Host $password

#############################################################################
#######################Get users' info / Change pass#########################

$USER = $args[0]
# UserPrincipalName Refere-se ao e-mail 
$CMNM = (Get-AzureADUser -Filter "MailNickName eq '$USER'")
$CUPN = $CMNM.UserPrincipalName
$CDN = $CMNM.DisplayName
$CMail = $CMNM.Mail
$CObjID = $CMNM.objectID
$CPW = $password
$CPWS = ConvertTo-SecureString -String $CPW -AsPlainText -Force

Write-Host "Reseting the password of: $CUPN" -ForegroundColor Magenta -BackgroundColor Black
Set-AzureADUserPassword -ObjectId $CObjID -Password $CPWS -ForceChangePasswordNextLogin $true

#############################################################################
############################Send pass by E-mail##############################

#Generate message body
$MsgBody = "Oi $CDN,<br><br>"
$MsgBody += "Voce solicitou redefinição da senha Office 365.<br>"
$MsgBody += "Utilize esta senha temporária e redefina na tela de login.<br>"
$MsgBody += "https://cin.ufpe.br/azure<br><br>"
$MsgBody += "<table border=0> <tr> <th> User </th> <th> Password </th> <tr>"
$MsgBody += "<tr> <td> $CUPN </td> <td> $CPW </td> </tr> </table>"

Write-Host "Sending the password to: $CMail"
Send-MailMessage -From $FromAddress -To $CMail -Subject $MailSubject -Body $MsgBody -Priority High -SmtpServer $SmtpPServer -Credential $cred -UseSsl -BodyAsHtml -encoding ([System.Text.Encoding]::UTF8)
# $credMail CASO UTUILIZE E-MAIL DIFERENTE DO ADMIN MICROSOFT

#############################################################################
################################End Session##################################

Get-PSSession | Remove-PSSession

#############################################################################
