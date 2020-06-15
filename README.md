# office365-ps

- Instalar módulo AzureAD  
Install-module -Name AzureAD  
- Conectar ao Office  
Connect-AzureAD <'Digitar as credenciais na janela'>

- Exibir usuários com 'Get-AzureADUser'  
    Example 1: Get ten users          | Example 2: Get a user by ID   
    PS C:\>Get-AzureADUser -Top 10    | PS C:\>Get-AzureADUser -ObjectId "testUpn@tenant.com"   

    Example 3: Search among retrieved users   
    PS C:\> Get-AzureADUser -SearchString "New"   

    ObjectId                             DisplayName UserPrincipalName                   UserType   
    \--------                             ----------- -----------------                   --------   
    5e8b0f4d-2cd4-4e17-9467-b0f6a5c0c4d0 New user    NewUser@contoso.onmicrosoft.com     Member   
    2b450b8e-1db6-42cb-a545-1b05eb8a358b New user    NewTestUser@contoso.onmicrosoft.com Member   

    Example 4: Get a user by userPrincipalName   
    PS C:\>Get-AzureADUser -Filter "userPrincipalName eq 'jondoe@contoso.com'"   

    Example 5: Get a user by userPrincipalName   
    PS C:\>Get-AzureADUser -Filter "startswith(Title,'Network')"   

    This command gets all the users whos title starts with Network. ie Network Manager and Network Assistant.   
