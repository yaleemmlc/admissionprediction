#Pulling out 'previous dispo' time series for each pt

getdispo <- function(master) {
        dispo <- select(master, PAT_MRN_ID, PAT_ENC_CSN_ID,
                        disposition, arrivaltime)
        dispo <- dispo[order(dispo$PAT_MRN_ID, dispo$PAT_ENC_CSN_ID),]
        
        #this function takes a vector of dispos and shifts it by one to the right
        getprev <- function(x) {
                if (length(x) > 1) {
                        x <- c(NA, as.character(x[-length(x)]))
                }
                else{
                        x <- NA
                }
                        
                data.frame(x)
        }
        
        dispo <- dispo %>% group_by(PAT_MRN_ID) %>%
                do(cbind(PAT_ENC_CSN_ID = .$PAT_ENC_CSN_ID, 
                         getprev(.$disposition))) %>%
                ungroup() %>%
                select(-PAT_MRN_ID) %>%
                rename(previousdispo = x)
}



#         
#         #lets see individual ED usage
# edvisits <- group_by(dispo, PAT_MRN_ID) %>%
#         summarise(num_edvisit = n())
# edvisits_sorted <- edvisits[order(x$num_edvisit, decreasing = T),]
