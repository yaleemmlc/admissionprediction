#15. Chief complaint: take top 200 most frequently occuring CCs. Bin others into 'other'

cleancc <- function(path, master, n_categories = 200) {
        cc <- read_csv(path)
        cc <- select(cc, -COMMENTS) %>%
                rename(complaint = ENC_REASON_NAME) %>%
                filter(PAT_ENC_CSN_ID %in% master$PAT_ENC_CSN_ID)
        
        #take top n_categories
        top_complaints <- names(head(sort(table(cc$complaint), decreasing = T), n_categories))
        
        cc$complaint[!cc$complaint %in% top_complaints] <- 'other'
        
        #remove spaces and force into lowercase
        cc$complaint <- paste('cc_', gsub(' ', '', tolower(cc$complaint)), sep ='')
        
        cc_binary <- dcast(cc, PAT_ENC_CSN_ID ~ complaint, length)
        #some encounters have more than 1 CC...
        
        cc_binary
}