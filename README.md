# Getting and Cleaning Data Course Project

The Human Activity Recognition Using Smartphones Dataset is grouped by test subject and then activities and summarized by the mean for each measurement.  The variable names from the original dataset have been changed to easier to understand names.


## Repository Contents

The repository includes one file that can be used to read the data from The Human Activity Recognition Using Smartphones Dataset and outputs the tidydata.txt data table.  The original dataset is available at the site where the data was obtained:
<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

| File Name | Description |
| --------- | ----------- |
| README.md   | Documentation explaining the project and how to use files contained in the repository. |
| CodeBook.md | Describes the variables, data, transformations of the dataset. |
| tidydata.txt | The tidy version of The Human Activity Recognition Using Smartphones Dataset which is grouped by test subject and then activities and summarized by the mean for each measurement. |
| run_analysis.R | R script to convert The Human Activity Recognition Using Smartphones Dataset to tidydata.txt.  The script uses read.table() to read the measurement data, merge() to merge the training and test data sets, group_by() to group by test subject and activity, and summarize_at() to summarize by mean. |

## The Process

1. Merge the training and the test sets to create one data set.

2. Insert descriptive activity names.

3. Extract the measurements on the mean and standard deviation for each observation.

4. Appropriately label the data set with descriptive variable names.

5. Create a second, independent tidy data set with the average of each variable for each activity and each subject.

### Merge the Training and the Test Sets
First, we need to merge the training and test sets.  In order to do this we need to read in the X_test, X_train, y_test, and y_train tables using read.table().  The tables are then converted to tibble format for easier viewing using tbl_df().  We will also rename the y_test and y_train data frames "activities" using 

```r
X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt", colClasses = "character")
X_test <- tbl_df(X_test)

y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
y_test <- tbl_df(y_test)

X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt", colClasses = "character")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")

X_train <- tbl_df(X_train)
y_train <- tbl_df(y_train)

```

We then rename the "V1" column in the y_train and y_test data frames to "activities" using rename() and column bind the same columns to the X_train and X_test data frames.

```r
y_test <- rename(y_test, activities = V1)

X_test <- cbind(y_test, X_test)

y_train <- rename(y_train, activities = V1)

X_train <- cbind(y_train, X_train)

```

The key for merging the X_test and X_train data frames is the subject variable.  So, before merging the data frames, we need to read in the subject_test and subject_train data frames using read.table, rename the "V1" column in each "subject", and bind them to the X_test and X_train data frames.

```r
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", colClasses = "character")
subject_test <- tbl_df(subject_test)

subject_test <- rename(subject_test, subject = V1)

X_test <- cbind(subject_test, X_test)

subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", colClasses = "character")
subject_train <- tbl_df(subject_train)

subject_train <- rename(subject_train, subject = V1)
X_train <- cbind(subject_train, X_train)
```

Now, we will merge the X_train and X_test data frames using merge().

```r
X_merged <- merge(X_test, X_train, all = TRUE)
```

### Insert descriptive activity names.

The activity numbers are replaced by their corresponding activity names using gsub().

```r
X_test[,1] <- gsub("1", "WALKING", X_test[,1])
X_test[,1] <- gsub("2", "WALKING_UPSTAIRS", X_test[,1])
X_test[,1] <- gsub("3", "WALKING_DOWNSTAIRS", X_test[,1])
X_test[,1] <- gsub("4", "SITTING", X_test[,1])
X_test[,1] <- gsub("5", "STANDING", X_test[,1])
X_test[,1] <- gsub("6", "LAYING", X_test[,1])

X_train[,1] <- gsub("1", "WALKING", X_train[,1])
X_train[,1] <- gsub("2", "WALKING_UPSTAIRS", X_train[,1])
X_train[,1] <- gsub("3", "WALKING_DOWNSTAIRS", X_train[,1])
X_train[,1] <- gsub("4", "SITTING", X_train[,1])
X_train[,1] <- gsub("5", "STANDING", X_train[,1])
X_train[,1] <- gsub("6", "LAYING", X_train[,1])
```

### Extract the measurements on the mean and standard deviation for each observation.

Next, we are going to extract the measurements on the mean and standard deviation for each observation.  In order to do this we will first need to read in the features data frame using read.table() and index the measurements on mean and standard deviation so we can later select only the columns associated with mean and standard deviations in our X_merged data frame.  Because we have the subject and activities columns at the beggining of the we will also need to add 2 to the mean and standard deviation index.

```r

features <- read.table("./data/UCI HAR Dataset/features.txt", colClasses = "character")
features <- tbl_df(features)

meanstdindex <- c(grep("mean", features$V2), grep("std", features$V2))
meanstdindex <- sort(meanstdindex)
meanstdindex <- meanstdindex + 2
```

Using the index, we then select the corresponding columns in our X_merged data frame using select().

```r
X_merged <- select(X_merged, c(1, 2, meanstdindex))
```

### Appropriately label the data set with descriptive variable names.

The fourth step in the process is to appropriately label the data set with descriptive variable names.  First, we will remove the "V"s from the variable names of our merged data set using gsub() so we can use the remaining numbers to so we can use the remaining numbers to filter out the measurement labels from the features data frame not associated with mean or standard deviation.

```r
X_merged_names <- names(X_merged[3:81])
X_merged_names <- gsub("V","",X_merged_names)
features <- features[X_merged_names,2]
```

We will now substitute the starting "t" and "f" for each measurement label with "time" and "freq", change the labels to lower case, delete "()" and "-", and replace "bodybody" with "body" for clarity purposes.

```r
features <- sub("^t", "time", features$V2)
features <- sub("^f", "freq", features)

features <- tolower(features)
features <- sub("\\()", "", features)
features <- gsub("-", "", features)
features <- sub("bodybody", "body", features)
```

Using our new features vector, we can now replace all of the variable names in X_merged with descriptive labels using colnames().

```r
colnames(X_merged) <- c("subject", "activities", features)
```

### Create a second, independent tidy data set with the average of each variable for each activity and each subject.

Finally, it is time create our tidy data set.  We need to group by subject and activities then take the mean of each measurement for each activity that was performed by the subject.  There will be one observation for each activity performed by each subject.  So, there will be six activities for each of the 30 subjects totaling 180 observations.  One observation per row and one variable per column.  This is tidy data.

```r
X_merged[,1] <- as.numeric(X_merged[,1])
for(i in 3:81){
        X_merged[,i] <- as.numeric(X_merged[,i])
}

groupedbysubject <- group_by(X_merged, subject, activities)
summarizedbymean <- summarize_at(groupedbysubject, vars(timebodyaccmeanx:freqbodygyrojerkmagmeanfreq), funs(mean))

summarizedbymean <- arrange(summarizedbymean, subject)
```

## Conclusion

The original data set has been merged into one data frame, the activities have been appropriately labeled, the measurements have been clearly labeled, and there has been one data frame created which is grouped by subject and activity and summarized by mean for each observation.




