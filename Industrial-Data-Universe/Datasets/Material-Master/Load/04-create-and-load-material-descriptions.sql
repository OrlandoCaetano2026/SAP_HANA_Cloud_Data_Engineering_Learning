-- ============================================================================
-- A3 / DOC 03 - Material Master Data Foundation
-- Script 04/07 (Load): create and load MATERIAL_DESCRIPTION (SAP MAKT)
-- Target schema : INDUSTRIAL_DATA
-- Grain         : MATNR + SPRAS (language key)
-- Content       : 300 EN + 300 PT = 600 rows
-- EN text reuses the original A1 material description (lineage preserved).
-- PT text is derived from the material group, keeping the pair a real
-- translation of the same business object.
-- ============================================================================

CREATE COLUMN TABLE INDUSTRIAL_DATA.MATERIAL_DESCRIPTION (
    MATNR NVARCHAR(40) NOT NULL,
    SPRAS NVARCHAR(2)  NOT NULL,
    MAKTX NVARCHAR(40) NOT NULL,
    PRIMARY KEY (MATNR, SPRAS),
    CONSTRAINT FK_MATERIAL_DESCRIPTION_MATERIAL
        FOREIGN KEY (MATNR) REFERENCES INDUSTRIAL_DATA.MATERIAL (MATNR),
    CONSTRAINT CHK_MATERIAL_DESCRIPTION_SPRAS CHECK (SPRAS IN ('EN','PT'))
);

-- English descriptions: inherited from the A1 material master ------------------
INSERT INTO INDUSTRIAL_DATA.MATERIAL_DESCRIPTION (MATNR, SPRAS, MAKTX)
SELECT M.MATNR, 'EN', SUBSTRING(M.DESCRIPTION, 1, 40)
FROM INDUSTRIAL_DATA.MATERIAL M;

-- Portuguese descriptions: localized per material group -----------------------
INSERT INTO INDUSTRIAL_DATA.MATERIAL_DESCRIPTION (MATNR, SPRAS, MAKTX)
SELECT M.MATNR, 'PT',
       CASE M.MATKL
           WHEN 'BEARINGS'  THEN 'Rolamentos'
           WHEN 'CABLES'    THEN 'Cabos e fiação'
           WHEN 'CHEMICALS' THEN 'Produtos químicos'
           WHEN 'COMM'      THEN 'Componentes de comunicação'
           WHEN 'CONTROLS'  THEN 'Componentes de controle'
           WHEN 'DISPLAYS'  THEN 'Unidades de display'
           WHEN 'FASTENERS' THEN 'Fixadores'
           WHEN 'FRAMES'    THEN 'Estruturas metálicas'
           WHEN 'GEARS'     THEN 'Engrenagens e transmissão'
           WHEN 'HOUSINGS'  THEN 'Carcaças e gabinetes'
           WHEN 'METALS'    THEN 'Matéria-prima metálica'
           WHEN 'POLYMERS'  THEN 'Polímeros e plásticos'
           WHEN 'POWER'     THEN 'Componentes de potência'
           WHEN 'SENSORS'   THEN 'Sensores'
           WHEN 'SHAFTS'    THEN 'Eixos'
           WHEN 'ASSEMBLY'  THEN 'Conjuntos mecânicos'
           WHEN 'MODULE'    THEN 'Módulos eletrônicos'
           WHEN 'SUBSYS'    THEN 'Subsistemas'
           WHEN 'EQUIPMENT' THEN 'Equipamento industrial'
           WHEN 'SOLUTIONS' THEN 'Soluções integradas'
           WHEN 'SYSTEMS'   THEN 'Sistemas integrados'
           WHEN 'LABELS'    THEN 'Etiquetas e marcação'
           WHEN 'PACKAGING' THEN 'Material de embalagem'
           WHEN 'PROTECT'   THEN 'Material de proteção'
       END || ' ' || SUBSTRING(M.MATNR, LOCATE(M.MATNR, '-') + 1)
FROM INDUSTRIAL_DATA.MATERIAL M;

COMMIT;
