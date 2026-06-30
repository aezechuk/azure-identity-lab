# Azure Identity & Access Administration Lab
### Microsoft Entra ID P2 · Azure RBAC · PowerShell · Cloud Governance

A working Microsoft Entra ID and Azure RBAC implementation built on a real P2 tenant, simulating identity governance for a small healthcare staffing company.

---

## Business Case

Meridian Health Staffing is migrating to Azure with no formal access management in place. Users share credentials, nobody can say who has access to what, and there's no audit trail. Before any workload gets deployed, identity has to be the foundation — not an afterthought.

This project builds that foundation: least-privilege access by department, separation between identity management and resource access, MFA enforcement, an emergency access path, and a process for reviewing and removing access over time.

---

## Architecture
AZURE TENANT: meridianhealthstaffing.onmicrosoft.com

│

├── ENTRA ID (P2)

│   ├── Users — 4 department users, 1 admin, 1 break-glass

│   ├── Department groups — grp-clinical-ops, grp-finance, grp-it-helpdesk

│   ├── RBAC groups — scoped Azure resource access per department

│   ├── Role-assignable groups — Entra ID directory roles (User Admin, Security Reader)

│   ├── Conditional Access — MFA required, break-glass excluded

│   └── Access Reviews — monthly, privileged roles + contractor access

│

└── SUBSCRIPTION

├── rg-clinical-ops → Contributor

├── rg-finance      → Reader

└── rg-it-admin     → Contributor

**Design principle:** every RBAC and directory role assignment goes to a group, never a user. Access changes when group membership changes — not when someone remembers to update a role assignment.

---

## How to Build This

1. **Create the tenant.** Free or trial Entra ID tenant, P2 for Conditional Access and Access Reviews.
2. **Provision users** — `scripts/create-users.ps1`. Idempotent, skips existing users.
3. **Create groups** — `scripts/create-groups.ps1`. Department, RBAC, and role-assignable groups, separated by purpose.
4. **Assign membership** — `scripts/add-group-members.ps1`.
5. **Create resource groups and tag them** — one per department, tagged for cost and ownership.
6. **Assign RBAC at resource group scope** — group to role, never user to role.
7. **Assign Entra ID directory roles to the role-assignable groups.**
8. **Configure Conditional Access** — require MFA for all users, exclude break-glass.
9. **Configure break-glass** — Global Admin, no license, credentials stored outside the daily password manager.
10. **Set up Access Reviews** — monthly cadence on privileged role groups and the contractor group.
11. **Offboard a user** — `scripts/offboard-user.ps1`. Removes groups, revokes sessions, disables the account.

Full command-level detail is in [`docs/admin-runbook.md`](docs/admin-runbook.md).

---

## What I'd Change in Production

This is a lab — small, single-region, single subscription, one admin. None of that holds at real scale. If this were a live tenant:

**Subscriptions, not resource groups, would separate environments.** One subscription per environment (dev/staging/prod) or per major business unit, not three resource groups under one subscription. Resource groups would still be the unit for tagging and RBAC scope within each subscription.

**Dynamic groups would replace manual membership** for anything rule-based — department from HR system, contractor status from job title. Manual group membership doesn't scale past a handful of users and it's the first thing that goes stale.

**The offboarding script would be triggered, not run by hand.** Right now it requires someone to remember to run it. In production that's an Azure Automation runbook fired by an HR system event, or Entra ID Lifecycle Workflows if the org has Governance licensing. A manual script is a single point of human failure.

**Audit logs would go to a Log Analytics workspace**, not sit in the 30-day Entra ID retention window. Compliance and incident response both need longer retention than the platform gives you for free.

**Access reviews would have more than one reviewer.** Right now I'm the sole reviewer for everything, which defeats part of the point of a review — a second set of eyes. Department managers should own reviews for their own teams.

**Azure Policy would actually be enforced**, not just documented. Required tags, allowed regions — these should be Deny policies at the subscription level so non-compliant resources can't be created in the first place, not caught after the fact.

**Custom RBAC roles would replace built-in Contributor** in the departments that don't need full resource management. Contributor is broad. A team that only deploys storage and app services doesn't need rights to deploy and delete everything else just because Contributor is the convenient built-in role.

---

## Documentation

- [Admin Runbook](docs/admin-runbook.md)
- [Access Control Matrix](docs/access-control-matrix.md)
- [Governance Policy](docs/governance-policy.md)
- [Risk Control Table](docs/risk-control-table.md)
- [Screenshots Index](screenshots/screenshots-index.md)

---

**Arielle Ezechukwu** — Cybersecurity, GRC, Cloud Administration
[GitHub](https://github.com/aezechuk)
