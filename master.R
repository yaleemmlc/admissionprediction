#Pipeline: takes all our data and outputs one master.csv, where each row represents a unique patient encounter
library(dplyr)
library(readr)
library(reshape2)
library(lubridate)
library(parallel)


# set up our parallel processors. We will be using mclapply.
n.cores <- 5

#1) process base, esi, and demographics csv files
source('./Scripts/R/1_cleanbase_cleanesi_cleandemo.R')
basepath <- './Data/base_list_bydepartment.csv'
esipath <- './Data/esi.csv'
demopath <- './Data/demo.csv'

master <- left_join(cleanbase(basepath), cleanesi(esipath)) %>%
        left_join(cleandemo(demopath))

print(paste(Sys.time(), 'Base, ESI, demographics processing complete'))

#2) process time variables, join to master
source('./Scripts/R/2_cleantime.R')
timepath <- './Data/time_info.csv'

master <- left_join(master, cleantime(timepath))

print(paste(Sys.time(),'Time variables processing complete'))


#3) get previous dispo
source('./Scripts/R/3_dispo_timeseries.R')

master <- left_join(master, getdispo(master))

print(paste(Sys.time(),'Previous dispo processing complete'))


#4) process PMH (diagnosis codes), join to master
source('./Scripts/R/4_pmhclean_all.R')
pmhpath <- './Data/pmh2.csv'
icd9path <- './Web_data/$dxref 2015_2.csv'

master <- left_join(master, cleanpmh(pmhpath, icd9path, master))

print(paste(Sys.time(), 'PMH processing complete'))


#5) clean past_labs.csv
source('./Scripts/R/6_cleanlabs.R')
labspath <- './Data/past_labs.csv'
lab_list <- cleanlabs(labspath, master)
num_labs <- lab_list[[1]]
cat_labs <- lab_list[[2]]
rm(lab_list)

print(paste(Sys.time(), 'Labs cleaning complete'))


#6) create a list of previous encounters within 1 year, save it for later use

load('./Results/previous.RData')

# source('./Scripts/R/7_countpreviousvisits.R')
# previous <- countprevious(master)
# #save 'previous' since this is the bottleneck
# print("Saving previous")
# save(previous, file = './Results/previous.RData')

#6b) count number of ed visits/admissions
source('./Scripts/R/7b_countadmissions.R')

master <- left_join(master,
                    countadmissions(master, previous))

print(paste(Sys.time(), 'Counting previous complete'))

#7) use the cleaned lab dataframes and a list of previous encounters to calculate historical lab statistics

source('./Scripts/R/8_processhistoricallabs.R')
source('./Scripts/R/10_processhistoricallabs_categorical.R')
master <- left_join(master, processlabs_num(num_labs, previous))
print(paste(Sys.time(), 'Numeric labs processing complete'))

master <- left_join(master, processlabs_cat(cat_labs, previous))
print(paste(Sys.time(), 'Categorical labs processing complete'))

rm(num_labs)
rm(cat_labs)

#8) clean vitals

source('./Scripts/R/9_edvitalsclean.R')
vitalspath <- './Data/ed_vitals.csv'
vitals <- cleanvitals(vitalspath, master)
print(paste(Sys.time(), 'Vitals cleaning complete'))

#8b) pull out triage vitals

source('./Scripts/R/9b_gettriagevitals.R')
master <- left_join(master, gettriagevitals(vitals, master))

print(paste(Sys.time(), 'Triage vitals processing complete'))

#9) use cleaned vitals dataframe and 'previous' to calculate historical vitals statistics

source('./Scripts/R/9c_processhistoricalvitals.R')
master <- left_join(master, gethistoricalvitals(vitals, previous))

print(paste(Sys.time(), 'Historic vitals processing complete'))
rm(vitals)

#10) clean imaging, then use 'previous' to calculate number of previous imaging by modality
source('./Scripts/R/11_cleanimgekg.R')
source('./Scripts/R/12_countprevimg.R')
imgpath <- './Data/img_ekg.csv'
master <- left_join(master, countprevimg(cleanimg(imgpath), previous))

print(paste(Sys.time(), 'Historical imaging processing complete'))

#11) clean outpt meds
source('./Scripts/R/13_cleanmeds.R')
medpath <- "./Data/outpt_meds_class.csv"
master <- left_join(master, cleanmeds(medpath))

print(paste(Sys.time(), 'Med processing complete'))


#12) clean surgical history
source('./Scripts/R/14_pshclean.R')
pshpath <- './Data/surg_hx.csv'
master <- left_join(master, countpsh(pshpath))

#13) clean chief complaint
source('./Scripts/R/15_chiefcomplaint.R')
ccpath <- './Data/chief_complaint.csv'
master <- left_join(master, cleancc(ccpath, master, n_categories = 200))

print(paste(Sys.time(), 'Chief complaint processing complete'))


# Final: save the final Robject
save(master, file = './Results/master.RData')

