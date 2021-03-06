select distinct * from eicu_crd.lab;

-- unique patient stays
--from eicu_crd.patient pat
--left join eicu_crd.diagnosis diag
--on pat.patientunitstayid = diag.patientunitstayid
--group by pat.patientunitstayid
--order by pat.patientunitstayid ASC;