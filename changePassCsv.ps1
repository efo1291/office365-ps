#############################################################################
##########################Check if Administrator#############################

#Checks if the user is in the administrator group. Warns and stops if the user is not.
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "You are not running this as local administrator. Run it again in an elevated prompt." ; break }

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
################# ACTION - Disable account / Show result ####################

# Import file CSV
$ImportCSV = Import-Csv 'C:\users\user\Desktop\LabCSV.csv'

# Change random pass
$ImportCSV | ForEach-Object { 
    Write-Host "CHANGING PASS:" $_.UserPrincipalName "|" $_.DisplayName
    . .\randomPass.ps1
    $passwordS = ConvertTo-SecureString -String $password -AsPlainText -Force
    Set-AzureADUserPassword -ObjectId $_.ObjectID -Password $passwordS -ForceChangePasswordNextLogin $True 
    Write-Host $password }
