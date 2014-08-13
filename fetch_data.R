
dataDir<- "./data"

if (!file.exists( dataDir )) {
  dir.create( dataDir )
}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName<- "HAR-Data.zip"

if ( !file.exists( fileName ) ) {
  download.file(fileUrl, destfile = paste( dataDir, fileName, sep='/' ), method = "curl")

  curWD<-getwd()
  setwd( dataDir )
  system( paste( "unzip", fileName ) )
  
  setwd( curWD )
}
