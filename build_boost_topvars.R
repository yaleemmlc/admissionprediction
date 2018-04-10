#Cross validation for XGBoost model (top variables) (Github)

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

load('./Results/5v_cleandf.RData')

# Option C. use top variables by 'gain'
source('./Scripts/R/24_usetopvars.R')
df <- usetopvars(df)

#3) Re-encode dataframe into design matrix x and response y
source("./Scripts/R/21_makematrix.R")
dataset <- makematrix(df, sparse = T) #sparse = F for a normal matrix (for keras, glmnet)
save(dataset, file = './Results/5v_sparseMatrix_topvars.RData')
 
load('./Results/5v_indeces_list.RData')

source('./Scripts/R/25_fitboost.R')

results <- matrix(NA, length(indeces_list), 2)
colnames(results) <- c('train', 'dev')

for (depth in c(7,10,15)) {
        for (i in 1:length(indeces_list)) {
                indeces <- indeces_list[[i]]
                aucs <- fitboost(dataset, indeces, 
                                 max_depth = depth, 
                                 eta = 0.3,
                                 nthread = 5,
                                 nrounds = 20,
                                 colsample_bylevel = 0.5)
                results[i,] <- aucs
        }
        print(results)
        #get mean train and dev AUCs
        print(paste('Average train and dev AUCs (topvariables) for depth', depth))
        print(colMeans(results))
}
