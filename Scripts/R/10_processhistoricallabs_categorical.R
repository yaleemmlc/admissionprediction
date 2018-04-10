# 10. Process historical CATEGORICAL labs
# Processing is different from numerical labs since the statistics we want are
# 1) COUNT - number of tests within 1 year
# 2) SUM - number of positives within 1 year
# 3) LAST - last value for the lab 

processlabs_cat <- function(labs, previous) {
        labs <- labs[order(labs$PAT_ENC_CSN_ID),]
        #Vectorized version
        #for each encounter, returns a matrix w/ 3 rows (last, sum, count)
        matrices <- mclapply(previous, function(prev_encounters) {
                #default is an empty matrix
                result <- array(NA, c(3,ncol(labs)-1))
                
                if (length(prev_encounters) > 0) {
                        prev_labs <- filter(labs, PAT_ENC_CSN_ID %in% prev_encounters) %>%
                                select(-PAT_ENC_CSN_ID)
                        if (nrow(prev_labs) > 0) {
                                #1) labs_last
                                result[1,] <- as.matrix(prev_labs[nrow(prev_labs),])
                                
                                #2) labs_sum
                                result[2,] <- sapply(prev_labs, sum, na.rm = T)
                                
                                #3) labs_count
                                result[3,] <- sapply(prev_labs, function(x) length(x[!is.na(x)]))
                        }
                }
                
                result
        }, mc.cores = n.cores)
        
        #collapse the list of matrices
        bigmatrix <- do.call(rbind, matrices)
        #separate the rows into appropriate matrix
        labs_last <- bigmatrix[seq(1, nrow(bigmatrix), 3), ]
        labs_npos <- bigmatrix[seq(2, nrow(bigmatrix), 3),]
        labs_count <- bigmatrix[seq(3, nrow(bigmatrix), 3),]
        
        final_matrix <- cbind(labs_last,labs_npos,labs_count)
        final_df <- data.frame(as.numeric(names(previous)), final_matrix)
        labels <- paste(names(labs)[-1], 
                        rep(c('last','npos','count'), each = ncol(labs) - 1), sep = '_')
        names(final_df) <- c('PAT_ENC_CSN_ID', labels)
        
        #replace Inf, -Inf, NaN w/ NA
        final_df[,-1] <- lapply(final_df[,-1], function(x) {
                replace(x, is.infinite(x) | is.nan(x),NA)
        })
        
        final_df
}