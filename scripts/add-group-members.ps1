# ============================================
# Meridian Health Staffing — Group Membership
# Author: Arielle Ezechukwu
# Description: Adds users to their correct
#              department, RBAC, and role-assignable
#              groups in the Meridian Health tenant
# Usage: Run in PowerShell 7 after connecting
#        to Microsoft Graph
# ============================================

# Define group memberships
$memberships = @(
    # Department groups
    @{
        GroupName = "grp-clinical-ops"
        Members   = @(
            "alice.chen@meridianhealthstaffing.onmicrosoft.com",
            "dan.ortiz@meridianhealthstaffing.onmicrosoft.com"
        )
    },
    @{
        GroupName = "grp-finance"
        Members   = @(
            "bob.harris@meridianhealthstaffing.onmicrosoft.com"
        )
    },
    @{
        GroupName = "grp-it-helpdesk"
        Members   = @(
            "carol.james@meridianhealthstaffing.onmicrosoft.com"
        )
    },

    # RBAC groups
    @{
        GroupName = "rbac-rg-clinical-contributors"
        Members   = @(
            "alice.chen@meridianhealthstaffing.onmicrosoft.com",
            "dan.ortiz@meridianhealthstaffing.onmicrosoft.com"
        )
    },
    @{
        GroupName = "rbac-rg-finance-readers"
        Members   = @(
            "bob.harris@meridianhealthstaffing.onmicrosoft.com"
        )
    },
    @{
        GroupName = "rbac-rg-it-contributors"
        Members   = @(
            "carol.james@meridianhealthstaffing.onmicrosoft.com"
        )
    },

    # Role-assignable groups
    @{
        GroupName = "role-user-administrators"
        Members   = @(
            "carol.james@meridianhealthstaffing.onmicrosoft.com"
        )
    },
    @{
        GroupName = "role-security-readers"
        Members   = @(
            "bob.harris@meridianhealthstaffing.onmicrosoft.com"
        )
    }
)

# Tracking counters
$added   = 0
$skipped = 0
$failed  = 0

# Process each group
foreach ($membership in $memberships) {

    # Get the group object
    $group = Get-MgGroup -Filter "DisplayName eq '$($membership.GroupName)'" -ErrorAction SilentlyContinue

    if (-not $group) {
        Write-Host "GROUP NOT FOUND: $($membership.GroupName)" -ForegroundColor Red
        $failed++
        continue
    }

    # Process each member
    foreach ($upn in $membership.Members) {
        try {
            # Get the user object
            $user = Get-MgUser -Filter "UserPrincipalName eq '$upn'" -ErrorAction SilentlyContinue

            if (-not $user) {
                Write-Host "USER NOT FOUND: $upn" -ForegroundColor Red
                $failed++
                continue
            }

            # Check if already a member
            $existingMember = Get-MgGroupMember -GroupId $group.Id | Where-Object { $_.Id -eq $user.Id }

            if ($existingMember) {
                Write-Host "SKIPPED (already a member): $upn → $($membership.GroupName)" -ForegroundColor Yellow
                $skipped++
                continue
            }

            # Add user to group
            New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id

            Write-Host "ADDED: $upn → $($membership.GroupName)" -ForegroundColor Green
            $added++
        }
        catch {
            Write-Host "FAILED: $upn → $($membership.GroupName) — $($_.Exception.Message)" -ForegroundColor Red
            $failed++
        }
    }
}

# Summary
Write-Host ""
Write-Host "===== Summary =====" -ForegroundColor Cyan
Write-Host "Added   : $added"   -ForegroundColor Green
Write-Host "Skipped : $skipped" -ForegroundColor Yellow
Write-Host "Failed  : $failed"  -ForegroundColor Red
