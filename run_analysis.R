# This script uses data from fhe following site.
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones   
# Merge the data files to create one data set.
# Extract only the measurements on the mean and standard deviation for each measurement. 
# Create descriptive activity names for the activities in the data set.
# Label the data set with descriptive variable names. 
# Create a second independent tidy data set.
# Put the average of each variable for each activity and each subject in the tidy data.
# Writes the tidy data set to a text file.

# Load the reshape2 library to use the melt function
library(reshape2)

# Read the file for the activity labels and give columns descriptive names
activity_labels <- read.table("activity_labels.txt", col.names = c("activity_id", "activity_name"))

# Read the file for the features and give columns descriptive names
features <- read.table("features.txt", col.names = c("feature_id", "feature_name"))

# Read the data from the test files and give columns descriptive names
test_data <- read.table("./test/X_test.txt")
colnames(test_data) <- features[,"feature_name"]
test_labels <- read.table("./test/y_test.txt", col.names = "activity_id")
test_subject <- read.table("./test/subject_test.txt", col.names = "subject_id")

# Put all the test data into one data set
test_final <- cbind(test_data, test_labels, test_subject)

# Read the data from the train files and give columns descriptive names
train_data <- read.table("./train/X_train.txt")
colnames(train_data) <- features[,"feature_name"]
train_labels <- read.table("./train/y_train.txt", col.names = "activity_id")
train_subject <- read.table("./train/subject_train.txt", col.names = "subject_id")

# Put all the train data into one data set
train_final <- cbind(train_data, train_labels, train_subject)

# Combine the final test and train data into one data set
merge_data <- rbind(test_final, train_final)

# Find the features that measure only the mean and standard deviation
find_mean_std <- grep("mean|std", features[,"feature_name"], ignore.case = TRUE)

# Put all the mean and standard deviation measurements in one data set
mean_std_data <- merge_data[,find_mean_std]

# Add activity and subject data to the mean and standard deviations data
final_data <- cbind(merge_data[,562:563], mean_std_data)

# Merge the activity labels with the rest of the data
all_data <- merge(activity_labels, final_data, by = "activity_id")

# Create the tidy data set with the average of each variable for each activity and each subject
tidy_data <- aggregate(all_data[,4:89], list(all_data$subject_id, all_data$activity_name), mean)
names(tidy_data)[1:2] <- c("subject_id", "activity_name")

# Convert tidy data so each measurement is a value and set column names
melted_data <- melt(tidy_data, id.vars=c("subject_id", "activity_name"))
names(melted_data)[3:4] <- c("feature_name", "mean")

# Write the data set to a text file
write.table(melted_data, "tidy_data.txt", row.name = FALSE)
