-- ============================================================================
-- A4 / DOC 04 - Supplier / Business Partner Foundation
-- Script 02/08 (Load): populate Supplier configuration / check tables
-- Target schema : INDUSTRIAL_DATA
-- Content       : PAYMENT_TERMS (11 rows), SUPPLIER_TYPE (4 rows),
--                 SUPPLIER_STATUS (3 rows), SUPPLIER_RATING_SCALE (5 rows)
-- ============================================================================

-- Payment Terms (standard SAP ZTERM values) ------------------------------------
INSERT INTO INDUSTRIAL_DATA.PAYMENT_TERMS VALUES ('NET14','14 days net',14,7,2.00);
INSERT INTO INDUSTRIAL_DATA.PAYMENT_TERMS VALUES ('NET30','30 days net',30,10,1.00);
INSERT INTO INDUSTRIAL_DATA.PAYMENT_TERMS VALUES ('NET45','45 days net',45,0,0.00);
INSERT INTO INDUSTRIAL_DATA.PAYMENT_TERMS VALUES ('NET60','60 days net',60,0,0.00);
INSERT INTO INDUSTRIAL_DATA.PAYMENT_TERMS VALUES ('NET90','90 days net',90,0,0.00);
INSERT INTO INDUSTRIAL_DATA.PAYMENT_TERMS VALUES ('COD','Cash on delivery',0,0,0.00);
INSERT INTO INDUSTRIAL_DATA.PAYMENT_TERMS VALUES ('PREPAID','Prepayment required',-1,0,0.00);
INSERT INTO INDUSTRIAL_DATA.PAYMENT_TERMS VALUES ('2NET10','2% discount if paid within 10 days, otherwise net 30',30,10,2.00);
INSERT INTO INDUSTRIAL_DATA.PAYMENT_TERMS VALUES ('1NET15','1% discount if paid within 15 days, otherwise net 45',45,15,1.00);
INSERT INTO INDUSTRIAL_DATA.PAYMENT_TERMS VALUES ('MONTHLY','Monthly invoicing, due on last day of month',30,0,0.00);
INSERT INTO INDUSTRIAL_DATA.PAYMENT_TERMS VALUES ('CONSIGN','Consignment (paid after sale)',0,0,0.00);

-- Supplier Types (classification for different supplier roles) ----------------
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_TYPE (SUPPLIER_TYPE_CODE, SUPPLIER_TYPE_TEXT, DESCRIPTION) VALUES ('ROW','Raw Materials','Suppliers of raw materials and components');
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_TYPE (SUPPLIER_TYPE_CODE, SUPPLIER_TYPE_TEXT, DESCRIPTION) VALUES ('MERCH','Merchant / Trading','Distributors and trading companies');
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_TYPE (SUPPLIER_TYPE_CODE, SUPPLIER_TYPE_TEXT, DESCRIPTION) VALUES ('SERV','Service Provider','Providers of services, maintenance, logistics');
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_TYPE (SUPPLIER_TYPE_CODE, SUPPLIER_TYPE_TEXT, DESCRIPTION) VALUES ('MFG','Contract Manufacturer','Subcontractors for production or assembly');

-- Supplier Status (operational state in the system) ---------------------------
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_STATUS (STATUS_CODE, STATUS_TEXT, DESCRIPTION) VALUES ('ACTIVE','Active','Supplier is actively used for procurement');
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_STATUS (STATUS_CODE, STATUS_TEXT, DESCRIPTION) VALUES ('BLOCKED','Blocked','Supplier is blocked, no new orders');
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_STATUS (STATUS_CODE, STATUS_TEXT, DESCRIPTION) VALUES ('PENDING','Pending Approval','Supplier is under qualification/approval');

-- Rating Scale (1–5 scale for quality, delivery, cost) ------------------------
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_RATING_SCALE VALUES (1,'Poor','Significant issues, needs immediate action');
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_RATING_SCALE VALUES (2,'Below Average','Issues present, improvement needed');
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_RATING_SCALE VALUES (3,'Average','Meets expectations, acceptable performance');
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_RATING_SCALE VALUES (4,'Good','Consistently good performance');
INSERT INTO INDUSTRIAL_DATA.SUPPLIER_RATING_SCALE VALUES (5,'Excellent','Exceeds expectations, best in class');

COMMIT;
