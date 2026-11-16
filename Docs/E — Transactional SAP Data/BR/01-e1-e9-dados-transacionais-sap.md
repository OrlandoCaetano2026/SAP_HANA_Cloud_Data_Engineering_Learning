# E1 a E9: Dados Transacionais SAP

**🌐 Idioma / Language:** 🇧🇷 **Português** | [🇺🇸 English](../EN/01-e1-e9-transactional-sap-data.en.md)

[⬆️ Voltar ao README](../../../README.md)

> **Status:** ✅ Entregue (E1 a E9) · ⚠️ Sem evidências em `Evidences/LAB_E/` (ver "Limites desta documentação")
> **Ambiente:** SAP HANA Cloud Trial, schema `INDUSTRIAL_DATA`
> **Origem dos dados:** scripts `Industrial-Data-Universe/Datasets/*/A5…A12-COMPLETE-LOAD.sql` (documentados no DOC 04 do Bloco A)
> **Classificação:** ambiente educacional, dados fictícios, sem dados de produção

## 🎯 Visão executiva

O Bloco E não criou tabelas novas. Seus nove cenários foram **entregues dentro dos scripts A5 a A12** (DOC 04 do Bloco A). Este documento é o mapa que liga cada cenário E às tabelas reais, com contagem de linhas, chaves e o fluxo que as conecta.

| Cenário | Objetivo | Tabelas em `INDUSTRIAL_DATA` | Linhas | Origem |
|---|---|---|---|---|
| E1 | Purchase Orders | `PURCHASE_ORDER`, `PURCHASE_ORDER_ITEM` | 40 / 198 | A5 |
| E2 | Goods Receipt | `GOODS_RECEIPT`, `GOODS_RECEIPT_ITEM` | 25 / 116 | A6 |
| E3 | Material Movements | `MOVEMENT_TYPE` (+ `GOODS_RECEIPT.MOVEMENT_TYPE_CODE`) | 4 tipos; só `101` usado | A6 |
| E4 | Inventory Snapshot | `STOCK_BALANCE` | 110 | A6 |
| E5 | Production Orders | `PRODUCTION_ORDER`, `PRODUCTION_ORDER_COMPONENT`, `PRODUCTION_ORDER_STATUS` | 30 / 124 / 4 | A9 |
| E6 | Production Confirmations | `OPERATION_CONFIRMATION`, `WORK_CENTER`, `SHIFT` | 94 / 10 / 3 | A11 |
| E7 | Inspection Lots | `INSPECTION_LOT`, `INSPECTION_TYPE` | 116 / 3 | A10 |
| E8 | Quality Results | `UD_CODE` (+ `INSPECTION_LOT.UD_CODE`) | 3 códigos | A10 |
| E9 | Warehouse Movements | `WAREHOUSE_TASK`, `HANDLING_UNIT`, `STORAGE_BIN`, `STORAGE_TYPE`, `WAREHOUSE_NUMBER` | 116 / 116 / 100 / 4 / 1 | A12 |

## 🔗 Fluxo transacional

```text
SUPPLIER ─► PURCHASE_ORDER ─► PURCHASE_ORDER_ITEM
                 │
                 ├─► GOODS_RECEIPT ─► GOODS_RECEIPT_ITEM ──► STOCK_BALANCE (por MATNR/WERKS)
                 │        │
                 │        ├─► INSPECTION_LOT ─► UD_CODE (decisão de uso)
                 │        │        │
                 │        │        └─► HANDLING_UNIT ─► WAREHOUSE_TASK ─► STORAGE_BIN
                 │        │
                 └─► SUPPLIER_INVOICE ─► SUPPLIER_INVOICE_ITEM   (A7, Contas a Pagar)

MATERIAL ─► PRODUCTION_ORDER ─► PRODUCTION_ORDER_COMPONENT
                  └─► OPERATION_CONFIRMATION ─► WORK_CENTER, SHIFT
```

## 📚 Cenários

### E1: Purchase Orders (A5)

- `PURCHASE_ORDER` (PK `EBELN`): `LIFNR`, `EKORG`, `DOC_TYPE_CODE`, `STATUS_CODE`, `CURRENCY`, `PO_DATE`, `ITEM_COUNT`.
- `PURCHASE_ORDER_ITEM` (PK `PO_ITEM_ID`, IDENTITY): `EBELN`, `ITEM_NO`, `MATNR`, `WERKS`, `QUANTITY`, `NET_PRICE`, `DELIVERY_DATE`.
- Tipos de pedido (`DOC_TYPE_CODE`): NB 14, FO 13, ZC 13.
- Status (`STATUS_CODE`): RELEASED 20, OPEN 10, CANCELLED 5, CLOSED 5.
- Todos os pedidos estão em `BRL`. `PO_DATE` de 2026-01-06 a 2026-07-20.
- Não há valor total no cabeçalho: ele se deriva de `QUANTITY` × `NET_PRICE` dos itens.

### E2: Goods Receipt (A6)

- `GOODS_RECEIPT` (PK `GR_ID`): `EBELN`, `WERKS`, `MOVEMENT_TYPE_CODE`, `GR_DATE`.
- `GOODS_RECEIPT_ITEM` (PK `GR_ITEM_ID`, IDENTITY): `GR_ID`, `PO_ITEM_NO`, `MATNR`, `WERKS`, `QUANTITY_ORDERED`, `QUANTITY_RECEIVED`, `RECEIPT_PCT`, `BATCH_NO`.
- `GR_DATE` de 2026-01-27 a 2026-08-13. `RECEIPT_PCT` permite recebimento parcial (ex.: 85,00).

### E3: Material Movements (A6)

- `MOVEMENT_TYPE`: `101` Goods Receipt for Purchase Order, `102` Reversal of Goods Receipt, `261` Goods Issue for Consumption, `262` Reversal of Goods Issue.
- Só `101` é usado nos recebimentos (25 de 25). Os demais existem no cadastro sem movimentos.

### E4: Inventory Snapshot (A6)

- `STOCK_BALANCE` (PK `STOCK_ID`, IDENTITY): `MATNR`, `WERKS`, `QUANTITY_ON_HAND`, `LAST_UPDATED`. 110 linhas, todas com `LAST_UPDATED` = 2026-09-18.

### E5: Production Orders (A9)

- `PRODUCTION_ORDER` (PK `AUFNR`): `MATNR`, `WERKS`, `STATUS_CODE`, `QUANTITY_PLANNED`, `QUANTITY_CONFIRMED`, `START_DATE`, `FINISH_DATE`.
- `PRODUCTION_ORDER_COMPONENT` (PK `COMPONENT_ID`, IDENTITY): `AUFNR`, `COMPONENT_NO`, `COMPONENT_MATNR`, `QUANTITY_REQUIRED`, `QUANTITY_CONSUMED`.

### E6: Production Confirmations (A11)

- `OPERATION_CONFIRMATION` (PK `CONFIRMATION_ID`, IDENTITY): `AUFNR`, `OPERATION_NO`, `OPERATION_TEXT`, `WORK_CENTER_ID`, `SHIFT_CODE`, `QUANTITY_GOOD`, `QUANTITY_SCRAP`, `SETUP_TIME_MIN`, `RUN_TIME_MIN`, `CONFIRMATION_DATE`.

### E7: Inspection Lots (A10)

- `INSPECTION_LOT` (PK `LOT_ID`): `GR_ID`, `MATNR`, `WERKS`, `INSPECTION_TYPE_CODE`, `LOT_QUANTITY`, `UD_CODE`, `CREATED_DATE`, `UD_DATE`.
- 116 lotes, todos do tipo `01` (Goods Receipt Inspection). O lote aponta para o cabeçalho do recebimento (`GR_ID`), não para o item.

### E8: Quality Results (A10)

- `UD_CODE`: APPROVED 82, PENDING 23, REJECTED 11 lotes.
- `UD_DATE` é nulo nos 23 lotes `PENDING`.
- Não existem tabelas de características inspecionadas, motivo de rejeição ou certificado.

### E9: Warehouse Movements (A12)

- `WAREHOUSE_TASK` (PK `TASK_ID`, IDENTITY): `HU_ID`, `SOURCE_BIN_ID`, `DEST_BIN_ID`, `TASK_STATUS`, `TASK_DATE`.
- `HANDLING_UNIT` (PK `HU_ID`): `MATNR`, `WERKS`, `LOT_ID` (FK para `INSPECTION_LOT`), `QUANTITY`, `CREATED_DATE`.
- `STORAGE_BIN` (PK `BIN_ID`): `WAREHOUSE_ID`, `WERKS`, `STORAGE_TYPE_CODE`, `AISLE`, `BIN_LEVEL`.

## ✅ Consultas para conferir no banco

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

-- Cadeia PO -> GR -> Lote de inspeção
SELECT po.EBELN, gr.GR_ID, il.LOT_ID, il.UD_CODE
FROM INDUSTRIAL_DATA.PURCHASE_ORDER po
JOIN INDUSTRIAL_DATA.GOODS_RECEIPT gr ON gr.EBELN = po.EBELN
JOIN INDUSTRIAL_DATA.INSPECTION_LOT il ON il.GR_ID = gr.GR_ID
ORDER BY po.EBELN LIMIT 10;
```

Resultado esperado das contagens: 40, 198, 25, 116, 110, 30, 94, 116, 116.

## ⚠️ Limites desta documentação

- O Bloco E **não tem evidências** (`Evidences/LAB_E/` está vazia). As contagens vêm dos scripts versionados, reconciliadas com os números oficiais do DOC 04. Não foram obtidas por consulta ao vivo nesta etapa.
- Não existe script próprio do Bloco E: a entrega está nos scripts A5 a A12.

## 🔭 Referências

- Estrutura completa (DDL, FKs): DOC 04, `Docs/A — Data & SAP-MES Master Data Foundation/BR/04-a4-a12-fundacao-transacional-completa.md`.
- Bloco B (consultas sobre estas tabelas): `Docs/B — SQL for SAP Data/BR/`.
