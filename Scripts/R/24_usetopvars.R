#24. use top variables by gain
usetopvars <- function(df) {
        topvars <- c('disposition',
                     #esi
                     'esi',
                     #demographics
                     'age', 'gender', 'maritalstatus', 'employstatus','insurance_status', 
                     'race','ethnicity','lang','religion',
                     #healthcare usage stat
                     'n_edvisits', 'previousdispo', 'n_admissions', 'n_surgeries',
                     #outpatient meds
                     names(df)[which(names(df) == 'meds_analgesicandantihistaminecombination'):which(names(df) == 'meds_vitamins')])
        df[,names(df) %in% topvars]
}


