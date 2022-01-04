DROP MATERIALIZED VIEW IF EXISTS echo_eicu_cohort CASCADE;
CREATE MATERIALIZED VIEW echo_eicu_cohort as

select * from

(select pat.patientunitstayid, gender, age, ethnicity, hospitalid, wardid,
admissionheight, hospitaladmittime24, hospitaladmitoffset, hospitaladmitsource,
hospitaldischargeyear, hospitaldischargetime24, hospitaldischargeoffset,
hospitaldischargestatus, unittype, unitadmittime24, admissionweight,
dischargeweight, unitdischargetime24, unitdischargeoffset, unitdischargestatus,
age_censored_89, echo_trt, echo_include from 

(SELECT *,
CAST ((CASE
	WHEN length(pat0.age)=0 THEN null -- setting blanks to null
	WHEN pat0.age LIKE '> 89' THEN '91' -- mark all ages greater than 89 as 91, we will deal with this censoring in R later
	ELSE pat0.age
END) AS INTEGER) -- cast age in characters to age in integer
 AS age_censored_89
FROM eicu_crd.patient AS pat0) AS pat

left join angus on pat.patientunitstayid = angus.patientunitstayid
left join (select pat.patientunitstayid,
CASE WHEN bool_and(cardioecho.treatmentoffset is null) or bool_or(cardioecho.treatmentoffset between -1440 and pat.unitdischargeoffset) THEN 1
		   ELSE 0 END AS echo_include,
CASE WHEN bool_and(cardioecho.treatmentoffset is null) THEN 0 ELSE 1 END AS echo_trt
from eicu_crd.patient as pat
left join (select * from eicu_crd.treatment
where treatmentstring LIKE '%echo%'
or treatmentstring LIKE '%diagnostic ultrasound of heart%') as cardioecho
on pat.patientunitstayid = cardioecho.patientunitstayid
group by pat.patientunitstayid) as echo_between
on pat.patientunitstayid = echo_between.patientunitstayid
left join (with firstIcu as (
     SELECT  uniquepid
                , patienthealthsystemstayid
                , patientunitstayid
                , row_number() OVER (PARTITION BY uniquepid, patienthealthsystemstayid ORDER BY unitvisitnumber) AS first_icu
     FROM eicu_crd.patient
)
SELECT  --uniquepid
           --, patienthealthsystemstayid
           --,
		   patientunitstayid, first_icu
FROM  firstIcu
    WHERE first_icu = 1) as firsticu
 on pat.patientunitstayid = firsticu.patientunitstayid
 
-- compare the following with fig 1 STROBE diagram from the echo paper
where angus = 1 -- sepsis patients from angus definition
and age_censored_89 >= 18 -- adult patients
and first_icu = 1
and pat.unittype LIKE ANY (array['MICU', 'SICU', 'Med-Surg ICU', 'Neuro ICU']) -- medical, surgical, or MED-SURG ICU admission
-- Note that we also consider Neuro ICU. This is category is not available in MIMIC replication, as neuro ICUs are a newer category.
)
 as echo_temp
 where echo_include = 1 -- remove those only with echos 24 hours before admission or after discharge
; 