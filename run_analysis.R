setwd("C:\\Users\\alanc\\Desktop\\Alans Data Science Class\\Getting and Cleaning Data\\Week 4")

X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt", colClasses = "character")
X_test <- tbl_df(X_test)

y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
y_test <- tbl_df(y_test)

y_test <- rename(y_test, activities = V1)

X_test <- cbind(y_test, X_test)

X_test[,1] <- gsub("1", "WALKING", X_test[,1])
X_test[,1] <- gsub("2", "WALKING_UPSTAIRS", X_test[,1])
X_test[,1] <- gsub("3", "WALKING_DOWNSTAIRS", X_test[,1])
X_test[,1] <- gsub("4", "SITTING", X_test[,1])
X_test[,1] <- gsub("5", "STANDING", X_test[,1])
X_test[,1] <- gsub("6", "LAYING", X_test[,1])

subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", colClasses = "character")
subject_test <- tbl_df(subject_test)

subject_test <- rename(subject_test, subject = V1)

X_test <- cbind(subject_test, X_test)


X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt", colClasses = "character")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")

X_train <- tbl_df(X_train)
y_train <- tbl_df(y_train)

y_train <- rename(y_train, activities = V1)

X_train <- cbind(y_train, X_train)

X_train[,1] <- gsub("1", "WALKING", X_train[,1])
X_train[,1] <- gsub("2", "WALKING_UPSTAIRS", X_train[,1])
X_train[,1] <- gsub("3", "WALKING_DOWNSTAIRS", X_train[,1])
X_train[,1] <- gsub("4", "SITTING", X_train[,1])
X_train[,1] <- gsub("5", "STANDING", X_train[,1])
X_train[,1] <- gsub("6", "LAYING", X_train[,1])

subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", colClasses = "character")
subject_train <- tbl_df(subject_train)

subject_train <- rename(subject_train, subject = V1)
X_train <- cbind(subject_train, X_train)

X_merged <- merge(X_test, X_train, all = TRUE)

features <- read.table("./data/UCI HAR Dataset/features.txt", colClasses = "character")
features <- tbl_df(features)

meanstdindex <- c(grep("mean", features$V2), grep("std", features$V2))
meanstdindex <- sort(meanstdindex)
meanstdindex <- meanstdindex + 2

X_merged <- select(X_merged, c(1, 2, meanstdindex))

X_merged_names <- names(X_merged[3:81])
X_merged_names <- gsub("V","",X_merged_names)
features <- features[X_merged_names,2]

features <- sub("^t", "time", features$V2)
features <- sub("^f", "freq", features)

features <- tolower(features)
features <- sub("\\()", "", features)
features <- gsub("-", "", features)
features <- sub("bodybody", "body", features)

colnames(X_merged) <- c("subject", "activities", features)

X_merged[,1] <- as.numeric(X_merged[,1])
for(i in 3:81){
        X_merged[,i] <- as.numeric(X_merged[,i])
}

groupedbysubject <- group_by(X_merged, subject, activities)
summarizedbymean <- summarize_at(groupedbysubject, vars(timebodyaccmeanx:freqbodygyrojerkmagmeanfreq), funs(mean))

summarizedbymean <- arrange(summarizedbymean, subject)


