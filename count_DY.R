# Counting cases and person-years for both birth cohort and calender period

# Packages used:
# Epi
# popEpi

# Input:
# dat        : Data used
# eaoo       : Earliest age of onset (1,5,10)
# start_year : Starting year for the first birth cohort. Default 1924.
# effect     : Indicator for which effect it counts according to. Default is 
#              birth cohort (BC). The other option is calender period (CP).


# Output:
#   If effect is "BC". Returns a list containing:
#       1) A list which has a data frame for each birth cohort:
#           - Each data frame consists of the number of counts and person years:  
#                 - The count of cases at time t (D)
#                 - The sum of person years at time t (Y)
#                 - Time given in ages (A)
#                 - Group of the birth cohort
#       2) A data frame 
#                 - The count of cases at time t (D)
#                 - The sum of person years at time t (Y)
#                 - Time given in ages (A)
#                 - Group of the birth cohort
#   - If effect is "CP". Returns a list containing:
#       1) A list which has a data frame for each calender period:
#           - Each data frame consists of the number of counts and person years:  
#                 - The count of cases at time t (D)
#                 - The sum of person years at time t (Y)
#                 - Time given in ages (A)
#                 - Group of the calender period
#       2) A data frame 
#                 - The count of cases at time t (D)
#                 - The sum of person years at time t (Y)
#                 - Time given in ages (A)
#                 - Group of the calender period


count_DY <- function(dat, eaoo, start_year = 1924, effect = "BC"){
  # Checks if the eaoo values are valid values
  if(sum(eaoo == c(1,5,10)) != 1)  stop("eaoo is not equal to either (1,5,10)!")
  
  # Checks if it looks at birth cohorts
  if(effect == "BC"){
    # Secures that start year is between 1924 and 2021
    if(start_year < 1924)  stop("Must be larger or equal to 1924.")
    if(start_year > 2021 )  stop("Must be smaller than 2021")
    
    # Latest date of birth date possible
    lbthd <- 2022 - eaoo               
    lbthd_int <- 2010                  
    # Secures that there is at least 10 years in the last interval
    if(lbthd - lbthd_int <= 10){      
      lbthd_int <- 2000
    }
    
    # Creates the intervals of birth cohorts
    bth_cohort <- c(1924,seq(1940,lbthd_int,10),lbthd)
    bth_cohort <- bth_cohort[bth_cohort >= start_year]
    
    # Checks if the number of number of cases i
    if(length(bth_cohort) < 5)  stop("start_year is to large, to compute.")
    
    lbc <- list()
    DATA_DY <- data.frame()
    cat("Check point: Data prep", "\n")
    
    for(i in 1:(length(bth_cohort) - 1)){
      # Picks data of individuals born in the chosen birth cohort
      dat_b <- dat[round(dat$dobth,2) >= bth_cohort[i] & 
                     round(dat$dobth,2) < bth_cohort[i+1], 
                   c(1,3,4,5,6)]
      # Transforms the data into lexis format
      Ldat <- Lexis(entry = list(age = doinc - dobth, per = doinc),
                    exit = list(per = doend),
                    exit.status = factor(censor_stat, 
                                         labels = c("Well", "Event",
                                                    "Emigration", "Dead")),
                    data = dat_b)
      
      # Splits the data for counting cases and person-years
      b <- seq(eaoo,80,1)
      sdat <- splitLexis(Ldat, "age", breaks = b)
      
      iss <- c(1,2,5,10)
      # Counts the number of events and person-years.
      xtab <- xtabs(cbind(D = (lex.Xst == "Event"),
                          Y = lex.dur) ~ pmax(plyr::round_any(age,iss[1],
                                                              f=floor),
                                              eaoo),
                    data = sdat)
      
      D_count <- xtab[,"D"]
      print(D_count)
      j <- 1 
      # Checks if the number of counts is above 5 for ages looked at
      while(sum( as.numeric(D_count) < 5) > 1){
        j <- j + 1 
        cat("WHILE iteration: " ,j, "\n")
        if(j == 5){
          break("Number of cases is to small.")
        }
        y <- iss[j]
        # Counts the number of events and person-years.
        xtab <- xtabs(cbind(D = (lex.Xst == "Event"),
                            Y = lex.dur) ~ pmax(plyr::round_any(age,iss[j],
                                                                f=floor),
                                                eaoo),
                      data = sdat)
        D_count <- xtab[,"D"]
        cat("D: ", "\n")
        print(D_count)
      }
      cat("Check point: D greater or equal 5", "\n")
      fdat <- as.data.frame(cbind(xtab))
      data_DY <- cbind(fdat,
                       A = as.numeric(row.names(fdat)),
                       B = i)
      
      # Saves the counts and person-years for each birth cohorts
      lbc[[i]] <- list("Birth cohort" = paste(bth_cohort[i],
                                              bth_cohort[i+1] - 1,
                                              sep = "-"),
                       "Data" = data_DY)
      DATA_DY <- rbind(DATA_DY,data_DY)
    }
    # Saves all the output into one list
    out <- list(lbc,DATA_DY)
  }
  
  # Checks if it looks at calender period
  if(effect == "CP"){
    
    # Checks if the max age is between 1 and 80
    max_age = 80
    if(max_age <= 1)  stop("max_age must be strictly greater than 1.")
    if(max_age > 80)  stop("max_age can maximum be 80.")
    
    if(max_age != 80){
      dat_MA = dat
      dat_MA$doend = pmin(dat$doend,dat$dobth + max_age)
      dat_MA$censor_stat[dat_MA$doend != dat$doend] = 0
      dat_MA = dat_MA[dat_MA$doinc <= dat_MA$doend,]
      dat = dat_MA
    }
    
    # The intervals used to separate the data sets
    diag_cohort <- seq(2004,2022,3)
    
    lbc <- list()
    DATA_DY <- data.frame()
    cat("Check point: Data prep", "\n")
    for(i in 1:(length(diag_cohort) - 1)){
      c# Picks data of individuals born in the chosen calender period
      dat_b <- dat[round(dat$doinc,2) < diag_cohort[i+1] & 
                     round(dat$doend,2) >=  diag_cohort[i], 
                   c(1,3,4,5,6)]
      # Setting start date
      dat_b$doinc <- pmax(dat_b$doinc,diag_cohort[i])
      # Setting end date
      dat_bb <- dat_b
      dat_bb$doend <- pmin(dat_b$doend,diag_cohort[i+1])
      dat_bb$censor_stat[dat_bb$doend != dat_b$doend] <- 0
      # Transforms the data into lexis format
      Ldat <- Lexis(entry = list(age = doinc - dobth, per = doinc),
                    exit = list(per = doend),
                    exit.status = factor(censor_stat, 
                                         labels = c("Well", "Event",
                                                    "Emigration", "Dead")),
                    data = dat_bb)
      
      # Splits the data for counting cases and person-years
      b <- seq(eaoo,max_age,1)
      sdat <- splitLexis(Ldat, "age", breaks = b)
      
      iss <- c(1,2,5,10)
      # Counts the number of events and person-years.
      xtab <- xtabs(cbind(D = (lex.Xst == "Event"),
                          Y = lex.dur) ~ pmax(plyr::round_any(age,iss[1],f=floor),eaoo),
                    data = sdat)
      
      D_count <- xtab[,"D"]
      print(D_count)
      j <- 1 
      # Checks if the number of counts is above 5 for ages looked at
      while(sum( as.numeric(D_count) < 5) > 1){
        j <- j + 1 
        cat("WHILE iteration: " ,j, "\n")
        if(j == 5){
          break("Number of cases is to small.")
        }
        y <- iss[j]
        # Counts the number of events and person-years.
        xtab <- xtabs(cbind(D = (lex.Xst == "Event"),
                            Y = lex.dur) ~ pmax(plyr::round_any(age,iss[j],f=floor),eaoo),
                      data = sdat)
        D_count <- xtab[,"D"]
        cat("D: ", "\n")
        print(D_count)
      }
      cat("Check point: D greater or equal 5", "\n")
      fdat <- as.data.frame(cbind(xtab))
      data_DY <- cbind(fdat,
                       A = as.numeric(row.names(fdat)),
                       B = i)
      # Saves the counts and person-years for each birth cohorts
      lbc[[i]] <- list("Birth cohort" = paste(diag_cohort[i],
                                              diag_cohort[i+1] - 1,
                                              sep = "-"),
                       "Data" = data_DY)
      DATA_DY <- rbind(DATA_DY,data_DY)
    }
    # Saves all the output into one list
    out <- list(lbc,DATA_DY)
  }
  return(out)
}
