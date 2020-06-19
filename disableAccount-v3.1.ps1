#############################################################################
##########################Check if Administrator#############################

#Checks if the user is in the administrator group. Warns and stops if the user is not.
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "You are not running this as local administrator. Run it again in an elevated prompt." ; break }

#############################################################################
#########################Input array And Vaidate it##########################

$ORIGINALUSERS = $args[0]
[System.Collections.ArrayList]$USERS = @()

if ($args[0] -eq $null) {
    Write-Warning "Missing parameter '$$ <user>'" }

ForEach ($user in $ORIGINALUSERS) {       
    $USERS.Add($user) | Out-Null
        if (($user.Length -le 2)) {    
            Write-Warning "Invalid user $user"
            $USERS.Remove($user) | Out-Null }
}

#############################################################################
##################Verify cred file And Connect Office 365####################

$Error.Clear()
Set-ExecutionPolicy Bypass

$credFile = "${env:\userprofile}\o365.cred"
if (-NOT (Test-Path $credFile -PathType Leaf)){
    Write-Warning "Credentials not found. Enter Office 365 credentials"
    $cred = Get-Credential
    $cred | Export-Clixml -Path $credFile ; $Error.Clear() }

$ErrorActionPreference = "silentlycontinue"
Write-Information "Importing credentials at" $credFile
$cred = Import-Clixml -Path $credFile
Connect-AzureAD -Credential $cred | Out-Null

If ($Error -ne $null) {
    Write-Warning "Invalid Credentials, Access denied or Network Problems"
    Remove-Item $credFile ; $Error.Clear() ; break }
    
#############################################################################
#######################Verify user on Office 365#########################    

if ($USERS -ne $null) {
    Write-Host "DISABLING ACCOUNTS" -ForegroundColor Cyan
    ForEach ($user in $USERS) {           
        $CMNN = (Get-AzureADUser -Filter "MailNickName eq '$user'")
        $CUPN = $CMNN.UserPrincipalName
        $CDN = $CMNN.DisplayName
        $CMail = $CMNN.Mail
        $CObjID = $CMNN.ObjectID

        if ( $CObjID -eq $null ) {
            Write-Host "User $user not found" -ForegroundColor Yellow }
        else {

#############################################################################
################# ACTION - Disable account / Show result ####################

            Write-Host "$CDN | $CUPN"
            #Set-AzureADUser -ObjectId $CObjID -AccountEnabled $False
                        
        }
        Get-AzureADUser -ObjectId $CObjID | Select DisplayName, UserPrincipalName, AccountEnabled    
    }

    
}
        
