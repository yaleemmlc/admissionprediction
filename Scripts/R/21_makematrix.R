#21) converts cleaned dataframe into numeric matrix and a response vector 
# returns a list of y = vector of response, x = sparse matrix of predictors

makematrix <- function(df, sparse = T) {
        library(Matrix)
        # recode our response
        df$disposition <- as.numeric(df$disposition == 'Admit')
        response <- df$disposition
        df <- select(df,-disposition)
        
        #dummify categorical variables and encode into matrix
        dmy <- dummyVars(" ~ .", data = df)
        if (sparse) {
                df <- Matrix(predict(dmy, newdata = df), sparse = T)
        } else {
                df <- predict(dmy, newdata = df)
        }
               
        list(y = response, x = df)
}




