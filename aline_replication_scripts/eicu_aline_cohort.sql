-- replicating ALINE cohort for EICU data which defines the cohort used for the ALINE study.

-- Inclusion criteria:
--  adult patients
--  In ICU for at least 24 hours
--  First ICU admission (patientunitstayid) for the healthsystemstayid
--  mechanical ventilation within the first 12 hours
--  medical or surgical ICU admission

-- Exclusion criteria:
--  **Angus sepsis
--  **On vasopressors (?is this different than on dobutamine)
--  IAC placed before admission
--  CSRU patients

-- **These exclusion criteria are applied in the data.sql file.

-- This query also extracts demographics, and necessary preliminary flags needed
-- for data extraction. For example, since all data is extracted before
-- ventilation, we need to extract start times of ventilation


-- This query requires the following tables:
--  ventdurations - extracted by mimic-code/concepts/durations/ventilation-durations.sql

-- goal: pick the first ICU stay (largest hospitalAdmitOffset) for each hospital admission (patientHealthSystemStayID)

-- I'm a newbie at postgresql, so this needs to be run first.. it will rewrite the actual database
-- which doesn't seem like the best thing to do

-- mark all ages greater than 89 as 90, we will deal with this censoring in R later
-- UPDATE eicu_crd.patient
-- SET age = REPLACE ( age, '> 89', '90');

-- setting blanks to null
-- UPDATE eicu_crd.patient
-- SET age = NULL
-- WHERE age = '';

-- cast age in characters to age in integer
-- ALTER TABLE eicu_crd.patient
-- ALTER COLUMN age SET DATA TYPE INTEGER USING age::integer;

SELECT *
FROM eicu_crd.patient as pat
LEFT JOIN eicu_crd.respiratorycare as resp
ON pat.patientunitstayid = resp.patientunitstayid
-- Inclusion criteria
WHERE pat.unitstaytype LIKE 'admit' -- first ICU admission, no readmissions, transfers, or stepdowns
AND pat.age > 16 -- 'adult' patients (mimic3 aline also uses age 16)
and pat.unitdischargeoffset > 24*60 -- in ICU for at least 24 hours
and resp.ventstartoffset BETWEEN 0 AND 12*60 -- vent started within 12 hours
and pat.unittype LIKE ANY (array['MICU', 'SICU', 'Med-Surg ICU']) -- medical, surgical, or MED-SURG ICU admission
-- Exclusion criteria
order by pat.patientunitstayid;

--select * from eicu_crd.apachepredvar
--order by age ASC;