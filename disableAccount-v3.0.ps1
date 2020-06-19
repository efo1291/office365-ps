#Checks if the user is in the administrator group. Warns and stops if the user is not.
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "You are not running this as local administrator. Run it again in an elevated prompt." ; break }

$ORIGINALUSERS = $args[0]
[System.Collections.ArrayList]$USERS = @()

ForEach ($user in $ORIGINALUSERS) {    
    $USERS.Add($user) | Out-Null
    if ($user -eq $null) {
        Write-Warning "Missing parameter '$$ <user>'"
        $USERS.Remove($user) | Out-Null ; break }
    else {
        if (-NOT ($user.Length -ge 3)) {    
            Write-Warning "Invalid user $user"
            $USERS.Remove($user) | Out-Null ; break  }}
}

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
    
clear
Write-Warning "DISABLING ACCOUNTS"
ForEach ($user in $USERS) {
    $CMNN = (Get-AzureADUser -Filter "MailNickName eq '$user'")
    $CUPN = $CMNN.UserPrincipalName
    $CDN = $CMNN.DisplayName
    $CMail = $CMNN.Mail
    $CObjID = $CMNN.ObjectID

    if ( $CObjID -eq $null ) {
        Write-Warning "User $user not found" ; break }

#############################################################################
#######################Disable account / Show result#########################
    
    #Set-AzureADUser -ObjectId $CObjID -AccountEnabled $False
    Get-AzureADUser -ObjectId $CObjID | Select DisplayName, UserPrincipalName, AccountEnabled    
}
