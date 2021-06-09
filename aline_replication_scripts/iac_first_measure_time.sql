DROP MATERIALIZED VIEW IF EXISTS ALINE_FLAG CASCADE;
CREATE MATERIALIZED VIEW ALINE_FLAG as

select patientunitstayid, min(meas_time) iac_first_meastime, 1 as aline_flag
from
((select patientunitstayid, noteoffset as meas_time
from eicu_crd.note
where notetype = 'Arterial Catheter')
UNION
(select patientunitstayid, chartoffset as meas_time
from eicu_crd.pivoted_vital
where (ibp_systolic is not null or ibp_diastolic is not null or ibp_mean is not null))) as uniontemp
group by patientunitstayid
order by patientunitstayid;