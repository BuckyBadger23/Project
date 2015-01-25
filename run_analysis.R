# Step 1: Download the "zipped" data from Internet into a folder 
#called "human_data" which is saved in the working directory.

if(!file.exists("./human_data")){dir.create("./human_data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./human_data/Dataset.zip",mode = 'wb')

# Step 2: Unzip the folder called Dataset. After unzipping the working files are
#located in a folder called "UCI HAR Dataset".

unzip(zipfile="./human_data/Dataset.zip",exdir="./human_data")

# Step 3: Load the subject values from each group. Note that these files have no headers.

subjTrain <- read.table("./human_data/UCI HAR Dataset/train/subject_train.txt", header = FALSE )
subjTest  <- read.table("./human_data/UCI HAR Dataset/test/subject_test.txt", header = FALSE)

# Step 4: Load the activity values from each group. Note that these files have no headers.

actTrain <- read.table("./human_data/UCI HAR Dataset/train/Y_train.txt",header = FALSE)
actTest <- read.table("./human_data/UCI HAR Dataset/test/Y_test.txt",header = FALSE)

# Step 5: Load the features (all 561) values from each group. Note that these files have no headers.

featTrain <- read.table("./human_data/UCI HAR Dataset/train/X_train.txt",header = FALSE)
featTest <- read.table("./human_data/UCI HAR Dataset/test/X_test.txt",header = FALSE)

# Step 6: Make appropriate headers for all the column variables associated with activity.

activity_labels <- read.table("./human_data/UCI HAR Dataset/activity_labels.txt")[,2]
actTrain[,2] = activity_labels[actTrain[,1]]
names(actTrain) = c("Activity_ID", "Activity_Label")
actTest[,2] = activity_labels[actTest[,1]]
names(actTest) = c("Activity_ID", "Activity_Label")

# Step 7: Combine the training and test tables from steps 3, 4 and 5 above using the function rbind().

allSubjects <- rbind(subjTrain, subjTest)
allActivities <- rbind(actTrain, actTest)
allFeatures <- rbind(featTrain, featTest)

#Step 8: Subset allFeatures from step 6 above for only column names containing the substrings "mean" or "std".
names(allFeatures)  <- read.table("./human_data/UCI HAR Dataset/features.txt")[,2]
mean_std_features <- grepl("mean|std", names(allFeatures))

# Step 9. Make a header "subject" for the subject variable column.

names(allSubjects) <- c("subject")

# Step 10: Combine allSubjects, allActivities and allFeatures from step 7 using the cbind() function twice.

allSubjActiv <- cbind(allSubjects,allActivities)
allData <- cbind(allSubjActiv, allFeatures)

# Step 11:  Extract only the measurements on the mean and standard deviation for each measurement.
# Rename some of the columns to make them more "reader-friendly".

mean_std_Data <- allData[,mean_std_features] 
names(mean_std_Data) <- gsub("BodyBody", "Body", names(mean_std_Data))
names(mean_std_Data) <- gsub("^t", "time", names(mean_std_Data))
names(mean_std_Data) <- gsub("^f", "frequency", names(mean_std_Data))

# Step 12: Apply mean function to dataset mean_std_Data for each subject and activity.
# Rename this file "tidyData" and write it to the working directory.

library(plyr)
tidyData<-aggregate(. ~subject + Activity_ID +Activity_Label, mean_std_Data, mean)
tidyData<-tidyData[order(tidyData$subject,tidyData$Activity_ID),]


write.table(tidyData, file = "tidyData.txt",row.name=FALSE)