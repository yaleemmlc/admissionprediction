#Cross validation for XGBoost model (Github)
library(readr)
library(plyr)
library(dplyr)
library(reshape2)
library(parallel)
library(caret)
library(xgboost)
library(doMC)
library(pROC)

registerDoMC(5) #for parallelization. 
# Note that results may differ slightly when using a different number of cores, 
# given that nthreads in a hyperparameter for XGBoost.
# nthreads = 5 were used for all XGBoost portion of the study.


#1) load cleaned, deidentified dataframe

load('./Results/5v_cleandf.RData')

#2) Create a list of indeces for model fitting
source('./Scripts/R/20b_splitdataindex.R')
indeces_list <- splitdataindex(df)
save(indeces_list, file = './Results/5v_indeces_list.RData')

#3) Re-encode dataframe into design matrix x and response y
source("./Scripts/R/21_makematrix.R")
dataset <- makematrix(df, sparse = T)
save(dataset, file = './Results/5v_sparseMatrix.RData')

#4) Start CV
source('./Scripts/R/25_fitboost.R')

results <- matrix(NA, length(indeces_list), 2)
colnames(results) <- c('train', 'dev')

# Hyperparameters are changed manually. Here, we are optimizing depth.
for (depth in c(15,20,25)) {
        for (i in 1:length(indeces_list)) {
                indeces <- indeces_list[[i]]
                aucs <- fitboost(dataset, indeces, 
                                 max_depth = depth, 
                                 eta = 0.3,
                                 nthread = 5,
                                 nrounds = 30,
                                 colsample_bylevel = 0.05)
                results[i,] <- aucs
        }
        print(results)
        #get mean train and dev AUCs
        print(paste('Average train and dev AUCs for depth', depth))
        print(colMeans(results))
        
}