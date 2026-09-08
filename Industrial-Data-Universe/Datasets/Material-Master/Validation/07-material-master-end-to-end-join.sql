-- ============================================================================
-- A3 / DOC 03 - Validation 07/08: end-to-end join across A1 + A2 + A3
-- Walks from the client-level material through its language description, down
-- to the plant, across to the company code, into the A2 purchasing group and
-- purchasing organization, and finally into the derived-currency valuation.
-- Two rows per material type cover ROH, HALB, FERT and VERP.
-- ============================================================================
SELECT MATNR, MTART, DESCRICAO_PT, PLANT_COMPANY, PURCH_GROUP_ORG,
       VALUATION, PRICE, BASE_UOM, ALT_UOMS
FROM (
    SELECT
        M.MATNR                                                          AS MATNR,
        M.MTART                                                          AS MTART,
        D.MAKTX                                                          AS DESCRICAO_PT,
        MP.WERKS || ' / ' || P.BUKRS || ' ' || CC.CURRENCY               AS PLANT_COMPANY,
        COALESCE(MP.EKGRP, 'in-house') || ' / ' || COALESCE(PPO.EKORG, '-') AS PURCH_GROUP_ORG,
        MV.BKLAS || ' ' || MV.VPRSV                                      AS VALUATION,
        TO_NVARCHAR(COALESCE(MV.STPRS, MV.VERPR)) || ' ' || MV.WAERS     AS PRICE,
        M.MEINS                                                          AS BASE_UOM,
        TO_NVARCHAR((SELECT COUNT(*) FROM INDUSTRIAL_DATA.MATERIAL_UOM U
                     WHERE U.MATNR = M.MATNR))                           AS ALT_UOMS,
        ROW_NUMBER() OVER (PARTITION BY M.MTART ORDER BY M.MATNR, MP.WERKS) AS RN
    FROM INDUSTRIAL_DATA.MATERIAL M
    INNER JOIN INDUSTRIAL_DATA.MATERIAL_DESCRIPTION D
            ON D.MATNR = M.MATNR AND D.SPRAS = 'PT'
    INNER JOIN INDUSTRIAL_DATA.MATERIAL_PLANT MP
            ON MP.MATNR = M.MATNR
    INNER JOIN INDUSTRIAL_DATA.PLANT P
            ON P.WERKS = MP.WERKS
    INNER JOIN INDUSTRIAL_DATA.COMPANY_CODE CC
            ON CC.BUKRS = P.BUKRS
    INNER JOIN INDUSTRIAL_DATA.MATERIAL_VALUATION MV
            ON MV.MATNR = MP.MATNR AND MV.BWKEY = MP.WERKS AND MV.BWTAR = 'STD'
    LEFT  JOIN INDUSTRIAL_DATA.PURCHASING_GROUP PG
            ON PG.EKGRP = MP.EKGRP
    LEFT  JOIN INDUSTRIAL_DATA.PLANT_PURCHASING_ORG PPO
            ON PPO.WERKS = MP.WERKS AND PPO.ASSIGNMENT_TYPE = 'PRIMARY'
) T
WHERE RN <= 2
ORDER BY MTART, MATNR;
