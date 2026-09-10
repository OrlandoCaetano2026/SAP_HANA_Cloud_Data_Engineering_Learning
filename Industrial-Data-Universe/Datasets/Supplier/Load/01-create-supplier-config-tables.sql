-- ============================================================================
-- A4 / DOC 04 - Supplier / Business Partner Foundation
-- Script 01/08 (Load): Create Supplier configuration / check tables
-- Target schema : INDUSTRIAL_DATA
-- Purpose       : introduce SAP-style control tables (PAYMENT_TERMS, SUPPLIER_TYPE,
--                 SUPPLIER_STATUS, SUPPLIER_RATING_SCALE) that enforce domain
--                 integrity on the Supplier views in scripts 03–08.
-- Notes         : run once. Does not modify Foundation, Enterprise or Material data.
-- ============================================================================

-- --------------------------------------------------------------------------
-- PAYMENT_TERMS (SAP ZTERM equivalent)
-- Standard payment terms used by suppliers (NET30, NET60, COD, etc)
-- --------------------------------------------------------------------------
CREATE COLUMN TABLE INDUSTRIAL_DATA.PAYMENT_TERMS (
    ZTERM                    NVARCHAR(10) NOT NULL,
    ZTERM_TEXT               NVARCHAR(200) NOT NULL,
    DAYS_DUE                 INTEGER      NOT NULL,
    DISCOUNT_DAYS            INTEGER      NOT NULL,
    DISCOUNT_PERCENT         DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (ZTERM),
    CONSTRAINT CHK_PAYMENT_TERMS_DAYS CHECK (DAYS_DUE >= -1),
    CONSTRAINT CHK_PAYMENT_TERMS_DISCOUNT_DAYS CHECK (DISCOUNT_DAYS >= 0),
    CONSTRAINT CHK_PAYMENT_TERMS_DISCOUNT_PCT CHECK (DISCOUNT_PERCENT >= 0.00 AND DISCOUNT_PERCENT <= 100.00)
);

-- --------------------------------------------------------------------------
-- SUPPLIER_TYPE (control attribute for supplier classification)
-- --------------------------------------------------------------------------
CREATE COLUMN TABLE INDUSTRIAL_DATA.SUPPLIER_TYPE (
    SUPPLIER_TYPE_CODE      NVARCHAR(10) NOT NULL,
    SUPPLIER_TYPE_TEXT      NVARCHAR(100) NOT NULL,
    DESCRIPTION             NVARCHAR(200),
    PRIMARY KEY (SUPPLIER_TYPE_CODE),
    CONSTRAINT CHK_SUPPLIER_TYPE_CODE CHECK (SUPPLIER_TYPE_CODE IN ('ROW','MERCH','SERV','MFG'))
);

-- --------------------------------------------------------------------------
-- SUPPLIER_STATUS (control attribute for supplier operational status)
-- --------------------------------------------------------------------------
CREATE COLUMN TABLE INDUSTRIAL_DATA.SUPPLIER_STATUS (
    STATUS_CODE             NVARCHAR(10) NOT NULL,
    STATUS_TEXT             NVARCHAR(100) NOT NULL,
    DESCRIPTION             NVARCHAR(200),
    PRIMARY KEY (STATUS_CODE),
    CONSTRAINT CHK_SUPPLIER_STATUS_CODE CHECK (STATUS_CODE IN ('ACTIVE','BLOCKED','PENDING'))
);

-- --------------------------------------------------------------------------
-- SUPPLIER_RATING_SCALE (numeric scale 1–5 for rating attributes)
-- --------------------------------------------------------------------------
CREATE COLUMN TABLE INDUSTRIAL_DATA.SUPPLIER_RATING_SCALE (
    RATING_VALUE            INTEGER      NOT NULL,
    RATING_TEXT             NVARCHAR(40) NOT NULL,
    DESCRIPTION             NVARCHAR(100),
    PRIMARY KEY (RATING_VALUE),
    CONSTRAINT CHK_SUPPLIER_RATING_SCALE_VALUE CHECK (RATING_VALUE BETWEEN 1 AND 5)
);