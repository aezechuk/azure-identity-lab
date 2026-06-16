# Screenshots Index

## Phase 1 — Setup
| # | Filename | What It Shows |
|---|----------|---------------|
| 01 | [01-azure-portal-home.png](01-azure-portal-home.png) | Azure portal home showing subscription and tenant name |
| 02 | [02-cost-budget-alert.png](02-cost-budget-alert.png) | Budget alert configuration at $5/month |
| 03 | [03-entra-id-overview.png](03-entra-id-overview.png) | Entra ID overview showing tenant ID, domain, and P2 edition |

## Phase 2 — Users, Groups, RBAC
| # | Filename | What It Shows |
|---|----------|---------------|
| 04 | [04-user-list.png](04-user-list.png) | All users in Entra ID including admin and break-glass |
| 05 | [05-cloudshell-user-list.png](05-cloudshell-user-list.png) | PowerShell output showing all users via Get-MgUser |
| 06 | [06-entra-groups-list.png](06-entra-groups-list.png) | All 8 groups in Entra ID |
| 07 | [07-rbac-group-members.png](07-rbac-group-members.png) | Member list of rbac-rg-clinical-contributors |
| 08 | [08-resource-groups-list.png](08-resource-groups-list.png) | All three resource groups in East US |
| 09 | [09-iam-clinical-contributor.png](09-iam-clinical-contributor.png) | IAM role assignment on rg-clinical-ops showing Contributor |
| 10 | [10-iam-finance-reader.png](10-iam-finance-reader.png) | IAM role assignment on rg-finance showing Reader |
| 11 | [11-iam-it-contributor.png](11-iam-it-contributor.png) | IAM role assignment on rg-it-admin showing Contributor |
| 12 | [12-entra-role-carol.png](12-entra-role-carol.png) | User Administrator role assigned to role-user-administrators group |
| 13 | [13-entra-role-bob.png](13-entra-role-bob.png) | Security Reader role assigned to role-security-readers group |

## Phase 3 — Governance, Security & Logging
| # | Filename | What It Shows |
|---|----------|---------------|
| 14 | [14-rg-tags.png](14-rg-tags.png) | Tags applied to resource groups |
| 15 | [15-security-defaults-disabled.png](15-security-defaults-disabled.png) | Security Defaults disabled in favor of Conditional Access |
| 16 | [16-conditional-access-policy.png](16-conditional-access-policy.png) | CA policy requiring MFA for all users with break-glass excluded |
| 17 | [17-audit-logs.png](17-audit-logs.png) | Entra ID audit logs showing user and group activity |
| 18 | [18-signin-logs.png](18-signin-logs.png) | Sign-in logs showing multiple user sign-ins |
| 19 | [19-activity-log.png](19-activity-log.png) | Azure Monitor activity log showing resource group creation |
| 20 | [20-breakglass-account.png](20-breakglass-account.png) | Break-glass account with Global Admin role assigned |
| 21 | [21-access-reviews.png](21-access-reviews.png) | Identity Governance access reviews dashboard showing all 3 reviews |

## Phase 4 — Deprovisioning
| # | Filename | What It Shows |
|---|----------|---------------|
| 22 | [22-offboard-script-output.png](22-offboard-script-output.png) | Clean offboarding script output showing all 4 steps successful |
| 23 | [23-dan-account-disabled.png](23-dan-account-disabled.png) | Dan Ortiz account showing Account Enabled = No |
| 24 | [24-dan-audit-log.png](24-dan-audit-log.png) | Audit log entries showing Dan's offboarding actions |
