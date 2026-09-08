-- ============================================================================
-- A3 / DOC 03 - Material Master Data Foundation
-- Script 07/07 (Load): alternative units of measure (SAP MARM)
-- Target schema : INDUSTRIAL_DATA
-- Conversion    : quantity in base UoM = quantity in alt UoM * UMREZ / UMREN
-- Every material carries a mandatory 1:1 row for its own base unit, exactly
-- as SAP always stores the base unit of measure in MARM.
-- ============================================================================

-- 1) Packaging units required by the alternative conversions -----------------
INSERT INTO INDUSTRIAL_DATA.UNIT_OF_MEASURE VALUES ('BOX','Box','QUANTITY','BX');
INSERT INTO INDUSTRIAL_DATA.UNIT_OF_MEASURE VALUES ('PAL','Pallet','QUANTITY','PF');

-- 2) MATERIAL_UOM (SAP MARM) -----------------------------------------------
CREATE COLUMN TABLE INDUSTRIAL_DATA.MATERIAL_UOM (
    MATNR NVARCHAR(40) NOT NULL,
    MEINH NVARCHAR(3)  NOT NULL,
    UMREZ INTEGER      NOT NULL,
    UMREN INTEGER      NOT NULL,
    PRIMARY KEY (MATNR, MEINH),
    CONSTRAINT FK_MATERIAL_UOM_MATERIAL
        FOREIGN KEY (MATNR) REFERENCES INDUSTRIAL_DATA.MATERIAL (MATNR),
    CONSTRAINT FK_MATERIAL_UOM_UNIT
        FOREIGN KEY (MEINH) REFERENCES INDUSTRIAL_DATA.UNIT_OF_MEASURE (MSEHI),
    CONSTRAINT CHK_MATERIAL_UOM_FACTORS CHECK (UMREZ > 0 AND UMREN > 0)
);

-- 3a) Mandatory base unit row: always 1:1 ---------------------------------
INSERT INTO INDUSTRIAL_DATA.MATERIAL_UOM (MATNR, MEINH, UMREZ, UMREN)
SELECT MATNR, MEINS, 1, 1
FROM INDUSTRIAL_DATA.MATERIAL;

-- 3b) Box: 1 BOX = 12 EA, for every piece-managed material ------------------
INSERT INTO INDUSTRIAL_DATA.MATERIAL_UOM (MATNR, MEINH, UMREZ, UMREN)
SELECT MATNR, 'BOX', 12, 1
FROM INDUSTRIAL_DATA.MATERIAL
WHERE MEINS = 'EA';

-- 3c) Pallet: 1 PAL = 240 EA (20 boxes), finished products and packaging ----
INSERT INTO INDUSTRIAL_DATA.MATERIAL_UOM (MATNR, MEINH, UMREZ, UMREN)
SELECT MATNR, 'PAL', 240, 1
FROM INDUSTRIAL_DATA.MATERIAL
WHERE MEINS = 'EA' AND MTART IN ('FERT','VERP');

COMMIT;
