# Install and import the required module if it's not already installed
if (-not (Get-InstalledModule -Name Microsoft.Graph -ErrorAction SilentlyContinue)) {
    Install-Module -Name Microsoft.Graph -Force -Scope CurrentUser
}
Import-Module Microsoft.Graph

# Import the CSV data
$csvPath = '/Users/willyoung/Library/CloudStorage/OneDrive-Cardonet/Ticket Work/665198/V2PhoneNumberList_2025-01-30_10-55-33-UTC.csv'  # Adjust this to your CSV file path
$csvData = Import-Csv -Path $csvPath

# Connect to Microsoft Graph using your admin credentials
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

# Loop through each record in the CSV
foreach ($entry in $csvData) {
    $phoneNumber = $entry.'Phone Number'
    $userPrincipalName = $entry.'UserPrincipalName'

    # Skip if phone number or user principal name is missing
    if ([string]::IsNullOrWhiteSpace($phoneNumber) -or [string]::IsNullOrWhiteSpace($userPrincipalName)) {
        Write-Output "Skipping user with missing data: $userPrincipalName"
        continue
    }

    # Update Microsoft Graph user's business phone
    try {
        $user = Get-MgUser -UserId $userPrincipalName
        Update-MgUser -UserId $user.Id -BusinessPhones @($phoneNumber)
        Write-Output "Updated user: $($user.DisplayName) - Phone Number: $phoneNumber"
    } catch {
        Write-Output "Error updating user: $userPrincipalName - $($_.Exception.Message)"
    }
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph
