# VAXPOX WP3 - Metadata & Sequence Submission Platform

An interactive web-based platform for standardized MPOX metadata collection and sequence analysis across four African research sites (Cameroon, Côte d'Ivoire, Madagascar, Central African Republic).

## 📋 Project Overview

**Objective:** Establish standardized metadata collection practices for MPOX virus sequences across the VAXPOX WP3 molecular virology component.

**Participating Sites:**
- 🇨🇲 **CAM** - Cameroon (Centre Pasteur du Cameroun)
- 🇨🇮 **CI** - Côte d'Ivoire (Institut Pasteur de Côte d'Ivoire)
- 🇲🇬 **MADA** - Madagascar (Institut Pasteur de Madagascar)
- 🇨🇫 **RCA** - Central African Republic (Institut Pasteur de Bangui)

## 🗂️ Project Files

### Core Applications

#### **Phase 1: Data Collection & Submission** (R Shiny)
- `vaxpox_metadata_app.R` - Interactive metadata submission application
- Features: Sample data form, sequence input, export (CSV/JSON/FASTA)
- Preloaded toy metadata for testing

#### **Phase 2: Dashboard & Data Management** (Interactive HTML)
- `phase2_dashboard.html` - Web dashboard for sample overview
- Features:
  - Data filtering by country and PCR status
  - Pending data sharing requests with approval/rejection
  - Comprehensive audit logs
  - Summary statistics and sample overview
  
#### **Phase 3: Advanced Analytics** (D3.js + Chart.js)
- `phase3_dashboard.html` - Genomic analysis platform
- Features:
  - **Interactive phylogenetic tree** (D3.js) - draggable nodes, left-to-right layout
  - Quality control metrics and reports
  - GISAID publication tracking
  - SNP hotspot analysis
  - Sequence statistics by site

### Architecture & Documentation

- `phase1_architecture_diagram.html` - Interactive system architecture
  - Click Phase 2 or Phase 3 nodes to open dashboards
  - Drag nodes to reorganize layout
  - Shows data flow between countries and central Paris database

- `Data_Sharing_Architecture.md` - Comprehensive data governance proposal
  - Three implementation phases
  - Security and access control framework
  - Data processing agreements and compliance

### Supporting Files

- `Metadata_WP3_Summary.md` - Standardized metadata categories
- `toy_metadata.csv` - Example dataset for testing (10 samples)
- `VAXPOX_WP3_Metadata.pptx` - Presentation (English)
- `VAXPOX_WP3_Metadata_FR.pptx` - Presentation (French)

## 🚀 Getting Started

### View Interactive Demos

Open any HTML file directly in your browser:

1. **Architecture Overview** (recommended starting point)
   ```bash
   open phase1_architecture_diagram.html
   ```
   - Click orange (Phase 2) or green (Phase 3) nodes to explore dashboards

2. **Phase 2 Dashboard**
   ```bash
   open phase2_dashboard.html
   ```
   - Manage data sharing requests
   - View audit logs
   - Filter samples by country

3. **Phase 3 Analytics**
   ```bash
   open phase3_dashboard.html
   ```
   - Explore interactive phylogenetic tree (drag nodes!)
   - View quality control metrics
   - Track GISAID submissions
   - Analyze sequence variants

### Run R Shiny Application

```bash
R
# In R console:
shiny::runApp('vaxpox_metadata_app.R')
```

Then open `http://localhost:3838` in your browser.

## 📊 Key Features

### Metadata Standardization
All four sites collect identical core metadata:
- **Demographic:** Age, sex, residence
- **Clinical:** Symptoms, vaccination status, lesion count
- **Epidemiological:** Profession, animal/patient contact
- **Biological:** Sample type, PCR results, Ct values
- **Sequencing:** Genome sequences, quality scores

### Multi-Phase Implementation
- **Phase 1:** Centralized PostgreSQL database in Paris + Python API + country Shiny apps
- **Phase 2:** Web dashboard, data sharing requests, audit logs
- **Phase 3:** Advanced analytics, GISAID integration, phylogenetic tools

### Data Governance
- **Role-based access control** - Countries see only their data by default
- **Data sharing requests** - Explicit approval workflow
- **Audit trails** - Complete logging of all access
- **Encryption** - TLS in transit, AES-256 at rest

## 📈 Technologies

- **Frontend:** HTML5, CSS3, JavaScript, D3.js, Chart.js
- **Metadata App:** R Shiny
- **Backend (Phase 1+):** Python/FastAPI, PostgreSQL
- **Visualization:** D3.js (phylogenetic tree), Chart.js (metrics)

## 🔗 Data Sharing Architecture

The system enables secure multi-country collaboration:

```
Country A ─→ ┐
Country B ─→ │─→ [Central Database - Paris] ←─ [Phase 2: Dashboard]
Country C ─→ │                            ↓
Country D ─→ ┘                    [Phase 3: Analytics]
```

**Key Features:**
- Private data storage by default
- Explicit sharing requests with audit trail
- Option to share across all countries for consortium analyses
- Automated quality control and reporting

## 📝 Key Metadata Categories

### Selection Criteria
- **PCR Ct ≤ 30** - Only samples with sufficient viral load
- **Data Source:** National MPOX surveillance systems
- **Sample Types:** Surveillance cases, biobank samples, new cases

### Current Sequencing Technologies
| Site | Technology |
|------|-----------|
| CAM  | Illumina NextSEQ 550 |
| CI   | Oxford Nanopore (ONT) - SQK-RBK110 |
| MADA | Oxford Nanopore (ONT) - SQK-RBK110 |
| RCA  | To be specified |

## 🛡️ Security & Compliance

- GDPR-compliant data processing
- Multi-factor authentication
- Complete audit logging
- Data encryption (TLS + AES-256)
- Institutional Data Processing Agreements
- Regular security audits

## 📞 Contact

**Project Lead:** Sebastian Duchene-Garzon  
**Email:** sebastian.duchene6@gmail.com

## 📄 License

This project is part of the VAXPOX consortium. Use and distribution governed by consortium agreements.

---

**Last Updated:** 2026-04-27  
**Status:** Phase 1-3 architecture and prototypes complete

