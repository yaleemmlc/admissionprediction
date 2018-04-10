# 14. Past Surgical History Processing: outputs number of procedures/surgeries listed in EHR at time of visit

#import data and dictionary

countpsh <- function(path) {
        psh <- read_csv(path)
        psh_count <- group_by(psh, PAT_ENC_CSN_ID) %>%
                summarize(n_surgeries = n())
        psh_count
}

