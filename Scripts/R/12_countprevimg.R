#12. process historical imaging - we are just counting how many of orders / each modality within the past year

countprevimg <- function(img, previous) {
        #using the same method as the one used to process historical labs and vitals,
        matrices <- mclapply(previous, function(prev_encounters) {
                #default is a matrix of zeros (in this case, we only have 1 summary statistic, so equivalent to a vector)
                result <- array(0, c(1,ncol(img)-1))
                
                if (length(prev_encounters) > 0) {
                        prev_img <- filter(img, PAT_ENC_CSN_ID %in% prev_encounters) %>%
                                select(-PAT_ENC_CSN_ID)
                        if (nrow(prev_img) > 0) {
                                #1) count previous imaging by modality
                                result[1,] <- sapply(prev_img, sum, na.rm = T)
                        }
                }
                result
        }, mc.cores = n.cores)
        
        #collapse the list of matrices(vectors here)
        final_matrix <- do.call(rbind, matrices)
        #attach our ID column
        final_df <- data.frame(as.numeric(names(previous)), final_matrix)
        labels <- paste(names(img)[-1], 
                        rep(c('count'), each = ncol(img) - 1), sep = '_')
        names(final_df) <- c('PAT_ENC_CSN_ID', labels)
        final_df
}



