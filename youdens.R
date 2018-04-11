#Calculate optimum cutoff using Youden's Index, then calcuate Sen/Spe/PPV/NPV using cutoff (Github)

library(pROC)
library(caret)

load('./Results/5v_y_test.RData')
load('./Results/5v_bst_pred_test.RData')
load('./Results/5v_bst_pred_test_onlytriage.RData')
load('./Results/5v_bst_pred_test_onlyhx.RData')
load('./Results/5v_bst_pred_test_topvars.RData')
roc_curve <- roc(y_test, bst_pred_test)

#find optimal cutoff using Youden's method on the full XGBoost model
threshold <- coords(roc_curve, x="best", input="threshold", best.method="youden")

# calcuate Sen/Spe/PPV/NPV using cutoff (0.28)
confusionMatrix(as.numeric(bst_pred_test>threshold[1]), y_test, positive = '1')
confusionMatrix(as.numeric(bst_pred_test_onlyhx>threshold[1]), y_test, positive = '1')
confusionMatrix(as.numeric(bst_pred_test_onlytriage>threshold[1]), y_test, positive = '1')
confusionMatrix(as.numeric(bst_pred_test_topvars>threshold[1]), y_test, positive = '1')

load('./Results/5v_lr_pred_test.RData')
confusionMatrix(as.numeric(keras_pred_test>threshold[1]), y_test, positive = '1')

load('./Results/5v_lr_pred_test_onlytriage.RData')
confusionMatrix(as.numeric(keras_pred_test>threshold[1]), y_test, positive = '1')

load('./Results/5v_lr_pred_test_onlyhx.RData')
confusionMatrix(as.numeric(keras_pred_test>threshold[1]), y_test, positive = '1')

load('./Results/5v_keras_pred_test.RData')
confusionMatrix(as.numeric(keras_pred_test>threshold[1]), y_test, positive = '1')

load('./Results/5v_keras_pred_test_onlytriage.RData')
confusionMatrix(as.numeric(keras_pred_test>threshold[1]), y_test, positive = '1')

load('./Results/5v_keras_pred_test_onlyhx.RData')
confusionMatrix(as.numeric(keras_pred_test>threshold[1]), y_test, positive = '1')

