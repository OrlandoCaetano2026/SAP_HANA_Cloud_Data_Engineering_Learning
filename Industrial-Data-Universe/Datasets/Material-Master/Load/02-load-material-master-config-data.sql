-- ============================================================================
-- A3 / DOC 03 - Material Master Data Foundation
-- Script 02/07 (Load): populate Material Master configuration / check tables
-- Target schema : INDUSTRIAL_DATA
-- Content       : 4 material types, 24 material groups, 4 units of measure,
--                 5 divisions - matching the exact A1 material population.
-- Number ranges : aligned to the real A1 material numbering. ROH spans three
--                 prefixes (RM 100001-100080, EC 200001-200060,
--                 MC 300001-300060), so ROH uses one wide interval.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- MATERIAL_TYPE : control attributes per SAP material type
-- BESKZ  E = in-house, F = external, X = both
-- VPRSV  S = standard price, V = moving average price
-- ----------------------------------------------------------------------------
INSERT INTO INDUSTRIAL_DATA.MATERIAL_TYPE VALUES ('ROH','Raw material','RAW','F','V','3000','Y','Y','100000','399999');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_TYPE VALUES ('HALB','Semi-finished product','SEMIFINISHED','X','S','7900','Y','Y','400000','499999');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_TYPE VALUES ('FERT','Finished product','FINISHED','E','S','7920','Y','Y','500000','599999');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_TYPE VALUES ('VERP','Packaging material','PACKAGING','F','V','3030','Y','Y','600000','699999');

-- ----------------------------------------------------------------------------
-- UNIT_OF_MEASURE : base units used by MATERIAL.MEINS (ISO codes per UN/ECE)
-- ----------------------------------------------------------------------------
INSERT INTO INDUSTRIAL_DATA.UNIT_OF_MEASURE VALUES ('EA','Each','QUANTITY','PCE');
INSERT INTO INDUSTRIAL_DATA.UNIT_OF_MEASURE VALUES ('KG','Kilogram','MASS','KGM');
INSERT INTO INDUSTRIAL_DATA.UNIT_OF_MEASURE VALUES ('L','Litre','VOLUME','LTR');
INSERT INTO INDUSTRIAL_DATA.UNIT_OF_MEASURE VALUES ('M','Metre','LENGTH','MTR');

-- ----------------------------------------------------------------------------
-- DIVISION : client-level classifying attribute (SAP SPART)
-- ----------------------------------------------------------------------------
INSERT INTO INDUSTRIAL_DATA.DIVISION VALUES ('00','Cross-Division');
INSERT INTO INDUSTRIAL_DATA.DIVISION VALUES ('10','Mechanical Components');
INSERT INTO INDUSTRIAL_DATA.DIVISION VALUES ('20','Electronic Components');
INSERT INTO INDUSTRIAL_DATA.DIVISION VALUES ('30','Chemical Products');
INSERT INTO INDUSTRIAL_DATA.DIVISION VALUES ('40','Packaging');

-- ----------------------------------------------------------------------------
-- MATERIAL_GROUP : the 24 groups actually present in the A1 material data
-- Segment drives the client-view division assignment in script 03.
-- ----------------------------------------------------------------------------
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('BEARINGS','Bearings','MECHANICAL');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('CABLES','Cables and wiring','ELECTRONIC');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('CHEMICALS','Industrial chemicals','CHEMICAL');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('COMM','Communication components','ELECTRONIC');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('CONTROLS','Control components','ELECTRONIC');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('DISPLAYS','Display units','ELECTRONIC');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('FASTENERS','Fasteners','MECHANICAL');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('FRAMES','Structural frames','MECHANICAL');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('GEARS','Gears and transmission','MECHANICAL');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('HOUSINGS','Housings and enclosures','MECHANICAL');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('METALS','Metal raw material','MECHANICAL');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('POLYMERS','Polymers and plastics','CHEMICAL');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('POWER','Power components','ELECTRONIC');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('SENSORS','Sensors','ELECTRONIC');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('SHAFTS','Shafts','MECHANICAL');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('ASSEMBLY','Mechanical assemblies','MECHANICAL');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('MODULE','Electronic modules','ELECTRONIC');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('SUBSYS','Subsystems','ELECTRONIC');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('EQUIPMENT','Industrial equipment','MECHANICAL');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('SOLUTIONS','Integrated solutions','GENERAL');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('SYSTEMS','Integrated systems','ELECTRONIC');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('LABELS','Labels and marking','PACKAGING');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('PACKAGING','Packaging material','PACKAGING');
INSERT INTO INDUSTRIAL_DATA.MATERIAL_GROUP VALUES ('PROTECT','Protective material','PACKAGING');

COMMIT;
