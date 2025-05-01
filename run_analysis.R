# run_analysis.R code file

# Loading dplyr package to eventually tidy the data
library(dplyr)

# Step 1: Merge test and train folders

# Read training data
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

# Same thing, but for test data
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

# Now use rbind to merge training and test datasets
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

# Step 2: Extract only the measurements on the mean and standard deviation
# for each measurement

# Reading feature names from features document
features <- read.table("UCI HAR Dataset/features.txt", 
                       col.names = c("index", "name"))

# Identify indices for mean() and std() measurements
mean_std_indices <- grep("mean\\(\\)|std\\(\\)", features$name)

# Indexing columns specified on the last line and renaming the columns to
# match features$name
x_data_subset <- x_data[, mean_std_indices]
colnames(x_data_subset) <- features$name[mean_std_indices]

# Step 3: Use descriptive activity names to name the activities in the dataset

# Using activity_labels.txt to index columns in y_data based on number 1-6
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", 
                              col.names = c("id", "activity"))
y_data$activity <- activity_labels[y_data$V1, 2]

# Step 4: Appropriately label the data set with descriptive variable names

# Use cbind to combine data together, rename column in subject_data
colnames(subject_data) <- "subject"
combined_data <- cbind(y_data, subject_data, x_data_subset)

# Step 5: Create a second, independent tidy data set with the average of each
# variable for each activity and each subject

# Creating the dataset, tidying everything up
final_dataset <- combined_data %>%
  group_by(subject, activity) %>%
  summarize(across(everything(), mean), .groups = 'drop')

# Optional print statement at the end
print(final_dataset)

# Writing .txt file for submission
write.table(final_dataset, file = "tidy_dataset.txt", row.name = FALSE)