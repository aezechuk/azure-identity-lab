# Risk Control Table
## Meridian Health Staffing — Azure Identity Lab

**Last Updated:** June 2026  
**Owner:** Arielle Ezechukwu  
**Framework:** NIST SP 800-53 Rev. 5  
**Purpose:** Documents risks identified in the Meridian Health Staffing scenario, controls implemented, evidence collected, and mapping to NIST 800-53 security controls.

---

## Risk Control Matrix

| # | Risk | Likelihood | Impact | Control Implemented | NIST 800-53 | Evidence |
|---|------|------------|--------|---------------------|-------------|----------|
| 1 | Excessive admin privileges — users with more access than needed | High | High | Least-privilege RBAC at resource group scope. Finance received Reader, not Contributor. No subscription-level assignments except admin account. | AC-6 (Least Privilege) | Screenshots 09, 10, 11 |
| 2 | No audit trail for identity and resource changes | High | Medium | Entra ID Audit Logs and Azure Activity Log reviewed and captured. All admin actions generate audit entries. | AU-2 (Event Logging) | Screenshots 17, 18, 19, 24 |
| 3 | Weak or no MFA enforcement on user accounts | Medium | High | Security Defaults disabled and replaced with Conditional Access policy requiring MFA for all users. Break-glass excluded. | IA-5 (Authenticator Management) | Screenshots 15, 16 |
| 4 | Orphaned accounts — ex-employees or contractors retaining active access | High | High | Formal offboarding checklist executed via PowerShell script. Dan Ortiz deprovisioned: groups removed, sessions revoked, account disabled. 30-day retention hold documented. | AC-2 (Account Management) | Screenshots 22, 23, 24 |
| 5 | No emergency admin access if primary admin is locked out | Low | Critical | Break-glass account configured with Global Administrator role. Excluded from all Conditional Access policies. Credentials stored separately from daily-use accounts. | CP-2 (Contingency Plan) | Screenshot 20 |
| 6 | Untagged resources — no cost attribution or ownership tracking | Medium | Medium | Mandatory tagging policy documented. All resource groups tagged at creation with environment, department, owner, project, and cost-center. | CM-8 (Information System Component Inventory) | Screenshot 14 |
| 7 | Individual RBAC assignments creating unmanageable access sprawl | High | Medium | All RBAC roles assigned to groups, never directly to users (except admin at subscription scope). Group-based lifecycle management ensures access changes with membership. | AC-2 (Account Management) | Screenshots 06, 07, 09, 10, 11 |
| 8 | Privileged directory roles assigned without review process | Medium | High | Role-assignable groups used for Entra ID directory roles. Monthly access reviews configured in Identity Governance for all privileged role groups. | AC-2 (Account Management), AC-6 (Least Privilege) | Screenshots 12, 13, 21 |
| 9 | No separation between Entra ID directory access and Azure resource access | Medium | High | Entra ID roles and Azure RBAC roles managed as separate systems. Directory roles assigned via role-assignable groups. Resource access assigned via RBAC groups at RG scope. | AC-5 (Separation of Duties) | Screenshots 06, 12, 13 |
| 10 | Contractor access not reviewed on a regular cadence | High | High | Monthly access review configured specifically for rbac-rg-clinical-contributors covering contractor access. Auto-apply enabled to remove access if denied. | AC-2 (Account Management) | Screenshot 21 |

---

## Risk Rating Definitions

| Rating | Definition |
|--------|------------|
| Critical | Immediate threat to tenant security or compliance |
| High | Significant risk requiring prompt remediation |
| Medium | Moderate risk that should be addressed in next cycle |
| Low | Minor risk with limited impact if exploited |

---

## Control Effectiveness Summary

| Control Category | Controls Implemented | Status |
|-----------------|---------------------|--------|
| Access Control (AC) | Least privilege, group-based RBAC, account management, separation of duties | ✅ Implemented |
| Audit & Accountability (AU) | Entra ID audit logs, sign-in logs, activity log | ✅ Implemented |
| Identification & Authentication (IA) | MFA via Conditional Access, break-glass account | ✅ Implemented |
| Configuration Management (CM) | Resource tagging, governance policy documentation | ✅ Implemented |
| Contingency Planning (CP) | Break-glass account, emergency access procedure | ✅ Implemented |

---

## Residual Risks & Recommendations

| Risk | Residual Risk | Recommendation |
|------|--------------|----------------|
| MFA bypass via legacy authentication protocols | Low — CA policy blocks legacy auth | Monitor sign-in logs for legacy auth attempts |
| Break-glass account credential exposure | Low — credentials stored separately | Rotate break-glass password quarterly |
| Audit log retention limited to 7 days (Free tier) | Medium — P2 extends to 30 days | Configure Log Analytics workspace for long-term retention |
| No Azure Policy enforcement on resource tagging | Medium — manual tagging in place | Assign Deny policy for untagged resources before workload deployment |
| Single reviewer for all access reviews | Medium — admin is sole reviewer | Assign department managers as secondary reviewers as org grows |
