#Calculate optimum cutoff using Youden's Index, then calcuate Sen/Spe/PPV/NPV using cutoff (Github)

library(pROC)
library(caret)

load('./Results/5v_y_test.RData')
load('./Results/5v_bst_pred_test.RData')

#find optimal cutoff using Youden's method on the full XGBoost model
roc_curve <- roc(y_test, bst_pred_test)
threshold <- coords(roc_curve, x="best", input="threshold", best.method="youden")



# calcuate Sen/Spe/PPV/NPV using cutoff (0.28)
confusionMatrix(as.numeric(bst_pred_test>threshold[1]), y_test, positive = '1')
ci.thresholds(roc_curve, boot.n = 1000, thresholds = threshold)

# choose cutoff for each model to match a fixed specificity of 0.85 to faciliate comparison

load('./Results/5v_bst_pred_test_onlytriage.RData')
load('./Results/5v_bst_pred_test_onlyhx.RData')
load('./Results/5v_bst_pred_test_topvars.RData')
confusionMatrix(as.numeric(bst_pred_test_onlytriage>0.42), y_test, positive = '1')
confusionMatrix(as.numeric(bst_pred_test_onlyhx>0.30), y_test, positive = '1')
confusionMatrix(as.numeric(bst_pred_test_topvars>0.29), y_test, positive = '1')


#will load one by one given all the objects have the same name ('keras_pred_test')

#LR models
load('./Results/5v_lr_pred_test_onlytriage.RData')
confusionMatrix(as.numeric(keras_pred_test>0.43), y_test, positive = '1')

load('./Results/5v_lr_pred_test_onlyhx.RData')
confusionMatrix(as.numeric(keras_pred_test>0.28), y_test, positive = '1')

load('./Results/5v_lr_pred_test.RData')
confusionMatrix(as.numeric(keras_pred_test>0.34), y_test, positive = '1')

#DNN models
load('./Results/5v_keras_pred_test_onlytriage.RData')
confusionMatrix(as.numeric(keras_pred_test>0.39), y_test, positive = '1')

load('./Results/5v_keras_pred_test_onlyhx.RData')
confusionMatrix(as.numeric(keras_pred_test>0.30), y_test, positive = '1')

load('./Results/5v_keras_pred_test.RData')
confusionMatrix(as.numeric(keras_pred_test>0.28), y_test, positive = '1')
