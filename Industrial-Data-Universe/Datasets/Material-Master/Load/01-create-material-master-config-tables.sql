-- ============================================================================
-- A3 / DOC 03 - Material Master Data Foundation
-- Script 01/07 (Load): create Material Master configuration / check tables
-- Target schema : INDUSTRIAL_DATA
-- Purpose       : introduce SAP-style control tables (T134/T134M, T023,
--                 T006, TSPA) that enforce domain integrity on the Material
--                 client view in script 03.
-- Notes         : run once. Does not modify Foundation or Enterprise data.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- MATERIAL_TYPE  (SAP T134 / T134M)
-- Drives default procurement type, price control, valuation class and whether
-- the type is quantity / value updated in the valuation view (script 06).
-- ----------------------------------------------------------------------------
CREATE COLUMN TABLE INDUSTRIAL_DATA.MATERIAL_TYPE (
    MTART                     NVARCHAR(4)  NOT NULL,
    MTART_TEXT                NVARCHAR(40) NOT NULL,
    MATERIAL_TYPE_CLASS       NVARCHAR(20) NOT NULL,
    DEFAULT_PROCUREMENT_TYPE  NVARCHAR(1)  NOT NULL,
    DEFAULT_PRICE_CONTROL     NVARCHAR(1)  NOT NULL,
    DEFAULT_VALUATION_CLASS   NVARCHAR(4)  NOT NULL,
    IS_QTY_UPDATED            NVARCHAR(1)  NOT NULL,
    IS_VALUE_UPDATED          NVARCHAR(1)  NOT NULL,
    INT_NUMBER_RANGE_FROM     NVARCHAR(10) NOT NULL,
    INT_NUMBER_RANGE_TO       NVARCHAR(10) NOT NULL,
    PRIMARY KEY (MTART),
    CONSTRAINT CHK_MATERIAL_TYPE_BESKZ CHECK (DEFAULT_PROCUREMENT_TYPE IN ('E','F','X')),
    CONSTRAINT CHK_MATERIAL_TYPE_VPRSV CHECK (DEFAULT_PRICE_CONTROL IN ('S','V')),
    CONSTRAINT CHK_MATERIAL_TYPE_QTY   CHECK (IS_QTY_UPDATED IN ('Y','N')),
    CONSTRAINT CHK_MATERIAL_TYPE_VALUE CHECK (IS_VALUE_UPDATED IN ('Y','N'))
);

-- ----------------------------------------------------------------------------
-- MATERIAL_GROUP  (SAP T023 / T023T)
-- Normalizes the 24 free-text material groups inherited from A1.
-- ----------------------------------------------------------------------------
CREATE COLUMN TABLE INDUSTRIAL_DATA.MATERIAL_GROUP (
    MATKL                     NVARCHAR(9)  NOT NULL,
    MATKL_TEXT                NVARCHAR(40) NOT NULL,
    MATERIAL_GROUP_SEGMENT    NVARCHAR(20) NOT NULL,
    PRIMARY KEY (MATKL),
    CONSTRAINT CHK_MATERIAL_GROUP_SEGMENT CHECK (MATERIAL_GROUP_SEGMENT IN ('MECHANICAL','ELECTRONIC','CHEMICAL','PACKAGING','GENERAL'))
);

-- ----------------------------------------------------------------------------
-- UNIT_OF_MEASURE  (SAP T006 / T006A)
-- Adds dimension and ISO code to the base units used by MATERIAL.MEINS.
-- ----------------------------------------------------------------------------
CREATE COLUMN TABLE INDUSTRIAL_DATA.UNIT_OF_MEASURE (
    MSEHI                     NVARCHAR(3)  NOT NULL,
    MSEH_TEXT                 NVARCHAR(30) NOT NULL,
    DIMENSION                 NVARCHAR(15) NOT NULL,
    ISO_CODE                  NVARCHAR(3)  NOT NULL,
    PRIMARY KEY (MSEHI),
    CONSTRAINT CHK_UOM_DIMENSION CHECK (DIMENSION IN ('MASS','LENGTH','VOLUME','QUANTITY'))
);

-- ----------------------------------------------------------------------------
-- DIVISION  (SAP TSPA / TSPAT)
-- Client-level classifying attribute referenced by MATERIAL.SPART (script 03).
-- ----------------------------------------------------------------------------
CREATE COLUMN TABLE INDUSTRIAL_DATA.DIVISION (
    SPART                     NVARCHAR(2)  NOT NULL,
    SPART_TEXT                NVARCHAR(40) NOT NULL,
    PRIMARY KEY (SPART)
);
