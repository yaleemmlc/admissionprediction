#run XGBoost 100 times to get mean information gain (Github)

library(readr)
library(dplyr)
library(reshape2)
library(parallel)
library(caret)
library(xgboost)
library(doMC)
library(pROC)
library(keras)
registerDoMC(5) #for parallelization


#1) load data, then create train/test split
load('./Results/5v_sparseMatrix.RData')
load('./Results/5v_indeces_list.RData')
indeces <- indeces_list[[1]]
x <- dataset$x
y <- dataset$y
rm(dataset)

x_test <- x[indeces$i_test,]
y_test <- y[indeces$i_test]

x_train <- x[-indeces$i_test,]
y_train <- y[-indeces$i_test]


save(y_test, file = './Results/5v_y_test.RData')

rm(x); rm(y)

#2) run XGBoost 100 times

for (i in 1:100) {
        bst <- xgboost(data = x_train, label = y_train,
                       max_depth = 20, eta = 0.3,
                       nthread = 5, nrounds = 30,
                       eval_metric = 'auc',
                       objective = "binary:logistic",
                       colsample_bylevel = 0.05)
        # get importance table
        importance <- xgb.importance(feature_names = x_train@Dimnames[[2]], model = bst)
        #extract gain
        importance <- importance[,c(1,2)]
        #change name of column
        label <- paste0("Gain", i)
        names(importance)[2] <- label
        if (i == 1) {
                result <- importance
        } else {
                result <- left_join(result, importance, by = 'Feature')
        }
        print(paste("Finished iteration",i))
}

#save results 
save(result, file = './Results/5v_bst_importance_100.RData')
