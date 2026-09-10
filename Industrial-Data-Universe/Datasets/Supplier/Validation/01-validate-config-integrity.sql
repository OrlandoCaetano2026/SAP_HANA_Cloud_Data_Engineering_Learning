-- ============================================================================
-- A4 / DOC 04 - Supplier / Business Partner Foundation
-- Validation 01/08: configuration / check tables integrity
-- Confirms the 4 check tables are populated with expected cardinality,
-- payment terms have valid day ranges, and rating scales are complete 1–5.
-- ============================================================================
SELECT * FROM (
    SELECT 1 AS SORT_ORDER, 'ROW_COUNT' AS CHECK_ITEM, 'PAYMENT_TERMS' AS OBJECT_NAME,
           TO_NVARCHAR(COUNT(*)) AS ACTUAL_VALUE, '11' AS EXPECTED_VALUE,
           CASE WHEN COUNT(*) = 11 THEN 'PASSED' ELSE 'FAILED' END AS VALIDATION_STATUS
    FROM INDUSTRIAL_DATA.PAYMENT_TERMS
    UNION ALL
    SELECT 2, 'ROW_COUNT', 'SUPPLIER_TYPE', TO_NVARCHAR(COUNT(*)), '4',
           CASE WHEN COUNT(*) = 4 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.SUPPLIER_TYPE
    UNION ALL
    SELECT 3, 'ROW_COUNT', 'SUPPLIER_STATUS', TO_NVARCHAR(COUNT(*)), '3',
           CASE WHEN COUNT(*) = 3 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.SUPPLIER_STATUS
    UNION ALL
    SELECT 4, 'ROW_COUNT', 'SUPPLIER_RATING_SCALE', TO_NVARCHAR(COUNT(*)), '5',
           CASE WHEN COUNT(*) = 5 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.SUPPLIER_RATING_SCALE
    UNION ALL
    SELECT 5, 'PAYMENT_TERMS_DAYS', 'Invalid day ranges (negative except PREPAID)',
           TO_NVARCHAR(COUNT(*)), '0',
           CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.PAYMENT_TERMS
    WHERE DAYS_DUE < -1 OR (ZTERM <> 'PREPAID' AND DAYS_DUE < 0)
    UNION ALL
    SELECT 6, 'PAYMENT_TERMS_DISCOUNT', 'Discount percent > 100%',
           TO_NVARCHAR(COUNT(*)), '0',
           CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.PAYMENT_TERMS
    WHERE DISCOUNT_PERCENT > 100.00
    UNION ALL
    SELECT 7, 'RATING_SCALE_COMPLETE', 'Rating scale values 1–5 all present',
           TO_NVARCHAR(COUNT(DISTINCT RATING_VALUE)), '5',
           CASE WHEN COUNT(DISTINCT RATING_VALUE) = 5 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.SUPPLIER_RATING_SCALE
    WHERE RATING_VALUE BETWEEN 1 AND 5
)
ORDER BY SORT_ORDER, OBJECT_NAME;
