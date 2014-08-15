require( 'data.table' )

# get the data and place it in dataDir
source( 'fetch_data.R' )

dataSet.basePath<- paste( dataDir, "UCI\\ HAR\\ Dataset", sep="/" )
testSet.path<- paste( dataSet.basePath, "test", sep="/" )
trainSet.path<- paste( dataSet.basePath, "train", sep="/" )

# 1. Merges the training and the test sets to create one data set.
testSet.XfileName<- paste( testSet.path, "X_test.txt", sep="/" )
testSet.yfileName<- paste( testSet.path, "y_test.txt", sep="/" )
testSet.subjfileName<- paste( testSet.path, "subject_test.txt", sep="/" )

trainSet.XfileName<- paste( trainSet.path, "X_train.txt", sep="/" )
trainSet.yfileName<- paste( trainSet.path, "y_train.txt", sep="/" )
trainSet.subjfileName<- paste( trainSet.path, "subject_train.txt", sep="/" )

X.test<- fread( testSet.XfileName,
                nrow=10 )


# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
