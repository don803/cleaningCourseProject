#clear things out
rm(list=ls())

#set my WD
setwd('c:\\data\\cleaning\\courseproject\\')

#Get the zip
if (!file.exists("getdata-projectfiles-UCI HAR Dataset.zip")) {   
    filename<-"getdata-projectfiles-UCI HAR Dataset.zip"
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, destfile = filename, extra='-L',mode='wb')
}

#extract it
if (!file.exists("UCI HAR Dataset")) {   unzip(filename) }

#manipulate my labels
featurelabels<-read.table("UCI HAR Dataset/features.txt")
featurelabels[,2]<-as.character(featurelabels[,2])
activitylabels<-read.table(".\\UCI HAR Dataset\\activity_labels.txt")
activitylabels[,2]<-as.character(activitylabels[,2])
newfeaturelabels<-grep(".*mean.*|.*std.*",featurelabels[,2])
newfeaturelabels.names<-featurelabels[newfeaturelabels,2]
newfeaturelabels.names<-gsub('-mean','Mean',newfeaturelabels.names)
newfeaturelabels.names<-gsub('-std','StandardDeviation',newfeaturelabels.names)
newfeaturelabels.names<-gsub('[-()]','',newfeaturelabels.names)

#load the data
x_train <- read.table(".\\UCI HAR Dataset\\train\\x_train.txt")[newfeaturelabels]
subject_train <- read.table(".\\UCI HAR Dataset\\train\\subject_train.txt")
y_train <- read.table(".\\UCI HAR Dataset\\train\\y_train.txt")
x_test <- read.table(".\\UCI HAR Dataset\\test\\x_test.txt")[newfeaturelabels]
subject_test <- read.table(".\\UCI HAR Dataset\\test\\subject_test.txt")
y_test <- read.table(".\\UCI HAR Dataset\\test\\y_test.txt")

#combine the data
x_combined <- rbind(x_test, x_train)
subject_combined <- rbind(subject_test, subject_train)
y_combined <- rbind(y_test, y_train)
master_combined<-cbind(subject_combined,y_combined,x_combined)

#neaten things up
colnames(master_combined)<-c("subject","activity",newfeaturelabels.names)
master_combined$subject<-as.factor(master_combined$subject)
master_combined$activity<-factor(master_combined$activity,levels=activitylabels[,1],labels=activitylabels[,2])

#create the oupput table
library(reshape2)
master_combinedmelt<-melt(master_combined,id=c("subject","activity"))
master_combinedmean<-dcast(master_combinedmelt,subject+activity~variable,mean)
write.table(master_combinedmean,"result.txt",row.names=F,quote=F)
