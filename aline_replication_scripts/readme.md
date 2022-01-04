# Reproducing the ALINE dataset in eICU

The scripts here reproduce the ALINE study data within the eICU Collaborative Research Database. This recasts the study data for use in metaanalysis and heterogeneous/multi-sourced data methods. The eICU dataset is advantageous for metaanalysis because it includes hundreds of hospitals across the USA, compared to the few hospitals in the Boston area represented in MIMIC.

> Hsu DJ, Feng M, Kothari R, Zhou H, Chen KP, Celi LA. The association between indwelling arterial catheters and mortality in hemodynamically stable patients with respiratory failure: a propensity score analysis. CHEST Journal. 2015 Dec 1;148(6):1470-6.

The original study used the MIMIC-II database. Later the code was reproduced within the [MIMIC-III database](https://github.com/MIT-LCP/mimic-code).

Reproducing the dataset required rewriting virtually all queries from scratch, due to major differences in schema and data definition. In some cases, covariates cannot be reproduced exactly, but similar variables are substituted when possible.

# Requirements

An installation of eICU database in a PostgreSQL database is required to run these scripts. See [here](https://eicu-crd.mit.edu/gettingstarted/dbsetup/) for setup instructions.

# Recommended usage

The scripts should be run in the following order:
* angus.sql
* eicu_aline_cohort.sql
* aline_lab.sql
* aline_gcs.sql
* aline_vital.sql
* aline_sofa.sql
* aline_dataset.sql

# Notes on modifications or ambiguities in deriving the data

Some differences between our reproduced dataset and the original MIMIC-II study and/or MIMIC-III version include:

* the inclusion criteria for the original paper is adults, but in the MIMIC-III replication, age 16+ seems to be used. We will use age 16+ here.
* the original ALINE study uses PCO2, Bicarb, and PO2 and MIMIC-III replication only uses TCO2. We go with the original paper and use PCO2, Bicarb, and PO2 to match clinical practice.
* the MIMIC-III replication contains CSRU patients which were excluded from the original study. In this data we go with the original paper and choose only the MICU and SICU patients. The EICU database also has the following units which we rule out: cardiac ICU, coronary care unit-cardiothoracic ICU (CCU-CTICU), cardiothoracic ICU (CTICU), neuro ICU, cardiac surgery ICU (CSICU), so we will only get MICU, SICU, and Med-Surg ICU.
* time to discharge as an outcome (no mortality in eICU)
* APACHE IV scores are used because they supercede SOFA scores
* the weekday of admission is not available in eICU
