require( 'data.table' )

# get the data and place it in dataDir
source( 'fetch_data.R' )

#
## set rowlimit for debugging, use -1 for production
#
rowLimit<- 100 # debug
#rowLimit<- -1 # production

#
## setup paths -- relative to current WD
#
dataSet.basePath<- paste( dataDir, "UCI HAR Dataset", sep="/" )
testSet.path<- paste( dataSet.basePath, "test", sep="/" )
trainSet.path<- paste( dataSet.basePath, "train", sep="/" )

##
## 1. Merges the training and the test sets to create one data set.
##
#
Corpus<- data.frame()

## set various source file names -- using paths above
#

## features in order of columns in the X files
features.fileName<- paste( dataSet.basePath, "features.txt", sep="/" )

## labels traslating numeric y values to human activity/category labels
activityLabels.fileName<- paste( dataSet.basePath, "activity_labels.txt", sep="/" )

## Test Set data -- X (data recordings), y (outcome activity) and Subject info
testSet.XfileName<- paste( testSet.path, "X_test.txt", sep="/" )
testSet.yfileName<- paste( testSet.path, "y_test.txt", sep="/" )
testSet.subjfileName<- paste( testSet.path, "subject_test.txt", sep="/" )

## Training Set data
trainSet.XfileName<- paste( trainSet.path, "X_train.txt", sep="/" )
trainSet.yfileName<- paste( trainSet.path, "y_train.txt", sep="/" )
trainSet.subjfileName<- paste( trainSet.path, "subject_train.txt", sep="/" )

## activities df used to look up class from y value
activities<- as.data.frame( fread( activityLabels.fileName ) )

## read y
y.test<- fread( testSet.yfileName, nrows=rowLimit )
y.train<- fread( trainSet.yfileName, nrows=rowLimit )
y<- rbind( as.data.frame( y.test ), as.data.frame( y.train ) )
y.test<-NULL; y.train<- NULL
y<- y[,1]   # slam it down to a vector
# create an additional vector with the class labels
##
## NB>  This handles step 3 of the assignment
##    ( 3. Uses descriptive activity names to name the activities in the data set)
y.class<- activities[match( y, activities[,1] ), 2]
activities<- NULL


## read the column labels for X from the features file
features.table<- fread( features.fileName )
features<- features.table$V2  # we just want the 'names' not the row ids, etc.
features.table<- NULL
# only keep the mean and standard dev variables -- see features_info.txt for naming conventions
##
## NB>  This handles step 2 of the assignemnt:
##  (2. Extracts only the measurements on the mean and standard deviation for each measurement.)
##
## construct a vector of the column names we're keeping and a mask vector to compare against the original set
##
features.keep<- features[grep( "mean\\(\\)|std\\(\\)", features )]
features.mask<- (features %in% features.keep)  

# start building the corpus from the biggest piece -- X data
## read the sensor (X) data -- 561 fixed width columns
widths<- vector()
# negative widths cause read.fwf to SKIP the column.  All cols are 16 chars wide, so we leverage the mask vector
widths[1:length(features)]<- 16*(1*features.mask + -1*!features.mask)    # assuming the features file rows (length) is in sync with the X file width (number of variables)
# first chunk
Corpus<- read.fwf( testSet.XfileName, 
                   widths=widths, header=FALSE,
                   n=rowLimit ) 
# second chunk -- rbind it BELOW the first 
Corpus<- rbind( Corpus,
                read.fwf( trainSet.XfileName,
                    widths=widths, header=FALSE,
                    n=rowLimit ) )

## read the subject IDs
subjects.test<- fread( testSet.subjfileName, nrows=rowLimit )
subjects.train<- fread( trainSet.subjfileName, nrows=rowLimit )

## put it all together in one big, hairy data frame !
# note order of outcome first, then inputs -- subject is kinda in the middle
# also note test on top of train -- no reason, just did it that way.  BUT, has to be consistent.
Corpus<- as.data.frame( cbind( rbind( subjects.test, subjects.train), # y, 
                               y.class, Corpus ) )
# add labels for the first two columns and the kept measurement columns
##
## NB> This handles step 4 from the assignment:
##  (4. Appropriately labels the data set with descriptive variable names.)
##
colnames(Corpus)<- c(  "SubjectNum", # "ActivityID", 
                      "Activity", features.keep )

y<- NULL; y.class<- NULL; subjects.test<- NULL; subjects.train<- NULL; X.test<- NULL; X.train<- NULL

# it's convenient to work with Activity and Subject as Factors later on...
Corpus$Activity<- as.factor( Corpus$Activity )
Corpus$SubjectNum<- as.factor( Corpus$SubjectNum )

#
## Corpus now holds ALL the data combined
#


# (2. Extracts only the measurements on the mean and standard deviation for each measurement. )
# (3. Uses descriptive activity names to name the activities in the data set) --> See comment in Step 1/reading activities above
# (4. Appropriately labels the data set with descriptive variable names.)
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.


corp.summary<- aggregate.data.frame( Corpus, by=list( Corpus$SubjectNum, Corpus$Activity ), FUN=mean )
corp.summary<- corp.summary[, -3:-4]
colnames( corp.summary )[1:2]<- c( "SubjectNum", "Activity" )
corp.summary<- corp.summary[ order( corp.summary$SubjectNum ), ]
rownames( corp.summary )<- NULL




