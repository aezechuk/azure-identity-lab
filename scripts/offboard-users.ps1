# ============================================
# Meridian Health Staffing — User Offboarding
# Author: Arielle Ezechukwu
# Description: Fully offboards a user by removing
#              group memberships, revoking sessions,
#              and blocking sign-in
# Usage: .\offboard-user.ps1 -UPN "user@domain.com"
# Note: Password reset is performed manually in the
#       portal as a defense-in-depth measure.
#       It is not required when account is disabled
#       and sessions are revoked.
# ============================================

param(
    [Parameter(Mandatory)]
    [string]$UPN
)

# Connect check
$context = Get-MgContext
if (-not $context) {
    Write-Host "Not connected to Microsoft Graph. Run Connect-MgGraph first." -ForegroundColor Red
    exit
}

Write-Host "`n===== Starting Offboarding for: $UPN =====" -ForegroundColor Cyan

# Get the user
try {
    $user = Get-MgUser -Filter "UserPrincipalName eq '$UPN'" -ErrorAction Stop
    if (-not $user) {
        Write-Host "USER NOT FOUND: $UPN" -ForegroundColor Red
        exit
    }
    Write-Host "Found user: $($user.DisplayName)" -ForegroundColor Green
}
catch {
    Write-Host "ERROR finding user: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Step 1 — Remove from all groups
Write-Host "`n[Step 1] Removing from all groups..." -ForegroundColor Yellow
try {
    $groups = Get-MgUserTransitiveMemberOf -UserId $user.Id
    foreach ($group in $groups) {
        $groupDetails = Get-MgGroup -GroupId $group.Id -ErrorAction SilentlyContinue
        if ($groupDetails) {
            try {
                Remove-MgGroupMemberByRef -GroupId $group.Id -DirectoryObjectId $user.Id
                Write-Host "  REMOVED from: $($groupDetails.DisplayName)" -ForegroundColor Green
            }
            catch {
                Write-Host "  SKIPPED: $($groupDetails.DisplayName) — $($_.Exception.Message)" -ForegroundColor Gray
            }
        }
    }
}
catch {
    Write-Host "  ERROR removing groups: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 2 — Revoke all sessions
Write-Host "`n[Step 2] Revoking all active sessions..." -ForegroundColor Yellow
try {
    Revoke-MgUserSignInSession -UserId $user.Id
    Write-Host "  SUCCESS: All sessions revoked" -ForegroundColor Green
}
catch {
    Write-Host "  ERROR revoking sessions: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3 — Block sign-in
Write-Host "`n[Step 3] Blocking sign-in..." -ForegroundColor Yellow
try {
    Update-MgUser -UserId $user.Id -AccountEnabled:$false
    Write-Host "  SUCCESS: Account disabled" -ForegroundColor Green
}
catch {
    Write-Host "  ERROR blocking sign-in: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4 — Verify current state
Write-Host "`n[Step 4] Verifying account state..." -ForegroundColor Yellow
$verifyUser = Get-MgUser -UserId $user.Id -Property "DisplayName, AccountEnabled, UserPrincipalName"
Write-Host "  Name      : $($verifyUser.DisplayName)"
Write-Host "  UPN       : $($verifyUser.UserPrincipalName)"
Write-Host "  Enabled   : $($verifyUser.AccountEnabled)"

# Summary
Write-Host "`n===== Offboarding Complete =====" -ForegroundColor Cyan
Write-Host "User $UPN has been offboarded." -ForegroundColor Green
Write-Host "ACTION REQUIRED: Reset password manually in Entra ID portal." -ForegroundColor Yellow
Write-Host "NOTE: Account retained for 30-day hold per data retention policy." -ForegroundColor Yellow
Write-Host "Schedule hard delete after: $((Get-Date).AddDays(30).ToString('MM/dd/yyyy'))" -ForegroundColor Yellow
