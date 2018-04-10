#Triage vitals: extracts vitals taken during triage, outputs their mean if more than one set was taken

gettriagevitals <- function(vitals, master) {
        # left_join to add a roomtime variable for each encounter
        # discard rows without a roomtime variable
        triagevitals <- left_join(vitals, master[,c("PAT_ENC_CSN_ID", 'roomtime')], by = 'PAT_ENC_CSN_ID') %>%
        filter(!is.na(roomtime))
        
        # 5) filter dataframe by RECORDED_TIME <= roomtime for that PAT_ENC_CSN_ID
        triagevitals <- filter(triagevitals, RECORDED_TIME <= roomtime)
        
        # 6) if more than one set of vitals were taken before pt was roomed,
        #   take their average value. 
        #  for o2_device, take the maximum factor level recorded
        # this will output 1 row / patient encounter id
        triagevitals <- group_by(triagevitals, PAT_ENC_CSN_ID) %>%
                summarize(triage_vital_hr = mean(Pulse, na.rm = T),
                          triage_vital_sbp = mean(sbp, na.rm = T),
                          triage_vital_dbp = mean(dbp, na.rm = T),
                          triage_vital_rr = mean(Resp, na.rm = T),
                          triage_vital_o2 = mean(SpO2, na.rm = T),
                          triage_vital_o2_device = max(o2_device, na.rm = T),
                          triage_vital_temp = mean(Temp, na.rm = T))
        
        triagevitals[,-1] <- lapply(triagevitals[,-1], function(x) {
                replace(x, is.infinite(x) | is.nan(x),NA)
        })
        
        triagevitals
}








