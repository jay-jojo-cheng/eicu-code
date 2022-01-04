# Reproducing the ECHO dataset in eICU

The scripts here reproduce the ECHO study data within the eICU Collaborative Research Database. This recasts the study data for use in metaanalysis and heterogeneous/multi-sourced data methods. The eICU dataset is advantageous for metaanalysis because it includes hundreds of hospitals across the USA, compared to the few hospitals in the Boston area represented in MIMIC.

> Feng, M., McSparron, J.I., Kien, D.T. et al. Transthoracic echocardiography and mortality in sepsis: analysis of the MIMIC-III database. Intensive Care Med 44, 884–892 (2018). https://doi.org/10.1007/s00134-018-5208-7

The original study used the [MIMIC-III database](https://github.com/MIT-LCP/mimic-code).

Reproducing the dataset required rewriting from scratch, due to major differences in schema and data definition. In some cases, covariates cannot be reproduced exactly, but similar variables are substituted when possible.

# Requirements

An installation of eICU database in a PostgreSQL database is required to run these scripts. See [here](https://eicu-crd.mit.edu/gettingstarted/dbsetup/) for setup instructions.

# Recommended usage

The scripts should be run in the following order:
 this is the final dataset. we save this as a csv.
* echo_icd.sql 
* cohort.sql
* other_echo_vars.sql

# Notes on modifications or ambiguities in deriving the data

Some differences between our reproduced dataset and the original MIMIC-II study and/or MIMIC-III version include:

* The original paper uses ALL ECHO, both transthoracic (TTE) and transesophageal (TEE), probably unintentionally, since the article specifies only TTE. We will also use both types of echo to make it comparable to what was done in the analysis and not what was reported in the article.
* APACHE IV scores are used because they supercede SOFA scores
* the weekday of admission is not available in eICU
* eICU has an additional Neuro ICU population that is included here; they are not excluded because it is not a cardio-related ICU
* time to discharge as an outcome (no mortality in eICU)
