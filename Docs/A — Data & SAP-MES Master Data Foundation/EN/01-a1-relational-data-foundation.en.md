# A1: Relational Data Foundation in SAP HANA Cloud

**🌐 Language / Idioma:** [🇧🇷 Português](../BR/01-a1-fundacao-de-dados-relacionais.md) | 🇺🇸 **English**

> **Status:** ✅ Completed  
> **Block:** A — Data & SAP-MES Master Data Foundation  
> **Schema:** `LAB_A1`  
> **Evidence:** `Evidences/LAB_A1/`

[⬆️ Back to the README](../../../README.en.md) | [➡️ Next document: Dataset design, validation, and loading](./02-a1-dataset-design-validation-and-loading.en.md)


---

## 🎯 Executive overview

A1 establishes the project's first relational foundation. Five `COLUMN` tables represent global material data, plants, storage locations, and the Material × Plant and Material × Storage Location organizational extensions. The laboratory uses fictional data only and does not fully reproduce physical SAP ERP or SAP S/4HANA tables.

## 🏭 Scenario storytelling

A material has a global identity, while selected characteristics depend on the plant. After plant extension, the material can be made available in valid storage locations of that plant. The model separates responsibilities to reduce redundancy and prevent inconsistent combinations.

```text
Global material
      ↓
Plant extension
      ↓
Storage-location availability
```

## 🧭 Learning objectives

- understand schemas as logical namespaces;
- create `COLUMN` tables with `NVARCHAR` and `NOT NULL`;
- apply simple, composite, and three-column Primary Keys;
- create simple and composite Foreign Keys;
- resolve an `N:N` relationship with an associative entity;
- validate constraints in the catalog;
- verify referential integrity through positive and negative tests.


---

## 🏗️ Architecture and flows

The flows use colors and shapes to distinguish the user, platform, tools, database, decisions, and results. This visually represents both the architecture and constraint behavior.

### Platform-to-schema flow

```mermaid
flowchart TB
    U(["Technical user"]):::actor --> BTP["SAP BTP Trial"]:::platform
    BTP --> CF["Cloud Foundry Runtime"]:::runtime --> DEV["Space dev"]:::runtime
    DEV --> HC[("SAP HANA Cloud<br/>Free Tier")]:::database --> HCC["SAP HANA Cloud Central"]:::tool
    HCC --> SQL["SQL Console"]:::tool --> LAB[("Schema LAB_A1")]:::schema
    HCC --> DBO["Database Objects"]:::tool --> LAB
    classDef actor fill:#E8F1FF,stroke:#2563EB,color:#123A70,stroke-width:2px;
    classDef platform fill:#FFF3D8,stroke:#F59E0B,color:#8A4B00,stroke-width:2px;
    classDef runtime fill:#F3E8FF,stroke:#9333EA,color:#581C87,stroke-width:2px;
    classDef database fill:#E7F8EC,stroke:#16A34A,color:#14532D,stroke-width:2px;
    classDef tool fill:#FFF1F2,stroke:#E11D48,color:#881337,stroke-width:2px;
    classDef schema fill:#E0F2FE,stroke:#0284C7,color:#0C4A6E,stroke-width:3px;
```

### Relational flow

```mermaid
flowchart TB
    M["MATERIAL<br/>PK: MATNR"]:::master -->|"1:N · MATNR"| MP["MATERIAL_PLANT<br/>PK: MATNR + WERKS"]:::assoc
    P["PLANT<br/>PK: WERKS"]:::org -->|"1:N · WERKS"| MP
    P -->|"1:N · WERKS"| S["STORAGE_LOCATION<br/>PK: WERKS + LGORT"]:::org
    MP -->|"1:N · MATNR + WERKS"| MSL["MATERIAL_STORAGE_LOCATION<br/>PK: MATNR + WERKS + LGORT"]:::assoc
    S -->|"1:N · WERKS + LGORT"| MSL
    classDef master fill:#E8F1FF,stroke:#2563EB,color:#123A70,stroke-width:2px;
    classDef org fill:#FFF3D8,stroke:#F59E0B,color:#8A4B00,stroke-width:2px;
    classDef assoc fill:#E7F8EC,stroke:#16A34A,color:#14532D,stroke-width:2px;
```

### Referential-integrity flow

```mermaid
flowchart TB
    I["INSERT into STORAGE_LOCATION"]:::step --> D{"PLANT.WERKS exists?"}:::decision
    D -->|"Yes"| OK["Record accepted<br/>1000 / 0001"]:::success
    D -->|"No"| ER["Error 461<br/>Foreign Key violation"]:::error
    classDef step fill:#FFF3D8,stroke:#F59E0B,color:#8A4B00,stroke-width:2px;
    classDef decision fill:#F3E8FF,stroke:#9333EA,color:#581C87,stroke-width:2px;
    classDef success fill:#E7F8EC,stroke:#16A34A,color:#14532D,stroke-width:2px;
    classDef error fill:#FFF1F2,stroke:#E11D48,color:#881337,stroke-width:2px;
```


---

## 🛠️ Integrated implementation and evidence

Each evidence image appears at the exact point in the narrative where the result was produced. Code, explanation, and visual outcome therefore remain connected.

### 1. `LAB_A1` schema

The schema acts as a logical folder inside the database. Even with `CURRENT_SCHEMA = DBADMIN`, qualified names such as `LAB_A1.MATERIAL` direct objects to the laboratory namespace.

```sql
SELECT CURRENT_USER, CURRENT_SCHEMA FROM DUMMY;
CREATE SCHEMA LAB_A1;
SELECT SCHEMA_NAME FROM SYS.SCHEMAS WHERE SCHEMA_NAME = 'LAB_A1';
```

![LAB_A1 schema created and validated](../../../Evidences/LAB_A1/01-hana-a1-lab-schema-created.png)

With the namespace available, the first entity created was the global material.

### 2. Global `MATERIAL` entity

`MATNR` identifies each material. The remaining fields describe type, group, and base unit while keeping the model small and focused on relational foundations.

```sql
CREATE COLUMN TABLE LAB_A1.MATERIAL (
    MATNR NVARCHAR(40) NOT NULL,
    DESCRIPTION NVARCHAR(100) NOT NULL,
    MTART NVARCHAR(4) NOT NULL,
    MATKL NVARCHAR(9) NOT NULL,
    MEINS NVARCHAR(3) NOT NULL,
    PRIMARY KEY (MATNR)
);
```

![MATERIAL DDL executed successfully](../../../Evidences/LAB_A1/02-hana-a1-material-table-created.png)

Catalog inspection confirms Column Store, data types, required fields, and key position without relying only on the DDL result.

![MATERIAL structure in Database Objects](../../../Evidences/LAB_A1/03-hana-a1-material-table-database-object.png)

### 3. Organizational `PLANT` entity

A plant is multifunctional and may support procurement, receiving, quality, planning, production, storage, and shipping. `WERKS` was defined as the Primary Key.

```sql
CREATE COLUMN TABLE LAB_A1.PLANT (
    WERKS NVARCHAR(4) NOT NULL,
    PLANT_NAME NVARCHAR(100) NOT NULL,
    COUNTRY NVARCHAR(3) NOT NULL,
    PRIMARY KEY (WERKS)
);
```

![PLANT DDL executed successfully](../../../Evidences/LAB_A1/04-hana-a1-plant-table-created.png)

![PLANT structure in Database Objects](../../../Evidences/LAB_A1/05-hana-a1-plant-table-database-object.png)

With the organizational record defined, the model could represent plant-dependent storage locations.

### 4. `STORAGE_LOCATION` and composite key

Because `LGORT` may be reused across different plants, the complete storage-location identity is `WERKS + LGORT`.

```sql
CREATE COLUMN TABLE LAB_A1.STORAGE_LOCATION (
    WERKS NVARCHAR(4) NOT NULL,
    LGORT NVARCHAR(4) NOT NULL,
    STORAGE_LOCATION_NAME NVARCHAR(100) NOT NULL,
    PRIMARY KEY (WERKS, LGORT)
);
```

![STORAGE_LOCATION DDL executed successfully](../../../Evidences/LAB_A1/06-hana-a1-storage-location-table-created.png)

In the structural view, `WERKS` appears as `Key 1` and `LGORT` as `Key 2`, making the composite identity explicit.

![Composite Primary Key of STORAGE_LOCATION](../../../Evidences/LAB_A1/07-hana-a1-storage-location-composite-key.png)

### 5. `PLANT → STORAGE_LOCATION` relationship

`ALTER TABLE` converted the functional correspondence of `WERKS` into a database-enforced rule. Every plant used by `STORAGE_LOCATION` must exist in `PLANT`.

```sql
ALTER TABLE LAB_A1.STORAGE_LOCATION
ADD CONSTRAINT FK_STORAGE_LOCATION_PLANT
FOREIGN KEY (WERKS)
REFERENCES LAB_A1.PLANT (WERKS);
```

![STORAGE_LOCATION to PLANT Foreign Key created](../../../Evidences/LAB_A1/08-hana-a1-storage-location-plant-foreign-key-created.png)

The relationship was queried in the catalog. Joule records integrated AI assistance, while technical validation comes from the system view.

```sql
SELECT SCHEMA_NAME, TABLE_NAME, COLUMN_NAME, POSITION,
       CONSTRAINT_NAME, REFERENCED_SCHEMA_NAME,
       REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME,
       IS_ENFORCED, IS_VALIDATED
FROM SYS.REFERENTIAL_CONSTRAINTS
WHERE SCHEMA_NAME = 'LAB_A1'
ORDER BY TABLE_NAME, CONSTRAINT_NAME, POSITION;
```

![Foreign Key validated in the catalog with Joule assistance](../../../Evidences/LAB_A1/09-hana-a1-storage-location-plant-foreign-key-validated.png)

### 6. `MATERIAL_PLANT` associative entity

A material can exist in several plants, and a plant can contain several materials. `MATERIAL_PLANT` converts this conceptual `N:N` relationship into two `1:N` relationships and stores examples of plant-dependent attributes.

```sql
CREATE COLUMN TABLE LAB_A1.MATERIAL_PLANT (
    MATNR NVARCHAR(40) NOT NULL,
    WERKS NVARCHAR(4) NOT NULL,
    PROCUREMENT_TYPE NVARCHAR(1) NOT NULL,
    MRP_TYPE NVARCHAR(2) NOT NULL,
    PRIMARY KEY (MATNR, WERKS),
    CONSTRAINT FK_MATERIAL_PLANT_MATERIAL FOREIGN KEY (MATNR)
        REFERENCES LAB_A1.MATERIAL (MATNR),
    CONSTRAINT FK_MATERIAL_PLANT_PLANT FOREIGN KEY (WERKS)
        REFERENCES LAB_A1.PLANT (WERKS)
);
```

![MATERIAL_PLANT created with PK and FKs](../../../Evidences/LAB_A1/13-hana-a1-material-plant-table-created.png)

![Composite Primary Key of MATERIAL_PLANT](../../../Evidences/LAB_A1/14-hana-a1-material-plant-composite-key.png)

The catalog displays relationships to `MATERIAL.MATNR` and `PLANT.WERKS`, completing material extension to the plant.

![MATERIAL_PLANT Foreign Keys validated](../../../Evidences/LAB_A1/15-hana-a1-material-plant-foreign-keys-validated.png)

### 7. `MATERIAL_STORAGE_LOCATION` entity

The final entity requires two valid conditions: the material must be extended to the plant, and the storage location must belong to the same plant. The three-column PK identifies each specific extension.

```sql
CREATE COLUMN TABLE LAB_A1.MATERIAL_STORAGE_LOCATION (
    MATNR NVARCHAR(40) NOT NULL,
    WERKS NVARCHAR(4) NOT NULL,
    LGORT NVARCHAR(4) NOT NULL,
    STORAGE_STATUS NVARCHAR(1) NOT NULL,
    PRIMARY KEY (MATNR, WERKS, LGORT),
    CONSTRAINT FK_MAT_SLOC_MATERIAL_PLANT FOREIGN KEY (MATNR, WERKS)
        REFERENCES LAB_A1.MATERIAL_PLANT (MATNR, WERKS),
    CONSTRAINT FK_MAT_SLOC_STORAGE_LOCATION FOREIGN KEY (WERKS, LGORT)
        REFERENCES LAB_A1.STORAGE_LOCATION (WERKS, LGORT)
);
```

![MATERIAL_STORAGE_LOCATION created](../../../Evidences/LAB_A1/16-hana-a1-material-storage-location-table-created.png)

Inspection displays `MATNR`, `WERKS`, and `LGORT` as `Key 1`, `Key 2`, and `Key 3`.

![Three-column Primary Key](../../../Evidences/LAB_A1/17-hana-a1-material-storage-location-composite-key.png)

Validation of each composite-FK column position completes the structural construction of the five tables.

![Composite Foreign Keys validated](../../../Evidences/LAB_A1/18-hana-a1-material-storage-location-foreign-keys-validated.png)

## 🧪 Behavioral validation

### Valid parent record

Testing began by creating fictional plant `1000`, required by any related child storage location.

```sql
INSERT INTO LAB_A1.PLANT (WERKS, PLANT_NAME, COUNTRY)
VALUES ('1000', 'Manufacturing Plant Alpha', 'BRA');
SELECT * FROM LAB_A1.PLANT WHERE WERKS = '1000';
```

![Parent PLANT record inserted](../../../Evidences/LAB_A1/10-hana-a1-parent-plant-data-inserted.png)

### Valid storage location accepted

Because `PLANT.WERKS = 1000` exists, `1000/0001` was accepted.

```sql
INSERT INTO LAB_A1.STORAGE_LOCATION (WERKS, LGORT, STORAGE_LOCATION_NAME)
VALUES ('1000', '0001', 'Raw Materials');
SELECT * FROM LAB_A1.STORAGE_LOCATION
WHERE WERKS = '1000' AND LGORT = '0001';
```

![Valid storage location accepted](../../../Evidences/LAB_A1/11-hana-a1-storage-location-valid-foreign-key-insert.png)

### Orphan storage location rejected

The next attempt used `WERKS = 9999`, which does not exist in the parent table.

```sql
INSERT INTO LAB_A1.STORAGE_LOCATION (WERKS, LGORT, STORAGE_LOCATION_NAME)
VALUES ('9999', '0001', 'Invalid Orphan Storage Location');
```

![Orphan storage location rejected by the Foreign Key](../../../Evidences/LAB_A1/12-hana-a1-orphan-storage-location-foreign-key-rejected.png)

Error 461 completes behavioral validation. The Foreign Key does not merely document the relationship: it physically prevents orphan records and protects future queries, integrations, and applications.


---

## ✅ Validation matrix

| Criterion | Result |
|---|---|
| `LAB_A1` schema created | ✅ |
| Five `COLUMN` tables created | ✅ |
| Simple and composite PKs validated | ✅ |
| Simple and composite FKs validated | ✅ |
| Valid parent and storage-location records inserted | ✅ |
| Orphan storage location rejected | ✅ |
| Physical evidence links `01` through `18` | ✅ |
| Real company data used | ❌ No |

## 🧯 Troubleshooting

- **`object already exists`:** inspect the catalog before repeating a `CREATE`; do not automatically execute `DROP`.
- **`foreign key constraint violation`:** load parent tables before child tables and review the supplied key.
- **Foreign Key absent from Columns:** query `SYS.REFERENTIAL_CONSTRAINTS`, because Columns focuses on columns and PKs.
- **`Current Schema = DBADMIN`:** continue using qualified names such as `LAB_A1.OBJECT`; creating a schema does not automatically change the session context.

## 🛡️ Best practices and production recommendations

- do not use `DBADMIN` as an application identity;
- adopt least-privilege technical users and roles;
- name constraints explicitly;
- version DDL and later migrate to HDI/database-as-code;
- analyze dependencies before destructive changes;
- review SQL suggested by Joule or any AI;
- load in the order `PLANT → MATERIAL → STORAGE_LOCATION → MATERIAL_PLANT → MATERIAL_STORAGE_LOCATION`;
- never publish credentials or real company data.

## 🚀 Next document

The next document separately covers dataset generation, validation, and loading:

### [DOC 02: Dataset design, validation, and loading](./02-a1-dataset-design-validation-and-loading.en.md)

New evidence will be stored under `Evidences/LAB_02/`, restarting from `01`.

## 📚 Official references

- [SAP HANA Cloud Getting Started Guide](https://help.sap.com/docs/hana-cloud/sap-hana-cloud-getting-started-guide/create-schema-tables-and-insert-data-using-sap-hana-database-explorer)
- [SAP HANA Cloud SQL Reference](https://help.sap.com/docs/hana-cloud-database/sap-hana-cloud-sap-hana-database-sql-reference-guide/create-table-statement-data-definition)
- [REFERENTIAL_CONSTRAINTS System View](https://help.sap.com/docs/hana-cloud-database/sap-hana-cloud-sap-hana-database-sql-reference-guide/referential-constraints-system-view)
- [Using Gen AI in the SQL Console](https://help.sap.com/docs/hana-cloud/sap-hana-cloud-administration-guide/using-gen-ai-in-sql-console)


---

## 👤 Autor

### Orlando dos Santos Caetano

**SAP MM · PP · QM · WM | MES | SAP Integration | Data Engineering | Generative AI**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Orlando%20Caetano-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/orlando-caetano/)
[![GitHub](https://img.shields.io/badge/GitHub-OrlandoCaetano2026-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/OrlandoCaetano2026)

![SAP MM](https://img.shields.io/badge/SAP-MM-0FAAFF?style=flat-square&logo=sap&logoColor=white)
![SAP PP](https://img.shields.io/badge/SAP-PP-0FAAFF?style=flat-square&logo=sap&logoColor=white)
![SAP QM](https://img.shields.io/badge/SAP-QM-0FAAFF?style=flat-square&logo=sap&logoColor=white)
![SAP WM](https://img.shields.io/badge/SAP-WM-0FAAFF?style=flat-square&logo=sap&logoColor=white)
![MES](https://img.shields.io/badge/MES-Manufacturing%20Execution-3B82F6?style=flat-square)
![SAP HANA Cloud](https://img.shields.io/badge/SAP-HANA%20Cloud-0FAAFF?style=flat-square&logo=sap&logoColor=white)
![Data Engineering](https://img.shields.io/badge/Data-Engineering-4F46E5?style=flat-square)
![SAP Integration](https://img.shields.io/badge/SAP-Integration%20Suite-0FAAFF?style=flat-square&logo=sap&logoColor=white)
![Generative AI](https://img.shields.io/badge/Generative-AI-8B5CF6?style=flat-square)

**SAP Certified - Integration Developer (C_CPI)**  
**SAP Certified - SAP Generative AI Developer (C_AIG)**


---

[⬆️ Back to the README](../../../README.en.md) | [➡️ Next document](./02-a1-dataset-design-validation-and-loading.en.md)
