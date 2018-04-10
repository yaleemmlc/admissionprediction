#13. Clean meds
cleanmeds <- function(path) {
        meds <- read_csv(path)
        #count meds/category name for each patient (total 48 categories)
        meds_binary <- dcast(meds, PAT_ENC_CSN_ID ~ NAME)
        names(meds_binary)[-1] <- paste('meds_', gsub(' ', '', names(meds_binary)[-1]), sep ='')
        meds_binary
}

