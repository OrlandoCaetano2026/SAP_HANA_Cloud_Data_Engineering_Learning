# A1: Fundação de Dados Relacionais no SAP HANA Cloud

---

**🌐 Idioma / Language:** 🇧🇷 **Português** | [🇺🇸 English](../EN/01-a1-relational-data-foundation.en.md)

---

[⬆️ README](../../../README.md) | [➡️ A2: Estrutura Organizacional SAP](./02-a2-estrutura-organizacional-sap.md)

---

## 🎯 Visão executiva

O A1 criou uma fundação relacional industrial governada no SAP HANA Cloud. Cinco tabelas `COLUMN`, um Industrial Data Universe determinístico e uma cadeia de geração, validação, carga e auditoria produziram **3.715 registros**, **zero órfãos** e **zero duplicidades**. Todos os dados são sintéticos.

---

## 🏗️ Arquitetura e fluxos

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

## 🗂️ Modelo final

| Table | Primary Key | Final rows |
|---|---|---:|
| `PLANT` | `WERKS` | 20 |
| `MATERIAL` | `MATNR` | 300 |
| `STORAGE_LOCATION` | `WERKS + LGORT` | 152 |
| `MATERIAL_PLANT` | `MATNR + WERKS` | 1,080 |
| `MATERIAL_STORAGE_LOCATION` | `MATNR + WERKS + LGORT` | 2,163 |

---

## 🧱 Implementação e evidências integradas

---

### 01. Schema LAB_A1 criado

O schema foi isolado do contexto corrente DBADMIN.

![Schema LAB_A1 criado](../../../Evidences/LAB_A1/01-hana-a1-lab-schema-created.png)

---

### 02. Tabela MATERIAL criada

MATERIAL recebeu chave global e atributos básicos.

![Tabela MATERIAL criada](../../../Evidences/LAB_A1/02-hana-a1-material-table-created.png)

---

### 03. Estrutura de MATERIAL

O catálogo confirmou Column Store, obrigatoriedade e chave.

![Estrutura de MATERIAL](../../../Evidences/LAB_A1/03-hana-a1-material-table-database-object.png)

---

### 04. Tabela PLANT criada

PLANT introduziu o nível organizacional multifuncional.

![Tabela PLANT criada](../../../Evidences/LAB_A1/04-hana-a1-plant-table-created.png)

---

### 05. Estrutura de PLANT

WERKS foi confirmado como chave única.

![Estrutura de PLANT](../../../Evidences/LAB_A1/05-hana-a1-plant-table-database-object.png)

---

### 06. Tabela STORAGE_LOCATION criada

A identidade do depósito passou a depender de WERKS e LGORT.

![Tabela STORAGE_LOCATION criada](../../../Evidences/LAB_A1/06-hana-a1-storage-location-table-created.png)

---

### 07. PK composta de STORAGE_LOCATION

Key 1 e Key 2 confirmaram a chave composta.

![PK composta de STORAGE_LOCATION](../../../Evidences/LAB_A1/07-hana-a1-storage-location-composite-key.png)

---

### 08. FK Storage Location para Plant

ALTER TABLE transformou a relação em regra aplicada pelo banco.

![FK Storage Location para Plant](../../../Evidences/LAB_A1/08-hana-a1-storage-location-plant-foreign-key-created.png)

---

### 09. FK validada no catálogo

SYS.REFERENTIAL_CONSTRAINTS confirmou a ligação; Joule atuou somente como apoio.

![FK validada no catálogo](../../../Evidences/LAB_A1/09-hana-a1-storage-location-plant-foreign-key-validated.png)

---

### 10. Registro pai inserido

O centro 1000 foi preparado para o teste comportamental.

![Registro pai inserido](../../../Evidences/LAB_A1/10-hana-a1-parent-plant-data-inserted.png)

---

### 11. Depósito válido aceito

1000/0001 foi aceito por possuir registro pai.

![Depósito válido aceito](../../../Evidences/LAB_A1/11-hana-a1-storage-location-valid-foreign-key-insert.png)

---

### 12. Depósito órfão rejeitado

9999/0001 foi rejeitado com erro de Foreign Key.

![Depósito órfão rejeitado](../../../Evidences/LAB_A1/12-hana-a1-orphan-storage-location-foreign-key-rejected.png)

---

### 13. MATERIAL_PLANT criada

A entidade associativa resolveu Material por Plant.

![MATERIAL_PLANT criada](../../../Evidences/LAB_A1/13-hana-a1-material-plant-table-created.png)

---

### 14. PK composta de MATERIAL_PLANT

MATNR e WERKS formaram a identidade da expansão.

![PK composta de MATERIAL_PLANT](../../../Evidences/LAB_A1/14-hana-a1-material-plant-composite-key.png)

---

### 15. FKs de MATERIAL_PLANT

As relações para MATERIAL e PLANT foram validadas.

![FKs de MATERIAL_PLANT](../../../Evidences/LAB_A1/15-hana-a1-material-plant-foreign-keys-validated.png)

---

### 16. MATERIAL_STORAGE_LOCATION criada

A entidade final conectou material, centro e depósito.

![MATERIAL_STORAGE_LOCATION criada](../../../Evidences/LAB_A1/16-hana-a1-material-storage-location-table-created.png)

---

### 17. PK de três colunas

MATNR, WERKS e LGORT foram confirmados como Key 1, 2 e 3.

![PK de três colunas](../../../Evidences/LAB_A1/17-hana-a1-material-storage-location-composite-key.png)

---

### 18. FKs compostas validadas

As duas FKs compostas fecharam a fundação estrutural.

![FKs compostas validadas](../../../Evidences/LAB_A1/18-hana-a1-material-storage-location-foreign-keys-validated.png)

---

### 19. Tabelas limpas antes da carga

Os dois registros manuais foram removidos na ordem filha para pai; todas as tabelas ficaram vazias.

![Tabelas limpas antes da carga](../../../Evidences/LAB_A1/19-a1-foundation-tables-cleared-before-dataset-load.png)

---

### 20. Instância de importação selecionada

O Import and Export foi explorado. Como a origem disponível exigia Data Lake Files, o A1 adotou scripts SQL gerados; cloud storage permanece no roadmap.

![Instância de importação selecionada](../../../Evidences/LAB_A1/20-a1-import-data-target-instance-selected.png)

---

### 21. 20 Plants carregados

PLANT foi carregada primeiro por não depender de outra tabela.

![20 Plants carregados](../../../Evidences/LAB_A1/21-a1-plant-dataset-loaded.png)

---

### 22. 300 Materials carregados

MATERIAL recebeu as seis famílias sintéticas aprovadas.

![300 Materials carregados](../../../Evidences/LAB_A1/22-a1-material-dataset-loaded.png)

---

### 23. 152 depósitos carregados

Todos os depósitos localizaram seus respectivos Plants.

![152 depósitos carregados](../../../Evidences/LAB_A1/23-a1-storage-location-dataset-loaded.png)

---

### 24. 1.080 extensões Material Plant

As extensões respeitaram simultaneamente MATERIAL e PLANT.

![1.080 extensões Material Plant](../../../Evidences/LAB_A1/24-a1-material-plant-dataset-loaded.png)

---

### 25. 2.163 extensões Material Storage Location

A carga final validou as FKs compostas de ponta a ponta.

![2.163 extensões Material Storage Location](../../../Evidences/LAB_A1/25-a1-material-storage-location-dataset-loaded.png)

---

### 26. Contagens finais

As cinco contagens reconciliaram exatamente 3.715 registros.

![Contagens finais](../../../Evidences/LAB_A1/26-a1-foundation-dataset-load-final-counts.png)

---

### 27. Integridade referencial pós-carga

Cinco verificações com LEFT JOIN retornaram zero órfãos.

![Integridade referencial pós-carga](../../../Evidences/LAB_A1/27-a1-post-load-referential-integrity-validated.png)

---

### 28. Unicidade das PKs

Cinco verificações com GROUP BY e HAVING retornaram zero duplicidades.

![Unicidade das PKs](../../../Evidences/LAB_A1/28-a1-post-load-primary-key-uniqueness-validated.png)

---

### 29. JOIN ponta a ponta

A consulta integrou as cinco tabelas em uma visão funcional.

![JOIN ponta a ponta](../../../Evidences/LAB_A1/29-a1-foundation-end-to-end-relational-join.png)

---

### 30. Distribuição por Plant

Os 20 Plants reconciliaram 1.080 extensões, 152 depósitos e 2.163 associações, sendo 2.066 ativas e 97 inativas.

![Distribuição por Plant](../../../Evidences/LAB_A1/30-a1-foundation-data-distribution-by-plant.png)

---

## 🌐 Industrial Data Universe

O Blueprint transversal fica em `Industrial-Data-Universe/Blueprint/`. Config, contract e rules estão `APPROVED`; o Validation Engine está `PASSED`; a seed é `20260903`. Foram preservados geradores Python, cinco CSVs válidos, cinco pacotes negativos, manifest com SHA-256, relatório Markdown, scripts SQL de carga e seis auditorias SQL.

---

## ✅ Matriz de validação final

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

## 🧯 Troubleshooting e decisões

- Instância parada: iniciar no HANA Cloud Central e aguardar `Running`.
- Import local ausente: A1 usou SQL Load Generator; Data Lake Files será praticado no bloco de Data Engineering.
- FK invisível em Columns: consultar `SYS.REFERENTIAL_CONSTRAINTS`.
- Python deve ser salvo como `.py`, não colado no PowerShell.
- Remover `__pycache__` e manter `*.pyc` no `.gitignore`.
- Comandos para copiar devem estar sem acento grave isolado, asteriscos corrompidos ou linha vazia final.

---

## 📚 Referências oficiais

- [SAP HANA Cloud Administration Guide](https://help.sap.com/docs/hana-cloud/sap-hana-cloud-administration-guide)
- [SAP HANA Cloud SQL Reference](https://help.sap.com/docs/hana-cloud-database/sap-hana-cloud-sap-hana-database-sql-reference-guide)
- [REFERENTIAL_CONSTRAINTS System View](https://help.sap.com/docs/hana-cloud-database/sap-hana-cloud-sap-hana-database-sql-reference-guide/referential-constraints-system-view)
- [Defining and Assigning Plants](https://learning.sap.com/courses/cross-functional-customizing-in-sap-s-4hana-materials-management/defining-and-assigning-plants)
- [Customizing Storage Locations](https://learning.sap.com/courses/exploring-basic-data-for-manufacturing-and-product-management-in-sap-s-4hana/customizing-storage-location)

---

## 🚀 Próximo cenário

[A2: Estrutura Organizacional SAP](./02-a2-estrutura-organizacional-sap.md), com evidências em `Evidences/LAB_A2/`.

---

## 👤 Autor e contato

### Orlando dos Santos Caetano

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Orlando%20Caetano-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/orlando-caetano/)
[![GitHub](https://img.shields.io/badge/GitHub-OrlandoCaetano2026-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/OrlandoCaetano2026)

![SAP MM](https://img.shields.io/badge/SAP-MM-0FAAFF?style=flat-square&logo=sap&logoColor=white) ![SAP PP](https://img.shields.io/badge/SAP-PP-0FAAFF?style=flat-square&logo=sap&logoColor=white) ![SAP QM](https://img.shields.io/badge/SAP-QM-0FAAFF?style=flat-square&logo=sap&logoColor=white) ![SAP WM](https://img.shields.io/badge/SAP-WM-0FAAFF?style=flat-square&logo=sap&logoColor=white) ![MES](https://img.shields.io/badge/MES-Manufacturing-3B82F6?style=flat-square) ![HANA Cloud](https://img.shields.io/badge/SAP-HANA%20Cloud-0FAAFF?style=flat-square&logo=sap&logoColor=white) ![Data Engineering](https://img.shields.io/badge/Data-Engineering-4F46E5?style=flat-square) ![Integration Suite](https://img.shields.io/badge/SAP-Integration%20Suite-0FAAFF?style=flat-square&logo=sap&logoColor=white) ![Generative AI](https://img.shields.io/badge/Generative-AI-8B5CF6?style=flat-square)

---

[⬆️ README](../../../README.md) | [➡️ A2: Estrutura Organizacional SAP](./02-a2-estrutura-organizacional-sap.md)
