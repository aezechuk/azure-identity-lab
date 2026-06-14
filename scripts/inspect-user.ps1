$upn = "bob.harris@meridianhealthstaffing.onmicrosoft.com"
$user = Get-MgUser -Filter "UserPrincipalName eq '$upn'"
Write-Host "`n===== User Details =====" -ForegroundColor Cyan
Write-Host "Name       : $($user.DisplayName)"
Write-Host "UPN        : $($user.UserPrincipalName)"
Write-Host "Department : $($user.Department)"
Write-Host "Job Title  : $($user.JobTitle)"
Write-Host "Enabled    : $($user.AccountEnabled)"
# Get group memberships
$groups = Get-MgUserTransitiveMemberOf -UserId $user.Id
Write-Host "`n===== Group Memberships =====" -ForegroundColor Cyan
foreach ($group in $groups) {
    Write-Host "  - $($group.AdditionalProperties['displayName'])"
}
# Get Entra ID directory role assignments
$roles = Get-MgUserTransitiveMemberOf -UserId $user.Id | Where-Object { $_.AdditionalProperties['@odata.type'] -eq '#microsoft.graph.directoryRole' }
Write-Host "`n===== Entra ID Directory Roles =====" -ForegroundColor Cyan
if ($roles) {
    foreach ($role in $roles) {
        Write-Host "  - $($role.AdditionalProperties['displayName'])" -ForegroundColor Yellow
    }
} else {
    Write-Host "  None assigned" -ForegroundColor Gray
}
