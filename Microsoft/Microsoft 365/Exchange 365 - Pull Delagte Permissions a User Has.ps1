# Check if Exchange Online module is installed, if not, install and import it
$moduleName = 'ExchangeOnlineManagement'

if (-not (Get-Module -ListAvailable -Name $moduleName)) {
    Write-Host "ExchangeOnlineManagement module not found. Installing..." -ForegroundColor Yellow
    Install-Module -Name $moduleName -Force -AllowClobber
} else {
    Write-Host "ExchangeOnlineManagement module found. Importing..." -ForegroundColor Green
}

# Import the module
Import-Module $moduleName -Force

# Define the user to search for
$User = "user@domain.com"

# Define the mailbox domain filter (e.g., "@example.com")
$FilterDomain = "@example.com"

# Initialize array to store results
$Results = @()

Write-Host "Retrieving all mailboxes matching domain filter..." -ForegroundColor Cyan
# Get mailboxes that match the domain filter
$mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.PrimarySmtpAddress -like "*$FilterDomain" }
$totalMailboxes = $mailboxes.Count
$currentMailbox = 0

if ($totalMailboxes -eq 0) {
    Write-Host "No mailboxes found with the domain $FilterDomain." -ForegroundColor Yellow
    exit
}

Write-Host "Checking Full Access permissions for $User..." -ForegroundColor Cyan
foreach ($Mailbox in $mailboxes) {
    $currentMailbox++
    $progress = [math]::Min(($currentMailbox / $totalMailboxes) * 100, 100)  # Ensure max is 100
    Write-Progress -Activity "Checking Full Access" -Status "Scanning $($Mailbox.PrimarySmtpAddress)" -PercentComplete $progress

    $Permissions = Get-MailboxPermission -Identity $Mailbox.PrimarySmtpAddress | Where-Object {
        $_.User -like $User -and $_.AccessRights -contains "FullAccess"
    }

    if ($Permissions) {
        $Results += [PSCustomObject]@{
            Mailbox        = $Mailbox.PrimarySmtpAddress
            User           = $User
            AccessType     = "Full Access"
        }
    }
}

Write-Host "Checking Send As permissions for $User..." -ForegroundColor Cyan
$currentMailbox = 0  # Reset counter
foreach ($Mailbox in $mailboxes) {
    $currentMailbox++
    $progress = [math]::Min(($currentMailbox / $totalMailboxes) * 100, 100)
    Write-Progress -Activity "Checking Send As" -Status "Processing $($Mailbox.PrimarySmtpAddress)" -PercentComplete $progress

    $SendAsPermissions = Get-RecipientPermission -Identity $Mailbox.PrimarySmtpAddress | Where-Object {
        $_.Trustee -like $User -and $_.AccessRights -contains "SendAs"
    }

    if ($SendAsPermissions) {
        $Results += [PSCustomObject]@{
            Mailbox        = $Mailbox.PrimarySmtpAddress
            User           = $User
            AccessType     = "Send As"
        }
    }
}

Write-Host "Checking Send on Behalf permissions for $User..." -ForegroundColor Cyan
$currentMailbox = 0
foreach ($Mailbox in $mailboxes) {
    $currentMailbox++
    $progress = [math]::Min(($currentMailbox / $totalMailboxes) * 100, 100)
    Write-Progress -Activity "Checking Send on Behalf" -Status "Scanning $($Mailbox.PrimarySmtpAddress)" -PercentComplete $progress

    $Delegates = Get-Mailbox -Identity $Mailbox.PrimarySmtpAddress | Select-Object -ExpandProperty GrantSendOnBehalfTo
    if ($Delegates -match $User) {
        $Results += [PSCustomObject]@{
            Mailbox        = $Mailbox.PrimarySmtpAddress
            User           = $User
            AccessType     = "Send on Behalf"
        }
    }
}

# Clear Progress Bar
Write-Progress -Activity "Complete" -Completed

# Display Results
if ($Results.Count -gt 0) {
    $Results | Format-Table -AutoSize
} else {
    Write-Host "No delegate access found for $User on mailboxes in domain $FilterDomain." -ForegroundColor Yellow
}

# Optional: Export results to CSV
$Results | Export-Csv -Path "$env:USERPROFILE\Desktop\DelegatePermissions_$($User.Split('@')[0])_$($FilterDomain.Replace('@','')).csv" -NoTypeInformation
Write-Host "Results saved to DelegatePermissions_$($User.Split('@')[0])_$($FilterDomain.Replace('@','')).csv on your Desktop." -ForegroundColor Green
