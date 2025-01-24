
# Import the Active Directory module
Import-Module ActiveDirectory

# Define the path
$ImportFolder = "C:\Path\to\import"

# Specify the list of group names to update
$GroupNames = @("Group1", "Group2", "Group3")

# Iterate through each group and import the members
foreach ($GroupName in $GroupNames) {
    # Set the import path for the current group
    $ImportPath = Join-Path -Path $ImportFolder -ChildPath "$GroupName.csv"

    # Check if the import file exists
    if (Test-Path $ImportPath) {
        # Import the CSV file
        $ImportedMembers = Import-Csv -Path $ImportPath

        # Iterate through each member and add or remove them from the group
        foreach ($Member in $ImportedMembers) {
            # Check if the member exists in the group
            $IsMember = Get-ADGroupMember -Identity $GroupName -Recursive | Where-Object {
                $_.SamAccountName -eq $Member.SamAccountName -or $_.DistinguishedName -eq $Member.DistinguishedName
            }

            # If the member is not found, add them to the group
            if (!$IsMember) {
                Add-ADGroupMember -Identity $GroupName -Members $Member.SamAccountName
                Write-Host "Added member: $($Member.Name) to group: $GroupName"
            }

            # If the member is found, remove them from the group
            else {
                Remove-ADGroupMember -Identity $GroupName -Members $Member.SamAccountName -Confirm:$false
                Write-Host "Removed member: $($Member.Name) from group: $GroupName"
            }
        }
    }
    else {
        Write-Host "Import file not found for group: $GroupName"
    }
}
