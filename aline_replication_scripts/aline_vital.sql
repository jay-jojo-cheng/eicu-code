-- this is the last step of the aline dataset replication query
-- it requires aline_cohort and aline_pivoted_labs tables

DROP MATERIALIZED VIEW IF EXISTS ALINE_VITAL CASCADE;
CREATE MATERIALIZED VIEW ALINE_VITAL as

SELECT patientunitstayid, map_first, aline_map_first, nisystolic_first,
nidiastolic_first, hr_first, temp_first, spo2_first, 
(nisystolic_first + 2*nidiastolic_first)/3 as calculated_map_first
FROM

(with vitals as (select co.patientunitstayid,
			  vital.chartoffset vchartoffset, 
			  --vitals
			  meanarterialpressure, arteriallinemap, -- map and invasive map
			  nibp_systolic, nibp_diastolic, -- systoli and diastolic for calculated map
			  heartrate, temperature, spo2
from public.aline_cohort co

left join public.aline_pivoted_vital vital
on co.patientunitstayid = vital.patientunitstayid
	  
where vital.chartoffset <= ventstartoffset
and vital.chartoffset >= ventstartoffset - 1440 -- vitals are taken at most 2 days before the ventilation (cf mimic aline_vitals.sql)
order by co.patientunitstayid, vital.chartoffset desc) 

SELECT
  vitals.patientunitstayid
--vitals
, (ARRAY_AGG(meanarterialpressure ORDER BY vchartoffset desc) FILTER (WHERE meanarterialpressure IS NOT NULL))[1] as map_first
, (ARRAY_AGG(arteriallinemap ORDER BY vchartoffset desc) FILTER (WHERE arteriallinemap IS NOT NULL))[1] as aline_map_first
, (ARRAY_AGG(nibp_systolic ORDER BY vchartoffset desc) FILTER (WHERE nibp_systolic IS NOT NULL))[1] as nisystolic_first
, (ARRAY_AGG(nibp_diastolic ORDER BY vchartoffset desc) FILTER (WHERE nibp_diastolic IS NOT NULL))[1] as nidiastolic_first
, (ARRAY_AGG(heartrate ORDER BY vchartoffset desc) FILTER (WHERE heartrate IS NOT NULL))[1] as hr_first
, (ARRAY_AGG(temperature ORDER BY vchartoffset desc) FILTER (WHERE temperature IS NOT NULL))[1] as temp_first
, (ARRAY_AGG(spo2 ORDER BY vchartoffset desc) FILTER (WHERE spo2 IS NOT NULL))[1] as spo2_first
FROM vitals
GROUP BY vitals.patientunitstayid) as vitaltemp;