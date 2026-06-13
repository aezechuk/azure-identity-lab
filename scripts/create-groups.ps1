# ============================================
# Meridian Health Staffing — Group Provisioning
# Author: Arielle Ezechukwu
# Description: Creates security groups, RBAC groups,
#              and role-assignable groups for the
#              Meridian Health Staffing lab tenant
# Usage: Run in PowerShell 7 after connecting
#        to Microsoft Graph
# ============================================

# Define all groups
$groups = @(
    # Department security groups
    @{
        DisplayName        = "grp-clinical-ops"
        MailNickname       = "grp-clinical-ops"
        Description        = "Clinical Operations department users"
        IsAssignableToRole = $false
    },
    @{
        DisplayName        = "grp-finance"
        MailNickname       = "grp-finance"
        Description        = "Finance department users"
        IsAssignableToRole = $false
    },
    @{
        DisplayName        = "grp-it-helpdesk"
        MailNickname       = "grp-it-helpdesk"
        Description        = "IT Help Desk users"
        IsAssignableToRole = $false
    },
    # RBAC groups for Azure resource access
    @{
        DisplayName        = "rbac-rg-clinical-contributors"
        MailNickname       = "rbac-rg-clinical-contributors"
        Description        = "Contributor access on rg-clinical-ops"
        IsAssignableToRole = $false
    },
    @{
        DisplayName        = "rbac-rg-finance-readers"
        MailNickname       = "rbac-rg-finance-readers"
        Description        = "Reader access on rg-finance"
        IsAssignableToRole = $false
    },
    @{
        DisplayName        = "rbac-rg-it-contributors"
        MailNickname       = "rbac-rg-it-contributors"
        Description        = "Contributor access on rg-it-admin"
        IsAssignableToRole = $false
    },
    # Role-assignable groups for Entra ID directory roles
    @{
        DisplayName        = "role-user-administrators"
        MailNickname       = "role-user-administrators"
        Description        = "Assigned Entra ID User Administrator role"
        IsAssignableToRole = $true
    },
    @{
        DisplayName        = "role-security-readers"
        MailNickname       = "role-security-readers"
        Description        = "Assigned Entra ID Security Reader role"
        IsAssignableToRole = $true
    }
)

# Tracking counters
$created = 0
$skipped = 0
$failed  = 0

# Create each group
foreach ($group in $groups) {
    try {
        # Check if group already exists
        $existing = Get-MgGroup -Filter "DisplayName eq '$($group.DisplayName)'" -ErrorAction SilentlyContinue

        if ($existing) {
            Write-Host "SKIPPED (already exists): $($group.DisplayName)" -ForegroundColor Yellow
            $skipped++
            continue
        }

        # Create the group
        $newGroup = New-MgGroup `
            -DisplayName        $group.DisplayName `
            -MailNickname       $group.MailNickname `
            -Description        $group.Description `
            -SecurityEnabled `
            -MailEnabled:$false `
            -IsAssignableToRole:$group.IsAssignableToRole

        if ($newGroup) {
            Write-Host "CREATED: $($group.DisplayName)" -ForegroundColor Green
            $created++
        } else {
            Write-Host "FAILED: $($group.DisplayName) — no object returned" -ForegroundColor Red
            $failed++
        }
    }
    catch {
        Write-Host "FAILED: $($group.DisplayName) — $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

# Summary
Write-Host ""
Write-Host "===== Summary =====" -ForegroundColor Cyan
Write-Host "Created : $created" -ForegroundColor Green
Write-Host "Skipped : $skipped" -ForegroundColor Yellow
Write-Host "Failed  : $failed"  -ForegroundColor Red
