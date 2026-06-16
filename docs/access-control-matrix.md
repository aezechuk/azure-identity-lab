# Access Control Matrix
## Meridian Health Staffing — Azure Identity Lab

**Last Updated:** June 2026  
**Owner:** Arielle Ezechukwu  
**Purpose:** Single source of truth for all identity and access assignments in the Meridian Health Staffing Azure tenant.

---

## User — Group Membership

| User | Display Name | Department | Department Group | RBAC Group | Role-Assignable Group |
|------|-------------|------------|-----------------|------------|----------------------|
| aezechuk | Admin | IT | None | None (direct) | None |
| breakglass | Break Glass | IT | None | None | None |
| alice.chen | Alice Chen | Clinical Operations | grp-clinical-ops | rbac-rg-clinical-contributors | None |
| bob.harris | Bob Harris | Finance | grp-finance | rbac-rg-finance-readers | role-security-readers |
| carol.james | Carol James | IT | grp-it-helpdesk | rbac-rg-it-contributors | role-user-administrators |
| dan.ortiz | Dan Ortiz | Clinical Operations | grp-clinical-ops (removed) | rbac-rg-clinical-contributors (removed) | None |

---

## Azure RBAC Assignments

| Group | Role | Scope | Scope Type | Justification |
|-------|------|-------|------------|---------------|
| rbac-rg-clinical-contributors | Contributor | rg-clinical-ops | Resource Group | Clinical team manages their own resources |
| rbac-rg-finance-readers | Reader | rg-finance | Resource Group | Finance needs visibility only, not modify rights |
| rbac-rg-it-contributors | Contributor | rg-it-admin | Resource Group | IT manages lab infrastructure |
| aezechuk (direct) | Owner | Subscription | Subscription | Global admin requires full subscription access |

---

## Entra ID Directory Role Assignments

| Group | Directory Role | Members | Justification |
|-------|---------------|---------|---------------|
| role-user-administrators | User Administrator | carol.james | IT Help Desk manages user accounts and passwords |
| role-security-readers | Security Reader | bob.harris | Finance auditor reads security reports read-only |
| N/A (direct) | Global Administrator | aezechuk | Primary tenant administrator |
| N/A (direct) | Global Administrator | breakglass | Emergency admin — break-glass account |

---

## Conditional Access

| Policy | Included Users | Excluded Users | Condition | Grant Control |
|--------|---------------|----------------|-----------|---------------|
| Require MFA for all users | All users | aezechuk, breakglass | Any location, any app | Require MFA |

---

## Deprovisioned Users

| User | Offboard Date | Method | Status | Hard Delete Date |
|------|--------------|--------|--------|-----------------|
| dan.ortiz | June 2026 | offboard-user.ps1 | Account disabled, sessions revoked, groups removed | July 15, 2026 |

---

## Access Review Schedule

| Review Name | Scope | Frequency | Reviewer | Purpose |
|-------------|-------|-----------|----------|---------|
| review-contractor-access | rbac-rg-clinical-contributors | Monthly | Admin | Verify contractor access is still required |
| review-privileged-roles-user-admin | role-user-administrators | Monthly | Admin | Verify User Administrator assignments |
| review-privileged-roles-security-reader | role-security-readers | Monthly | Admin | Verify Security Reader assignments |

---

## Notes

- All Azure RBAC roles are assigned to groups, never directly to users (except admin account at subscription scope)
- Role-assignable groups are used for Entra ID directory roles to enable group-based lifecycle management
- Break-glass account is excluded from all Conditional Access policies
- Dan Ortiz account retained for 30-day hold per data retention policy before hard delete
- Access reviews configured in Entra ID Identity Governance and run monthly
