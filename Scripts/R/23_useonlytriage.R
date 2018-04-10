# use only triageinfo (demographics, cc, triage vitals)

useonlytriage <- function(df) {
        demographics <- 1:16
        triage_vitals <- which(names(df) == 'triage_vital_hr'):which(names(df) == 'triage_vital_temp')
        cc <- which(names(df) == 'cc_abdominalcramping'):which(names(df) == 'cc_wristpain')
        onlytriage <- c(demographics, triage_vitals, cc)
        
        df[,onlytriage]
}

#use only patient history (demographics, history)

useonlyhistory <- function(df) {
        triage_vitals <- which(names(df) == 'triage_vital_hr'):which(names(df) == 'triage_vital_temp')
        cc <- which(names(df) == 'cc_abdominalcramping'):which(names(df) == 'cc_wristpain')
        other_triage <- c(which(names(df) == 'dep_name'),
                          which(names(df) == 'esi'),
                          which(names(df) == 'arrivalmode'):which(names(df) == 'arrivalhour_bin'))
        triage_variables <- c(triage_vitals, cc, other_triage)
        df[,-triage_variables]
}