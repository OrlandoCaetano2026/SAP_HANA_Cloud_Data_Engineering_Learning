# Industrial Data Universe

This directory governs the synthetic industrial universe reused across the project.

| Directory | Responsibility |
|---|---|
| `Blueprint/` | Canonical PT-BR, EN, and machine-readable JSON |
| `Config/` | Approved operational parameters |
| `Schemas/` | Dataset contract and validation rules |
| `Generators/` | Domain generators and validators |
| `Datasets/` | Valid, negative, load, and validation artifacts |
| `Validation/` | Cross-domain validation assets |

Foundation v1 uses seed `20260903`, status `APPROVED`, Validation Engine `PASSED`, and 3,715 records persisted to `LAB_A1`.

## Datasets/ subfolders (A4–A12, see [DOC 04](../Docs/A%20—%20Data%20%26%20SAP-MES%20Master%20Data%20Foundation/EN/04-a4-a12-transactional-data-foundation.en.md))

| Folder | Scenario | Domain |
|---|---|---|
| `Supplier/` | A4 | MM — Supplier / Business Partner |
| `PurchaseOrder/` | A5 | MM — Purchasing (Info Record + PO) |
| `Inventory/` | A6 | MM — Goods Receipt & Stock |
| `AccountsPayable/` | A7 | FI — Supplier Invoice |
| `SalesOrder/` | A8 | SD — Customer & Sales Order |
| `Production/` | A9 | PP — Production Order / MRP |
| `QualityManagement/` | A10 | QM — Inspection Lot / Usage Decision |
| `MES/` | A11 | PP/MES — Work Center & Confirmations |
| `EWM/` | A12 | EWM — Storage Bin, Handling Unit, Warehouse Task |

Each folder holds a single self-contained `A<N>-COMPLETE-LOAD.sql` mega-script (DROP → CREATE → INSERT → validation), executed directly via SAP HANA Cloud Central SQL Console.
