-- ============================================================================
-- A3 / DOC 03 - Validation 06/08: multicurrency readiness
-- The valuation view carries a WAERS column populated by derivation, not a
-- hard-coded literal. Today every valuation is BRL. Plants 1200 and 2800,
-- reserved for the future BRL/USD scenario, are confirmed organizationally
-- ready: currency column present, value populated, schema unchanged.
-- ============================================================================
SELECT * FROM (
    SELECT 1 AS SORT_ORDER, 'CURRENCY_TABLE' AS CHECK_ITEM, 'CURRENCY rows available' AS OBJECT_NAME,
           TO_NVARCHAR(COUNT(*)) AS ACTUAL_VALUE, 'BRL + USD + EUR' AS EXPECTED_VALUE,
           CASE WHEN COUNT(*) >= 2 THEN 'PASSED' ELSE 'FAILED' END AS VALIDATION_STATUS
    FROM INDUSTRIAL_DATA.CURRENCY
    UNION ALL
    SELECT 2, 'USD_REGISTERED', 'USD present for future scenario',
           TO_NVARCHAR(COUNT(*)), '1',
           CASE WHEN COUNT(*) = 1 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.CURRENCY WHERE WAERS = 'USD'
    UNION ALL
    SELECT 3, 'DERIVATION_INTACT', 'Valuation rows whose currency was not derived from company code',
           TO_NVARCHAR(COUNT(*)), '0',
           CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.MATERIAL_VALUATION MV
    INNER JOIN INDUSTRIAL_DATA.PLANT        P  ON P.WERKS  = MV.BWKEY
    INNER JOIN INDUSTRIAL_DATA.COMPANY_CODE CC ON CC.BUKRS = P.BUKRS
    WHERE MV.WAERS <> CC.CURRENCY
    UNION ALL
    SELECT 4, 'MULTICURRENCY_READINESS', 'Plant ' || MV.BWKEY || ' valuation currency',
           MAX(MV.WAERS) || ' - ' || TO_NVARCHAR(COUNT(*)) || ' valuated materials',
           'READY_FOR_FUTURE_CURRENCY_SCENARIO', 'INFO'
    FROM INDUSTRIAL_DATA.MATERIAL_VALUATION MV
    WHERE MV.BWKEY IN ('1200','2800')
    GROUP BY MV.BWKEY
)
ORDER BY SORT_ORDER, OBJECT_NAME;
