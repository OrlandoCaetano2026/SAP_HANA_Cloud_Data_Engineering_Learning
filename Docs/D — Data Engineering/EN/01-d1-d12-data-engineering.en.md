# D1 to D12: Data Engineering on SAP HANA Cloud

**🌐 Language / Idioma:** 🇺🇸 **English** | [🇧🇷 Português](../BR/01-d1-d12-engenharia-de-dados.md)

[⬆️ Back to README](../../../README.md)

> **Status:** ✅ Completed (D1, D2, D3, D5, D6, D7, D8, D10, D11) · ⚠️ Partial (D4 — full definitions of rules R01–R13 not recovered in this session; D9 — connection validated with certificate validation disabled; D12 — memory measured, `EXPLAIN PLAN` not persisted)
> **Environment:** SAP HANA Cloud Trial (Free Tier, US10 region, version 2026.28.10)
> **Source:** schema `INDUSTRIAL_DATA` (`PURCHASE_ORDER` 40 rows, `MATERIAL` 300 rows) · **Target:** schema `DBADMIN`
> **Classification:** educational environment, synthetic data, no production data

## 🎯 Executive overview

Block A taught how to query data and Block B taught how to model queries. Block C moved development into the professional workflow, with a project, an HDI Container and deployment. **Block D** answers the next question: **how does data arrive, get cleansed, validated, loaded incrementally, deduplicated, traced and made available for consumption** in a data engineering pipeline.

Unlike Block C, Block D was executed entirely by hand, through the SAP HANA Cloud SQL Console, without a Data Provisioning Server. This is a real Free Tier limitation: managed SDI replication is not available, so every load pattern (replication, delta, merge) was built with explicit SQL. The trade-off is that every step stayed visible and auditable.

| Scenario | Objective | Outcome |
|---|---|---|
| D1 | Data Ingestion | ✅ Landing of 300 records reconciled with the source |
| D2 | Data Cleansing | ✅ Invalid values handled; validation of 300 rows with `NA` |
| D3 | Transformation Pipelines | ✅ Curated layer validated (300 rows), with weight profile and zero-value rules |
| D4 | Data Quality | ⚠️ Batch of 13 rules executed and validated; full definitions of R01–R13 not recovered |
| D5 | Incremental Loading | ✅ Initial load (23) + delta (17) = 40 rows; rerun with 0 rows |
| D6 | Delta Processing (MERGE) | ✅ `MERGE INTO` with `WHEN MATCHED` / `WHEN NOT MATCHED`; result of 41 rows |
| D7 | Deduplication | ✅ 43 records with duplicates reduced to 41 unique with `ROW_NUMBER()` |
| D8 | Data Lineage | ✅ Lineage documented; dependency catalog limited (see storytelling) |
| D9 | Remote Sources | ⚠️ Remote source `HANA_SELF` created; TLS validation disabled (lab only) |
| D10 | Virtual Tables | ✅ `VT_PURCHASE_ORDER` queried remotely, 40 rows identical to the source |
| D11 | Replication | ✅ Replica `REP_PURCHASE_ORDER` with 40 rows, 0 differences, incremental rerun with 0 rows |
| D12 | Performance & Optimization | ⚠️ Memory per table measured (`M_CS_TABLES`); `EXPLAIN PLAN` not persisted |

> [!IMPORTANT]
> TLS certificate validation was **disabled** (`sslValidateCertificate=false`) on the D9 remote source. This was a lab decision, because the Trial does not allow generating the PSE file required. In production, validation must be enabled with the correct certificate.
>
> The `DBADMIN` password was typed by the user directly into the SQL Console and does not appear in the history, because the interface masks it as `***`. No credential was written to any file in the repository.

---

## 🧭 Functional storytelling

### D1 — Ingestion: the first reconciliation proof

Ingestion was treated as a simple question: **did the landing receive every record from the source?** The answer was verified by counting and reconciliation, before any transformation.

![D1-EV01 — Landing reconciliation with 300 records](../../../Evidences/LAB_D/D1-EV01-reconciliacao-landing-300.png)
*D1-EV01 — Source and landing counts match (300 records).*

### D2 — Cleansing: NULLs and invalid formats

Missing values and inconsistent formats were handled with `COALESCE`, `TRIM` and `CASE`, without deleting records. The criterion was that cleansing **must not reduce the row count**: the final result has to keep 300 rows, now with treated values.

![D2-EV01 — Cleansing validation, 300 rows with NA](../../../Evidences/LAB_D/D2-EV01-validacao-limpeza-300-na.png)
*D2-EV01 — Validation of the 300 rows after cleansing, with `NA` marking on treated fields.*

### D3 — Transformation: from RAW to curated

The curated layer was built with `CTAS` (`CREATE COLUMN TABLE ... AS (SELECT ...)`) and validated in three aspects: row count (300), weight profile and zero-value rules, and net percentage with minimum and maximum within the expected range.

![D3-EV01 — Transformation validation, 300 rows](../../../Evidences/LAB_D/D3-EV01-validacao-transformacao-300.png)
*D3-EV01 — Row count of the curated layer after transformation.*

![D3-EV02 — Weight profile and zero-value rules](../../../Evidences/LAB_D/D3-EV02-perfil-pesos-regras-zero.png)
*D3-EV02 — Weight profile and verification of the zero-value rules.*

![D3-EV03 — Net percentage, minimum and maximum](../../../Evidences/LAB_D/D3-EV03-percentual-liquido-min-max.png)
*D3-EV03 — Net percentage with the minimum and maximum limits verified.*

### D4 — Quality: technical and functional rules

The quality batch executed **13 rules** (R01–R13) over the curated layer and recorded the result per rule. During execution an important finding emerged: rule **R05 had a blind spot**, caused by the injection of goods receipt (GR) records that changed the validation scenario. This finding was documented and rule **R13** was created to cover the gap.

The full definitions of **R01, R04, R06–R10 and R12** were not recovered in this session, because the SQL Console history did not return the original batch text in the search. For technical honesty, those rules appear below only with their known status, and the definitions should be recovered from the script repository or rewritten before being used as reference.

| Rule | Known role | Status |
|---|---|---|
| R01 | — | Definition to be confirmed |
| R02 | Quality rule in the batch | Executed; see D4-EV01 |
| R03 | Quality rule in the batch | Executed; restored and validated in D4-EV02 |
| R04 | — | Definition to be confirmed |
| R05 | Blind spot caused by GR injection | Documented; restored in D4-EV02 |
| R06–R10 | — | Definition to be confirmed |
| R11 | Quality rule in the batch | Executed; see D4-EV01 |
| R12 | — | Definition to be confirmed |
| R13 | Created to cover the R05 blind spot | Executed in batch 3 |

![D4-EV01 — Result of the 13 rules in batch 3](../../../Evidences/LAB_D/D4-EV01-regras-13-resultado-batch3.jpg)
*D4-EV01 — Result of the 13 rules in batch 3.*

![D4-EV02 — R05 and R03 restored](../../../Evidences/LAB_D/D4-EV02-r05-r03-restaurado.jpg)
*D4-EV02 — Restoration of R05 and R03 after the scenario adjustment.*

### D5 — Incremental loading with a watermark

The incremental load uses a **control table** (`DBADMIN.ETL_CONTROL`) holding the last processed date (`ULTIMA_MARCA`), the load timestamp and the number of rows loaded. The first load uses the cutoff `PO_DATE <= '2026-04-30'`, and subsequent loads fetch only `PO_DATE > ULTIMA_MARCA`.

```sql
CREATE COLUMN TABLE DBADMIN.TGT_PURCHASE_ORDER AS (SELECT * FROM INDUSTRIAL_DATA.PURCHASE_ORDER WHERE 1 = 0) WITH NO DATA;
ALTER TABLE DBADMIN.TGT_PURCHASE_ORDER ADD PRIMARY KEY (EBELN);

CREATE COLUMN TABLE DBADMIN.ETL_CONTROL (
  TABELA NVARCHAR(60) PRIMARY KEY,
  ULTIMA_MARCA DATE,
  ULTIMA_CARGA TIMESTAMP,
  LINHAS_CARREGADAS INTEGER
);

INSERT INTO DBADMIN.TGT_PURCHASE_ORDER
SELECT * FROM INDUSTRIAL_DATA.PURCHASE_ORDER
WHERE PO_DATE <= '2026-04-30';

-- Delta: only records after the watermark
INSERT INTO DBADMIN.TGT_PURCHASE_ORDER
SELECT * FROM INDUSTRIAL_DATA.PURCHASE_ORDER
WHERE PO_DATE > (SELECT ULTIMA_MARCA FROM DBADMIN.ETL_CONTROL WHERE TABELA = 'PURCHASE_ORDER');
```

Result: initial load of **23** rows, delta of **17** rows, total of **40**, and a delta rerun with **0** rows. The rerun returning 0 rows is the proof of idempotency: running it again does not duplicate anything.

![D5-EV01 — Initial load validation, 23 rows](../../../Evidences/LAB_D/D5-EV01-validacao-carga-inicial-23.jpg)
*D5-EV01 — Initial load with 23 rows.*

![D5-EV02 — Incremental load history, 17 rows](../../../Evidences/LAB_D/D5-EV02-historico-carga-incremental-17.jpg)
*D5-EV02 — Incremental load history with 17 rows.*

![D5-EV03 — Post-delta validation, 40 rows](../../../Evidences/LAB_D/D5-EV03-validacao-pos-delta-40.jpg)
*D5-EV03 — Validation after the delta, with 40 rows.*

![D5-EV04 — Delta rerun, 0 rows](../../../Evidences/LAB_D/D5-EV04-reexecucao-delta-0.jpg)
*D5-EV04 — Delta rerun returning 0 rows.*

### D6 — Delta with MERGE: update and insert in one statement

D5 can only **insert** new records. When an existing record changes in the source, it must be **updated**. `MERGE INTO` handles both cases in one statement, matching on the `EBELN` key:

```sql
MERGE INTO DBADMIN.TGT_PURCHASE_ORDER AS T
USING DBADMIN.STG_PO_DELTA AS S
  ON T.EBELN = S.EBELN
WHEN MATCHED THEN UPDATE SET
  T.LIFNR = S.LIFNR, T.EKORG = S.EKORG, T.DOC_TYPE_CODE = S.DOC_TYPE_CODE,
  T.STATUS_CODE = S.STATUS_CODE, T.CURRENCY = S.CURRENCY,
  T.PO_DATE = S.PO_DATE, T.ITEM_COUNT = S.ITEM_COUNT
WHEN NOT MATCHED THEN INSERT
  (EBELN, LIFNR, EKORG, DOC_TYPE_CODE, STATUS_CODE, CURRENCY, PO_DATE, ITEM_COUNT)
  VALUES (S.EBELN, S.LIFNR, S.EKORG, S.DOC_TYPE_CODE, S.STATUS_CODE, S.CURRENCY, S.PO_DATE, S.ITEM_COUNT);
```

The staging table had **18** records. After the MERGE, the target had **41** rows, up from 40. The count of 41 is the result validation; the exact split between updates and inserts was not recorded separately in the history.

![D6-EV01 — MERGE history, 18 staging records](../../../Evidences/LAB_D/D6-EV01-historico-merge-18.jpg)
*D6-EV01 — MERGE statement history over the 18-record staging table.*

![D6-EV02 — Post-MERGE validation, 41 rows](../../../Evidences/LAB_D/D6-EV02-validacao-merge-41.jpg)
*D6-EV02 — Target with 41 rows after the MERGE.*

### D7 — Deduplication with ROW_NUMBER

The table `DUP_PURCHASE_ORDER` had **43** records, with duplicate keys. Deduplication keeps one record per `EBELN`, choosing the most recent `PO_DATE`, using `ROW_NUMBER()`:

```sql
CREATE COLUMN TABLE DBADMIN.DDP_PURCHASE_ORDER AS (
  SELECT EBELN, LIFNR, EKORG, DOC_TYPE_CODE, STATUS_CODE, CURRENCY, PO_DATE, ITEM_COUNT
  FROM (
    SELECT d.*,
           ROW_NUMBER() OVER (PARTITION BY EBELN ORDER BY PO_DATE DESC, STATUS_CODE) AS RN
    FROM DBADMIN.DUP_PURCHASE_ORDER d
  )
  WHERE RN = 1
) WITH DATA;
```

Result: **41** unique records. The 2 removed records are exactly the duplicates on the `EBELN` key.

![D7-EV01 — Deduplication history, 43 to 41](../../../Evidences/LAB_D/D7-EV01-historico-dedup-43-41.jpg)
*D7-EV01 — Deduplication history, from 43 to 41 records.*

![D7-EV02 — Deduplication validation, 41 records](../../../Evidences/LAB_D/D7-EV02-validacao-dedup-41.jpg)
*D7-EV02 — Validation with 41 unique records.*

### D8 — Lineage: what the catalog shows and what it does not

Lineage was investigated with `SYS.OBJECT_DEPENDENCIES`. The catalog showed only one dependency, `DBADMIN.MAT → INDUSTRIAL_DATA.MATERIAL`, created by a synonym. Tables created with `CTAS` **do not generate lineage records in the catalog**.

For this reason, the block's lineage was **documented from the executed statements**, not automatically. This matters for data engineering: the database catalog does not replace lineage documentation maintained by the team.

![D8-EV01 — Dependency catalog in DBADMIN](../../../Evidences/LAB_D/D8-EV01-catalogo-dependencias-dbadmin.jpg)
*D8-EV01 — Dependency query, showing only the synonym relationship.*

### D9 — Remote sources: from zero to TLS

Before D9, the instance had no remote source (`SYS.REMOTE_SOURCES` empty), but the `hanaodbc` adapter was available. The source `HANA_SELF` was created pointing to the instance's own endpoint, with the credential typed by the user:

```sql
CREATE REMOTE SOURCE HANA_SELF ADAPTER "hanaodbc"
CONFIGURATION 'Driver=libodbcHDB.so;
  ServerNode=ea686d62-9946-4aac-a0c4-cbbe65a3f818.hna0.prod-us10.hanacloud.ondemand.com:443;
  encrypt=true;sslValidateCertificate=false'
WITH CREDENTIAL TYPE 'PASSWORD'
USING 'user=DBADMIN;password=YOUR_PASSWORD_HERE';
```

The first attempt, with `sslValidateCertificate=true`, failed with `Cannot create SSL context ... PSE file does not exist`. The PSE (`/tmp/<instance>/sec/sapcli.pse`) cannot be generated in the Trial, so the source was recreated with validation disabled. The connection then worked. This is the block's biggest security risk and is recorded as a lab limitation.

![D9-EV01 — No remote sources, adapters available](../../../Evidences/LAB_D/D9-EV01-fontes-remotas-zero-adapters-10.jpg)
*D9-EV01 — Initial state: no remote source created.*

![D9-EV02 — HANA_SELF source created successfully](../../../Evidences/LAB_D/D9-EV02-criacao-fonte-remota-hana-self-success.png)
*D9-EV02 — `HANA_SELF` source created.*

![D9-EV03 — Recreated without certificate validation](../../../Evidences/LAB_D/D9-EV03-recriacao-fonte-sem-validacao-certificado.png)
*D9-EV03 — Source recreated with `sslValidateCertificate=false`, after the TLS error.*

### D10 — Virtual table: query without copying

The virtual table `VT_PURCHASE_ORDER` points to the remote source. The path required **four parts** (`source.database.schema.table`); with three parts the statement was rejected with a syntax error (dberror 257).

```sql
CREATE VIRTUAL TABLE DBADMIN.VT_PURCHASE_ORDER
  AT "HANA_SELF"."HDB"."INDUSTRIAL_DATA"."PURCHASE_ORDER";
```

Result: **40** rows, identical to the source.

![D10-EV01 — Virtual table created successfully](../../../Evidences/LAB_D/D10-EV01-criacao-tabela-virtual-success.jpg)
*D10-EV01 — Creation of `VT_PURCHASE_ORDER`.*

![D10-EV02 — Virtual table validation, 40 rows](../../../Evidences/LAB_D/D10-EV02-validacao-tabela-virtual-40.jpg)
*D10-EV02 — Query of the virtual table, 40 rows.*

### D11 — Manual replication: the alternative to SDI

Without the Data Provisioning Server, replication was done manually from the virtual table, first as a full load and then incrementally:

```sql
CREATE COLUMN TABLE DBADMIN.REP_PURCHASE_ORDER AS (
  SELECT * FROM DBADMIN.VT_PURCHASE_ORDER
) WITH DATA;
```

The replica has **40** rows and **0** differences from the source. On the incremental rerun, no new rows were loaded (**0** rows), showing the process is safe to repeat.

![D11-EV01 — Full replica load history](../../../Evidences/LAB_D/D11-EV01-historico-replica-carga-completa.jpg)
*D11-EV01 — Full load of the replica.*

![D11-EV02 — Replica validation, 40 rows and 0 differences](../../../Evidences/LAB_D/D11-EV02-validacao-replica-40-0-diferencas.jpg)
*D11-EV02 — Replica with 40 rows and 0 differences.*

![D11-EV03 — Incremental rerun, 0 rows](../../../Evidences/LAB_D/D11-EV03-reexecucao-incremental-0-linhas.jpg)
*D11-EV03 — Incremental rerun returning 0 rows.*

### D12 — Performance: measure before optimizing

With 40 to 300 rows per table, there is no measurable performance difference between strategies. For that reason the focus of D12 was **measuring consumption**, not optimizing. Memory per table was queried in `SYS.M_CS_TABLES` (`RECORD_COUNT` and `MEMORY_SIZE_IN_TOTAL`).

No execution plan was persisted. The `EXPLAIN PLAN` attempt writes to `EXPLAIN_PLAN_TABLE` in the current schema, but that table **did not exist** in the instance, and the query failed with dberror 259 in both `DBADMIN` and `INDUSTRIAL_DATA`. Nothing was persisted. This item remains open for an environment with more volume.

![D12-EV01 — Memory per table in M_CS_TABLES](../../../Evidences/LAB_D/D12-EV01-memoria-por-tabela-m-cs-tables.jpg)
*D12-EV01 — Memory consumption per table, measured in `SYS.M_CS_TABLES`.*

---

## 🗂️ Pipeline structure

```
INDUSTRIAL_DATA.PURCHASE_ORDER (source, 40 rows)
        │
        ├─ D5: initial load (cutoff 2026-04-30) + delta (PO_DATE > ULTIMA_MARCA)
        │       └─ DBADMIN.TGT_PURCHASE_ORDER  ←  DBADMIN.ETL_CONTROL (watermark)
        │
        ├─ D6: MERGE INTO from DBADMIN.STG_PO_DELTA (staging, 18 records)
        ├─ D7: ROW_NUMBER over DBADMIN.DUP_PURCHASE_ORDER (43 → 41 unique)
        │
        ├─ D9/D10: HANA_SELF → VT_PURCHASE_ORDER (virtual table, 40 rows)
        └─ D11: REP_PURCHASE_ORDER (replica by CTAS, 40 rows, 0 differences)

Cross-cutting validation: D1 (reconciliation), D2/D3 (cleansing and transformation), D4 (13 quality rules), D8 (lineage), D12 (memory)
```

---

## 📊 Evidence

| # | Evidence | Scenario | File |
|---|---|---|---|
| 1 | Landing reconciliation (300) | D1 | [D1-EV01](../../../Evidences/LAB_D/D1-EV01-reconciliacao-landing-300.png) |
| 2 | Cleansing validation (300, NA) | D2 | [D2-EV01](../../../Evidences/LAB_D/D2-EV01-validacao-limpeza-300-na.png) |
| 3 | Transformation validation (300) | D3 | [D3-EV01](../../../Evidences/LAB_D/D3-EV01-validacao-transformacao-300.png) |
| 4 | Weight profile and zero-value rules | D3 | [D3-EV02](../../../Evidences/LAB_D/D3-EV02-perfil-pesos-regras-zero.png) |
| 5 | Net percentage, minimum and maximum | D3 | [D3-EV03](../../../Evidences/LAB_D/D3-EV03-percentual-liquido-min-max.png) |
| 6 | Result of the 13 rules (batch 3) | D4 | [D4-EV01](../../../Evidences/LAB_D/D4-EV01-regras-13-resultado-batch3.jpg) |
| 7 | R05 and R03 restored | D4 | [D4-EV02](../../../Evidences/LAB_D/D4-EV02-r05-r03-restaurado.jpg) |
| 8 | Initial load (23) | D5 | [D5-EV01](../../../Evidences/LAB_D/D5-EV01-validacao-carga-inicial-23.jpg) |
| 9 | Delta history (17) | D5 | [D5-EV02](../../../Evidences/LAB_D/D5-EV02-historico-carga-incremental-17.jpg) |
| 10 | Post-delta (40) | D5 | [D5-EV03](../../../Evidences/LAB_D/D5-EV03-validacao-pos-delta-40.jpg) |
| 11 | Delta rerun (0) | D5 | [D5-EV04](../../../Evidences/LAB_D/D5-EV04-reexecucao-delta-0.jpg) |
| 12 | MERGE history (18) | D6 | [D6-EV01](../../../Evidences/LAB_D/D6-EV01-historico-merge-18.jpg) |
| 13 | Post-MERGE validation (41) | D6 | [D6-EV02](../../../Evidences/LAB_D/D6-EV02-validacao-merge-41.jpg) |
| 14 | Deduplication history (43 → 41) | D7 | [D7-EV01](../../../Evidences/LAB_D/D7-EV01-historico-dedup-43-41.jpg) |
| 15 | Deduplication validation (41) | D7 | [D7-EV02](../../../Evidences/LAB_D/D7-EV02-validacao-dedup-41.jpg) |
| 16 | Dependency catalog | D8 | [D8-EV01](../../../Evidences/LAB_D/D8-EV01-catalogo-dependencias-dbadmin.jpg) |
| 17 | Initial remote source state | D9 | [D9-EV01](../../../Evidences/LAB_D/D9-EV01-fontes-remotas-zero-adapters-10.jpg) |
| 18 | `HANA_SELF` source created | D9 | [D9-EV02](../../../Evidences/LAB_D/D9-EV02-criacao-fonte-remota-hana-self-success.png) |
| 19 | Source recreated without certificate validation | D9 | [D9-EV03](../../../Evidences/LAB_D/D9-EV03-recriacao-fonte-sem-validacao-certificado.png) |
| 20 | Virtual table created | D10 | [D10-EV01](../../../Evidences/LAB_D/D10-EV01-criacao-tabela-virtual-success.jpg) |
| 21 | Virtual table (40) | D10 | [D10-EV02](../../../Evidences/LAB_D/D10-EV02-validacao-tabela-virtual-40.jpg) |
| 22 | Full replica load | D11 | [D11-EV01](../../../Evidences/LAB_D/D11-EV01-historico-replica-carga-completa.jpg) |
| 23 | Replica (40, 0 differences) | D11 | [D11-EV02](../../../Evidences/LAB_D/D11-EV02-validacao-replica-40-0-diferencas.jpg) |
| 24 | Incremental rerun (0) | D11 | [D11-EV03](../../../Evidences/LAB_D/D11-EV03-reexecucao-incremental-0-linhas.jpg) |
| 25 | Memory per table (M_CS_TABLES) | D12 | [D12-EV01](../../../Evidences/LAB_D/D12-EV01-memoria-por-tabela-m-cs-tables.jpg) |

---

## ⚠️ Limitations and open items

- **D4:** full definitions of R01, R04, R06–R10 and R12 not recovered. Recover them from the script repository before reusing the batch.
- **D4:** SHIFT scenario divergence: the handoff indicated 3 records, the database showed 0. Not resolved.
- **D4:** hypothesis for the `UD_CODE` status (82 / 23 / 11) not confirmed.
- **D9/D10:** TLS validation disabled (`sslValidateCertificate=false`). Lab use only.
- **D8:** `CTAS` does not generate lineage in the catalog. Lineage is documented manually.
- **D11:** without the Data Provisioning Server on Free Tier, replication is manual via virtual table.
- **D12:** `EXPLAIN PLAN` not persisted; volume too small to measure optimization gains.

## ➡️ Next steps

1. Recover the D4 quality batch text and complete the documentation of R01–R13.
2. Enable TLS certificate validation in an environment that allows generating the PSE.
3. Repeat D12 with larger volume to measure real performance gains.

---

[⬆️ Back to README](../../../README.md)
