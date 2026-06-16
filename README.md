# Azure Identity & Access Administration Lab
### Microsoft Entra ID P2 · Azure RBAC · PowerShell · Cloud Governance

---

## Project Overview

This project simulates building a secure identity and access management foundation for **Meridian Health Staffing** — a small healthcare staffing company migrating to Microsoft Azure. As the sole cloud administrator, I designed and implemented the organization's entire IAM structure from scratch using Microsoft Entra ID P2 and Azure RBAC.

The lab is built on a real Entra ID P2 tenant, executed primarily through PowerShell using the Microsoft Graph SDK, and documented as a production-ready portfolio artifact targeting Cloud/SaaS Administration and AZ-104 exam preparation.

---

## Business Scenario

Meridian Health Staffing has three departments: **Clinical Operations**, **Finance**, and **IT**. Before this project the organization had no formal IAM structure — users shared admin accounts, access was undocumented, and there was no audit trail or security baseline.

**Problems solved:**
- No formal user provisioning or deprovisioning process
- Excessive and undocumented admin privileges
- No audit trail for identity or resource access changes
- No MFA enforcement or security baseline
- No resource tagging or cost attribution
- No access review process for privileged roles or group memberships

---

## Architecture
```
AZURE TENANT: meridianhealthstaffing.onmicrosoft.com
│
├── MICROSOFT ENTRA ID (P2)
│   ├── Users
│   │   ├── aezechuk@meridianhealthstaffing (Global Admin)
│   │   ├── breakglass@meridianhealthstaffing (Emergency Admin)
│   │   ├── alice.chen@meridianhealthstaffing (Clinical Ops Manager)
│   │   ├── bob.harris@meridianhealthstaffing (Finance Analyst)
│   │   ├── carol.james@meridianhealthstaffing (IT Help Desk)
│   │   └── dan.ortiz@meridianhealthstaffing (Contractor — deprovisioned)
│   │
│   ├── Department Security Groups
│   │   ├── grp-clinical-ops
│   │   ├── grp-finance
│   │   └── grp-it-helpdesk
│   │
│   ├── RBAC Groups (Azure resource access)
│   │   ├── rbac-rg-clinical-contributors → Contributor on rg-clinical-ops
│   │   ├── rbac-rg-finance-readers       → Reader on rg-finance
│   │   └── rbac-rg-it-contributors       → Contributor on rg-it-admin
│   │
│   ├── Role-Assignable Groups (Entra ID directory roles)
│   │   ├── role-user-administrators → User Administrator (Carol James)
│   │   └── role-security-readers   → Security Reader (Bob Harris)
│   │
│   ├── Conditional Access
│   │   └── Require MFA for all users (break-glass excluded)
│   │
│   └── Identity Governance
│       ├── review-contractor-access (monthly)
│       ├── review-privileged-roles-user-admin (monthly)
│       └── review-privileged-roles-security-reader (monthly)
│
└── SUBSCRIPTION
    ├── rg-clinical-ops  (tags: dept=clinical, owner=alice.chen)
    ├── rg-finance       (tags: dept=finance, owner=bob.harris)
    └── rg-it-admin      (tags: dept=it, owner=carol.james)
```

## Skills Demonstrated

- Microsoft Entra ID P2 tenant administration
- User and group provisioning via PowerShell and Microsoft Graph SDK
- Security group design — department, RBAC, and role-assignable groups
- Azure RBAC role assignments at resource group scope (least privilege)
- Entra ID directory role assignments via role-assignable groups
- Conditional Access policy configuration with break-glass exclusion
- Identity Governance — access reviews for privileged roles and group membership
- Resource group creation and governance tagging
- Audit log and sign-in log review
- Break-glass emergency admin account configuration
- Full user deprovisioning lifecycle with PowerShell automation
- Offboarding automation with error handling and audit trail

---

## Tools & Technologies

| Tool | Purpose |
|------|---------|
| Microsoft Entra ID P2 | Identity and access management |
| Azure Portal | Resource management and administration |
| PowerShell 7 | Local scripting and automation |
| Microsoft Graph PowerShell SDK | User and group provisioning via API |
| Azure Cloud Shell | Resource group and RBAC management |
| Azure RBAC | Resource-level access control |
| Azure Monitor / Activity Log | Audit and monitoring |
| GitHub | Version control and portfolio documentation |

---

## Deliverables

| Document | Description |
|----------|-------------|
| [Admin Runbook](docs/admin-runbook.md) | Onboarding, offboarding, and tenant administration procedures |
| [Access Control Matrix](docs/access-control-matrix.md) | Full IAM inventory — users, groups, roles, and scopes |
| [Governance Policy](docs/governance-policy.md) | Tagging standards, access review schedule, policy recommendations |
| [Risk Control Table](docs/risk-control-table.md) | Risks identified, controls implemented, NIST 800-53 mapping |
| [Screenshots Index](screenshots/screenshots-index.md) | Labeled evidence of all lab configurations |

---

## Author

**Arielle Ezechukwu**
Cybersecurity · GRC · Cloud Administration
[GitHub](https://github.com/aezechuk) · [LinkedIn](#)
