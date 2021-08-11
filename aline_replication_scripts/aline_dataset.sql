-- exports the aline dataset to CSV

select co.patientunitstayid, patienthealthsystemstayid, uniquepid, aline_flag, iac_first_meastime,
unitdischargetime24, unitdischargeoffset, unitdischargestatus,
ethnicity, age, age_censored_89, gender, admissionweight, unitadmittime24, ventstartoffset,
hospitalid, wardid, numbedscategory, teachingstatus, region, unittype,
chf, afib, renal, liver, copd, cad, stroke, malignancy, respfail,
sofa_first, sofa_resp, sofa_nerv, sofa_cardio, sofa_liver, sofa_coag, sofa_kidney,
map_first, aline_map_first, calculated_map_first, nisystolic_first, nidiastolic_first,
hr_first, temp_first, spo2_first, bun_first, chloride_first, creatinine_first,
hgb_first, platelet_first, potassium_first, sodium_first, paco2_first, bicarbonate_first,
pao2_first, wbc_first, bilirubin_first
from public.aline_cohort co
left join public.aline_sofa sofa
on co.patientunitstayid = sofa.patientunitstayid
left join public.aline_vital vit
on co.patientunitstayid = vit.patientunitstayid
left join public.aline_lab lab
on co.patientunitstayid = lab.patientunitstayid;