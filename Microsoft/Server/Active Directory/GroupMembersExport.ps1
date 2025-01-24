# Import the Active Directory module
Import-Module ActiveDirectory

# Define the path
$ExportFolder = "C:\temp\398954\groups"

# Specify the list of group names you want to export members from
$GroupNames = @("AREF", "RS - (CEO)", "Corporate Affairs", "International & European", "Investment & Capital Markets", "RS - (IVIS)", "Market Insight & Fund Sectors", "Membership & Enterprise", "Operations", "RS - (Policy_ Strategy & Innovation)", "RS - (Investment20_20)", "RS - (Stewardship & Corporate Governance)")

# Iterate through each group and export the members
foreach ($GroupName in $GroupNames) {
    # Set the export path for the current group
    $ExportPath = Join-Path -Path $ExportFolder -ChildPath "$GroupName.csv"

    # Get the group members and export them to a CSV file
    Get-ADGroupMember -Identity $GroupName | Select-Object Name, SamAccountName, DistinguishedName |
        Export-Csv -Path $ExportPath -NoTypeInformation

    Write-Host "Exported group members for: $GroupName"
}
