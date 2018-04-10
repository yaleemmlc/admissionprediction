#Clean ED vitals

#takes in the path to ed_vitals.csv and a merged dataframe w/ encounter id and roomtime variable 
#and outputs a wide outliers-removed dataframe to be used in subsequent processing
cleanvitals <- function(path, master) {
        #read in raw file
        vitals <- read_csv(path) %>%
                select(-PAT_MRN_ID) %>%
                filter(PAT_ENC_CSN_ID %in% master$PAT_ENC_CSN_ID,
                       DISP_NAME %in% c('Pulse','Resp','SpO2', 'BP', 'Temp', 'O2 Device'))
        
        
        # 1) recast dataframe so that we have each variable in a separate column
        # (each row identified by a unique PAT_ENC_CSN_ID and RECORD_TIME combo
        #  use 1st instance if more than 1 value for the combo)
        vitals_w <- dcast(vitals, PAT_ENC_CSN_ID + RECORDED_TIME ~ DISP_NAME, 
                    fun.aggregate = function(x) x[1])
        
        # 2) split BP into sbp and dbp
        bp <- colsplit(vitals_w$BP, "/", c('sbp', 'dbp'))
        vitals_w$sbp <- bp$sbp
        vitals_w$dbp <- bp$dbp
        vitals_w$BP <- NULL
        
        # 3) reclass variables
        vitals_w[,-c(1:3)] <- lapply(vitals_w[,-c(1:3)], as.numeric)
        
        #process O2 device into binary 'assistedoxygen' (0 = room air, 1 = otherwise)
        vitals_w$`O2 Device`[grepl('room', as.character(vitals_w$`O2 Device`), ignore.case = T)] <- '0'
        vitals_w$`O2 Device`[as.character(vitals_w$`O2 Device`) != '0'] <- '1'
        vitals_w$o2_device <- as.numeric(vitals_w$`O2 Device`)
        vitals_w$`O2 Device` <- NULL

      
        #4) remove outliers in numeric variables
        removeoutliers <- function(x, min, max) {
                x[x >= max | x < min] <- NA
                x
        }
        
        #physiologic limits set as follows
        vitals_w$Pulse <- removeoutliers(vitals_w$Pulse, 30, 300)
        vitals_w$sbp <- removeoutliers(vitals_w$sbp, 30, 400)
        vitals_w$dbp <- removeoutliers(vitals_w$dbp, 25, 300)
        vitals_w$SpO2 <- removeoutliers(vitals_w$SpO2, 60, 100)
        vitals_w$Resp <- removeoutliers(vitals_w$Resp, 8, 70)
        vitals_w$Temp <- removeoutliers(vitals_w$Temp, 90, 110)
        
        vitals_w
}
