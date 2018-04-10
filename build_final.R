#Fit XGBoost model using the optimized hyperparameters and evaluate on test set (Github)

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


#1) create train/test split
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

#save to use later to calculate statistical measures (Sen/Spe/PPV/NPV)
save(y_test, file = './Results/5v_y_test.RData')

rm(x); rm(y)

#2) Fit model on all data except test set, using the optimized hyperparameters

bst <- xgboost(data = x_train, label = y_train,
               max_depth = 20, eta = 0.3,
               nthread = 5, nrounds = 30,
               eval_metric = 'auc',
               objective = "binary:logistic",
               colsample_bylevel = 0.05)

bst_pred_test <- predict(bst, x_test)
roc(y_test, bst_pred_test)
ci.auc(roc(y_test, bst_pred_test), conf.level = 0.95)

#save predictions
save(bst_pred_test, file = './Results/5v_bst_pred_test.RData')
