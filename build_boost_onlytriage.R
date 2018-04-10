#Cross validation for XGBoost model (only triage) (Github)

library(readr)
library(dplyr)
library(reshape2)
library(parallel)
library(caret)
library(xgboost)
library(doMC)
library(pROC)

registerDoMC(5) #for parallelization

#1) load merged dataframe and manually clean all features by hand

load('./Results/5v_cleandf.RData')

#2) use only triage variables
source('./Scripts/R/23_useonlytriage.R')
df <- useonlytriage(df)
print(dim(df))

#3) Re-encode dataframe into design matrix x and response y
source("./Scripts/R/21_makematrix.R")
dataset <- makematrix(df, sparse = T) #sparse = F for a normal matrix (for keras, glmnet)
print(dim(dataset$x))
save(dataset, file = './Results/5v_sparseMatrix_onlytriage.RData')


#4) load indeces
load('./Results/5v_indeces_list.RData')


#5) start
source('./Scripts/R/25_fitboost.R')

results <- matrix(NA, length(indeces_list), 2)
colnames(results) <- c('train', 'dev')

for (depth in c(15,20,25)) {
        for (i in 1:length(indeces_list)) {
                indeces <- indeces_list[[i]]
                aucs <- fitboost(dataset, indeces, 
                                 max_depth = depth, 
                                 eta = 0.3,
                                 nthread = 5,
                                 nrounds = 20,
                                 colsample_bylevel = 0.1)
                results[i,] <- aucs
        }
        print(results)
        #get mean train and dev AUCs
        print(paste('Average train and dev AUCs (onlytriage) for depth', depth))
        print(colMeans(results))
}
