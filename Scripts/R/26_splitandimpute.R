#Imputes input matrices for the training, validation, and test sets using the median from training set

splitandimpute <- function(indeces, x, y) {
        x_train <<- x[indeces$i_train,]
        y_train <<- y[indeces$i_train]
        
        
        x_dev <<- x[indeces$i_dev,]
        y_dev <<- y[indeces$i_dev]
        
        x_test <<- x[indeces$i_test,]
        y_test <<- y[indeces$i_test]
        
        
        #2) impute x_train, then apply preprocessing to traindev, dev, test
        impute <- preProcess(x_train, method = c('center','scale','medianImpute'))
        x_train <<- predict(impute,x_train)
        x_dev <<- predict(impute, x_dev)
        x_test <<- predict(impute, x_test)
        print('Dataset split and imputed')
}