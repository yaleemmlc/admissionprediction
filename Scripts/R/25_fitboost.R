# wrapper function to cross-validate xgboost models
fitboost <- function(dataset, indeces, 
                     max_depth, 
                     eta,
                     nthread,
                     nrounds,
                     colsample_bylevel) {
        x <- dataset$x
        y <- dataset$y
        rm(dataset)
        
        x_train <- x[indeces$i_train,]
        y_train <- y[indeces$i_train]
        
        x_dev <- x[indeces$i_dev,]
        y_dev <- y[indeces$i_dev]
        
        x_test <- x[indeces$i_test,]
        y_test <- y[indeces$i_test]
        
        rm(x); rm(y)
        
        #5) fit xgboost model
        bst <- xgboost(data = x_train, label = y_train,
                       max_depth = max_depth, eta = eta,
                       nthread = nthread, nrounds = nrounds,
                       eval_metric = 'auc',
                       objective = "binary:logistic",
                       colsample_bylevel = colsample_bylevel)
        print(bst)
        # save(bst, file = './Results/bst_model.RData')
        auc_train <- as.numeric(bst$evaluation_log$train_auc[length(bst$evaluation_log$train_auc)])
        
        #7) Predict on dev
        y_hat_dev <- predict(bst, x_dev)
        auc_dev <- as.numeric(auc(y_dev, y_hat_dev))
        
        c(auc_train,auc_dev)
}
