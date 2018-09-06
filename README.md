# Predicting hospital admission at emergency department triage using machine learning
#### Woo Suk Hong, Adrian Haimovich, R. Andrew Taylor

We provide the de-identified dataset and R scripts for the paper "Predicting hospital admission at emergency department triage using machine learning". All processing scripts in the *Scripts/R/* subdirectory take as input *.csv* files extracted from the enterprise data warehouse using SQL queries. The analysis scripts in the main directory take as input the de-identified dataset provided in this repository. The working directory should be set to the main directory with the analysis scripts. **All research using this dataset should cite the original paper.** "Hong WS, Haimovich AD, Taylor RA (2018) Predicting hospital admission at emergency department triage using machine learning. PLoS ONE 13(7): e0201016." (https://doi.org/10.1371/journal.pone.0201016)

[![DOI](https://zenodo.org/badge/128982821.svg)](https://zenodo.org/badge/latestdoi/128982821)


##### Dataset
* **Results/5v_cleandf.RData**: A 560,486 x 972 R dataframe that contains the de-identified dataset used for the analysis portion of the study. Those wishing to explore the data outside R should export the dataframe into a csv file (~ 1.7 GB) using the *write_csv* function in the **readr** package. 

##### Pipeline and Analysis Scripts

* **master.R**: the main processing pipeline that combines data from multiple csv files into one R dataframe, where each row is a patient visit. The pipeline calls on the scripts 1-15 in the */Scripts/R* folder. While the raw data files cannot be uploaded due to protected health information, we encourage those interested to take a look into the processing scripts. 

* **build_boost.R**: trains and ouputs the average AUC on the training and validation sets for an XGBoost model, given a set of hyperparameters. Outputs the design matrix used by all subsequent scripts.

* **build_final.R**: trains an XGBoost model using the optimized set of hyperparameters on all samples excluding the test set then outputs a test AUC with 95% CIs

* **build_keras.R**: trains and ouputs the average accuracy on the training and validation sets for a deep neural network (DNN) model, given the network architecture and other hyperparameters

* **build_final_keras.R**: trains a DNN model using the optimized set of hyperparameters on all samples excluding the test set then outputs a test AUC with 95% CIs

* **build_final_lr.R**: trains a LR model with *keras* using a network with no hidden layer

* **build_importance_ci.R**: trains the final XGBoost model 100 times to get the average information gain for each variable

* **build_boost_topvars.R**: calls on **/Scripts/R/24_usetopvars.R** to train an XGBoost model only using ESI level, outpatient medication counts, demographics, and hospital usage statistics. Outputs the design matrix used by all subsequent "topvars" scripts.

* **build_final_topvars.R**: trains an XGBoost model (only using the top variables) using the optimized set of hyperparameters on all samples excluding the test set then outputs a test AUC with 95% CIs 

* **build_boost_onlytriage.R**, **build_final_onlytriage.R**, **build_boost_onlyhx.R**, **build_final_onlyhx.R**, **build_keras_onlytriage.R**, **build_keras_final_onlytriage.R**, **build_keras_onlyhx.R**, **build_final_keras_onlyhx.R**, **build_final_lr_onlytriage.R**, **build_final_lr_onlyhx.R**: repeats the training process for "Only Triage" variables and "Only History" variables. The XGBoost training scripts should be run first to output the design matrix used for the DNN and LR training scripts.

* **youdens.R**: uses Youden's Index to calculate the sensitivity/specificity/PPV/NPV of each model.




##### Files in */Scripts/R*
###### All processing descriptions apply to each patient visit (i.e. by row) unless specified otherwise.

* **1_cleanbase_cleanesi_cleandemo.R**: creates the initial dataframe of visit ID, patient ID, ESI level, demographic information

* **2_cleantime.R**: extracts the arrival time (month, day, hour, 4-hr bin)

* **3_dispo_timeseries.R**: extracts the disposition of the previous ED visit if this is not the patient's first visit within the past year

* **4_pmhclean_all.R**: takes the list of ICD-9 codes on the patient's EHR at time of visit and recodes it using AHRQ CCS first-level categories such that each column is a CCS category taking a value of 1 or 0 depending on presence or absence of disease

* **6_cleanlabs.R**: cleans the lab csv file to create a dataframe that contains numeric labs ordered during a visit and another dataframe containing urinalysis and culture labs. 

* **7_countpreviousvisits.R**: creates a list of vectors, where each vector contains the IDs of previous visits made by the same patient within one year of visit

* **7b_countadmissions.R**: using the list of vectors of previous visits, counts the number of previous visits and the number of previous admissions within one year of visit

* **8_processhistoricallabs.R**: using the list of vectors of previous visits and the dataframe of numeric labs, extracts the last, min, max, median values of numeric labs ordered within one year of visit

* **10_processhistoricallabs_categorical.R**: using the list of vectors of previous visits and the dataframe of categorical labs, extracts the last value, number of tests, and number of positives for urinalysis and culture labs ordered within one year of visit

* **9_edvitalsclean.R**: cleans all sets of ED vitals for all visits, replacing outliers with missing values

* **9b_gettriagevitals.R**: using the dataframe of cleaned vitals, extracts vitals taken during triage, outputting their mean if more than one set was taken 

* **9c_processhistoricalvitals.R**: using the list of vectors of previous visits and the dataframe of vitals, extracts the last, min, max, median values of ED vitals ordered within one year of visit

* **11_cleanimgekg.R**: recategorizes imaging and EKG orders into 9 columns

* **12_countprevimg.R**: using the list of vectors of previous visits and the dataframe of imaging/EKG orders, counts the number orders per each modality made within one year of visit

* **13_cleanmeds.R**: counts the number of outpatient medications in 48 therapeutic categories

* **14_pshclean.R**: counts the number of procedures/surgeries listed in EHR at time of visit

* **15_chiefcomplaint.R**: adds chief complaint, taking the top 200 most frequently occuring values and binning all others into one

###### The following scripts process the merged dataframe created by **master.R** into a numeric matrix for input to *xgboost* and *keras*

* **20_cleanmerged.R**: cleans the variables in the merged dataframe by reassigning levels for categorical variables with high number of levels and replacing missing values with 0s for count and binary variables such as PMH

* **23_useonlytriage.R**: contains two functions *useonlytriage* and *useonlyhistory* that filter variables belong to each dataset type

* **24_usetopvars.R**: only keeps high information-gain variables identified by the full XGBoost model, namely, ESI, demographics, healthcare usuage statistics, and outpatient medications

* **20b_splitdataindex.R**: returns a list of splits, with a held out test set of 56,000, a validation set of 56,000 and a training set with all remaining samples. The test set is held constant while the validation and training sets are split multiple times for 5-fold cross-validation

* **20c_splitdataindex_testplateau.R**: returns a list of 6 splits with increasing proportions of the training set (1%, 10%, 30%, 50%, 80%, 100%). The held out test set remains the same for all splits.

* **21_makematrix.R**: converts the cleaned dataframe into a numeric matrix and a response vector

* **25_fitboost.R**: worker function for **build_boost.R**

* **26_splitandimpute.R**: centers, scales, and imputes the training, validation and test sets for **build_keras.R** and **build_final_keras.R** using the median values from the training set



