select * from public.aline_cohort
where patientunitstayid in

(select patientunitstayid from (
  SELECT patientunitstayid,
  ROW_NUMBER() OVER(PARTITION BY patientunitstayid ORDER BY patientunitstayid asc) AS Row
  FROM public.aline_cohort
) dups
where 
dups.Row > 1);

--select count( distinct patientunitstayid) from public.aline_cohort;