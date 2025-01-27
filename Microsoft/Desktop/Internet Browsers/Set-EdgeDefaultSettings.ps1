# Disable Edge Duality New Profile Window for all users
try {
    Write-Host "Disabling Edge Duality New Profile Window..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "ShowFeatureRecommendations" -Value 0 -Force
    Write-Host "Edge Duality New Profile Window disabled." -ForegroundColor Green
} catch {
    Write-Host "Failed to disable Edge Duality New Profile Window: $_" -ForegroundColor Red
}

# Set Edge as the default browser for all users
try {
    Write-Host "Setting Edge as the default browser..." -ForegroundColor Cyan
    $DefaultAppSettings = @"
<?xml version="1.0" encoding="UTF-8"?>
<DefaultAssociations>
    <Association Identifier=".html" ProgId="MSEdgeHTM" ApplicationName="Microsoft Edge" />
    <Association Identifier=".htm" ProgId="MSEdgeHTM" ApplicationName="Microsoft Edge" />
    <Association Identifier="http" ProgId="MSEdgeHTM" ApplicationName="Microsoft Edge" />
    <Association Identifier="https" ProgId="MSEdgeHTM" ApplicationName="Microsoft Edge" />
</DefaultAssociations>
"@

    $TempFile = "$env:TEMP\defaultapps.xml"
    $DefaultAppSettings | Out-File -FilePath $TempFile -Encoding UTF8
    Dism.exe /Online /Import-DefaultAppAssociations:$TempFile
    Remove-Item $TempFile
    Write-Host "Edge set as the default browser." -ForegroundColor Green
} catch {
    Write-Host "Failed to set Edge as the default browser: $_" -ForegroundColor Red
}

# Set Edge homepage to https://immersive.co.uk for all users
try {
    Write-Host "Setting Edge homepage to https://google.co.uk..." -ForegroundColor Cyan
    $EdgePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    if (!(Test-Path $EdgePolicyPath)) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft" -Name "Edge" -Force | Out-Null
    }
    Set-ItemProperty -Path $EdgePolicyPath -Name "RestoreOnStartupURLs" -Value @("https://google.co.uk”) -Force
    Set-ItemProperty -Path $EdgePolicyPath -Name "RestoreOnStartup" -Value 4 -Force
    Write-Host "Edge homepage set to https://google.co.uk." -ForegroundColor Green
} catch {
    Write-Host "Failed to set Edge homepage: $_" -ForegroundColor Red
}

# Set Google as the default search provider in Edge for all users
try {
    Write-Host "Setting Google as the default search provider in Edge..." -ForegroundColor Cyan
    $EdgePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    if (!(Test-Path $EdgePolicyPath)) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft" -Name "Edge" -Force | Out-Null
    }
    Set-ItemProperty -Path $EdgePolicyPath -Name "DefaultSearchProviderEnabled" -Value 1 -Force
    Set-ItemProperty -Path $EdgePolicyPath -Name "DefaultSearchProviderSearchURL" -Value "https://www.google.com/search?q={searchTerms}" -Force
    Set-ItemProperty -Path $EdgePolicyPath -Name "DefaultSearchProviderName" -Value "Google" -Force
    Set-ItemProperty -Path $EdgePolicyPath -Name "DefaultSearchProviderKeyword" -Value "google.com" -Force
    Write-Host "Google set as the default search provider in Edge." -ForegroundColor Green
} catch {
    Write-Host "Failed to set Google as the default search provider: $_" -ForegroundColor Red
}
