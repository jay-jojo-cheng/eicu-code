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

DROP MATERIALIZED VIEW IF EXISTS ALINE_COHORT CASCADE;
CREATE MATERIALIZED VIEW ALINE_COHORT as

select distinct on (pat.patientunitstayid) pat.patientunitstayid, pat.patienthealthsystemstayid, pat.uniquepid,
CASE
WHEN aline_flag = 1 then 1
WHEN aline_flag is null then 0
ELSE null END AS aline_flag, iac_first_meastime,
unitdischargetime24, unitdischargeoffset, unitdischargestatus,
ethnicity, age, age_censored_89, gender,
admissionweight, unitadmittime24, ventstartoffset,
pat.hospitalid, wardid, numbedscategory, teachingstatus, region, unittype,
chf, afib, renal, liver, copd, cad, stroke, malignancy, respfail

FROM 

(SELECT *,
CAST ((CASE
	WHEN length(pat0.age)=0 THEN null -- setting blanks to null
	WHEN pat0.age LIKE '> 89' THEN '91' -- mark all ages greater than 89 as 91, we will deal with this censoring in R later
	ELSE pat0.age
END) AS INTEGER) -- cast age in characters to age in integer
 AS age_censored_89

FROM eicu_crd.patient AS pat0) AS pat
LEFT JOIN eicu_crd.respiratorycare AS resp
ON pat.patientunitstayid = resp.patientunitstayid

LEFT JOIN eicu_crd.hospital AS hosp
on pat.hospitalid = hosp.hospitalid

LEFT JOIN public.aline_icd9 as icd
on pat.patientunitstayid = icd.patientunitstayid

LEFT JOIN public.aline_flag as iac
ON pat.patientunitstayid = iac.patientunitstayid

-- Inclusion criteria
WHERE pat.unitstaytype LIKE 'admit' -- first ICU admission, no readmissions, transfers, or stepdowns
AND pat.unitvisitnumber = 1 -- first ICU admission
AND pat.age_censored_89 > 16 -- 'adult' patients (mimic3 aline also uses age 16)
AND pat.unitdischargeoffset > 24*60 -- in ICU for at least 24 hours
AND resp.ventstartoffset BETWEEN 0 AND 24*60 -- vent started within 24 hours, not sure why the replication doc says 12 hours
AND pat.unittype LIKE ANY (array['MICU', 'SICU', 'Med-Surg ICU', 'Neuro ICU']) -- medical, surgical, or MED-SURG ICU admission
-- Note that we also consider Neuro ICU, since many of these patients need ventilation. This is not included in the original
-- replication, as neuro ICUs are a newer category.

-- Exclusion criteria
AND pat.patientunitstayid NOT IN
	(select distinct patientunitstayid
 	from public.aline_angus
 	where angus = 1) -- angus
AND pat.patientunitstayid NOT IN
	(select distinct patientunitstayid
	 from eicu_crd.pivoted_treatment_vasopressor) -- vasopressor use
AND ((iac_first_meastime >= 0) or (iac_first_meastime is null)) -- exclude IAC before admission
-- CSRU admission excluded from the unittype inclusion

order by pat.patientunitstayid, ventstartoffset;