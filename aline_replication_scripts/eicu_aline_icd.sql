select pat.patientunitstayid

-- endocarditis
, max(case when icd9code like any (array[
	'%036.42%','%074.22%','%093.20%','%093.21%','%093.22%'
	,'%093.23%','%093.24%','%098.84%'
    ,'%112.81%','%115.04%','%115.14%','%115.94%'
    ,'%391.1%','%421.0%','%421.1%','%421.9%'
    ,'%424.90%','%424.91%','%424.99%'])
  then 1 else 0 end) as endocarditis

-- heart failure
, max(case when icd9code like any (array[
	'%398.91%','%402.01%','%402.91%','%404.91%','%404.13%'
    ,'%404.93%','%428.0%','%428.1%','%428.20%','%428.21%'
    ,'%428.22%','428.23%','%428.30%','%428.31%','%428.32%'
    ,'%428.33%','%428.40%','%428.41%','%428.42%','%428.43%'
    ,'%428.9%','%428%','%428.2%','%428.3%','%428.4%'])
	  then 1 else 0 end) as chf

-- atrial fibrilliation or atrial flutter
, max(case when icd9code like '427.3%' then 1 else 0 end) as afib

-- renal
, max(case when icd9code like '585%' then 1 else 0 end) as renal

-- liver
, max(case when icd9code like '571%' then 1 else 0 end) as liver

-- copd
, max(case when icd9code like any (array[
	'%466.0%','%490%','%491.0%','%491.1%','%491.20%'
    ,'%491.21%','%491.8%','%491.9%','%492.0%','%492.8%'
    ,'%494%','%494.0%','%494.1%','%496%'])
	  then 1 else 0 end) as copd

-- coronary artery disease
, max(case when icd9code like '414%' then 1 else 0 end) as cad

-- stroke
, max(case when icd9code like any (array[
	'%430%', '%431%', '%432%', '%433%', '%434%'])
	  then 1 else 0 end) as stroke
	  
-- malignancy, includes remissions
, max(case when icd9code between '140' and '239' then 1 else 0 end) as malignancy

-- resp failure
, max(case when icd9code like '%518%' then 1 else 0 end) as respfail

-- ARDS
, max(case when icd9code like any (array[
	'%518.82%', '%518.5%'])
	  then 1 else 0 end) as ards
	  
-- pneumonia
, max(case when icd9code between '486' and '488.81'
      or icd9code between '480' and '480.99'
      or icd9code between '482' and '482.99'
      or icd9code between '506' and '507.8'
        then 1 else 0 end) as pneumonia

-- unique patient stays
from eicu_crd.patient pat
left join eicu_crd.diagnosis diag
on pat.patientunitstayid = diag.patientunitstayid
group by pat.patientunitstayid
order by pat.patientunitstayid ASC;