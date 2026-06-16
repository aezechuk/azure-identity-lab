# Admin Runbook
## Meridian Health Staffing — Azure Identity Lab

**Last Updated:** June 2026  
**Owner:** Arielle Ezechukwu  
**Purpose:** Step-by-step procedures for administering the Meridian Health Staffing Azure tenant. Written as a handoff document for any administrator managing this environment.

---

## Tenant Overview

| Field | Value |
|-------|-------|
| Tenant Name | Meridian Health Staffing |
| Domain | meridianhealthstaffing.onmicrosoft.com |
| Entra ID Edition | P2 |
| Primary Admin | aezechuk@meridianhealthstaffing.onmicrosoft.com |
| Break-Glass Account | breakglass@meridianhealthstaffing.onmicrosoft.com |
| Credential Storage | Stored separately from daily-use accounts |
| Azure Region | East US |

---

## Tools Required

| Tool | Purpose | Access |
|------|---------|--------|
| Azure Portal | Primary administration interface | portal.azure.com |
| PowerShell 7 | Local scripting and automation | Install from aka.ms/powershell |
| Microsoft Graph SDK | Identity management via API | Install-Module Microsoft.Graph |
| Azure Cloud Shell | Browser-based CLI, Az module pre-installed | Portal top bar >_ icon |

### Connecting to Microsoft Graph (local PowerShell)

```powershell
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "RoleManagement.ReadWrite.Directory", "Directory.AccessAsUser.All"
```

### Connecting to Azure (Cloud Shell)
Cloud Shell is pre-authenticated through the portal session. No additional connection steps required for Az module commands.

---

## User Onboarding

### Standard Onboarding Procedure

1. Run the user provisioning script:
```powershell
.\create-users.ps1
```
Add the new user to the `$users` array before running. The script will skip existing users and only create new ones.

2. Add the user to their department group and RBAC group:
```powershell
.\add-group-members.ps1
```
Update the `$memberships` array to include the new user in the correct groups.

3. Verify the user was created and assigned correctly:
```powershell
.\inspect-user.ps1 -UPN "newuser@meridianhealthstaffing.onmicrosoft.com"
```

4. Communicate the temporary password to the user securely. The script generates a random password and displays it in the terminal — copy it and deliver via a secure one-time link or in person. Never send via plain email.

5. Confirm the user completes MFA registration within 24 hours. The Conditional Access policy will prompt them on first sign-in.

### Group Assignment Reference

| Department | Department Group | RBAC Group | Azure Access |
|------------|-----------------|------------|--------------|
| Clinical Operations | grp-clinical-ops | rbac-rg-clinical-contributors | Contributor on rg-clinical-ops |
| Finance | grp-finance | rbac-rg-finance-readers | Reader on rg-finance |
| IT | grp-it-helpdesk | rbac-rg-it-contributors | Contributor on rg-it-admin |

---

## User Offboarding

### Standard Offboarding Procedure

Run the offboarding script immediately upon receiving termination notice:

```powershell
.\offboard-user.ps1 -UPN "user@meridianhealthstaffing.onmicrosoft.com"
```

The script executes the following steps automatically:
1. Removes user from all group memberships
2. Revokes all active sessions and tokens
3. Disables the account (blocks sign-in)
4. Verifies and displays final account state

After running the script:
- Reset the password manually in the portal: **Entra ID → Users → [user] → Reset password**
- Notify the user's manager to transfer ownership of any shared resources
- Log the offboarding date and schedule hard delete for 30 days later

### Offboarding Automation — Tool Selection Rationale

User offboarding is handled via PowerShell script (Level 1 automation). This was selected as appropriate for Meridian's size and maturity level.

| Level | Approach | Selected |
|-------|----------|---------|
| 1 | PowerShell script — manual trigger | ✅ Current |
| 2 | Azure Automation runbook — event trigger | Future |
| 3 | Entra ID Lifecycle Workflows — HR integration | Future |
| 4 | Full ITSM integration — zero manual steps | Future |

As the organization grows and integrates an HR system, upgrading to Level 3 Lifecycle Workflows is recommended.

### 30-Day Retention Policy

Accounts are not hard deleted immediately. The account remains in a disabled state for 30 days to support:
- Data recovery requests
- Legal hold requirements
- Access to shared mailboxes or files

After 30 days: **Entra ID → Users → [user] → Delete**

The deleted account moves to a soft-delete state for an additional 30 days before permanent deletion.

---

## Group Management

### Adding a Member to a Group

```powershell
$user = Get-MgUser -Filter "UserPrincipalName eq 'user@meridianhealthstaffing.onmicrosoft.com'"
$group = Get-MgGroup -Filter "DisplayName eq 'group-name'"
New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id
```

### Removing a Member from a Group

```powershell
$user = Get-MgUser -Filter "UserPrincipalName eq 'user@meridianhealthstaffing.onmicrosoft.com'"
$group = Get-MgGroup -Filter "DisplayName eq 'group-name'"
Remove-MgGroupMemberByRef -GroupId $group.Id -DirectoryObjectId $user.Id
```

### Viewing All Members of a Group

```powershell
$group = Get-MgGroup -Filter "DisplayName eq 'group-name'"
Get-MgGroupMember -GroupId $group.Id | ForEach-Object {
    Get-MgUser -UserId $_.Id | Select-Object DisplayName, UserPrincipalName
}
```

### Creating a New Group

Update the `$groups` array in `create-groups.ps1` and rerun the script. The duplicate check will skip existing groups and only create new ones.

---

## RBAC Management

### Assigning a New RBAC Role

```powershell
$groupId = (Get-AzADGroup -DisplayName "group-name").Id
New-AzRoleAssignment `
    -ObjectId           $groupId `
    -RoleDefinitionName "Contributor" `
    -ResourceGroupName  "rg-name"
```

### Verifying Role Assignments on a Resource Group

```powershell
Get-AzRoleAssignment -ResourceGroupName "rg-name" | Select-Object DisplayName, RoleDefinitionName, Scope
```

### Removing a Role Assignment

```powershell
Remove-AzRoleAssignment `
    -ObjectId           $groupId `
    -RoleDefinitionName "Contributor" `
    -ResourceGroupName  "rg-name"
```

**Best practice:** Always assign RBAC roles to groups, never directly to individual users. This ensures access is managed through group membership and remains auditable.

---

## Break-Glass Account

### Purpose
The break-glass account (`breakglass@meridianhealthstaffing.onmicrosoft.com`) is an emergency admin account used only when normal admin accounts are inaccessible due to:
- Lost or unavailable MFA device
- Compromised primary admin account
- Conditional Access misconfiguration locking out all admins

### Configuration
- Role: Global Administrator
- MFA: Not enforced — excluded from all Conditional Access policies
- License: None assigned — cloud-only account
- Credential storage: Stored separately from daily-use password manager

### Usage Procedure
1. Retrieve credentials from secure storage
2. Sign in at portal.azure.com in a private browser window
3. Resolve the issue that caused the lockout
4. Sign out immediately after the issue is resolved
5. Rotate the break-glass password after every use
6. Document the incident — date, reason for use, actions taken

### Monitoring
Any sign-in by the break-glass account should be treated as a security event requiring immediate review. Check **Entra ID → Monitoring → Sign-in logs** filtered to the break-glass UPN regularly.

### Testing
Test the break-glass account quarterly to verify credentials remain valid. Document each test in the audit log.

---

## Conditional Access

### Current Policy
**Policy name:** Require multifactor authentication for all users  
**State:** On  
**Included:** All users  
**Excluded:** aezechuk (admin), breakglass  
**Grant control:** Require MFA

### Adding a New Exclusion
Only add exclusions with documented business justification. Exclusions increase risk and should be reviewed quarterly.

**Entra ID → Security → Conditional Access → [policy] → Users → Exclude → Add user**

---

## Access Reviews

### Current Reviews

| Review | Scope | Frequency |
|--------|-------|-----------|
| review-contractor-access | rbac-rg-clinical-contributors | Monthly |
| review-privileged-roles-user-admin | role-user-administrators | Monthly |
| review-privileged-roles-security-reader | role-security-readers | Monthly |

### Completing a Review
1. Navigate to **Entra ID → Identity Governance → Access Reviews**
2. Click the active review
3. For each member select **Approve** or **Deny**
4. Provide justification for each decision
5. Submit the review before the expiration date

### If Access is Denied
Auto-apply is enabled — access is removed automatically when the review closes. No manual action required.

### If a Review is Missed
Access is not automatically removed (No change setting). Escalate to Global Admin for manual review and document the missed review.

---

## Audit Log Review

### Entra ID Audit Logs
**Location:** Entra ID → Monitoring → Audit Logs  
**Retention:** 30 days (P2)  
**Review frequency:** Weekly for admin accounts, monthly for all others

Useful filters:
- Category: UserManagement, GroupManagement, RoleManagement
- Initiated by: specific admin UPN
- Target: specific user UPN

### Sign-in Logs
**Location:** Entra ID → Monitoring → Sign-in Logs  
**Review frequency:** Weekly for admin and break-glass accounts

Watch for:
- Failed sign-in attempts
- Sign-ins from unexpected locations
- Any sign-in by the break-glass account

### Azure Activity Log
**Location:** Monitor → Activity Log  
**Covers:** Subscription-level resource operations  
**Review frequency:** Monthly

---

## Troubleshooting

| Issue | Likely Cause | Resolution |
|-------|-------------|------------|
| User cannot sign in | Account disabled or MFA not registered | Check account status in Entra ID. Verify MFA registration. |
| User cannot access resource group | Not in correct RBAC group | Run inspect-user.ps1 to verify group memberships. Add to correct RBAC group. |
| Script returns 403 Forbidden | Insufficient Graph scopes | Disconnect and reconnect with required scopes. See Tools Required section. |
| Access review not showing members | Group is empty | Verify group membership before starting review. |
| Break-glass sign-in blocked | Account may have been accidentally included in CA policy | Sign in via another admin account and check CA exclusions. |
