# import active directory module for running ad cmdlets
Import-Module activedirectory

$ADUsers = Import-Csv -Delimiter ";" C:\Users\Administrator\Documents\users.csv


foreach ($User in $ADUsers)
{
    Write-Host $User

    $Username    = $User.username
    $Password    = $User.password
    $Firstname   = $User.firstname
    $Lastname    = $User.lastname
    $OU          = $User.ou


  
if (Get-ADUser -F {SamAccountName -eq $Username}){
    Write-Warning "A user account with username $Username already exist in Active Directory-"
    }
    else{
        New-ADUser `
            -SamAccountName $Username `
            -Name "$Firstname $Lastname" `
            -Givenname $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName "$Lastname, $Firstname" `
            -Path $OU `
            -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -force) -ChangePasswordAtLogon $True
        Read-host "Successfully added account with username $Username, continue?"

    }
    
}


