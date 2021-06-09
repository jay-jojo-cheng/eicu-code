--aline gcs

-- this is the last step of the aline dataset replication query
-- it requires aline_cohort and aline_pivoted_labs tables

DROP MATERIALIZED VIEW IF EXISTS ALINE_GCS CASCADE;
CREATE MATERIALIZED VIEW ALINE_GCS as

with gcs as (select co.patientunitstayid,
			  score.chartoffset, 
			  --vitals
			  gcs
from public.aline_cohort co

left join eicu_crd.pivoted_score score
on co.patientunitstayid = score.patientunitstayid
	  
where score.chartoffset <= ventstartoffset
and score.chartoffset >= ventstartoffset - 1440 -- gcs noted at most 1 days before the ventilation (cf mimic aline_sofa.sql)
order by co.patientunitstayid, score.chartoffset desc) 

SELECT
  gcs.patientunitstayid
--vitals
, (ARRAY_AGG(gcs ORDER BY chartoffset desc) FILTER (WHERE gcs IS NOT NULL))[1] as gcs_first
FROM gcs
GROUP BY gcs.patientunitstayid;