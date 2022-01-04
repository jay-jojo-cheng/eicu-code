DROP MATERIALIZED VIEW IF EXISTS echo_eicu_icd CASCADE;
CREATE MATERIALIZED VIEW echo_eicu_icd as

SELECT patientunitstayid, MAX(icd_chf) as icd_chf, MAX(icd_afib) as icd_afib,
		MAX(icd_renal) as icd_renal, MAX(icd_liver) as icd_liver,
		MAX(icd_copd) as icd_copd, MAX(icd_cad) as icd_cad, MAX(icd_stroke) as icd_stroke,
		MAX(icd_malignancy) as icd_malignancy
		FROM (SELECT diag.patientunitstayid,
			  CASE
			  	when SUBSTR(icd9code,1,6) in
               ('398.91','402.01','402.91','404.91', '404.13', '404.93',
                 '428.20', '428.21', '428.22', '428.23', '428.30', '428.31',
				'428.32', '428.33', '428.40', '428.41', '428.42', '428.43') then 1
			  	WHEN SUBSTR(icd9code,1,5) in ('428.0', '428.1', '428.9',
											  '428.2', '428.3', '428.4') then 1
			  WHEN SUBSTR(icd9code,1,3) in ('428') then 1
               else 0 end as icd_chf,
			  
			  case when icd9code like '427.3%' then 1 else 0 end as icd_afib,
			  case when icd9code like '585%' then 1 else 0 end as icd_renal,
			  case when icd9code like '571%' then 1 else 0 end as icd_liver,
			  case when SUBSTR(icd9code,1,5) in ('466.0', '491.0', '491.1', '491.8', '491.9',
												 '492.0', '492.8', '494.0', '494.1') then 1
			  	when SUBSTR(icd9code,1,6) in ('491.20', '491.21') then 1
			  	when SUBSTR(icd9code,1,3) in ('490', '494', '496') then 1
               else 0 end as icd_copd,
			  case when icd9code like '414%' then 1 else 0 end as icd_cad,
			  case when icd9code like '430%' or icd9code like '431%'
               or icd9code like '432%' or icd9code like '433%'
               or icd9code like '434%'
               then 1 else 0 end as icd_stroke,
			  case when substr(icd9code,1,3) between '140' and '239' then 1 else 0 end as icd_malignancy
			FROM eicu_crd.diagnosis diag
			  LEFT JOIN eicu_crd.patient pat
			 ON diag.patientunitstayid = pat.patientunitstayid) AS icdtemp
		GROUP BY patientunitstayid;