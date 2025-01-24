# Import the Active Directory module
Import-Module ActiveDirectory

# Define the CSV file path
$csvFilePath = "C:\temp\398954\ADusers.csv"

# Get AD users and select required properties
$users = Get-ADUser -Filter * -Properties Name, SamAccountName, DistinguishedName |
         Select-Object Name, SamAccountName, DistinguishedName

# Export users to CSV
$users | Export-Csv -Path $csvFilePath -NoTypeInformation

# Output a success message
Write-Host "AD user information exported to $csvFilePath."
