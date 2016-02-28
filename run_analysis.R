##
## run_analysis.R
## Prepare folder "data" to download files after set the working directoiry
##
dataPath<-getwd()
dataPath<-paste(dataPath,"/data", sep="")
if(!file.exists(dataPath)){dir.create(dataPath)}
setwd(dataPath)
##
## Download files for assignment
##
dataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataUrl, destfile="dataSet.zip")
unzip(zipfile="./dataSet.zip")
##
## Load required packages
##
if (!require("data.table")) {install.packages("data.table")}
require("data.table")
if (!require("reshape2")) {install.packages("reshape2")}
require("reshape2")
##
## Load activity labels and features
## extract features
##
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./UCI HAR Dataset/features.txt")[,2]
extract_features <- grepl("mean|std", features)
##
## Read  X_test and  y_test data.
##
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
names(X_test) = features
##
## Measurements and standard deviation for each measurement
##
X_test = X_test[,extract_features]
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"
test_data <- cbind(as.data.table(subject_test), y_test, X_test)
##
## X_train & y_train data.
##
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(X_train) = features
X_train = X_train[,extract_features]
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"
train_data <- cbind(as.data.table(subject_train), y_train, X_train)
##
## Join (merge) test and train
##
data = rbind(test_data, train_data)
id_labels = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data = melt(data, id = id_labels, measure.vars = data_labels)
tidy_data = dcast(melt_data, subject + Activity_Label ~ variable, mean)
##
## Appropriately labels the data set with descriptive variable names.
##
names(tidy_data)<-gsub("^t", "Time", names(tidy_data))
names(tidy_data)<-gsub("^f", "Frequency", names(tidy_data))
names(tidy_data)<-gsub("Acc", "Accelerometer", names(tidy_data))
names(tidy_data)<-gsub("Gyro", "Gyroscope", names(tidy_data))
names(tidy_data)<-gsub("Mag", "Magnitude", names(tidy_data))
names(tidy_data)<-gsub("BodyBody", "Body", names(tidy_data))
names(tidy_data)<-gsub("mean\\(\\)", "Mean", names(tidy_data))
names(tidy_data)<-gsub("meanFreq\\(\\)", "Mean", names(tidy_data))
names(tidy_data)<-gsub("std\\(\\)", "Std", names(tidy_data))
##
## create file to upload.
##
write.table(tidy_data, file = "./tidy_data.txt")
## end