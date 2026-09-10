-- ============================================================================
-- A4 / DOC 04 - Supplier / Business Partner Foundation
-- Script 06/08 (Load): create and populate SUPPLIER_CONTACT (bilingual EN+PT)
-- Target schema : INDUSTRIAL_DATA
-- Purpose       : store contact persons per supplier in two languages
--                 EN: inherited synthetic pattern; PT: localized for Brazil
-- ============================================================================

DROP TABLE INDUSTRIAL_DATA.SUPPLIER_CONTACT;

CREATE COLUMN TABLE INDUSTRIAL_DATA.SUPPLIER_CONTACT (
    LIFNR                   NVARCHAR(10) NOT NULL,
    CONTACT_ID              NVARCHAR(10) NOT NULL,
    CONTACT_NAME_LANGUAGE   NVARCHAR(100) NOT NULL,
    CONTACT_LANGUAGE       NVARCHAR(2)  NOT NULL,
    CONTACT_EMAIL          NVARCHAR(100),
    CONTACT_PHONE          NVARCHAR(20),
    CONTACT_DEPARTMENT     NVARCHAR(30) NOT NULL,
    PRIMARY_CONTACT        NVARCHAR(1)  NOT NULL,
    PRIMARY KEY (LIFNR, CONTACT_ID),
    CONSTRAINT FK_SUPPLIER_CONTACT_SUPPLIER
        FOREIGN KEY (LIFNR) REFERENCES INDUSTRIAL_DATA.SUPPLIER (LIFNR),
    CONSTRAINT CHK_SUPPLIER_CONTACT_LANG CHECK (CONTACT_LANGUAGE IN ('EN','PT')),
    CONSTRAINT CHK_SUPPLIER_CONTACT_DEPT CHECK (CONTACT_DEPARTMENT IN ('SALES','QUALITY','LOGISTICS','BILLING')),
    CONSTRAINT CHK_SUPPLIER_CONTACT_PRIMARY CHECK (PRIMARY_CONTACT IN ('Y','N'))
);

-- English contacts (EN) - synthetic base from A1 pattern ----------------------
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_CONTACT
    (LIFNR, CONTACT_ID, CONTACT_NAME_LANGUAGE, CONTACT_LANGUAGE, CONTACT_EMAIL, CONTACT_PHONE, CONTACT_DEPARTMENT, PRIMARY_CONTACT)
SELECT
    LIFNR,
    'C001' AS CONTACT_ID,
    CASE MOD(CAST(SUBSTRING(LIFNR, 5) AS INT), 8)
        WHEN 0 THEN 'Robert Smith'
        WHEN 1 THEN 'James Wilson'
        WHEN 2 THEN 'Michael Johnson'
        WHEN 3 THEN 'David Brown'
        WHEN 4 THEN 'William Davis'
        WHEN 5 THEN 'Joseph Garcia'
        WHEN 6 THEN 'Charles Martinez'
        ELSE 'Thomas Anderson'
    END AS CONTACT_NAME_LANGUAGE,
    'EN' AS CONTACT_LANGUAGE,
    LOWER(REPLACE(CASE MOD(CAST(SUBSTRING(LIFNR, 5) AS INT), 8)
        WHEN 0 THEN 'robert.smith'
        WHEN 1 THEN 'james.wilson'
        WHEN 2 THEN 'michael.johnson'
        WHEN 3 THEN 'david.brown'
        WHEN 4 THEN 'william.davis'
        WHEN 5 THEN 'joseph.garcia'
        WHEN 6 THEN 'charles.martinez'
        ELSE 'thomas.anderson'
    END, '.', '_')) || '@' || REPLACE(LOWER(SUBSTRING(LIFNR_TEXT, 1, 15)), ' ', '') || '.com' AS CONTACT_EMAIL,
    '+55 11 ' || LPAD(CAST(MOD(CAST(SUBSTRING(LIFNR, 5) AS INT) * 97, 99999) AS NVARCHAR), 5, '0') AS CONTACT_PHONE,
    CASE MOD(CAST(SUBSTRING(LIFNR, 5) AS INT), 4)
        WHEN 0 THEN 'SALES'
        WHEN 1 THEN 'QUALITY'
        WHEN 2 THEN 'LOGISTICS'
        ELSE 'BILLING'
    END AS CONTACT_DEPARTMENT,
    'Y' AS PRIMARY_CONTACT
FROM INDUSTRIAL_DATA.SUPPLIER;

-- Portuguese contacts (PT) - localized for Brazil ---------------------------
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_CONTACT
    (LIFNR, CONTACT_ID, CONTACT_NAME_LANGUAGE, CONTACT_LANGUAGE, CONTACT_EMAIL, CONTACT_PHONE, CONTACT_DEPARTMENT, PRIMARY_CONTACT)
SELECT
    LIFNR,
    'C002' AS CONTACT_ID,
    CASE MOD(CAST(SUBSTRING(LIFNR, 5) AS INT), 8)
        WHEN 0 THEN 'João da Silva'
        WHEN 1 THEN 'José Santos'
        WHEN 2 THEN 'Carlos Oliveira'
        WHEN 3 THEN 'Pedro Costa'
        WHEN 4 THEN 'António Ferreira'
        WHEN 5 THEN 'Francisco Martins'
        WHEN 6 THEN 'Manuel Pereira'
        ELSE 'Miguel Gomes'
    END AS CONTACT_NAME_LANGUAGE,
    'PT' AS CONTACT_LANGUAGE,
    LOWER(REPLACE(CASE MOD(CAST(SUBSTRING(LIFNR, 5) AS INT), 8)
        WHEN 0 THEN 'joao.silva'
        WHEN 1 THEN 'jose.santos'
        WHEN 2 THEN 'carlos.oliveira'
        WHEN 3 THEN 'pedro.costa'
        WHEN 4 THEN 'antonio.ferreira'
        WHEN 5 THEN 'francisco.martins'
        WHEN 6 THEN 'manuel.pereira'
        ELSE 'miguel.gomes'
    END, '.', '_')) || '@' || REPLACE(LOWER(SUBSTRING(LIFNR_TEXT, 1, 15)), ' ', '') || '.com.br' AS CONTACT_EMAIL,
    '+55 11 ' || LPAD(CAST(MOD(CAST(SUBSTRING(LIFNR, 5) AS INT) * 101, 99999) AS NVARCHAR), 5, '0') AS CONTACT_PHONE,
    CASE MOD(CAST(SUBSTRING(LIFNR, 5) AS INT) + 1, 4)
        WHEN 0 THEN 'SALES'
        WHEN 1 THEN 'QUALITY'
        WHEN 2 THEN 'LOGISTICS'
        ELSE 'BILLING'
    END AS CONTACT_DEPARTMENT,
    'N' AS PRIMARY_CONTACT
FROM INDUSTRIAL_DATA.SUPPLIER;

COMMIT;
