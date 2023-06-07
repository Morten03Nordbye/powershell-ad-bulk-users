# Import the Active Directory module to provide the cmdlets we need
Import-Module ActiveDirectory

# Import user data from the CSV file located in the same directory as the script
$ADUsers = Import-Csv -Delimiter ";" .\users.csv

# Process each user in the CSV file one by one
foreach ($User in $ADUsers) {
    # Output a message indicating which user is currently being processed
    Write-Host "Processing user: $($User.username)"

    # Assign user properties from the current line of the CSV file
    $Username   = $User.username
    $Password   = $User.password
    $Firstname  = $User.firstname
    $Lastname   = $User.lastname
    $OU         = $User.ou
    $Group      = $User.groupname

    # Check if a user with the current username already exists in Active Directory
    if (Get-ADUser -Filter {SamAccountName -eq $Username}) {
        # If user exists, write a warning message to the console
        Write-Warning "A user account with username $Username already exists in Active Directory."
    } else {
        # If user does not exist, try to create a new user
        try {
            # Create a new user in Active Directory with the provided details
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

            # Add the newly created user to the specified group
            Add-ADGroupMember -Identity $Group -Members $Username

            # Output a message confirming successful user creation and group addition
            Read-Host "Successfully added account with username $Username to group $Group. Press Enter to continue."
        } catch {
            # If there's an error during the user creation process, write the error to the console
            Write-Error "An error occurred while creating user ${Username}: $_"
        }
    }
}
