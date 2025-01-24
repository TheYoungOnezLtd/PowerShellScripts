# Import the Active Directory module
Import-Module ActiveDirectory

# Define the CSV file paths
$csvFilePath = "C:\temp\398954\GroupNames.csv"
$csvModifiedFilePath = "C:\temp\398954\GroupNamesUpdated.csv"

# Export AD group names to CSV
Get-ADGroup -Filter * -Properties Name |
    Select-Object Name |
    Export-Csv -Path $csvFilePath -NoTypeInformation

# Import the modified group names from CSV and update AD groups
Import-Csv -Path $csvModifiedFilePath | ForEach-Object {
    $adGroup = Get-ADGroup -Filter "Name -eq '$($_.Name)'" -Properties Name
    if ($adGroup) {
        $newName = $_.NewName
        Rename-ADObject -Identity $adGroup.DistinguishedName -NewName $newName
        Write-Host "Updated group name: $($adGroup.Name) -> $newName"
    } else {
        Write-Host "Group not found: $($_.Name)"
    }
}

# Output a success message
Write-Host "AD group names updated."
