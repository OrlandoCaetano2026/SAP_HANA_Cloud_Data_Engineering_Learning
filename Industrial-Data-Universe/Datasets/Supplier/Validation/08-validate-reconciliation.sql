-- ============================================================================
-- A4 / DOC 04 - Supplier / Business Partner Foundation
-- Validation 08/08: final reconciliation and end-to-end metrics
-- Confirms total expected records across all A4 entities (~759 new records),
-- cardinality ratios (supplier base, coverage %, distributed assignments),
-- and no duplicate keys or orphaned records across the full model.
-- ============================================================================
SELECT * FROM (
    SELECT 1 AS SORT_ORDER, 'TOTAL_RECORDS' AS CHECK_ITEM, 'SUPPLIER total' AS OBJECT_NAME,
           TO_NVARCHAR(COUNT(*)) AS ACTUAL_VALUE, '70' AS EXPECTED_VALUE,
           CASE WHEN COUNT(*) = 70 THEN 'PASSED' ELSE 'FAILED' END AS VALIDATION_STATUS
    FROM INDUSTRIAL_DATA.SUPPLIER
    UNION ALL
    SELECT 2, 'TOTAL_RECORDS', 'SUPPLIER_PLANT total',
           TO_NVARCHAR(COUNT(*)), '~320',
           CASE WHEN COUNT(*) BETWEEN 300 AND 350 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.SUPPLIER_PLANT
    UNION ALL
    SELECT 3, 'TOTAL_RECORDS', 'SUPPLIER_CONTACT total',
           TO_NVARCHAR(COUNT(*)), '140',
           CASE WHEN COUNT(*) = 140 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.SUPPLIER_CONTACT
    UNION ALL
    SELECT 4, 'TOTAL_RECORDS', 'SUPPLIER_PURCHASING_ORG total',
           TO_NVARCHAR(COUNT(*)), '~120',
           CASE WHEN COUNT(*) BETWEEN 100 AND 140 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.SUPPLIER_PURCHASING_ORG
    UNION ALL
    SELECT 5, 'TOTAL_RECORDS', 'SUPPLIER_RATING total',
           TO_NVARCHAR(COUNT(*)), '~140',
           CASE WHEN COUNT(*) BETWEEN 130 AND 160 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.SUPPLIER_RATING
    UNION ALL
    SELECT 6, 'GRAND_TOTAL', 'Combined A4 records (supplier + contact + assignments + ratings)',
           TO_NVARCHAR(70 + (SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER_PLANT) +
                           (SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER_CONTACT) +
                           (SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER_PURCHASING_ORG) +
                           (SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER_RATING)),
           '~759 total A4 records',
           CASE WHEN 70 + (SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER_PLANT) +
                          (SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER_CONTACT) +
                          (SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER_PURCHASING_ORG) +
                          (SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER_RATING) BETWEEN 740 AND 780
                THEN 'PASSED' ELSE 'FAILED' END
    FROM DUAL
    UNION ALL
    SELECT 7, 'CARDINALITY_RATIO', 'Avg contacts per supplier (should be 2.0)',
           TO_NVARCHAR(ROUND((SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER_CONTACT) /
                            CAST((SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER) AS DECIMAL(5,2)), 2)),
           '2.0',
           'INFO'
    FROM DUAL
    UNION ALL
    SELECT 8, 'CARDINALITY_RATIO', 'Avg plant assignments per supplier (~40% coverage)',
           TO_NVARCHAR(ROUND((SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER_PLANT) /
                            CAST((SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER) AS DECIMAL(5,2)), 2)),
           '~4.6 (40% of ~10–12 plants)',
           'INFO'
    FROM DUAL
    UNION ALL
    SELECT 9, 'CARDINALITY_RATIO', 'Avg org assignments per supplier (~50% coverage)',
           TO_NVARCHAR(ROUND((SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER_PURCHASING_ORG) /
                            CAST((SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER) AS DECIMAL(5,2)), 2)),
           '~1.7 (50% of ~3–4 orgs)',
           'INFO'
    FROM DUAL
    UNION ALL
    SELECT 10, 'CARDINALITY_RATIO', 'Avg rating records per supplier (~2.0)',
           TO_NVARCHAR(ROUND((SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER_RATING) /
                            CAST((SELECT COUNT(*) FROM INDUSTRIAL_DATA.SUPPLIER) AS DECIMAL(5,2)), 2)),
           '~2.0 (2–3 periods per supplier)',
           'INFO'
    FROM DUAL
    UNION ALL
    SELECT 11, 'DUPLICATE_KEYS', 'Duplicate SUPPLIER primary keys (LIFNR)',
           TO_NVARCHAR(COUNT(*)), '0',
           CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END
    FROM (
        SELECT LIFNR, COUNT(*) AS cnt FROM INDUSTRIAL_DATA.SUPPLIER GROUP BY LIFNR HAVING COUNT(*) > 1
    )
    UNION ALL
    SELECT 12, 'DUPLICATE_KEYS', 'Duplicate SUPPLIER_CONTACT PKs (LIFNR, CONTACT_ID)',
           TO_NVARCHAR(COUNT(*)), '0',
           CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END
    FROM (
        SELECT LIFNR, CONTACT_ID, COUNT(*) AS cnt FROM INDUSTRIAL_DATA.SUPPLIER_CONTACT GROUP BY LIFNR, CONTACT_ID HAVING COUNT(*) > 1
    )
    UNION ALL
    SELECT 13, 'ORPHANED_RECORDS', 'SUPPLIER_CONTACT without matching SUPPLIER',
           TO_NVARCHAR(COUNT(*)), '0',
           CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.SUPPLIER_CONTACT SC
    WHERE NOT EXISTS (SELECT 1 FROM INDUSTRIAL_DATA.SUPPLIER S WHERE S.LIFNR = SC.LIFNR)
    UNION ALL
    SELECT 14, 'ORPHANED_RECORDS', 'SUPPLIER_PLANT without matching SUPPLIER',
           TO_NVARCHAR(COUNT(*)), '0',
           CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.SUPPLIER_PLANT SP
    WHERE NOT EXISTS (SELECT 1 FROM INDUSTRIAL_DATA.SUPPLIER S WHERE S.LIFNR = SP.LIFNR)
)
ORDER BY SORT_ORDER, OBJECT_NAME;
