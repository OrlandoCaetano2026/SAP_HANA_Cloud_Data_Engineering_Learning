# E1 to E9: Transactional SAP Data

**🌐 Idioma / Language:** [🇧🇷 Português](../BR/01-e1-e9-dados-transacionais-sap.md) | 🇺🇸 **English**

[⬆️ Back to README](../../../README.en.md)

> **Status:** ✅ Delivered (E1 to E9) · ⚠️ No evidence in `Evidences/LAB_E/` (see "Documentation limits")
> **Environment:** SAP HANA Cloud Trial, schema `INDUSTRIAL_DATA`
> **Data source:** scripts `Industrial-Data-Universe/Datasets/*/A5…A12-COMPLETE-LOAD.sql` (documented in DOC 04 of Block A)
> **Classification:** educational environment, fictional data, no production data

## 🎯 Executive overview

Block E did not create new tables. Its nine scenarios were **delivered inside scripts A5 to A12** (DOC 04 of Block A). This document is the map linking each E scenario to the real tables, with row counts, keys and the flow that connects them.

| Scenario | Objective | Tables in `INDUSTRIAL_DATA` | Rows | Source |
|---|---|---|---|---|
| E1 | Purchase Orders | `PURCHASE_ORDER`, `PURCHASE_ORDER_ITEM` | 40 / 198 | A5 |
| E2 | Goods Receipt | `GOODS_RECEIPT`, `GOODS_RECEIPT_ITEM` | 25 / 116 | A6 |
| E3 | Material Movements | `MOVEMENT_TYPE` (+ `GOODS_RECEIPT.MOVEMENT_TYPE_CODE`) | 4 types; only `101` used | A6 |
| E4 | Inventory Snapshot | `STOCK_BALANCE` | 110 | A6 |
| E5 | Production Orders | `PRODUCTION_ORDER`, `PRODUCTION_ORDER_COMPONENT`, `PRODUCTION_ORDER_STATUS` | 30 / 124 / 4 | A9 |
| E6 | Production Confirmations | `OPERATION_CONFIRMATION`, `WORK_CENTER`, `SHIFT` | 94 / 10 / 3 | A11 |
| E7 | Inspection Lots | `INSPECTION_LOT`, `INSPECTION_TYPE` | 116 / 3 | A10 |
| E8 | Quality Results | `UD_CODE` (+ `INSPECTION_LOT.UD_CODE`) | 3 codes | A10 |
| E9 | Warehouse Movements | `WAREHOUSE_TASK`, `HANDLING_UNIT`, `STORAGE_BIN`, `STORAGE_TYPE`, `WAREHOUSE_NUMBER` | 116 / 116 / 100 / 4 / 1 | A12 |

## 🔗 Transactional flow

```text
SUPPLIER ─► PURCHASE_ORDER ─► PURCHASE_ORDER_ITEM
                 │
                 ├─► GOODS_RECEIPT ─► GOODS_RECEIPT_ITEM ──► STOCK_BALANCE (by MATNR/WERKS)
                 │        │
                 │        ├─► INSPECTION_LOT ─► UD_CODE (usage decision)
                 │        │        │
                 │        │        └─► HANDLING_UNIT ─► WAREHOUSE_TASK ─► STORAGE_BIN
                 │        │
                 └─► SUPPLIER_INVOICE ─► SUPPLIER_INVOICE_ITEM   (A7, Accounts Payable)

MATERIAL ─► PRODUCTION_ORDER ─► PRODUCTION_ORDER_COMPONENT
                  └─► OPERATION_CONFIRMATION ─► WORK_CENTER, SHIFT
```

## 📚 Scenarios

### E1: Purchase Orders (A5)

- `PURCHASE_ORDER` (PK `EBELN`): `LIFNR`, `EKORG`, `DOC_TYPE_CODE`, `STATUS_CODE`, `CURRENCY`, `PO_DATE`, `ITEM_COUNT`.
- `PURCHASE_ORDER_ITEM` (PK `PO_ITEM_ID`, IDENTITY): `EBELN`, `ITEM_NO`, `MATNR`, `WERKS`, `QUANTITY`, `NET_PRICE`, `DELIVERY_DATE`.
- Order types (`DOC_TYPE_CODE`): NB 14, FO 13, ZC 13.
- Status (`STATUS_CODE`): RELEASED 20, OPEN 10, CANCELLED 5, CLOSED 5.
- All orders are in `BRL`. `PO_DATE` from 2026-01-06 to 2026-07-20.
- There is no total value in the header: it is derived from item `QUANTITY` × `NET_PRICE`.

### E2: Goods Receipt (A6)

- `GOODS_RECEIPT` (PK `GR_ID`): `EBELN`, `WERKS`, `MOVEMENT_TYPE_CODE`, `GR_DATE`.
- `GOODS_RECEIPT_ITEM` (PK `GR_ITEM_ID`, IDENTITY): `GR_ID`, `PO_ITEM_NO`, `MATNR`, `WERKS`, `QUANTITY_ORDERED`, `QUANTITY_RECEIVED`, `RECEIPT_PCT`, `BATCH_NO`.
- `GR_DATE` from 2026-01-27 to 2026-08-13. `RECEIPT_PCT` allows partial receipts (e.g. 85.00).

### E3: Material Movements (A6)

- `MOVEMENT_TYPE`: `101` Goods Receipt for Purchase Order, `102` Reversal of Goods Receipt, `261` Goods Issue for Consumption, `262` Reversal of Goods Issue.
- Only `101` is used in receipts (25 of 25). The others exist in the catalog with no movements.

### E4: Inventory Snapshot (A6)

- `STOCK_BALANCE` (PK `STOCK_ID`, IDENTITY): `MATNR`, `WERKS`, `QUANTITY_ON_HAND`, `LAST_UPDATED`. 110 rows, all with `LAST_UPDATED` = 2026-09-18.

### E5: Production Orders (A9)

- `PRODUCTION_ORDER` (PK `AUFNR`): `MATNR`, `WERKS`, `STATUS_CODE`, `QUANTITY_PLANNED`, `QUANTITY_CONFIRMED`, `START_DATE`, `FINISH_DATE`.
- `PRODUCTION_ORDER_COMPONENT` (PK `COMPONENT_ID`, IDENTITY): `AUFNR`, `COMPONENT_NO`, `COMPONENT_MATNR`, `QUANTITY_REQUIRED`, `QUANTITY_CONSUMED`.

### E6: Production Confirmations (A11)

- `OPERATION_CONFIRMATION` (PK `CONFIRMATION_ID`, IDENTITY): `AUFNR`, `OPERATION_NO`, `OPERATION_TEXT`, `WORK_CENTER_ID`, `SHIFT_CODE`, `QUANTITY_GOOD`, `QUANTITY_SCRAP`, `SETUP_TIME_MIN`, `RUN_TIME_MIN`, `CONFIRMATION_DATE`.

### E7: Inspection Lots (A10)

- `INSPECTION_LOT` (PK `LOT_ID`): `GR_ID`, `MATNR`, `WERKS`, `INSPECTION_TYPE_CODE`, `LOT_QUANTITY`, `UD_CODE`, `CREATED_DATE`, `UD_DATE`.
- 116 lots, all of type `01` (Goods Receipt Inspection). The lot points to the receipt header (`GR_ID`), not to the item.

### E8: Quality Results (A10)

- `UD_CODE`: APPROVED 82, PENDING 23, REJECTED 11 lots.
- `UD_DATE` is null in the 23 `PENDING` lots.
- There are no tables for inspected characteristics, rejection reason or certificate.

### E9: Warehouse Movements (A12)

- `WAREHOUSE_TASK` (PK `TASK_ID`, IDENTITY): `HU_ID`, `SOURCE_BIN_ID`, `DEST_BIN_ID`, `TASK_STATUS`, `TASK_DATE`.
- `HANDLING_UNIT` (PK `HU_ID`): `MATNR`, `WERKS`, `LOT_ID` (FK to `INSPECTION_LOT`), `QUANTITY`, `CREATED_DATE`.
- `STORAGE_BIN` (PK `BIN_ID`): `WAREHOUSE_ID`, `WERKS`, `STORAGE_TYPE_CODE`, `AISLE`, `BIN_LEVEL`.

## ✅ Queries to verify in the database

```sql
SELECT 'PURCHASE_ORDER' AS T, COUNT(*) AS N FROM INDUSTRIAL_DATA.PURCHASE_ORDER
UNION ALL SELECT 'PURCHASE_ORDER_ITEM', COUNT(*) FROM INDUSTRIAL_DATA.PURCHASE_ORDER_ITEM
UNION ALL SELECT 'GOODS_RECEIPT', COUNT(*) FROM INDUSTRIAL_DATA.GOODS_RECEIPT
UNION ALL SELECT 'GOODS_RECEIPT_ITEM', COUNT(*) FROM INDUSTRIAL_DATA.GOODS_RECEIPT_ITEM
UNION ALL SELECT 'STOCK_BALANCE', COUNT(*) FROM INDUSTRIAL_DATA.STOCK_BALANCE
UNION ALL SELECT 'PRODUCTION_ORDER', COUNT(*) FROM INDUSTRIAL_DATA.PRODUCTION_ORDER
UNION ALL SELECT 'OPERATION_CONFIRMATION', COUNT(*) FROM INDUSTRIAL_DATA.OPERATION_CONFIRMATION
UNION ALL SELECT 'INSPECTION_LOT', COUNT(*) FROM INDUSTRIAL_DATA.INSPECTION_LOT
UNION ALL SELECT 'WAREHOUSE_TASK', COUNT(*) FROM INDUSTRIAL_DATA.WAREHOUSE_TASK;

-- PO -> GR -> Inspection lot chain
SELECT po.EBELN, gr.GR_ID, il.LOT_ID, il.UD_CODE
FROM INDUSTRIAL_DATA.PURCHASE_ORDER po
JOIN INDUSTRIAL_DATA.GOODS_RECEIPT gr ON gr.EBELN = po.EBELN
JOIN INDUSTRIAL_DATA.INSPECTION_LOT il ON il.GR_ID = gr.GR_ID
ORDER BY po.EBELN LIMIT 10;
```

Expected counts: 40, 198, 25, 116, 110, 30, 94, 116, 116.

## ⚠️ Documentation limits

- Block E **has no evidence** (`Evidences/LAB_E/` is empty). Counts come from the versioned scripts, reconciled with the official DOC 04 numbers. They were not obtained by live query in this step.
- Block E has no script of its own: delivery lives in scripts A5 to A12.

## 🔭 References

- Full structure (DDL, FKs): DOC 04, `Docs/A — Data & SAP-MES Master Data Foundation/EN/04-a4-a12-transactional-data-foundation.en.md`.
- Block B (queries over these tables): `Docs/B — SQL for SAP Data/EN/`.
