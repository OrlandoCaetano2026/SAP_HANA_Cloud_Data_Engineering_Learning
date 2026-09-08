-- ============================================================================
-- A3 / DOC 03 - Material Master Data Foundation
-- Script 03/07 (Load): evolve the MATERIAL client view (SAP MARA)
-- Target schema : INDUSTRIAL_DATA
-- Steps         : 1) add 7 nullable client-level attributes
--                 2) deterministic backfill from MATERIAL_GROUP segment
--                 3) set mandatory attributes to NOT NULL
--                 4) add 5 foreign keys to the A3 check tables
-- MSTAE (cross-plant material status) stays nullable: blank = not blocked.
-- ============================================================================

-- 1) Add client-level attributes (nullable first) -----------------------------
ALTER TABLE INDUSTRIAL_DATA.MATERIAL ADD (
    MBRSH  NVARCHAR(1),
    SPART  NVARCHAR(2),
    PRDHA  NVARCHAR(18),
    MSTAE  NVARCHAR(2),
    BRGEW  DECIMAL(13,3),
    NTGEW  DECIMAL(13,3),
    GEWEI  NVARCHAR(3)
);

-- 2a) Backfill industry sector + division from the material group segment ------
UPDATE INDUSTRIAL_DATA.MATERIAL
SET MBRSH = (
        SELECT CASE G.MATERIAL_GROUP_SEGMENT
                   WHEN 'MECHANICAL' THEN 'M'
                   WHEN 'ELECTRONIC' THEN 'E'
                   WHEN 'CHEMICAL'   THEN 'C'
                   ELSE 'M'
               END
        FROM INDUSTRIAL_DATA.MATERIAL_GROUP G
        WHERE G.MATKL = INDUSTRIAL_DATA.MATERIAL.MATKL
    ),
    SPART = (
        SELECT CASE G.MATERIAL_GROUP_SEGMENT
                   WHEN 'MECHANICAL' THEN '10'
                   WHEN 'ELECTRONIC' THEN '20'
                   WHEN 'CHEMICAL'   THEN '30'
                   WHEN 'PACKAGING'  THEN '40'
                   ELSE '00'
               END
        FROM INDUSTRIAL_DATA.MATERIAL_GROUP G
        WHERE G.MATKL = INDUSTRIAL_DATA.MATERIAL.MATKL
    );

-- 2b) Backfill product hierarchy and synthetic weights (deterministic) --------
UPDATE INDUSTRIAL_DATA.MATERIAL
SET PRDHA = SPART || '-' || MTART || '-' || SUBSTRING(MATKL, 1, 4),
    NTGEW = ROUND(0.250 + MOD(TO_BIGINT(SUBSTRING(MATNR, LOCATE(MATNR, '-') + 1)), 4000) / 80.0, 3),
    BRGEW = ROUND((0.250 + MOD(TO_BIGINT(SUBSTRING(MATNR, LOCATE(MATNR, '-') + 1)), 4000) / 80.0) * 1.05, 3),
    GEWEI = 'KG';

-- 3) Promote mandatory client attributes to NOT NULL -------------------------
ALTER TABLE INDUSTRIAL_DATA.MATERIAL ALTER (MBRSH NVARCHAR(1)   NOT NULL);
ALTER TABLE INDUSTRIAL_DATA.MATERIAL ALTER (SPART NVARCHAR(2)   NOT NULL);
ALTER TABLE INDUSTRIAL_DATA.MATERIAL ALTER (PRDHA NVARCHAR(18)  NOT NULL);
ALTER TABLE INDUSTRIAL_DATA.MATERIAL ALTER (BRGEW DECIMAL(13,3) NOT NULL);
ALTER TABLE INDUSTRIAL_DATA.MATERIAL ALTER (NTGEW DECIMAL(13,3) NOT NULL);
ALTER TABLE INDUSTRIAL_DATA.MATERIAL ALTER (GEWEI NVARCHAR(3)   NOT NULL);

-- 4) Add foreign keys to the check tables ------------------------------------
ALTER TABLE INDUSTRIAL_DATA.MATERIAL ADD CONSTRAINT FK_MATERIAL_MATERIAL_TYPE
    FOREIGN KEY (MTART) REFERENCES INDUSTRIAL_DATA.MATERIAL_TYPE (MTART);
ALTER TABLE INDUSTRIAL_DATA.MATERIAL ADD CONSTRAINT FK_MATERIAL_MATERIAL_GROUP
    FOREIGN KEY (MATKL) REFERENCES INDUSTRIAL_DATA.MATERIAL_GROUP (MATKL);
ALTER TABLE INDUSTRIAL_DATA.MATERIAL ADD CONSTRAINT FK_MATERIAL_BASE_UOM
    FOREIGN KEY (MEINS) REFERENCES INDUSTRIAL_DATA.UNIT_OF_MEASURE (MSEHI);
ALTER TABLE INDUSTRIAL_DATA.MATERIAL ADD CONSTRAINT FK_MATERIAL_WEIGHT_UOM
    FOREIGN KEY (GEWEI) REFERENCES INDUSTRIAL_DATA.UNIT_OF_MEASURE (MSEHI);
ALTER TABLE INDUSTRIAL_DATA.MATERIAL ADD CONSTRAINT FK_MATERIAL_DIVISION
    FOREIGN KEY (SPART) REFERENCES INDUSTRIAL_DATA.DIVISION (SPART);

COMMIT;
