# VAXPOX WP3 - Multi-Jurisdictional Data Sharing Architecture

## Overview
Centralized data repository in Paris with role-based access control, allowing each country to maintain data sovereignty while enabling optional cross-country collaboration.

---

## System Architecture

### 1. **Central Repository (Paris)**
- **Database:** PostgreSQL with encrypted sensitive fields
- **Location:** Secure institutional server in Paris (Institut Pasteur)
- **Backup:** Redundant backups in EU data centers (GDPR compliant)

### 2. **Access Control Framework**

#### Role-Based Access Control (RBAC)
```
Country Admin (CAM, CI, MADA, RCA)
  ├── Create/edit samples from their country
  ├── View own country's data
  ├── Manage data sharing permissions
  ├── Request access to other countries' data

Data Custodian (Project Lead - Paris)
  ├── View all data across countries
  ├── Approve cross-country sharing requests
  ├── Manage compliance and audit logs

Consortium Coordinator
  ├── Manage user accounts and permissions
  └── Coordinate shared analyses (opt-in)
```

#### Data Access Tiers
1. **Private (Default):** Only the submitting country's team can access
2. **Shared (Requested):** Approved sharing with specific countries
3. **Consortium (Opt-in):** All participating countries can access (rare, explicit consent)

---

## Implementation Strategy

### Option A: **Web-Based Platform (Recommended)**

**Technology Stack:**
- **Frontend:** R Shiny or Python Dash (can embed existing metadata app)
- **Backend:** FastAPI/Django with authentication
- **Database:** PostgreSQL
- **Authentication:** LDAP/Active Directory + institutional SSO or OAuth
- **Data Encryption:** TLS in transit, AES-256 for sensitive fields at rest

**Features:**
- Each country has their own login credentials
- Dashboard shows only authorized data
- Data submission form submits to Paris database
- Audit trail logs all access and modifications
- Built-in data sharing request workflow
- Download capability (CSV, JSON) for authorized data

**Architecture Diagram:**
```
Country Site A (Shiny App)  →  \
Country Site B (Shiny App)  →  → [Central PostgreSQL in Paris]
Country Site C (Shiny App)  →  /     with Role-Based Access Control
Country Site D (Shiny App)  →  \
                                  ↓
                          [Audit Logging]
                                  ↓
                          [Data Encryption]
```

---

### Option B: **Lightweight Approach (Simpler)**

If full infrastructure is overkill, use:
- **R/Python script** that each country runs locally
- **Encrypted file sharing** via institutional servers (sFTP, or Nextcloud)
- **Master CSV/JSON** in Paris that each country can append to
- **Git-based versioning** of metadata with branch per country

**Workflow:**
1. Each country prepares metadata locally using Shiny app
2. Exports to encrypted file
3. Uploads to shared server (with password/token)
4. Paris validates and integrates into master database
5. Countries can download approved shared data via API call

---

## Data Governance Framework

### Sharing Workflow
```
Country A collects sample → Stored privately in Paris
        ↓
Country B requests access to Country A's samples
        ↓
Country A approves sharing (optional conditions: subregions, de-identified)
        ↓
Country B gains read-only access to approved subset
        ↓
Audit log records: who, what, when, why
```

### Compliance & Security

| Aspect | Implementation |
|--------|-----------------|
| **Encryption** | AES-256 for sensitive fields; TLS for all transfers |
| **Authentication** | Multi-factor authentication (MFA) for institutional admins |
| **Audit Trail** | Complete log of access, modifications, data sharing approvals |
| **Data Minimization** | Only necessary fields transmitted; option to de-identify |
| **Retention** | Clear data retention policy (per country or institutional law) |
| **Backup/Recovery** | Encrypted backups in EU; disaster recovery plan |
| **GDPR/Local Law** | Data Processing Agreement (DPA) signed by all parties |

---

## Recommended Implementation: Hybrid Approach

### Phase 1: **Simple & Functional (Weeks 1-2)**
1. Set up PostgreSQL in Paris at secure institutional server
2. Create Python/R data API with authentication
3. Modify Shiny app to:
   - Include login (username/country code)
   - Submit data to Paris API (via `httr` or `requests`)
   - Retrieve only country's own data on load
4. Manual data sharing approval via email to Sebastian

### Phase 2: **Enhanced (Weeks 3-4)**
1. Add web dashboard for:
   - Viewing all samples (filtered by country)
   - Data sharing request interface
   - Audit log viewer
2. Automated data sharing approval system
3. API endpoint for download (CSV, JSON)

### Phase 3: **Mature (Weeks 5+)**
1. Advanced analytics dashboard (shared analyses)
2. Automated quality control reports
3. Publication-ready data export
4. Integration with sequence repository (GISAID, NCBI)

---

## Security Checklist

- [ ] Database encryption at rest
- [ ] TLS/HTTPS for all API calls
- [ ] Authentication: institutional SSO or OAuth
- [ ] Role-based access control (RBAC) enforced at database level
- [ ] Audit logging on all data access/modifications
- [ ] Data Processing Agreement signed by all 4 countries
- [ ] Backup strategy (redundant, encrypted, off-site)
- [ ] Incident response plan
- [ ] Regular security audits
- [ ] User access reviews (quarterly)

---

## Estimated Infrastructure Costs

| Component | Cost (Annual) |
|-----------|---------------|
| PostgreSQL server (Paris) | €500–2,000 |
| API hosting | €0–1,000 (if self-hosted) |
| SSL certificates | €0–200 |
| Backups/DR | €500–1,500 |
| **Total** | **€1,500–4,700** |

---

## Next Steps

1. **Confirm** which implementation approach fits your timeline and resources
2. **Identify** institutional IT/database administrator in Paris
3. **Draft** Data Processing Agreement with country representatives
4. **Create** detailed API specification (endpoints, authentication, data schema)
5. **Test** with pilot submissions from one country

---

## Questions to Clarify

1. Who manages the Paris database (your lab, central IT, external vendor)?
2. Do all countries have institutional SSO/LDAP systems?
3. What is the expected data volume (samples/year)?
4. Are there strict data sovereignty laws in any of the four countries?
5. Timeline for launch?
