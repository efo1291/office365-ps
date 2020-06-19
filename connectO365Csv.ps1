###########################Define Variables##################################

$credFile = "${env:\userprofile}\o365.cred"

##########################Check if Administrator#############################

if (-NOT ([Security.Principal.WindowsPrincipal] `
[Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You are not running this as local administrator. Run it again in an elevated prompt."
    break }
    
##################Verify cred file And Connect Office 365####################

$Error.Clear()
Set-ExecutionPolicy Bypass

if (-NOT (Test-Path $credFile -PathType Leaf)) {
    Write-Warning "Credentials not found. Enter Office 365 credentials"
    $cred = Get-Credential
    $cred | Export-Clixml -Path $credFile
    $Error.Clear() }

$ErrorActionPreference = "silentlycontinue"
Write-Information "Importing credentials at" $credFile
$cred = Import-Clixml -Path $credFile
Connect-AzureAD -Credential $cred | Out-Null

If ($Error -ne $null) {
    Write-Warning "Invalid Credentials, Access denied or Network Problems"
    Remove-Item $credFile
    $Error.Clear()
    break }
