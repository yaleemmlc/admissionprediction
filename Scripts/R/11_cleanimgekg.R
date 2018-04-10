#11. clean and recategorize ekg/imaging orders

cleanimg <- function(path) {
        df <- read_csv(path)
        orders <- df$DISPLAY_NAME
        #recategorize into 8 categories, then bin the rest into 'otherimg'
        orders[grep('^ct head', orders, ignore.case = T)] <- 'headct'
        orders[grep('^cta|^ct', orders, ignore.case = T)] <- 'otherct'
        orders[grep('^ekg', orders, ignore.case = T)] <- 'ekg'
        orders[grep('^xr chest|^cxr' , orders, ignore.case = T)] <- 'cxr'
        orders[grep('^xr|2V|3V|4V|view', orders, ignore.case = T)] <- 'otherxr'
        orders[grep('echo', orders, ignore.case = T)] <- 'echo'
        orders[grep('^us|ultrasound', orders, ignore.case = T)] <- 'otherus'
        orders[grep('^mri', orders, ignore.case = T)] <- 'mri'
        orders[!orders %in% c('ekg','cxr','otherxr','otherct','otherus','headct','echo','mri')] <- 'otherimg'
        
        df$DISPLAY_NAME <- orders
        #recast dataframe into wide format, using length (the default) as aggregate function
        counts <- dcast(df, PAT_ENC_CSN_ID ~ DISPLAY_NAME)
        counts
}
