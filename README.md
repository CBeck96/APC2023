# APC2023
This is a github repository for the code used to get the results in the paper: "Trends in the incidence of mental disorders according to age, period, and birth cohort". (LINK)

## Functions

| R-function            | Calculates                                   |
| --------------------- | -------------------------------------------- |
|          |           |

### Libraries used

| Library       | Used in                                         |
| ------------- | ----------------------------------------------- |
|   |          |

At each of the R-scripts, the packages used in a function is listed. 

## Analysis





Epidemioligy with R - Bendix Carstensen

### Birth cohorts 

### Calender period


## Description of input data 

The study looks at individuals who are alive and healthy in Denmark at the begining of 2004 or your 1'st, 5'th or 10'th birthday (Depending on the earliest age of onset of the diagnose) whatever comes later. The study ends at the end of 2021. After cleaning the data, there is a data-set for each diagnose of intrest and it has the following columns.

| Column number | Column name   | Description                                                                        |
| ------------- | ------------- | ---------------------------------------------------------------------------------- |
| 1             | PID	          |	Person ID                                                                          |
| 2	            | KQN	          |	Sex                                                                                |
| 3	            | censor_stat	  |	Censoring status at end of study (1: Healthy, 2: Diagnosed, 3: Emigrated, 4: Dead) |
| 4	            | dobth	        |	Date of birth as continuous variable                                               |
| 5	            | doinc	        |	Date of entry as continuous variable                                               |
| 6  	          | doend	        | Date of exit as continuous variable                                                |

Example of dates as continuous variables:

| Date          | Continuous date  |
| ------------- | ---------------- |
| 01/01/2004    | 2004.000         |
| 18/03/2006    | 2006.208         |
| 07/07/2007    | 2007.511         |
| 30/11/2016    | 2016.913         |

### Availability of data and materials

Data for this study os property of Statistic Denmark and the Danish Health Data Authority. The data are available from the authorities, but restrictions apply.
