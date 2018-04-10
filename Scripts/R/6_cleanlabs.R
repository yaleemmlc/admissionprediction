#Cleaning past_labs.csv so that we can process it later

library(readr)
library(dplyr)
library(reshape2)


cleanlabs <- function(path, master) {
        #If you feel lazy and just want as much as info as you want (prob better for deep learning):
        labs <- read_csv(path) %>%
              filter(PAT_ENC_CSN_ID %in% master$PAT_ENC_CSN_ID)
        
        toplabs <- tail(names(sort(table(labs$COMMON_NAME))), 150)
        
        
        #take advantage of the fact that most numeric labs have reference units while categorical variables don't
        units <- select(labs, COMMON_NAME, REFERENCE_UNIT) %>% 
                distinct()
        numeric_variables <- na.omit(units)$COMMON_NAME
        
        #separate categorical from numeric variables
        numlabs <- toplabs[toplabs %in% numeric_variables]
        
        #looking at categoricallabs, move 'INR','BUN / CREAT RATIO' to numlabs
        numlabs_wo_units <- c('INR','BUN / CREAT RATIO', 'POC TROPONIN I.')
        numlabs <- c(numlabs, numlabs_wo_units)
        
        #looking at numlabs, some urinanalysis labs are included
        urinelabs <- grep('UA$|UAP$|LVL$', numlabs, value =  T)
        numlabs <- numlabs[-grep('UA$|UAP$|LVL$', numlabs)] #removing urinelabs
        
        #categorical labs will be hand-picked due to large number of meaningless/hard to process labs
        urine <- c('BLOOD UA', 'PROTEIN UA', 'NITRITE UA', 'LEUKOCYTES UA', 'GLUCOSE UA', 'KETONES UA',
                   'PREG TEST UR')
        cultures <- c('URINE CULTURE, ROUTINE', 'BLOOD CULTURE, ROUTINE')
        
        
        filterlabs <- function(labdf, lablist) {
                filter(labdf, COMMON_NAME %in% lablist) %>% 
                        select(PAT_ENC_CSN_ID, RESULT_TIME, COMMON_NAME, ORD_VALUE) %>%
                        mutate(ORD_VALUE = as.character(ORD_VALUE))
        }
        
        
        #1) NUMERIC LABS
        numlabs_l <- filterlabs(labs, numlabs)
        
        numlabs_l$ORD_VALUE <- gsub('.*<.*', '0', numlabs_l$ORD_VALUE)
        # first regex replaces '<0.03', '< 0.10' these kind of values into 0, so that they values can become numeric 
        # and we can calculate of median/min/max
        
        numlabs_l$ORD_VALUE <- gsub('(\\d+)\\D+$', '\\1', numlabs_l$ORD_VALUE)
        # second regex gets rid of any characters (e.g. doctor names: '0.33 taylor' or '0.00 negative') 
        # that come after lab values (this leaves categorical values such as 'negative', 'moderate' intact)
        
        numlabs_l$ORD_VALUE <- as.numeric(numlabs_l$ORD_VALUE)
        #force into numeric, all character variables will become NA, which we will throw away
        numlabs_l <- na.omit(numlabs_l) 
        
        numlabs_w <- dcast(numlabs_l, PAT_ENC_CSN_ID ~ COMMON_NAME,
                           fun.aggregate = function(x) x[1])
        #this will only take the first recorded value. Most labs are only ordered once in the ED, except troponin.
        #sacrificing accuracy for simplicity...
        
        
        #2) URINE LABS 
        
        ualabs_l <- filterlabs(labs, urine)
        ualabs_l <- na.omit(ualabs_l)
        
        #take advantage of the fact that urine labs can all be processed the same way
        # same w/ culture labs
        positivevalues <- c('1', '2', '3', '1+', '2+', '3+', 
                            'TRACE', 'SMALL', 'MODERATE', 'LARGE', 
                            'POSITIVE', 'positive', '+')
        #positive will be given 1 negative will be given 0
        ualabs_l$ORD_VALUE <- ifelse(ualabs_l$ORD_VALUE %in% positivevalues, 1, 0)
        ualabs_w <- dcast(ualabs_l, PAT_ENC_CSN_ID ~ COMMON_NAME,
                          fun.aggregate = function(x) x[1])
        
        
        # 3) CULTURE LABS
        
        cultlabs_l <- filterlabs(labs, cultures)
        cultlabs_l <- na.omit(cultlabs_l)
        #culture result comments are spread across multiple values... paste them together to get the whole story
        cultlabs_w <- dcast(cultlabs_l, PAT_ENC_CSN_ID ~ COMMON_NAME,
                            fun.aggregate = function(x) paste(x, collapse = ''))
        
        #change "" into NAs
        cultlabs_w[,-1] <- lapply(cultlabs_w[,-1], function(x) {
                x[x == ""] <- NA
                x
        })
        
        
        # Recode such that value is 1 for any occurence of positive in comment and 0 for otherwise (leave NAs intact)
        cultlabs_w$`BLOOD CULTURE, ROUTINE`[grepl('positive|aerobic|strep', 
                                                  cultlabs_w$`BLOOD CULTURE, ROUTINE`,
                                                  ignore.case = T)] <- '1'
        cultlabs_w$`BLOOD CULTURE, ROUTINE`[cultlabs_w$`BLOOD CULTURE, ROUTINE` != '1'] <- '0'
        
        
        cultlabs_w$`URINE CULTURE, ROUTINE`[grepl('100,000|50,000|49,000', 
                                                  cultlabs_w$`URINE CULTURE, ROUTINE`,
                                                  ignore.case = T)] <- '1'
        cultlabs_w$`URINE CULTURE, ROUTINE`[cultlabs_w$`URINE CULTURE, ROUTINE` != '1'] <- '0'
        
        #force into numeric
        cultlabs_w[,-1] <- lapply(cultlabs_w[,-1], as.numeric)
        
        
        #join categorical labs into one
        catlabs_w <- full_join(ualabs_w, cultlabs_w)
        list(numlabs_w, catlabs_w)
}






