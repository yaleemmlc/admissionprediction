
# Previous visit info
# need a  dataframe w PAT_MRN_ID, PAT_ENC_CSN_ID, and arrivaltime

# Goal: a list of vectors, where, for each encounter, 
# a vector contains the ids of previous encounters within the past year
countprevious <- function(master, n_row = nrow(master)) {
        df <- select(master, PAT_MRN_ID, PAT_ENC_CSN_ID, arrivaltime)
        df <- df[order(df$PAT_MRN_ID, df$PAT_ENC_CSN_ID),]
        #for testing purposes, take first n_row
        df <- head(df, n_row)
        df$oneyear <- df$arrivaltime - 365*24*60*60
        #initialize a list to put our vector results in
        previous <- vector("list", nrow(df))
        #name by encounter
        names(previous) <- df$PAT_ENC_CSN_ID
        
        for (i in 1:nrow(df)) {
                mrn <- df$PAT_MRN_ID[i]
                time_max <- df$arrivaltime[i]
                time_min <- df$oneyear[i]
                within1year <- filter(df, PAT_MRN_ID == mrn, 
                                      arrivaltime < time_max, 
                                      arrivaltime >= time_min)$PAT_ENC_CSN_ID
                previous[[i]] <- within1year
        }

        previous
}