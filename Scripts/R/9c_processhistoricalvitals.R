# 9. get historical vitals

gethistoricalvitals <- function(vitals, previous) {
        vitals <- vitals[order(vitals$PAT_ENC_CSN_ID, vitals$RECORDED_TIME),]
        #remove the RECORDED_TIME variable, since we will be filtering by encounters NOT time of vitals
        #we know that the dcast function will return a dataframe ordered by ID and Time
        vitals$RECORDED_TIME <- NULL
        
        matrices <- mclapply(previous, function(prev_encounters) {
                #default is an empty matrix
                result <- array(NA, c(4,ncol(vitals)-1))
                
                if (length(prev_encounters) > 0) {
                        prev_vitals <- filter(vitals, PAT_ENC_CSN_ID %in% prev_encounters) %>%
                                select(-PAT_ENC_CSN_ID)
                        if (nrow(prev_vitals) > 0) {
                                #1) labs_last
                                result[1,] <- as.matrix(prev_vitals[nrow(prev_vitals),])
                                
                                #2) labs_min
                                result[2,] <- sapply(prev_vitals, min, na.rm = T)
                                
                                #3) labs_max
                                result[3,] <- sapply(prev_vitals, max, na.rm = T)
                                
                                #4) labs_median
                                result[4,] <- sapply(prev_vitals, median, na.rm = T)
                        }
                }
                
                result
        }, mc.cores = n.cores)
        
        #collapse the list of matrices
        bigmatrix <- do.call(rbind, matrices)
        #separate the rows into appropriate matrix
        vitals_last <- bigmatrix[seq(1, nrow(bigmatrix), 4), ]
        vitals_min <- bigmatrix[seq(2, nrow(bigmatrix), 4),]
        vitals_max <- bigmatrix[seq(3, nrow(bigmatrix), 4),]
        vitals_median <- bigmatrix[seq(4, nrow(bigmatrix), 4),]
        
        final_matrix <- cbind(vitals_last,vitals_min,vitals_max,vitals_median)
        final_df <- data.frame(as.numeric(names(previous)), final_matrix)
        labels <- paste(names(vitals)[-1], 
                        rep(c('last','min','max','median'), each = ncol(vitals) - 1), sep = '_')
        names(final_df) <- c('PAT_ENC_CSN_ID', labels)
        
        #replace Inf, -Inf, NaN w/ NA
        final_df[,-1] <- lapply(final_df[,-1], function(x) {
                replace(x, is.infinite(x) | is.nan(x),NA)
        })
        
        final_df
}
