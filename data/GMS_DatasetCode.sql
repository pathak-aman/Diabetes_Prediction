  
  /* dropped an old variable 
  alter table CombinedData_1
  DROP COLUMN Age; */
  
 /* adding Diabetes Dx column - modified Mardini's code to give unique patients only*/
/* select condition_occurrence.condition_concept_id, concept.concept_name as condition_name, count(distinct condition_occurrence.person_id) as disease_count
from condition_occurrence, concept
where condition_occurrence.condition_concept_id = concept.concept_id 
and
concept_name like '%diabete%'
group by condition_occurrence.condition_concept_id, concept.concept_name 
having count(distinct condition_occurrence.person_id) 
order by disease_count DESC; */


#creating binary variable for drugs#
CREATE TABLE PersonDrugIndicator AS
SELECT
    person_id,
    MAX(CASE WHEN drug_concept_id IN (19080793, 19079990, 40166816,19077636, 19077638) THEN 1 ELSE 0 END) AS Glipizide_Indicator,
    MAX(CASE WHEN drug_concept_id IN (1597761, 1597772, 1597773) THEN 1 ELSE 0 END) AS Glimepiride_Indicator,
    MAX(CASE WHEN drug_concept_id IN (1559685, 19079986, 19077659, 19077681, 40166002, 40166003, 19077682, 19077684) THEN 1 ELSE 0 END) AS Glyburide_Indicator,
    MAX(CASE WHEN drug_concept_id IN (40164897, 40164929, 40164930, 40164946, 40164947, 40163924, 40163928) THEN 1 ELSE 0 END) AS Metformin_Indicator,
    MAX(CASE WHEN drug_concept_id IN (19079293,1525221, 1525216) THEN 1 ELSE 0 END) AS Pioglitazone_Indicator,
    MAX(CASE WHEN drug_concept_id IN (1547508, 1547505, 19079465, 1547506) THEN 1 ELSE 0 END) AS Rosiglitazone_Indicator,
    MAX(CASE WHEN drug_concept_id IN (1547508, 1547505, 19079465, 1547506, 19079293,1525221, 1525216,
    40164897, 40164929, 40164930, 40164946, 40164947, 40163924, 40163928, 1559685, 19079986, 19077659, 19077681, 40166002, 40166003, 19077682, 19077684,
    1597761, 1597772, 1597773, 19080793, 19079990, 40166816,19077636, 19077638) THEN 1 ELSE 0 END) AS DMDrug_Indicator
FROM
    drug_exposure
GROUP BY
    person_id;

#creating binary variable for procedure#
CREATE TABLE ProcedureIndicator AS
SELECT
    person_id,
    MAX(CASE WHEN procedure_concept_id IN (4064918) THEN 1 ELSE 0 END) AS DMScreen_Indicator
FROM
    procedure_occurrence
GROUP BY
    person_id;
    
#creating binary variable for Lab Tests#
CREATE TABLE LabIndicator AS
SELECT
    person_id,
    MAX(CASE WHEN measurement_concept_id IN (2212392, 2212393) THEN 1 ELSE 0 END) AS A1C_Indicator,
    MAX(CASE WHEN measurement_concept_id IN (2212359, 2212367, 2212363, 2212360, 2212361, 2212362, 2212366) THEN 1 ELSE 0 END) AS GlucoseTest_Indicator,
    MAX(CASE WHEN measurement_concept_id IN (2212418, 2212803, 2212156) THEN 1 ELSE 0 END) AS InsulinTest_Indicator,
    MAX(CASE WHEN measurement_concept_id IN (2212418, 2212803, 2212156, 2212359, 2212367, 2212363, 2212360, 2212361, 2212362, 2212366, 2212392, 2212393) THEN 1 ELSE 0 END) AS AnyLab_Indicator
FROM
    measurement
GROUP BY
    person_id;
    
#creating binary variable dor diabetes Dx#
CREATE TABLE DiabetesIndicator AS
SELECT
    person_id,
    MAX(CASE WHEN condition_concept_id IN (201826, 40482801, 195771, 201254, 376065, 443732, 443729, 443731, 435216, 40484648, 318712, 443734, 200687, 377821, 443735, 373999, 201530, 443733, 443730, 321822, 439770, 201531, 4228112, 443592, 438476, 30968, 201820) THEN 1 ELSE 0 END) AS Diabetes_Indicator
FROM
    condition_occurrence
GROUP BY
    person_id;
    
#combine#
CREATE TABLE Dataset_1 AS
SELECT 
    person.*,
    PersonDrugIndicator.Glipizide_Indicator,  PersonDrugIndicator.Glimepiride_Indicator,  PersonDrugIndicator.Glyburide_Indicator,
     PersonDrugIndicator.Metformin_Indicator,  PersonDrugIndicator.Pioglitazone_Indicator,  PersonDrugIndicator.Rosiglitazone_Indicator, PersonDrugIndicator.DMDrug_Indicator,
    ProcedureIndicator.DMScreen_Indicator,
    LabIndicator.A1C_Indicator,  LabIndicator.GlucoseTest_Indicator,  LabIndicator.InsulinTest_Indicator,  LabIndicator.AnyLab_Indicator, 
    DiabetesIndicator.Diabetes_Indicator
FROM 
    person
LEFT JOIN 
    PersonDrugIndicator ON person.person_id = PersonDrugIndicator.person_id 
LEFT JOIN 
    ProcedureIndicator ON person.person_id = ProcedureIndicator.person_id 
LEFT JOIN 
    LabIndicator ON person.person_id = LabIndicator.person_id
LEFT JOIN 
    DiabetesIndicator ON person.person_id = DiabetesIndicator.person_id;
  


 CREATE TABLE GMS4 AS
SELECT 
    Dataset_1.*,
    location.state,
    CASE
        WHEN gender_concept_id = 8507 THEN 1 /*female*/
        WHEN gender_concept_id = 8532 THEN 2 /*male*/
        ELSE NULL  -- Handle other values if necessary
    END AS GenderCategory,
    
    CASE
        WHEN race_concept_id = 8527 THEN 1 /*White*/
        WHEN race_concept_id = 8516 THEN 2 /*Black*/
        ELSE 3  -- Assuming 3 for 'Unknown'
    END AS RaceCategory,
    
    CASE
        WHEN ethnicity_concept_id = 38003564 THEN 1 /*Non-Hispanic*/
        WHEN ethnicity_concept_id = 38003563 THEN 2 /*Hispanic*/
        ELSE 3  -- Assuming 3 for 'Unknown'
    END AS EthnicityCategory,
    
    CASE
        WHEN year_of_birth IS NOT NULL THEN 2023 - year_of_birth
        ELSE NULL  -- Handle missing or invalid birth years
    END AS Age,
    
    CASE 
        WHEN state IN ('CT', 'ME', 'MA', 'NH', 'RI', 'VT', 'NJ', 'NY', 'PA') THEN '1' /*Northeast*/
        WHEN state IN ('IL', 'IN', 'MI', 'OH', 'WI', 'IA', 'KS', 'MN', 'MO', 'NE', 'ND', 'SD') THEN '2' /*Midwest*/
        WHEN state IN ('DE', 'FL', 'GA', 'MD', 'NC', 'SC', 'VA', 'DC', 'WV', 'AL', 'KY', 'MS', 'TN', 'AR', 'LA', 'OK', 'TX') THEN '3' /*South*/
        WHEN state IN ('AZ', 'CO', 'ID', 'MT', 'NV', 'NM', 'UT', 'WY', 'AK', 'CA', 'HI', 'OR', 'WA') THEN '4' /*West*/
        ELSE '5'  -- Handle other cases if needed
    END AS Region
    
FROM 
    Dataset_1
LEFT JOIN 
    location ON Dataset_1.location_id = location.location_id;
    
      
 select * from GMS4; 