-- ============================================================================
-- A3 / DOC 03 - Material Master Data Foundation
-- Script 05/07 (Load): evolve the MATERIAL_PLANT plant view (SAP MARC)
-- Target schema : INDUSTRIAL_DATA
-- Steps         : 1) add 7 nullable plant-level attributes
--                 2) deterministic backfill, honouring SAP field relevance
--                 3) set unconditionally mandatory attributes to NOT NULL
--                 4) wire EKGRP to the A2 purchasing structure
-- Field relevance (mirrors SAP field selection):
--   EKGRP / PLIFZ  -> only for externally procured materials (BESKZ = 'F')
--   MINBE          -> only for reorder point planning (MRP type 'VB')
--   MMSTA          -> null = not blocked at plant level
-- ============================================================================

-- 1) Add plant-level attributes (nullable first) -----------------------------
ALTER TABLE INDUSTRIAL_DATA.MATERIAL_PLANT ADD (
    DISPO NVARCHAR(3),
    EKGRP NVARCHAR(3),
    MMSTA NVARCHAR(2),
    PLIFZ INTEGER,
    WEBAZ INTEGER,
    EISBE DECIMAL(13,3),
    MINBE DECIMAL(13,3)
);

-- 2a) MRP controller: one per plant -----------------------------------------
UPDATE INDUSTRIAL_DATA.MATERIAL_PLANT
SET DISPO = SUBSTRING(WERKS, 1, 3);

-- 2b) Purchasing group: commodity aligned, external procurement only ---------
UPDATE INDUSTRIAL_DATA.MATERIAL_PLANT
SET EKGRP = (
        SELECT CASE M.MATKL
                   WHEN 'METALS'    THEN 'G01'
                   WHEN 'FASTENERS' THEN 'G01'
                   WHEN 'SHAFTS'    THEN 'G01'
                   WHEN 'CHEMICALS' THEN 'G02'
                   WHEN 'POLYMERS'  THEN 'G02'
                   WHEN 'CABLES'    THEN 'G03'
                   WHEN 'COMM'      THEN 'G03'
                   WHEN 'DISPLAYS'  THEN 'G03'
                   WHEN 'POWER'     THEN 'G03'
                   WHEN 'BEARINGS'  THEN 'G04'
                   WHEN 'FRAMES'    THEN 'G04'
                   WHEN 'GEARS'     THEN 'G04'
                   WHEN 'HOUSINGS'  THEN 'G04'
                   WHEN 'CONTROLS'  THEN 'G05'
                   WHEN 'SENSORS'   THEN 'G05'
                   WHEN 'LABELS'    THEN 'G07'
                   WHEN 'PACKAGING' THEN 'G07'
                   WHEN 'PROTECT'   THEN 'G07'
               END
        FROM INDUSTRIAL_DATA.MATERIAL M
        WHERE M.MATNR = INDUSTRIAL_DATA.MATERIAL_PLANT.MATNR
    )
WHERE PROCUREMENT_TYPE = 'F';

-- 2c) Planned delivery time: external procurement only (7 to 45 days) --------
UPDATE INDUSTRIAL_DATA.MATERIAL_PLANT
SET PLIFZ = 7 + MOD(TO_BIGINT(SUBSTRING(MATNR, LOCATE(MATNR, '-') + 1)) + TO_BIGINT(WERKS), 39)
WHERE PROCUREMENT_TYPE = 'F';

-- 2d) Goods receipt processing time: always relevant (1 to 3 days) ----------
UPDATE INDUSTRIAL_DATA.MATERIAL_PLANT
SET WEBAZ = 1 + MOD(TO_BIGINT(SUBSTRING(MATNR, LOCATE(MATNR, '-') + 1)), 3);

-- 2e) Safety stock: always relevant ---------------------------------------
UPDATE INDUSTRIAL_DATA.MATERIAL_PLANT
SET EISBE = ROUND(10 + MOD(TO_BIGINT(SUBSTRING(MATNR, LOCATE(MATNR, '-') + 1)) + TO_BIGINT(WERKS), 500) / 2.0, 3);

-- 2f) Reorder point: reorder point planning only, always above safety stock --
UPDATE INDUSTRIAL_DATA.MATERIAL_PLANT
SET MINBE = ROUND(EISBE * 2.5, 3)
WHERE MRP_TYPE = 'VB';

-- 3) Promote unconditionally mandatory attributes to NOT NULL ---------------
ALTER TABLE INDUSTRIAL_DATA.MATERIAL_PLANT ALTER (DISPO NVARCHAR(3)   NOT NULL);
ALTER TABLE INDUSTRIAL_DATA.MATERIAL_PLANT ALTER (WEBAZ INTEGER       NOT NULL);
ALTER TABLE INDUSTRIAL_DATA.MATERIAL_PLANT ALTER (EISBE DECIMAL(13,3) NOT NULL);

-- 4) Wire the plant view to the A2 enterprise purchasing structure ----------
ALTER TABLE INDUSTRIAL_DATA.MATERIAL_PLANT ADD CONSTRAINT FK_MATERIAL_PLANT_PURCHASING_GROUP
    FOREIGN KEY (EKGRP) REFERENCES INDUSTRIAL_DATA.PURCHASING_GROUP (EKGRP);

COMMIT;
