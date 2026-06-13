# ============================================
# Meridian Health Staffing — User Provisioning
# Author: Arielle Ezechukwu
# Description: Creates Entra ID users for the
#              Meridian Health Staffing lab tenant
# Usage: Run in PowerShell 7 after connecting
#        to Microsoft Graph
# ============================================

# Define users
$users = @(
    @{
        DisplayName       = "Alice Chen"
        UserPrincipalName = "alice.chen@meridianhealthstaffing.onmicrosoft.com"
        MailNickname      = "alice.chen"
        Department        = "Clinical Operations"
        JobTitle          = "Operations Manager"
    },
    @{
        DisplayName       = "Bob Harris"
        UserPrincipalName = "bob.harris@meridianhealthstaffing.onmicrosoft.com"
        MailNickname      = "bob.harris"
        Department        = "Finance"
        JobTitle          = "Finance Analyst"
    },
    @{
        DisplayName       = "Carol James"
        UserPrincipalName = "carol.james@meridianhealthstaffing.onmicrosoft.com"
        MailNickname      = "carol.james"
        Department        = "IT"
        JobTitle          = "Help Desk Technician"
    },
    @{
        DisplayName       = "Dan Ortiz"
        UserPrincipalName = "dan.ortiz@meridianhealthstaffing.onmicrosoft.com"
        MailNickname      = "dan.ortiz"
        Department        = "Clinical Operations"
        JobTitle          = "Contractor"
    },
    @{
        DisplayName       = "Break Glass"
        UserPrincipalName = "breakglass@meridianhealthstaffing.onmicrosoft.com"
        MailNickname      = "breakglass"
        Department        = "IT"
        JobTitle          = "Emergency Admin"
    }
)

# Auto-generate a random temp password
function New-TempPassword {
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#$%'
    $password = -join (1..12 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    return $password
}

$tempPassword = New-TempPassword
Write-Host "Generated temp password: $tempPassword" -ForegroundColor Cyan
Write-Host "Save this before continuing." -ForegroundColor Yellow

# Password profile applied to all users
$passwordProfile = @{
    Password                      = $tempPassword
    ForceChangePasswordNextSignIn = $true
}

# Tracking counters
$created = 0
$skipped = 0
$failed  = 0

# Create each user
foreach ($user in $users) {
    try {
        # Check if user already exists
        $existing = Get-MgUser -Filter "UserPrincipalName eq '$($user.UserPrincipalName)'" -ErrorAction SilentlyContinue

        if ($existing) {
            Write-Host "SKIPPED (already exists): $($user.DisplayName)" -ForegroundColor Yellow
            $skipped++
            continue
        }

        # Create the user
        New-MgUser `
            -DisplayName       $user.DisplayName `
            -UserPrincipalName $user.UserPrincipalName `
            -MailNickname      $user.MailNickname `
            -Department        $user.Department `
            -JobTitle          $user.JobTitle `
            -AccountEnabled `
            -PasswordProfile   $passwordProfile `
            -UsageLocation     "US"

        Write-Host "CREATED: $($user.DisplayName)" -ForegroundColor Green
        $created++
    }
    catch {
        Write-Host "FAILED: $($user.DisplayName) — $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

# Summary
Write-Host ""
Write-Host "===== Summary =====" -ForegroundColor Cyan
Write-Host "Created : $created" -ForegroundColor Green
Write-Host "Skipped : $skipped" -ForegroundColor Yellow
Write-Host "Failed  : $failed"  -ForegroundColor Red
