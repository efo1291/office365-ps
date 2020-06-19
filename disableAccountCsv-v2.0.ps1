###########################Define Variables##################################

$PathCsv = 'C:\users\user\Desktop\LabCSV.csv'
$ImportCSV = Import-Csv $PathCsv

##############################Display Action#############################

Write-Host "--------------- DISABLING ACCOUNTS ---------------" -ForegroundColor Cyan

##############################Connect Office 365#############################

. .\connectO365Csv.ps1

######################Disable account by file CSV############################
 
$ImportCSV | ForEach-Object { 
    Write-Host "DISABLING ACCOUNT:" $_.UserPrincipalName "|" $_.DisplayName
    Set-AzureADUser -ObjectId $_.ObjectId -AccountEnabled $True }
