#Cross validation for XGBoost model (only history) (Github)

library(readr)
library(plyr)
library(dplyr)
library(reshape2)
library(parallel)
library(caret)
library(xgboost)
library(doMC)
library(pROC)

registerDoMC(5) #for parallelization

#1) load data
load('./Results/5v_cleandf.RData')

#2) Filter for only history variables
source('./Scripts/R/23_useonlytriage.R')
df <- useonlyhistory(df)

#3) Re-encode dataframe into design matrix x and response y
source("./Scripts/R/21_makematrix.R")
dataset <- makematrix(df, sparse = T)
save(dataset, file = './Results/5v_sparseMatrix_onlyhx.RData')

#4) load indeces
load('./Results/5v_indeces_list.RData')

source('./Scripts/R/25_fitboost.R')

results <- matrix(NA, length(indeces_list), 2)
colnames(results) <- c('train', 'dev')

#Tuning for depth
for (depth in c(15,20,25)) {
        for (i in 1:length(indeces_list)) {
                indeces <- indeces_list[[i]]
                aucs <- fitboost(dataset, indeces, 
                                 max_depth = depth, 
                                 eta = 0.3,
                                 nthread = 5,
                                 nrounds = 20,
                                 colsample_bylevel = 0.05)
                results[i,] <- aucs
        }
        print(results)
        #get mean train and dev AUCs
        print(paste('Average train and dev AUCs (onlyhistory) for depth', depth))
        print(colMeans(results))
}
