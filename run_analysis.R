# FILE
#   run_analysis.R
#
# OVERVIEW
#   Using data collected from the accelerometers from the Samsung Galaxy S 
#   smartphone, work with the data and make a clean data set, outputting the
#   resulting tidy data to a file named "tidy_data.txt".
#   See README.md for details.

library(data.table)

#Download the source file and store it in a temporary file, and unzip it.
sourceSet <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", sourceSet)
sourceSet <- unzip(sourceSet)

#extract all the paramater features of the training set
features <- fread(sourceSet[[2]])
activityLabel <- fread(sourceSet[[1]])

#read test data
testSubject <- fread(sourceSet[[14]])
testX <- fread(sourceSet[[15]])
testY <- fread(sourceSet[[16]])


#read training data
trainSubject <- fread(sourceSet[[26]])
trainX <- fread(sourceSet[[27]])
trainY <- fread(sourceSet[[28]])

#assemble data table
dataSubject <- rbind(testSubject, trainSubject)
dataActivity <- rbind(testY, trainY)
dataFeatures <- rbind(testX, trainX)
fullSet <- cbind(dataActivity, dataSubject, dataFeatures)
names(fullSet) <- c(c("activity", "subject"), as.character(features$V2))

# Subset the data table into descriptor columns and mean and standard deviation calculations
meanStdSet <- fullSet[, .SD, .SDcols = names(fullSet) %like% "activity|subject|mean\\(\\)|std\\(\\)"]

#convert activity labels from numeric to character
meanStdSet$activity <- activityLabel$V2[meanStdSet$activity]

#rename columns
names(meanStdSet)<-gsub("^t", "time", names(meanStdSet))
names(meanStdSet)<-gsub("^f", "freqency", names(meanStdSet))
names(meanStdSet)<-gsub("Acc", "Accelerometer", names(meanStdSet))
names(meanStdSet)<-gsub("Gyro", "Gyroscope", names(meanStdSet))
names(meanStdSet)<-gsub("Mag", "Magnitude", names(meanStdSet))
names(meanStdSet)<-gsub("BodyBody", "Body", names(meanStdSet))
names(meanStdSet)

#summarize the data into the mean of the mean and sd by all combinations of the activity and subject combinations 
tidyData <- meanStdSet[, lapply(.SD, mean), by = c("activity", "subject")]

#print file
write.table(tidyData, file = "tidy.txt", row.names = FALSE)


