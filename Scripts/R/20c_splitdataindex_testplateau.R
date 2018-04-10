#returns a list of 6 splits with increasing proportions of the training set
splitdataindex_testplateau <- function(df) {
        set.seed(3883)
        cuts <- c(0.01, 0.1, 0.3, 0.5, 0.8, 1)
        indeces_list <- vector("list", length(cuts))
        i_all <- as.numeric(rownames(df))
        i_test <- sample(i_all, 56000)
        i_train_all <- setdiff(i_all, i_test)
        for (i in 1:length(cuts)) {
                i_train <- sample(i_train_all, floor(length(i_train_all)*cuts[i]))
                indeces_list[[i]] <- list(i_train = i_train, i_test = i_test)
        }
        indeces_list
}
