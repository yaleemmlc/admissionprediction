#7b count healthcare usage statistics (n_edvisits, n_admissions)

countadmissions <- function(master, previous) {
        dispo <- select(master, PAT_ENC_CSN_ID, disposition)
        
        #counts number of admissions within the past year
        admit <- mclapply(previous, function(prev_encounters) {
                prev_dispo <- filter(dispo, PAT_ENC_CSN_ID %in% prev_encounters, disposition == 'Admit')
                nrow(prev_dispo)
        }, mc.cores = n.cores)
        
        #returns a dataframe of 3 columns: ID, number of ed visits and number of admissions within the past year
        counts <- data.frame(PAT_ENC_CSN_ID = as.numeric(names(previous)),
                             n_edvisits = sapply(previous, length), n_admissions = unlist(admit))

        counts
        
}




