-- this is the final dataset. we save this as a csv.
-- to run this, we need echo_eicu_icd and echo_eicu_cohort

select *,

-- ventilated on the fist day (follows ventilation_first_day.sql logic from mimiciii)
case
	when co.patientunitstayid in (select distinct patientunitstayid from eicu_crd.respiratorycare
where ventstartoffset between 0 and 1440 -- ventilation started during the first day
or (ventstartoffset < 0 and ventendoffset > 0) -- ventilation duration overlaps with ICU admission -> vented on admission OR
or (priorventstartoffset < 0 and priorventendoffset > 0) -- sometimes the later entries have the end time
order by patientunitstayid) then 1 else 0 end as vent,

-- vasopressor on the first day
case
	when co.patientunitstayid in (select distinct patientunitstayid from eicu_crd.pivoted_treatment_vasopressor
where chartoffset < 1440) then 1 else 0 end as vaso,

-- cvp flag (central venous pressure flag is 1 if there is a measurement, 0 otherwise)
case
	when co.patientunitstayid in (select distinct patientunitstayid from eicu_crd.vitalperiodic
where cvp is not NULL) then 1 else 0 end as vs_cvp_flag,

-- harder to find labs
-- troponin
case
	when co.patientunitstayid in (select distinct patientunitstayid from eicu_crd.lab
where labname like '%troponin%') then 1 else 0 end as lab_troponin_flag,

-- creatine kinase
case
	when co.patientunitstayid in (select distinct patientunitstayid from eicu_crd.lab
where labname like '%CPK%') then 1 else 0 end as lab_creatine_kinase_flag,

-- BNP
case
	when co.patientunitstayid in (select distinct patientunitstayid from eicu_crd.lab
where labname like '%BNP%') then 1 else 0 end as lab_bnp_flag,

-- sedative
case
	when co.patientunitstayid in (select distinct patientunitstayid from eicu_crd.treatment
where treatmentstring like '%sedative%') then 1 else 0 end as sedative


from echo_eicu_cohort as co

-- apachescore and saps
left join (select distinct patientunitstayid, acutephysiologyscore as saps,
apachescore as apachescore
from eicu_crd.apachepatientresult
order by patientunitstayid) as scores
on co.patientunitstayid = scores.patientunitstayid

-- icu_adm_hour
left join (select patientunitstayid, substr(hospitaladmittime24, 1,2) as icu_adm_hour
from eicu_crd.patient) as admhour
on co.patientunitstayid = admhour.patientunitstayid

-- icd variables
left join echo_eicu_icd as icd
on co.patientunitstayid = icd.patientunitstayid

-- vital variables
-- MAP
-- Note that the aline pivoted vital table is not just run on the final aline cohort
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, meanarterialpressure as vs_map_first
FROM   public.aline_pivoted_vital
where meanarterialpressure is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as vs_map
on co.patientunitstayid = vs_map.patientunitstayid

-- heartrate
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, heartrate as vs_heart_rate_first
FROM   public.aline_pivoted_vital
where heartrate is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as vs_hr
on co.patientunitstayid = vs_hr.patientunitstayid

-- temperature
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, temperature as vs_temp_first
FROM   public.aline_pivoted_vital
where temperature is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as vs_temp
on co.patientunitstayid = vs_temp.patientunitstayid

-- labs
-- chloride
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, chloride as lab_chloride_first
FROM   eicu_crd.pivoted_lab
where chloride is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as labs_cl
on co.patientunitstayid = labs_cl.patientunitstayid

-- creatinine
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, creatinine as lab_creatinine_first
FROM   eicu_crd.pivoted_lab
where creatinine is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as labs_creat
on co.patientunitstayid = labs_creat.patientunitstayid

-- platelets
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, platelets as lab_platelet_first
FROM   eicu_crd.pivoted_lab
where platelets is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as labs_plat
on co.patientunitstayid = labs_plat.patientunitstayid

-- potassium
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, potassium as lab_potassium_first
FROM   eicu_crd.pivoted_lab
where potassium is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as labs_pot
on co.patientunitstayid = labs_pot.patientunitstayid

-- lactate
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, lactate as lab_lactate_first
FROM   eicu_crd.pivoted_lab
where lactate is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as labs_lact
on co.patientunitstayid = labs_lact.patientunitstayid

-- hemoglobin
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, hemoglobin as lab_hemoglobin_first
FROM   eicu_crd.pivoted_lab
where hemoglobin is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as labs_hemo
on co.patientunitstayid = labs_hemo.patientunitstayid

-- sodium
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, sodium as lab_sodium_first
FROM   eicu_crd.pivoted_lab
where sodium is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as labs_na
on co.patientunitstayid = labs_na.patientunitstayid

-- bicarbonate
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, bicarbonate as lab_bicarbonate_first
FROM   eicu_crd.pivoted_lab
where bicarbonate is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as labs_bicarb
on co.patientunitstayid = labs_bicarb.patientunitstayid

-- wbc (white blood cell)
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, wbc as lab_wbc_first
FROM   eicu_crd.pivoted_lab
where wbc is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as labs_wbc
on co.patientunitstayid = labs_wbc.patientunitstayid

-- bun
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, bun as lab_bun_first
FROM   eicu_crd.pivoted_lab
where bun is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as labs_bun
on co.patientunitstayid = labs_bun.patientunitstayid

-- gasses
-- pao2
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, pao2 as lab_po2_first
FROM   eicu_crd.pivoted_bg
where pao2 is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as labs_po2
on co.patientunitstayid = labs_po2.patientunitstayid

-- ph
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, ph as lab_ph_first
FROM   eicu_crd.pivoted_bg
where ph is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as labs_ph
on co.patientunitstayid = labs_ph.patientunitstayid

-- paco2
left join (SELECT DISTINCT ON (patientunitstayid)
	patientunitstayid, paco2 as lab_pco2_first
FROM   eicu_crd.pivoted_bg
where paco2 is not NULL
ORDER  BY patientunitstayid, chartoffset ASC NULLS LAST) as labs_pco2
on co.patientunitstayid = labs_pco2.patientunitstayid

left join eicu_crd.hospital as hos
on co.hospitalid = hos.hospitalid;


