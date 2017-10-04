##variable fname contains filename as string to which final result 
##should be stored. The separate of output file is " "
##It is presumed that archive with all data is unpacked to working directory
##with original folder tree. Therefore the upper-level folder in working 
##directory is UCI HAR Dataset
run_analysis <- function(fname="tidy_data.csv"){
  ##initiating all packages required
  
  library(dplyr)
  library(lubridate)
  library(reshape2)
  library(tidyr)
  library(data.table)
  
  ##reading source files
  
  features<-read.table("./UCI HAR Dataset/features.txt", sep=" ", header=FALSE)
  activity_labels<-read.table("./UCI HAR Dataset/activity_labels.txt", sep=" ", header=FALSE)
  subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt", sep=" ", header=FALSE)
  X_test<-read.table("./UCI HAR Dataset/test/X_test.txt", fill=TRUE, header=FALSE)
  y_test<-read.table("./UCI HAR Dataset/test/y_test.txt", sep=" ", header=FALSE)
  subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt", sep=" ", header=FALSE)
  X_train<-read.table("./UCI HAR Dataset/train/X_train.txt", fill=TRUE, header=FALSE)
  y_train<-read.table("./UCI HAR Dataset/train/y_train.txt", sep=" ", header=FALSE)
  X_test<-tbl_df(X_test)
  X_train<-tbl_df(X_train)
  
  ##Raw data from X_test and X-train pre-processing
  tide_data<-rbind(X_test %>% 
                     ## Selects columns which contains mean and standard deviation calculations
                     select(grep("^.*mean[:punct:(]|std[:punct:(].*$", features$V2)) %>%
                     ## Names preselected columns by their original name from features.txt file
                     setNames(features$V2[grep("^.*mean[:punct:(]|std[:punct:(].*$", features$V2)]) %>% 
                     ##Adds variable to mark that this dataset from test group, variable of 
                     ##subject_id and activity_id
                     mutate(Observation_group="test", Subject_id=subject_test$V1, Activity_id=y_test$V1) %>% 
                     ##Attaches activity type names to the file by activity_id column
                     merge(activity_labels, by.x="Activity_id", by.y="V1"), 
                   X_train %>% 
                     ## Selects columns which contains mean and standard deviation calculations
                     select(grep("^.*mean[:punct:(]|std[:punct:(].*$", features$V2)) %>% 
                     ## Names preselected columns by their original name from features.txt file
                     setNames(features$V2[grep("^.*mean[:punct:(]|std[:punct:(].*$", features$V2)]) %>%
                     ##Adds variable to mark that this dataset from test group, variable of 
                     ##subject_id and activity_id
                     mutate(Observation_group="train", Subject_id=subject_train$V1, Activity_id=y_train$V1) %>%
                     ##Attaches activity type names to the file by activity_id column
                     merge(activity_labels, by.x="Activity_id", by.y="V1")) 
  tide_data<-tide_data %>%
    ##Selects only required columns
    select(Subject_id, V2, names(tide_data[2:67])) %>%
    ##Renames columns to readable names
    rename(Activity_name=V2) %>%
    ##Creates groups by subject and activity name
    group_by(Subject_id, Activity_name) %>%
    ##Groups data with calculating average per group
    summarize_all(mean)
  ##Write down the dataset to the file with name stored in variable fname
  write.table(tide_data, fname, row.name=FALSE)
  }