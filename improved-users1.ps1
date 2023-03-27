# Import Active Directory module for running AD cmdlets
Import-Module ActiveDirectory

# Import user data from CSV
$ADUsers = Import-Csv -Delimiter ";" C:\Users\Administrator\Documents\users.csv

# Process each user in the CSV file
foreach ($User in $ADUsers) {
    Write-Host "Processing user: $($User.username)"

    # Assign user properties from CSV
    $Username   = $User.username
    $Password   = $User.password
    $Firstname  = $User.firstname
    $Lastname   = $User.lastname
    $OU         = $User.ou

    # Check if the user already exists in Active Directory
    if (Get-ADUser -Filter {SamAccountName -eq $Username}) {
        Write-Warning "A user account with username $Username already exists in Active Directory."
    } else {
        try {
            # Create a new AD user with the provided details
            New-ADUser `
                -SamAccountName $Username `
                -Name "$Firstname $Lastname" `
                -GivenName $Firstname `
                -Surname $Lastname `
                -Enabled $True `
                -DisplayName "$Lastname, $Firstname" `
                -Path $OU `
                -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
                -ChangePasswordAtLogon $True

            # Confirm user creation and continue
            Read-Host "Successfully added account with username $Username. Press Enter to continue."
        } catch {
            # Handle any errors during user creation
            Write-Error "An error occurred while creating user $Username: $_"
        }
    }
}
