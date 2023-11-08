# Age-Period-Cohort (APC2023)

This is a github repository for the code used to get the results in the paper: "Trends in the incidence of mental disorders according to age, period, and birth cohort". (LINK)

## Functions

Below is the R-functions created to make the analysis for the paper. 

| R-function            | Calculates                                              |
| --------------------- | ------------------------------------------------------- |
| `IR_birth_cohort()`   | The incidence rate with respect to birth cohort         |
| `IR_period()`         | The incidence rate with respect to calender period      |
| `count_DY()`          | Count the number of cases and sums up the person-years  |

### Libraries used

| Library       | Used in                                         |
| ------------- | ----------------------------------------------- |
| Epi           | The functions and analysis                      |
| popEpi        | The functions and analysis                      |
| mgcv          | The functions and analysis                      |
| ggplot2       | Creating the figures                            |
| ggnewscale    | Creating the figures                            |

At each of the R-scripts, the packages used in a function is listed. 

## Analysis

The analysis is run in the file `Analysis.R`. Note that the code is written as an example for a given diagnosis of interest denoted *DXX*. It might return an error or warning if the number of observations is too low to fit the model (GAM). If the counts and person-years still is of interest use the function `count_DY()`. In the file `panel_figure.R` the code for creating the panel plots can be found. 

The methods used in the functions follows the approach described in the book: **Epidemioligy with R** - by *Bendix Carstensen*. 

##### Birth cohorts 

The birth cohort groups depends on the earliest age of onset (EAOO) for the diagnose of interest. 

| EAOO | 1         | 5         |  10       | 
| ---- | --------- | --------- | --------- |
|      | 1924-1939 | 1924-1939 | 1924-1939 | 
|      | 1940-1949 | 1940-1949 | 1940-1949 | 
|      | 1950-1959 | 1950-1959 | 1950-1959 | 
|      | 1960-1969 | 1960-1969 | 1960-1969 | 
|      | 1970-1979 | 1970-1979 | 1970-1979 | 
|      | 1980-1989 | 1980-1989 | 1980-1989 | 
|      | 1990-1999 | 1990-1999 | 1990-1999 | 
|      | 2000-2009 | 2000-2016 | 2000-2011 | 
|      | 2010-2020 |         	 |           | 
 
##### Calender period

The calender periods chosen are as follows: [2004-2007), [2007-2010), [2010-2013), [2013-2016), [2016-2019), and [2019-2021).

## Description of input data 

The study looks at individuals who are alive and healthy in Denmark at the begining of 2004 or your 1'st, 5'th or 10'th birthday (Depending on the earliest age of onset of the diagnose) whatever comes later. The study ends at the end of 2021. After cleaning the data, there is a data-set for each diagnose of interest and it has the following columns.

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
