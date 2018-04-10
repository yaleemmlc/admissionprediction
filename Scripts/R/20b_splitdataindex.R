#returns a list of n splits, each element of which is a list of indeces (used for CV)
splitdataindex <- function(df, n = 5) {
        set.seed(3883)
        indeces_list <- vector("list", n)
        i_all <- as.numeric(rownames(df))
        i_test <- sample(i_all, 56000) 
        i_traindev <- setdiff(i_all, i_test)
        for (i in 1:n) {
                i_dev <- sample(i_traindev, 56000)
                i_train <- setdiff(i_traindev, i_dev)
                indeces_list[[i]] <- list(i_train = i_train, i_dev = i_dev, i_test = i_test)
        }
        indeces_list
}