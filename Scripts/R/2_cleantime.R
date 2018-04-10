## 2. Pull out time variables
library(readr)
library(lubridate)
library(dplyr)

cleantime <- function(path) {
        time <- read_csv(path)
        df <- select(time, one_of(c('Pat Enc CSN ID', 'ED Arrival Time', 'ED Roomed TS')))
        names(df)[1] <-'PAT_ENC_CSN_ID' 
        df <- mutate(df, arrivaltime = ymd_hms(df$`ED Arrival Time`)) %>%
                mutate(roomtime = ymd_hms(df$`ED Roomed TS`)) 
        df$`ED Arrival Time` <- NULL
        df$`ED Roomed TS` <- NULL
        df <- mutate(df, arrivalmonth = months(arrivaltime), 
                     arrivalday = weekdays(arrivaltime),
                     arrivalhour = hour(arrivaltime),
                     arrivalhour_bin = cut((arrivalhour+1)%%24, 
                                           breaks = c(-1,3,7,11,15,19,23),
                                           labels = c('23-02', '03-06', '07-10', '11-14','15-18', '19-22'),
                                           right = T))
        # hour variable binned into eight 4-hour blocks (7-10, 11-14, 15-18, 19-22, 23-02, 3-6)
        df
}

