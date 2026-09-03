# A1: Relational Data Foundation in SAP HANA Cloud

---

**🌐 Language / Idioma:** [🇧🇷 Português](../BR/01-a1-fundacao-de-dados-relacionais.md) | 🇺🇸 **English**

---

[⬆️ README](../../../README.en.md) | [➡️ A2: SAP Enterprise Structure](./02-a2-sap-enterprise-structure.en.md)

---

## 🎯 Executive overview

A1 created a governed industrial relational foundation in SAP HANA Cloud. Five `COLUMN` tables, a deterministic Industrial Data Universe, and a generation, validation, loading, and auditing chain produced **3,715 records**, **zero orphans**, and **zero duplicates**. All data is synthetic.

---

## 🏗️ Architecture and flows

```mermaid
flowchart LR
    B["Blueprint v1"]:::a --> C["Config + Contract + Rules"]:::b --> G["Foundation Generator"]:::c
    G --> V{"Validation Engine"}:::d
    V -->|PASSED| S["SQL Load Generator"]:::c --> H[("SAP HANA Cloud LAB_A1")]:::e
    H --> A["Post-load Audits"]:::a
    V -->|FAILED| G
    classDef a fill:#E8F1FF,stroke:#2563EB,color:#123A70,stroke-width:2px;
    classDef b fill:#FFF3D8,stroke:#F59E0B,color:#8A4B00,stroke-width:2px;
    classDef c fill:#F3E8FF,stroke:#9333EA,color:#581C87,stroke-width:2px;
    classDef d fill:#FFF1F2,stroke:#E11D48,color:#881337,stroke-width:2px;
    classDef e fill:#E7F8EC,stroke:#16A34A,color:#14532D,stroke-width:3px;
```

```mermaid
flowchart TB
 M["MATERIAL"] --> MP["MATERIAL_PLANT"]
 P["PLANT"] --> MP
 P --> S["STORAGE_LOCATION"]
 MP --> MSL["MATERIAL_STORAGE_LOCATION"]
 S --> MSL
```

---

## 🗂️ Final model

| Table | Primary Key | Final rows |
|---|---|---:|
| `PLANT` | `WERKS` | 20 |
| `MATERIAL` | `MATNR` | 300 |
| `STORAGE_LOCATION` | `WERKS + LGORT` | 152 |
| `MATERIAL_PLANT` | `MATNR + WERKS` | 1,080 |
| `MATERIAL_STORAGE_LOCATION` | `MATNR + WERKS + LGORT` | 2,163 |

---

## 🧱 Integrated implementation and evidence

---

### 01. LAB_A1 schema created

The schema was isolated from the current DBADMIN context.

![LAB_A1 schema created](../../../Evidences/LAB_A1/01-hana-a1-lab-schema-created.png)

---

### 02. MATERIAL table created

MATERIAL received a global key and basic attributes.

![MATERIAL table created](../../../Evidences/LAB_A1/02-hana-a1-material-table-created.png)

---

### 03. MATERIAL structure

The catalog confirmed Column Store, required fields, and key.

![MATERIAL structure](../../../Evidences/LAB_A1/03-hana-a1-material-table-database-object.png)

---

### 04. PLANT table created

PLANT introduced the multifunctional organizational level.

![PLANT table created](../../../Evidences/LAB_A1/04-hana-a1-plant-table-created.png)

---

### 05. PLANT structure

WERKS was confirmed as the unique key.

![PLANT structure](../../../Evidences/LAB_A1/05-hana-a1-plant-table-database-object.png)

---

### 06. STORAGE_LOCATION table created

Storage-location identity became dependent on WERKS and LGORT.

![STORAGE_LOCATION table created](../../../Evidences/LAB_A1/06-hana-a1-storage-location-table-created.png)

---

### 07. STORAGE_LOCATION composite PK

Key 1 and Key 2 confirmed the composite key.

![STORAGE_LOCATION composite PK](../../../Evidences/LAB_A1/07-hana-a1-storage-location-composite-key.png)

---

### 08. Storage Location to Plant FK

ALTER TABLE turned the relationship into a database-enforced rule.

![Storage Location to Plant FK](../../../Evidences/LAB_A1/08-hana-a1-storage-location-plant-foreign-key-created.png)

---

### 09. FK validated in catalog

SYS.REFERENTIAL_CONSTRAINTS confirmed the relationship; Joule served only as assistance.

![FK validated in catalog](../../../Evidences/LAB_A1/09-hana-a1-storage-location-plant-foreign-key-validated.png)

---

### 10. Parent record inserted

Plant 1000 prepared the behavioral test.

![Parent record inserted](../../../Evidences/LAB_A1/10-hana-a1-parent-plant-data-inserted.png)

---

### 11. Valid storage location accepted

1000/0001 was accepted because its parent existed.

![Valid storage location accepted](../../../Evidences/LAB_A1/11-hana-a1-storage-location-valid-foreign-key-insert.png)

---

### 12. Orphan storage location rejected

9999/0001 was rejected with a Foreign Key error.

![Orphan storage location rejected](../../../Evidences/LAB_A1/12-hana-a1-orphan-storage-location-foreign-key-rejected.png)

---

### 13. MATERIAL_PLANT created

The associative entity resolved Material by Plant.

![MATERIAL_PLANT created](../../../Evidences/LAB_A1/13-hana-a1-material-plant-table-created.png)

---

### 14. MATERIAL_PLANT composite PK

MATNR and WERKS formed the extension identity.

![MATERIAL_PLANT composite PK](../../../Evidences/LAB_A1/14-hana-a1-material-plant-composite-key.png)

---

### 15. MATERIAL_PLANT FKs

Relationships to MATERIAL and PLANT were validated.

![MATERIAL_PLANT FKs](../../../Evidences/LAB_A1/15-hana-a1-material-plant-foreign-keys-validated.png)

---

### 16. MATERIAL_STORAGE_LOCATION created

The final entity connected material, plant, and storage location.

![MATERIAL_STORAGE_LOCATION created](../../../Evidences/LAB_A1/16-hana-a1-material-storage-location-table-created.png)

---

### 17. Three-column PK

MATNR, WERKS, and LGORT were confirmed as Key 1, 2, and 3.

![Three-column PK](../../../Evidences/LAB_A1/17-hana-a1-material-storage-location-composite-key.png)

---

### 18. Composite FKs validated

Both composite FKs completed the structural foundation.

![Composite FKs validated](../../../Evidences/LAB_A1/18-hana-a1-material-storage-location-foreign-keys-validated.png)

---

### 19. Tables cleared before load

Both manual records were removed in child-to-parent order; all tables became empty.

![Tables cleared before load](../../../Evidences/LAB_A1/19-a1-foundation-tables-cleared-before-dataset-load.png)

---

### 20. Import target instance selected

Import and Export was explored. Because the available source required Data Lake Files, A1 used generated SQL scripts; cloud storage remains on the roadmap.

![Import target instance selected](../../../Evidences/LAB_A1/20-a1-import-data-target-instance-selected.png)

---

### 21. 20 Plants loaded

PLANT was loaded first because it had no parent dependency.

![20 Plants loaded](../../../Evidences/LAB_A1/21-a1-plant-dataset-loaded.png)

---

### 22. 300 Materials loaded

MATERIAL received the six approved synthetic families.

![300 Materials loaded](../../../Evidences/LAB_A1/22-a1-material-dataset-loaded.png)

---

### 23. 152 storage locations loaded

Every storage location found its parent Plant.

![152 storage locations loaded](../../../Evidences/LAB_A1/23-a1-storage-location-dataset-loaded.png)

---

### 24. 1,080 Material Plant extensions

Extensions respected both MATERIAL and PLANT.

![1,080 Material Plant extensions](../../../Evidences/LAB_A1/24-a1-material-plant-dataset-loaded.png)

---

### 25. 2,163 Material Storage Location extensions

The final load validated both composite FKs end to end.

![2,163 Material Storage Location extensions](../../../Evidences/LAB_A1/25-a1-material-storage-location-dataset-loaded.png)

---

### 26. Final counts

All five counts reconciled exactly 3,715 records.

![Final counts](../../../Evidences/LAB_A1/26-a1-foundation-dataset-load-final-counts.png)

---

### 27. Post-load referential integrity

Five LEFT JOIN checks returned zero orphans.

![Post-load referential integrity](../../../Evidences/LAB_A1/27-a1-post-load-referential-integrity-validated.png)

---

### 28. PK uniqueness

Five GROUP BY and HAVING checks returned zero duplicates.

![PK uniqueness](../../../Evidences/LAB_A1/28-a1-post-load-primary-key-uniqueness-validated.png)

---

### 29. End-to-end JOIN

The query integrated all five tables into a functional view.

![End-to-end JOIN](../../../Evidences/LAB_A1/29-a1-foundation-end-to-end-relational-join.png)

---

### 30. Distribution by Plant

The 20 Plants reconciled 1,080 extensions, 152 storage locations, and 2,163 assignments, including 2,066 active and 97 inactive.

![Distribution by Plant](../../../Evidences/LAB_A1/30-a1-foundation-data-distribution-by-plant.png)

---

## 🌐 Industrial Data Universe

The cross-scenario Blueprint lives under `Industrial-Data-Universe/Blueprint/`. Config, contract, and rules are `APPROVED`; the Validation Engine is `PASSED`; the seed is `20260903`. Python generators, five valid CSVs, five negative packages, a SHA-256 manifest, Markdown report, SQL load scripts, and six SQL audits were preserved.

---

## ✅ Final validation matrix

| Control | Result |
|---|---|
| Config, contract, rules | `APPROVED` |
| Validation Engine | `PASSED` |
| Total records | 3,715 |
| Orphans | 0 |
| Duplicate PKs | 0 |
| Active assignments | 2,066 |
| Inactive assignments | 97 |
| Physical evidence | 30 PNGs |

---

## 🧯 Troubleshooting and decisions

- Stopped instance: start it in HANA Cloud Central and wait for `Running`.
- No local import: A1 used SQL Load Generator; Data Lake Files will be practiced in Data Engineering.
- FK not visible under Columns: query `SYS.REFERENTIAL_CONSTRAINTS`.
- Python must be saved as `.py`, not pasted into PowerShell.
- Remove `__pycache__` and keep `*.pyc` in `.gitignore`.
- Copy-ready commands must not contain isolated backticks, corrupted asterisks, or trailing blank lines.

---

## 📚 Official references

- [SAP HANA Cloud Administration Guide](https://help.sap.com/docs/hana-cloud/sap-hana-cloud-administration-guide)
- [SAP HANA Cloud SQL Reference](https://help.sap.com/docs/hana-cloud-database/sap-hana-cloud-sap-hana-database-sql-reference-guide)
- [REFERENTIAL_CONSTRAINTS System View](https://help.sap.com/docs/hana-cloud-database/sap-hana-cloud-sap-hana-database-sql-reference-guide/referential-constraints-system-view)
- [Defining and Assigning Plants](https://learning.sap.com/courses/cross-functional-customizing-in-sap-s-4hana-materials-management/defining-and-assigning-plants)
- [Customizing Storage Locations](https://learning.sap.com/courses/exploring-basic-data-for-manufacturing-and-product-management-in-sap-s-4hana/customizing-storage-location)

---

## 🚀 Next scenario

[A2: SAP Enterprise Structure](./02-a2-sap-enterprise-structure.en.md), with evidence under `Evidences/LAB_A2/`.

---

## 👤 Author and contact

### Orlando dos Santos Caetano

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Orlando%20Caetano-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/orlando-caetano/)
[![GitHub](https://img.shields.io/badge/GitHub-OrlandoCaetano2026-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/OrlandoCaetano2026)

![SAP MM](https://img.shields.io/badge/SAP-MM-0FAAFF?style=flat-square&logo=sap&logoColor=white) ![SAP PP](https://img.shields.io/badge/SAP-PP-0FAAFF?style=flat-square&logo=sap&logoColor=white) ![SAP QM](https://img.shields.io/badge/SAP-QM-0FAAFF?style=flat-square&logo=sap&logoColor=white) ![SAP WM](https://img.shields.io/badge/SAP-WM-0FAAFF?style=flat-square&logo=sap&logoColor=white) ![MES](https://img.shields.io/badge/MES-Manufacturing-3B82F6?style=flat-square) ![HANA Cloud](https://img.shields.io/badge/SAP-HANA%20Cloud-0FAAFF?style=flat-square&logo=sap&logoColor=white) ![Data Engineering](https://img.shields.io/badge/Data-Engineering-4F46E5?style=flat-square) ![Integration Suite](https://img.shields.io/badge/SAP-Integration%20Suite-0FAAFF?style=flat-square&logo=sap&logoColor=white) ![Generative AI](https://img.shields.io/badge/Generative-AI-8B5CF6?style=flat-square)

---

[⬆️ README](../../../README.en.md) | [➡️ A2: SAP Enterprise Structure](./02-a2-sap-enterprise-structure.en.md)
