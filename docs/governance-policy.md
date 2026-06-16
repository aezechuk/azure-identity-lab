# Governance Policy
## Meridian Health Staffing — Azure Identity Lab

**Last Updated:** June 2026  
**Owner:** Arielle Ezechukwu  
**Purpose:** Documents the governance standards, tagging policy, access review schedule, and Azure Policy recommendations for the Meridian Health Staffing Azure tenant.

---

## Tagging Policy

All resource groups must have the following tags applied at creation. Resources inherit tags from their resource group where possible. Untagged resources are non-compliant.

| Tag Key | Required | Description | Example |
|---------|----------|-------------|---------|
| environment | Yes | Deployment environment | lab, dev, staging, prod |
| department | Yes | Owning department | clinical, finance, it |
| owner | Yes | Primary owner UPN | alice.chen |
| project | Yes | Project or workload name | meridian-iam-lab |
| cost-center | Yes | Cost attribution code | CC-CLINICAL, CC-FINANCE, CC-IT |

### Current Tag Assignments

| Resource Group | environment | department | owner | project | cost-center |
|---------------|-------------|------------|-------|---------|-------------|
| rg-clinical-ops | lab | clinical | alice.chen | meridian-iam-lab | CC-CLINICAL |
| rg-finance | lab | finance | bob.harris | meridian-iam-lab | CC-FINANCE |
| rg-it-admin | lab | it | carol.james | meridian-iam-lab | CC-IT |

---

## Access Review Schedule

Access reviews are configured in Entra ID Identity Governance and run automatically on a monthly cadence. Reviewers are notified by email at the start of each review period and reminded before expiration.

| Review Name | Scope | Frequency | Duration | Reviewer | Auto-Apply | If No Response |
|-------------|-------|-----------|----------|----------|------------|----------------|
| review-contractor-access | rbac-rg-clinical-contributors | Monthly | 7 days | Admin | Yes | No change |
| review-privileged-roles-user-admin | role-user-administrators | Monthly | 7 days | Admin | Yes | No change |
| review-privileged-roles-security-reader | role-security-readers | Monthly | 7 days | Admin | Yes | No change |

### Access Review Procedures

**When reviewing group membership:**
- Confirm each member still requires the access the group provides
- Require written justification for continued access
- Remove any members whose role has changed or who have left the organization
- Document any exceptions with business justification

**If a reviewer does not respond:**
- Access is not automatically removed (No change setting)
- Escalate to Global Admin for manual review
- Document the missed review in the audit log

---

## Offboarding Automation — Tool Selection Rationale

User offboarding at Meridian Health Staffing is handled via a PowerShell script (`offboard-user.ps1`) using the Microsoft Graph SDK. This approach was selected based on the organization's size and maturity level.

| Level | Approach | Best For | Selected |
|-------|----------|---------|---------|
| 1 | PowerShell script (manual trigger) | Small orgs, lean IT teams | ✅ Yes |
| 2 | Azure Automation runbook (scheduled/event trigger) | Mid-size orgs | No |
| 3 | Entra ID Lifecycle Workflows | Orgs with Governance licensing and HR integration | No |
| 4 | Full ITSM integration (ServiceNow + Logic Apps) | Large enterprises | No |

**Rationale:** Level 1 was selected because it is cost effective, fully auditable, and appropriate for Meridian's size. The script executes all critical offboarding steps automatically and generates clear terminal output for audit purposes. As the organization grows and integrates an HR system, upgrading to Level 3 Lifecycle Workflows would be the recommended next step.

---

## Azure Policy Recommendations

These policies are recommended for production environments where compute and storage resources will be deployed. They were not assigned in this lab because no resources were deployed that would trigger them, but they represent the governance controls that would be implemented before onboarding workloads.

| Policy Name | Effect | Scope | Justification |
|-------------|--------|-------|---------------|
| Require a tag on resource groups | Deny | Subscription | Enforces mandatory tagging for cost attribution and ownership tracking |
| Allowed locations | Deny | Subscription | Restricts resources to East US only for data residency compliance |
| Audit VMs that do not use managed disks | Audit | Subscription | Baseline compute security requirement |
| Require a tag on resources | Deny | Subscription | Ensures individual resources inherit governance tags |

---

## Cost Governance

- A $5/month budget alert is configured on the subscription
- All resource groups are tagged with cost-center for attribution
- This lab uses identity and RBAC features only — no compute, storage, or networking resources were deployed
- Expected monthly cost: $0

---

## Security Baseline

| Control | Implementation | Status |
|---------|---------------|--------|
| MFA for all users | Conditional Access policy | ✅ Active |
| Security Defaults | Disabled — replaced by Conditional Access | ✅ Configured |
| Break-glass account | Global Admin, excluded from CA, credentials stored separately | ✅ Configured |
| Least privilege RBAC | Group-based assignments at resource group scope | ✅ Implemented |
| Audit logging | Entra ID audit logs and Azure Activity Log | ✅ Active |
| Access reviews | Monthly reviews for privileged roles and RBAC groups | ✅ Active |

---

## Data Residency

All resources are deployed to **East US** region. No cross-region replication is configured. This aligns with a single-region deployment model appropriate for a lab environment. Production environments should consider geo-redundancy based on business continuity requirements.
