DROP MATERIALIZED VIEW IF EXISTS ALINE_SOFA CASCADE;
CREATE MATERIALIZED VIEW ALINE_SOFA as

select patientunitstayid,
sofa_resp + sofa_nerv + sofa_cardio + sofa_liver + sofa_coag + sofa_kidney as sofa_first,
sofa_resp, sofa_nerv, sofa_cardio, sofa_liver, sofa_coag, sofa_kidney
from

(select *,

case
when pao2_first >= 400 then 0
when pao2_first >= 300 and pao2_first < 400 then 1
when pao2_first >= 200 and pao2_first < 300 then 2
when pao2_first >= 100 and pao2_first < 200 then 3
when pao2_first < 100 then 4
else 0 end
as sofa_resp,

case
when gcs_first = 15 then 0
when gcs_first between 13 and 14 then 1
when gcs_first between 10 and 12 then 2
when gcs_first between 6 and 9 then 3
when gcs_first < 6 then 4
else 0 end
as sofa_nerv,

case
when map_first < 70 or aline_map_first < 70 or calculated_map_first < 70 then 1
when map_first >= 70 and aline_map_first >= 70 and calculated_map_first >= 70 then 0
else 0 end
as sofa_cardio,

case
when bilirubin_first < 1.2 then 0
when bilirubin_first >= 1.2 and bilirubin_first < 2 then 1
when bilirubin_first >= 2 and bilirubin_first < 6 then 2
when bilirubin_first >= 6 and bilirubin_first < 12 then 3
when bilirubin_first >= 12 then 4
else 0 end
as sofa_liver,

case
when platelet_first >= 150 then 0
when platelet_first >= 100 and platelet_first < 150 then 1
when platelet_first >= 50 and platelet_first < 100 then 2
when platelet_first >= 20 and platelet_first < 50 then 3
when platelet_first < 20 then 4
else 0 end
as sofa_coag,

case
when creatinine_first < 1.2 then 0
when creatinine_first >= 1.2 and creatinine_first < 2 then 1
when creatinine_first >= 2 and creatinine_first < 3.5 then 2
when creatinine_first >= 3.5 and creatinine_first < 5 then 3
when creatinine_first >= 5 then 4
else 0 end
as sofa_kidney

from
(select co.patientunitstayid, pao2_first, gcs_first, map_first, aline_map_first, calculated_map_first,
 bilirubin_first, platelet_first, creatinine_first
from aline_cohort co
left join aline_lab lab
on co.patientunitstayid = lab.patientunitstayid
left join aline_gcs gcs
on co.patientunitstayid = gcs.patientunitstayid
left join aline_vital vital
on co.patientunitstayid = vital.patientunitstayid) as sofatemp) as sofatemp2;