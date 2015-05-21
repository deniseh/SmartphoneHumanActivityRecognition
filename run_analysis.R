# This file does the following:
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable 
#    for each activity and each subject.
#

#load the reshape2 and dplyr libraries
library(reshape2)
library(dplyr)
#URL for where the data is located and where we'd like to place the files
dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dataZip <- "UCI-HAR-Dataset.zip"

#if the file hasn't already been downloaded, do so 
if (file.exists(dataZip) == FALSE) {
  download.file(dataURL, dataZip, method="curl")
}

#unzip the files
unzip(dataZip, overwrite=FALSE)

######### Merging the training and the test sets #########
#read in feature table and provide row and column names
features <- read.table("./UCI HAR Dataset/features.txt", col.names=c("feature_id","feature_name"),row.names=1)

#read in the test datasets and create a single table
testSubject <- read.table("./UCI HAR Dataset/test/subject_test.txt",col.names=c("subject_id"))
testX <- read.table("./UCI HAR Dataset/test/X_test.txt", col.names=features$feature_name)
testY <- read.table("./UCI HAR Dataset/test/Y_test.txt",col.names=c("activity_id"))
obsType <- "test data"
testDataset <- cbind(testSubject,testX,testY,obsType)

#read in the training datasets and create a single table
trainSubject <- read.table("./UCI HAR Dataset/train/subject_train.txt",col.names=c("subject_id"))
trainX <- read.table("./UCI HAR Dataset/train/X_train.txt", col.names=features$feature_name)
trainY <- read.table("./UCI HAR Dataset/train/Y_train.txt",col.names=c("activity_id"))
obsType <- "training data"
trainDataset <- cbind(trainSubject,trainX,trainY,obsType)

#combine both the test and the training data to a single dataset
allData <- rbind(testDataset,trainDataset)

######### Extracting only mean and standard deviation for each measurement #########
meanAndStdDataOnly <- allData[,c("subject_id","activity_id","obsType",colnames(allData)[grep("mean",colnames(allData))],colnames(allData)[grep("std",colnames(allData))])]

######### Applying descriptive activity names #########
#read in activity table and provide row and column names
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt", col.names=c("activity_id","activity_name")) 

#merge activityLabels into the dataset
meanAndStdDataOnly <- merge(activityLabels,meanAndStdDataOnly,by="activity_id")

######### Creating tidy data set with the average of each variable for each activity and each subject ######### 
#final step in creating a single tidy dataset
tidyData <- melt(meanAndStdDataOnly,id=c("subject_id","obsType","activity_name"),measure.vars=c(colnames(allData)[grep("mean",colnames(allData))],colnames(allData)[grep("std",colnames(allData))])) 
tidyData <- tbl_df(tidyData)

#summarize the tidy data
tidySummary <- tidyData %>% group_by(subject_id,activity_name,variable) %>% summarize(mean = mean(value, na.rm = TRUE))

#write out tidy data to a file
write.table(tidySummary, file="tidySummary.txt", row.name=FALSE) 
