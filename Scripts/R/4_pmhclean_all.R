## 4. PMH cleaning

library(readr)
library(dplyr)
library(reshape2)
library(stringr)
#the original icd9cm csv file downloaded from the web was opened in Excel then saved again
# Otherwise the file could not be read by R


cleanpmh <- function(pmhfilepath, icd9path, mergedfile) {
        #Read our pmh file
        pmh <- read_csv(pmhfilepath)
        #filter by encounter id in our mergedfile(eg. esi3) since the pmh dataframe is HUGE
        pmh_3 <- filter(pmh, PAT_ENC_CSN_ID %in% mergedfile$PAT_ENC_CSN_ID)
        #running the unique function on pmh_3$PAT_ENC_CSN_ID shows that 
        #there are only 100,000 out of 300,000 (from esi3 df) who have recorded PMH
        
        #read our CCS icd9 translation file
        # We will use icd9 encoding for now since there are 
        # only 39 NAs for ICD9 vs 90,000 NAs for ICD10 
        
        icd9cm <- read_csv(icd9path, 
                           col_types = cols(`'CCS CATEGORY'` = col_number()), 
                           skip = 1)
        
        # PROCESSING PMH FILE
        # 1) clean pmh dataframe by removing periods in icd9 code
        pmh_3$icd9 <- gsub("\\.", "", pmh_3$CURRENT_ICD9_LIST)
        
        # if there are more than 1 code value in the cell, take the first one
        # and left justify so that there are 5 characters exactly for each element
        # (this is the format of icd9 codes in the dictinoary)
        
        y <- gsub("\\,.*","", pmh_3$icd9)
        y[!is.na(y)] <- ifelse(nchar(y[!is.na(y)]) > 5, 
                               NA, 
                               paste0(y[!is.na(y)], sapply(nchar(y[!is.na(y)]), 
                                                           function(x) paste(rep(' ', abs(5 - x)), collapse = ""))))
        
        
        pmh_3$icd9 <- y
        
        
        
        # PART2: CLEAN icd9 -> ccs dictionary
        
        # 2) clean the ccs dictionary by subsetting the icd9 and the ccs label
        # then removing the quotes from the icd9 and punctuations from the labels
        ccs <- icd9cm[,c(1,3)]
        names(ccs) <- c('icd9', 'ccs')
        ccs$icd9 <- gsub("\\'", "", ccs$icd9)
        ccs$ccs <- tolower(gsub("[[:punct:]]| ", "", ccs$ccs))
        # remove nodx row
        ccs <- ccs[-1,]
        
        # 3) MERGE: left_join appropriate CCS category
        pmh_3 <- left_join(pmh_3, ccs, by = 'icd9')
        # sum(is.na(pmh_3$ccs)) # we have around 32,000 NAs (don't know where these 4000 came from)
        # sum(is.na(pmh_3$ccs)) / nrow(pmh_3) # 0.38% missing
        df_last <- select(pmh_3, PAT_ENC_CSN_ID, ccs)
        # note here that ccs category of 650+ = psych conditions, 2600+ = accidents/unspecified
        
        # 4) cast the dataframe such that we have a df where each row is an encounter 
        # and each column a CCS category. Value will take 1 or 0 depending on presence/absence
        df_binary <- dcast(df_last, PAT_ENC_CSN_ID ~ ccs, fun.aggregate = function(x) {
                as.numeric(length(x) > 0 )
        })
        #ignore NA valued ccs
        df_binary$'NA' <- NULL
        
        df_binary
}







