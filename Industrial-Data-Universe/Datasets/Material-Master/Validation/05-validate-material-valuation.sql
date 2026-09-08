-- ============================================================================
-- A3 / DOC 03 - Validation 05/08: MATERIAL_VALUATION (SAP MBEW)
-- Confirms 1080 valuation records, currency derived from the company code
-- with zero divergence, price control consistent with procurement type, and
-- reports the price range per material type.
-- ============================================================================
SELECT * FROM (
    SELECT 1 AS SORT_ORDER, 'ROW_COUNT' AS CHECK_ITEM, 'MATERIAL_VALUATION' AS OBJECT_NAME,
           TO_NVARCHAR(COUNT(*)) AS ACTUAL_VALUE, '1080' AS EXPECTED_VALUE,
           CASE WHEN COUNT(*) = 1080 THEN 'PASSED' ELSE 'FAILED' END AS VALIDATION_STATUS
    FROM INDUSTRIAL_DATA.MATERIAL_VALUATION
    UNION ALL
    SELECT 2, 'CURRENCY_DERIVATION', 'Valuation currency differing from company code',
           TO_NVARCHAR(COUNT(*)), '0',
           CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.MATERIAL_VALUATION MV
    INNER JOIN INDUSTRIAL_DATA.PLANT        P  ON P.WERKS  = MV.BWKEY
    INNER JOIN INDUSTRIAL_DATA.COMPANY_CODE CC ON CC.BUKRS = P.BUKRS
    WHERE MV.WAERS <> CC.CURRENCY
    UNION ALL
    SELECT 3, 'PRICE_CONTROL_VS_PROCUREMENT', 'Price control inconsistent with procurement type',
           TO_NVARCHAR(COUNT(*)), '0',
           CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END
    FROM INDUSTRIAL_DATA.MATERIAL_VALUATION MV
    INNER JOIN INDUSTRIAL_DATA.MATERIAL_PLANT MP ON MP.MATNR = MV.MATNR AND MP.WERKS = MV.BWKEY
    WHERE NOT ( (MV.VPRSV = 'V' AND MP.PROCUREMENT_TYPE = 'F')
             OR (MV.VPRSV = 'S' AND MP.PROCUREMENT_TYPE <> 'F') )
    UNION ALL
    SELECT 4, 'VALUATION_BY_TYPE', M.MTART || ' / ' || MV.BKLAS || ' / ' || MV.VPRSV,
           TO_NVARCHAR(COUNT(*)) || ' rows',
           TO_NVARCHAR(MIN(COALESCE(MV.STPRS, MV.VERPR))) || ' - ' ||
           TO_NVARCHAR(MAX(COALESCE(MV.STPRS, MV.VERPR))) || ' ' || MAX(MV.WAERS),
           'INFO'
    FROM INDUSTRIAL_DATA.MATERIAL_VALUATION MV
    INNER JOIN INDUSTRIAL_DATA.MATERIAL M ON M.MATNR = MV.MATNR
    GROUP BY M.MTART, MV.BKLAS, MV.VPRSV
    UNION ALL
    SELECT 5, 'CURRENCY_SPREAD', 'Distinct currencies in valuation',
           TO_NVARCHAR(COUNT(DISTINCT WAERS)), '1 (BRL today)', 'INFO'
    FROM INDUSTRIAL_DATA.MATERIAL_VALUATION
)
ORDER BY SORT_ORDER, OBJECT_NAME;
