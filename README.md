# Data-science-project

The code presented in file run_analysis.R.

General description

The code processes information regarding measurements of signals from Samsung watches accelerometer and gyroscope receiving
average summary per activity type and per subject for Mean and Standard deviation values for each variable

The code represents the function which input parameter fname contains filename where to store the output dataset. 
By default it was set as "tidy_data.csv". The output file separator is " ".

It is presumed that the archive with all data is unpacked to working directory with original folder tree stored. 
Therefore the upper-level folder in working directory is UCI HAR Dataset.

Working logic

1. Inititating all required libraries (data.table, dplyr, lubridate, tidyr)
2. Reading source files where basic folder inside working folder is UCI HAR Dataset.
3. Preprocessing information from X_test.txt and X_train.txt.
- Selecting only columns containing information regarding mean and standard deviation values in both datasets
- Assigning names for these columns in both datasets
- Adding columns with activity_id, subject_id and group name(test or train)
- Adding activity name by activity_id
- Selecting only required columns excluding working columns and non-required
- Grouping dataset per subject and activity name with calculating averages for each variable
- Writing down the file