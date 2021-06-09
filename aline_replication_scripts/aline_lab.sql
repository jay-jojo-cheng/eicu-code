-- this is the last step of the aline dataset replication query
-- it requires aline_cohort and aline_pivoted_lab

DROP MATERIALIZED VIEW IF EXISTS ALINE_LAB CASCADE;
CREATE MATERIALIZED VIEW ALINE_LAB as

with labs as (select co.patientunitstayid, apvlab.chartoffset labchartoffset,
			  --labs
			  bun, chloride, creatinine, hemoglobin, platelets,
			  potassium, sodium, paco2, bicarbonate, pao2, wbc,
			  bilirubin
from public.aline_cohort co
left join public.aline_pivoted_lab apvlab
on co.patientunitstayid = apvlab.patientunitstayid
	  
where apvlab.chartoffset <= ventstartoffset
and apvlab.chartoffset >= ventstartoffset - 2880 -- labs are taken at most 2 days before the ventilation (cf mimic aline_labs.sql)
order by co.patientunitstayid, apvlab.chartoffset desc) 

SELECT
  labs.patientunitstayid
--labs
, (ARRAY_AGG(bun ORDER BY labchartoffset desc) FILTER (WHERE bun IS NOT NULL))[1] as bun_first
, (ARRAY_AGG(chloride ORDER BY labchartoffset desc) FILTER (WHERE chloride IS NOT NULL))[1] as chloride_first
, (ARRAY_AGG(creatinine ORDER BY labchartoffset desc) FILTER (WHERE creatinine IS NOT NULL))[1] as creatinine_first
, (ARRAY_AGG(hemoglobin ORDER BY labchartoffset desc) FILTER (WHERE hemoglobin IS NOT NULL))[1] as hgb_first
, (ARRAY_AGG(platelets ORDER BY labchartoffset desc) FILTER (WHERE platelets IS NOT NULL))[1] as platelet_first
, (ARRAY_AGG(potassium ORDER BY labchartoffset desc) FILTER (WHERE potassium IS NOT NULL))[1] as potassium_first
, (ARRAY_AGG(sodium ORDER BY labchartoffset desc) FILTER (WHERE sodium IS NOT NULL))[1] as sodium_first
, (ARRAY_AGG(paco2 ORDER BY labchartoffset desc) FILTER (WHERE paco2 IS NOT NULL))[1] as paco2_first
, (ARRAY_AGG(bicarbonate ORDER BY labchartoffset desc) FILTER (WHERE bicarbonate IS NOT NULL))[1] as bicarbonate_first
, (ARRAY_AGG(pao2 ORDER BY labchartoffset desc) FILTER (WHERE pao2 IS NOT NULL))[1] as pao2_first
, (ARRAY_AGG(wbc ORDER BY labchartoffset desc) FILTER (WHERE wbc IS NOT NULL))[1] as wbc_first
, (ARRAY_AGG(bilirubin ORDER BY labchartoffset desc) FILTER (WHERE bilirubin IS NOT NULL))[1] as bilirubin_first
FROM labs
GROUP BY labs.patientunitstayid;