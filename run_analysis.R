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
    ##All variables which contain measurements united in one column Key1 as row values
    ##and all measurements in another called measurement
    gather(key=Key1, value=measurement, names(tide_data[2:67])) %>% 
    ##Divides Key1 column to factors coded in column value
    ##Fast_Fourier_Transform (FFT) - by 1st symbol in the string where f corresponds to
    ##FFT and t to Time series.
    ##Statistical_operation reflects whether mean or standard deviation calculated
    ##Axis_name shows XYZ axis or Other measurement for values which were not
    ##converted to XYZ axis
    ##Device_type - from which device the information was received Accelerometer/Gyroscope
    ##Acceleration_type - Body or Gravity accelarion
    ##Jerk_type - whether calculation based on jerk values or normal.
    ##Magnitude reflects magnitude or other measure
    mutate(Fast_Fourier_Transform=if_else(substr(Key1,1,1)=="f", TRUE, FALSE), 
           Statistical_operation=if_else(grepl("mean", Key1), "Mean", "Standard deviation"), 
           Axis_name=if_else(substr(Key1,nchar(Key1),nchar(Key1)) %in% c("X", "Y", "Z"), substr(Key1,nchar(Key1),nchar(Key1)),"Other"), 
           Device_type=if_else(grepl("Acc", Key1), "Accelerometer", "Gyroscope"), 
           Acceleration_type=if_else(grepl("Body", Key1), "Body acceleration", "Gravity acceleration"), 
           Jerk_type=if_else(grepl("Jerk", Key1), "Jerk signal", "Routine signal"), 
           Magnitude=if_else(grepl("Mag", Key1), "Signal magnitude", "Other measure") ) %>%
    ##Renames column with activities
    rename(Activity_type=V2, Measurement=measurement) %>% 
    ##Sets column to be presented in preprocessed table
    select(Observation_group, Subject_id, Activity_type, Fast_Fourier_Transform, 
           Axis_name, Device_type, Acceleration_type, Jerk_type, Magnitude, 
           Statistical_operation, Measurement)
  
  ##Creation of new data table with average of mean and standard deviation values per subject and activity type 
  new_data<-tide_data %>% 
    ##Creates groups activity type, subject, statistical operation and features of original variables
    group_by(Subject_id, Activity_type, Fast_Fourier_Transform, 
             Axis_name, Device_type, Acceleration_type, Jerk_type, Magnitude, 
             Statistical_operation) %>% 
    ##Calculates average figures per activity, subject and statistical operation
    summarize(Average_value=mean(Measurement)) %>% 
    ##Substitutes variables Statistical_operation and Measurement by Mean and Standard
    ##deviation variables containing its averages by activity and subject
    spread(Statistical_operation, Average_value)
  ##Writes information from new summarized table to the file which name was
  ##specified in fname variable which is input of function run_analysis
  write.table(new_data, fname, row.name=FALSE)
 
  }