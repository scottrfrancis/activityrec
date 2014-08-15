
dataDir<- "./data"
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName<- "HAR-Data.zip"



if (!file.exists( dataDir )) {
  dir.create( dataDir )
}

curWD<-getwd()
setwd( dataDir )

if ( !file.exists( fileName ) ) {
  download.file(fileUrl, destfile= fileName, method = "curl")

  system( paste( "unzip", fileName ) )  
}
setwd( curWD )

