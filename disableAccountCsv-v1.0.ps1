$adminAcc = '****@...'
$Pass = '********'
$cred = Get-Credential -credential $adminAcc,$Pass
$o365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Connect-AzureAD -Credential $cred

# Import file CSV
$ImportCSV = Import-Csv 'path\to\file.csv'

# Disable account by file CSV
$ImportCSV | ForEach-Object { 
    Write-Host "DISABLING ACCOUNT:" $_.UserPrincipalName "|" $_.DisplayName
    Set-AzureADUser -ObjectId $_.ObjectId -AccountEnabled $True}
