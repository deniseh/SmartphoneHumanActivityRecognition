# Smartphone Humani Activity Recognition Code Book

This document outlines any pre-requiste steps, the source of the data, variables and transformations, and outputs of `run_analyis.R`.  

## Pre-requisites

This package assumes that have installed reshape2 1.4.1 or higher and dplyr 0.4.1 or higher. This script will initialize these libraries with the library command, but will not automatically update or download these libraries on your behalf.

## Data Source

The data used in this analysis is the UCI "Human Activity Recognition Using Smartphones Data Set." The site describes this data as "Human Activity Recognition database built from the recordings of 30 subjects performing activities of daily living (ADL) while carrying a waist-mounted smartphone with embedded inertial sensors." Full inforamtion on the data and its format can be found at [link] http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones. 

The exact data file retrieved as a part of the script is: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

## Variables and Transformations

###Variables 
* `dataURL`: Fully qualified URL where the data is located
* `dataZip`: File name to be used as the destination file on local system
* `features`: data.table used to store feature names read from './UCI HAR Dataset/features.txt'
* `testSubject`: data.table used to store the `subject_id` read from './UCI HAR Dataset/test/subject_test.txt'
* `testX`: data.table used to store all observation values for each of the features. It is read from './UCI HAR Dataset/test/X_test.txt' and `features` is applied as the column names to the observations.
* `testY`: data.table used to stora the `activity_id` for each observation read from './UCI HAR Dataset/test/Y_test.txt'
* `obsType`: constant set to either "training data" or "test data" and stored with the resulting dataset so that if you wanted to subset based on the source of the data in the future, you could
* `testDataset`: concatination of `testSubject` , `testX`, and `testY` datasets with associated fixed value of `obsType`
* `trainSubject` , `trainX`, and `trainY` are the same as test except read from the equivalent 'train' files
* `trainDataset: same as testDataset above except using the associated train source datasets
* `allData`: union of `testDataset` and 'trainDataset`
* `meanAndStdDataOnly`: intermediate transformation dataset that is the same as `allData` except only mean and standard deviation observed columsn are retained from feature observation columns and ultimately including activity lables
* `activityLabels`: data.table used to store activity names and IDs read from './UCI HAR Dataset/activity_labels.txt'
* `tidyData`: is a dply data frame tbl that represents `meanAndStdDataOnly` with only a single measure and value for each row versus multiple observed values in each row   
* `tidySummary`: summarizes `tidyData` to calculate the mean for each subject, activity, and measure combination

### Steps and Transformations

1. Check locally to see if `dataZip` has been downloaded already. If not, use `dataURL` location to download it. If so, skip.
2. Unzip `dataZip` file but don't overwrite files if it has already been extracted. This will produce warnings, but okay to proceed.
3. Read './UCI HAR Dataset/features.txt' and store values `features` data.table
4. Read values from text files directly into `testSubject` , `testX`, and `testY`. While reading values into `testX` apply  
`features$feature_name` as column names to make values for human readable.
5. Set fixed variable `obsType` to "test data".
6. Column bind `testSubject` , `testX`, and `testY` datasets with associated fixed value of `obsType` into single data.frame `testDataset`.
7. Repeat steps 4-7 with equivalent training datasets.
8. Row bind `testDataset` with `trainDataset` into `allData`
9. Create `meanAndStdDataOnly` that is a subset of the column from `allData`. "subject_id","activity_id","obsType" are included explicitly and an inline grep (search) of columnames that include "std" and "mean" are kept as well.
10. Read './UCI HAR Dataset/activity_labels.txt' and store both names and IDs in `activityLabels` data.table 
11. Update existing `meanAndStdDataOnly` data.table to merge `activityLabels` joining on activity_id
12. Create `tidyData` by melting `meanAndStdDataOnly` using "subject_id","activity_id","obsType" as id columns and using the same inline grep above to list the measure variables
13. Convert `tidyData` to dply data frame tbl
14. Create `tidySummary` by perform an inline transformation of `tidyData` both grouping by "subject_id", "activity_name, and "variable" as well as creating a mean column calculated as the mean of the existing value column and removing any NAs (none known to occur but may happen in future data)

## Outputs

"tidySummary.txt" is written to the local directory an is a representation of `tidySummary` without row names.
