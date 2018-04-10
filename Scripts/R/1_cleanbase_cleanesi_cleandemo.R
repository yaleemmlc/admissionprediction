#1. Clean base,esi files
library(readr)
library(dplyr)

# 1a. Read in base file

cleanbase <- function(path) {
        base <- read_csv(path)
        #Change dep_name into factor
        base$dep_name <- factor(base$dep_name)
        #Assign duplicates to new dataframe
        duplicates <- base[duplicated(base$PAT_ENC_CSN_ID),]
        duplicates <- rename(duplicates, transfer_dep_name = dep_name)
        # remove those duplicated more than twice (i.e. transferred twice)
        duplicates_unique <- distinct(duplicates, PAT_ENC_CSN_ID, .keep_all = TRUE) 
        #remove pt MR column
        duplicates_unique$PAT_MRN_ID <- NULL
        # Create a df with unique PAT_ENC_CSN_ID and a new column "transfer_dep_name' 
        # that indicates whether pt was transferred, and if so, where 
        # (first transferred department in case of those 5 who were transfered twice).
        base_unique <- distinct(base, PAT_ENC_CSN_ID, .keep_all = TRUE)
        base_unique <- left_join(base_unique, duplicates_unique, by = "PAT_ENC_CSN_ID")
        base_unique
}



## 1b. Read in ESI level file



cleanesi <- function(path) {
        esi <- read.csv(path)
        #change esi level into factor
        esi$ESI <- factor(esi$ESI)
        # create a new dataframe of duplicates
        duplicates <- esi[duplicated(esi$PAT_ENC_CSN_ID),]
        duplicates <- rename(duplicates, second_esi = ESI)
        # remove those duplicated more than twice
        duplicates_unique <- distinct(duplicates, PAT_ENC_CSN_ID, .keep_all = TRUE) 
        #As we did previously for the base file, create a new column to indicate whether pt 
        # was assigned an ESI twice, and if so, what that level was.
        esi_unique <- distinct(esi, PAT_ENC_CSN_ID, .keep_all = TRUE) %>%
                left_join(duplicates_unique, by = "PAT_ENC_CSN_ID") %>%
                rename(esi = ESI)
        esi_unique
}

## 1c. Demographics


cleandemo <- function(path) {
        demo <- read.csv(path)
        # we will take the last demographic value, by first reversing the indexing of the dataframe
        # then using the distinct function
        demo_unique <- arrange(demo, -row_number()) %>%
                distinct(PAT_ENC_CSN_ID, .keep_all = TRUE)
        demo_unique
}
