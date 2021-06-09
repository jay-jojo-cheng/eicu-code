DROP MATERIALIZED VIEW IF EXISTS ALINE_ANGUS CASCADE;
CREATE MATERIALIZED VIEW ALINE_ANGUS as

SELECT patientunitstayid, infection, organ_dysfunction, explicit_sepsis, mech_vent,
CASE
	WHEN explicit_sepsis = 1 THEN 1
	WHEN infection = 1 AND organ_dysfunction = 1 THEN 1
	WHEN infection = 1 AND mech_vent = 1 THEN 1
	ELSE 0 END
AS angus
FROM (SELECT patientunitstayid, MAX(infection) as infection,
		MAX(organ_dysfunction) as organ_dysfunction,
		MAX(explicit_sepsis) as explicit_sepsis, MAX(mech_vent) as mech_vent
		FROM (SELECT diag.patientunitstayid,
				CASE
					WHEN SUBSTR(icd9code,1,3) IN ('001','002','003','004','005','008',
						   '009','010','011','012','013','014','015','016','017','018',
						   '020','021','022','023','024','025','026','027','030','031',
						   '032','033','034','035','036','037','038','039','040','041',
						   '090','091','092','093','094','095','096','097','098','100',
						   '101','102','103','104','110','111','112','114','115','116',
						   '117','118','320','322','324','325','420','421','451','461',
						   '462','463','464','465','481','482','485','486','494','510',
						   '513','540','541','542','566','567','590','597','601','614',
						   '615','616','681','682','683','686','730') THEN 1
					WHEN SUBSTR(icd9code,1,4) IN ('569.5','572.0','572.1','575.0','599.0','711.0',
							'790.7','996.6','998.5','999.3') THEN 1
					WHEN SUBSTR(icd9code,1,5) IN ('491.21','562.01','562.03','562.11','562.13',
							'569.83') THEN 1
					ELSE 0 END AS infection,
				CASE
					-- Acute Organ Dysfunction Diagnosis Codes
					WHEN SUBSTR(icd9code,1,3) IN ('458','293','570','584') THEN 1
					WHEN SUBSTR(icd9code,1,4) IN ('785.5','348.3','348.1',
							'287.4','287.5','286.9','286.6','573.4')  THEN 1
					ELSE 0 END AS organ_dysfunction,
					-- Explicit diagnosis of severe sepsis or septic shock
					CASE
					WHEN SUBSTR(icd9code,1,5) IN ('995.92','785.52')  THEN 1
			  		WHEN apacheadmissiondx like '%Sepsis%' THEN 1
					ELSE 0 END AS explicit_sepsis,
				CASE
					WHEN icd9code IN ('967.0', '967.1', '967.2') THEN 1
					ELSE 0 END AS mech_vent
			FROM eicu_crd.diagnosis diag
			  LEFT JOIN eicu_crd.patient pat
			 ON diag.patientunitstayid = pat.patientunitstayid) AS angustemp
		GROUP BY patientunitstayid) AS angustemp2
		order by patientunitstayid;