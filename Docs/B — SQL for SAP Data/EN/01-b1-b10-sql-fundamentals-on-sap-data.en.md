# B1 to B10: SQL Fundamentals on SAP Data

**🌐 Language / Idioma:** 🇺🇸 **English** | [🇧🇷 Português](../BR/01-b1-b10-fundamentos-sql-sobre-dados-sap.md)

[⬆️ Back to README](../../../README.md)

> **Status:** ✅ Completed and validated
> **Physical schema:** `INDUSTRIAL_DATA` (same consolidated dataset from Block A)
> **Environment:** SAP HANA Cloud Central → SQL Console
> **Classification:** hands-on practice, no photographic evidence captured — every result was validated interactively and cross-checked against counts already known from Block A

## 🎯 Executive overview

Block B takes the entire relational dataset built in Block A (~7,848 records, 39+ tables, a full procure-to-pay / order-to-cash / manufacturing / quality / warehouse cycle) and uses it as a **SQL practice field**, from fundamentals (`WHERE`, `ORDER BY`) to advanced topics (Window Functions, SQLScript, EXPLAIN PLAN). The methodology in every exercise was the same: **predict the result before running it, execute, and validate by cross-checking against a number already known from an earlier block** — never accept a result just because it "ran without error."

Unlike Block A and Block C, this block produced no formal photographic evidence (practice was 100% interactive, with results validated in real time during the conversation). The value of this document is recording **what** was practiced, **which real pitfalls** appeared, and **which cross-validation numbers** confirmed each concept — so the exercise is reproducible.

| Block | Topic | Core concepts |
|---|---|---|
| B1 | Fundamentals | Table structure, initial schema exploration |
| B2 | DML | `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, autocommit |
| B3 | Filtering & Sorting | `WHERE`, `LIKE`, `BETWEEN`, `IN`, `NOT IN` + NULL trap, `ORDER BY` + NULL |
| B4 | Joins | `INNER JOIN`, `LEFT JOIN`, multi-table JOIN chain, simplification |
| B5 | Aggregations | `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING` |
| B6 | Subqueries & CTEs | Scalar subquery, correlated subquery, `WITH` |
| B7 | Window Functions | `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `PARTITION BY` |
| B8 | Views | Simple `CREATE VIEW` and one with `CASE WHEN` |
| B9 | SQLScript | Parameterized Table Function (`CREATE FUNCTION ... RETURNS TABLE`) |
| B10 | Performance | `EXPLAIN PLAN`, reading an execution plan |

---

## 🧭 Functional storytelling

### B2 — DML and the two environment surprises

Two Cloud Trial behaviors defied expectations coming from other databases:

- **Autocommit with no useful `ROLLBACK`**: Cloud Central commits every statement immediately. An `UPDATE` with no `WHERE` (an intentional error, for learning) couldn't be undone with `ROLLBACK` — in production, the only real fix would be backup/PITR, unavailable on the Free Tier. This isn't a bug, it's the nature of an autocommit environment.
- **`TRUNCATE` doesn't reset `IDENTITY`**: unlike MySQL/SQL Server, HANA keeps the `IDENTITY` sequence after a `TRUNCATE` — inserting after truncating continues numbering from where it left off (e.g. 3 → 4), it doesn't restart at 1.

### B3 — The `NOT IN` with NULL trap

The central exercise of this block was validating, step by step, a JOIN chain (`INSPECTION_LOT → GOODS_RECEIPT → PURCHASE_ORDER → SUPPLIER`) before trusting a `NOT IN` result. Cross-validation:

```sql
-- Total suppliers with inspection history
SELECT DISTINCT S.LIFNR FROM INSPECTION_LOT IL
JOIN GOODS_RECEIPT GR ON IL.GR_ID = GR.GR_ID
JOIN PURCHASE_ORDER S ON GR.EBELN = S.EBELN;
-- 25 suppliers

-- NOT IN (suppliers without inspection)
SELECT LIFNR FROM SUPPLIER WHERE LIFNR NOT IN (...);
-- 45 suppliers → 70 total - 25 = 45 ✅ matches
```

Then, the isolated demonstration of the **NULL trap**:

```sql
SELECT LIFNR FROM SUPPLIER WHERE LIFNR NOT IN ('SUP-001', 'SUP-002', NULL);
-- 0 rows — ALWAYS, for any table
```

**Fixed rule:** if a `NOT IN` subquery can return NULL in its selected column, the entire result silently zeroes out (comparison against NULL becomes `UNKNOWN`, which breaks the `AND` chain). The original JOIN-chain query was safe because `S.LIFNR` is a `NOT NULL` FK — never NULL there, so it never fell into the trap.

The `ORDER BY` + NULL behavior was also validated: **ASC → NULL first; DESC → NULL last** (HANA's default, the opposite of Oracle's default).

### B4 — Joins, from concept to simplification

`INNER JOIN` was broken down by explaining the real execution order (`FROM → JOIN/ON → WHERE → SELECT → ORDER BY → LIMIT`, never the written order). `LEFT JOIN + IS NULL` solved "suppliers without a PO" (30 found, validated against `COUNT(DISTINCT LIFNR) = 40` with a PO → `70 - 40 = 30` ✅).

On the 4-table chain (`SUPPLIER_INVOICE → GOODS_RECEIPT → PURCHASE_ORDER → SUPPLIER`), came a modeling lesson: since `SUPPLIER_INVOICE` already carries a redundant `LIFNR`, the same result comes out with **1 JOIN** instead of 3 — but the two paths carry different meaning (full documentary traceability vs. trusting the redundant field).

### B5 — Aggregations and the WHERE → GROUP BY → HAVING order

```sql
SELECT STATUS_CODE, COUNT(*) FROM PURCHASE_ORDER GROUP BY STATUS_CODE;
-- RELEASED 20 · OPEN 10 · CANCELLED 5 · CLOSED 5 → sums to 40 ✅
```

The practical distinction between `WHERE` (filters before grouping) and `HAVING` (filters after) was cemented with an example combining both in the same query, cross-checked against totals already known from B4.

### B6 — Subqueries and CTEs

Scalar subquery (`WHERE value > (SELECT AVG(...))`), correlated subquery (demonstrating the difference between "outer row doesn't exist" vs. "exists but no match" — the first case makes the row disappear, the second returns NULL), and `WITH` rewriting the same B5.2 logic without repeating the `GROUP BY`.

### B7 — Window Functions

`ROW_NUMBER() OVER (ORDER BY ...)` numbering all 25 invoices without losing a single row (unlike `GROUP BY`, which collapses). `PARTITION BY WERKS` restarting the ranking at every plant (validated across all 20 plants). The classic pitfall — **a window function can't be filtered at the same level where it was computed** (`WHERE RANKING = 1` fails with `invalid column name`) — solved with an outer CTE. Finally, `RANK` vs `DENSE_RANK` vs `ROW_NUMBER` compared side by side on a real tie (`UD_CODE`), showing that `RANK` skips numbers after a tie while `DENSE_RANK` doesn't.

### B8 — Views

A simple `CREATE VIEW` (supplier invoicing summary) and a more robust view with `CASE WHEN` classifying each PO into a 3-way match status (`INVOICED` / `RECEIVED_NOT_INVOICED` / `AWAITING_RECEIPT`), queryable with `GROUP BY` just like a regular table.

### B9 — SQLScript

A parameterized Table Function solved a real question about "dynamic" views in practice: unlike a `VIEW` (always fixed), a function takes a parameter on each call:

```sql
CREATE FUNCTION FN_PO_BY_STATUS(IN P_STATUS NVARCHAR(20))
RETURNS TABLE (...) LANGUAGE SQLSCRIPT AS
BEGIN RETURN SELECT ... WHERE PO.STATUS_CODE = :P_STATUS; END;

SELECT * FROM FN_PO_BY_STATUS('RELEASED');  -- 20 rows
SELECT * FROM FN_PO_BY_STATUS('CANCELLED'); -- 5 rows
```

Both results match exactly the `GROUP BY` from B5.1.

### B10 — Performance

`EXPLAIN PLAN` read bottom-up: `TABLE SCAN` with `FILTER CONDITION` (predicate pushdown — the filter applied while reading, not after) followed by an `INDEX JOIN` (join via primary key, not a blind nested loop). Closed with a summary of best practices accumulated across the whole block (NOT IN vs NOT EXISTS, redundant JOIN, WHERE/HAVING order, window function + CTE).

---

## 📈 Cross-validation numbers used across the block

| Validation | Result |
|---|---:|
| Suppliers with inspection history | 25 |
| Suppliers without inspection (`NOT IN`) | 45 (70 − 25) |
| Suppliers with at least 1 PO | 40 |
| Suppliers without a PO (`LEFT JOIN` + `IS NULL`) | 30 (70 − 40) |
| POs by status | RELEASED 20 · OPEN 10 · CANCELLED 5 · CLOSED 5 (sums to 40) |
| `RELEASED` POs with more than 5 items | 5 (`PO-00039` with 11; 4× with 8) |
| Total invoices | 25 |
| Overall average invoicing | 444,636.35 |
| Plants with ranking restart (`PARTITION BY`) | 20 |

---

[⬆️ Back to README](../../../README.md)
