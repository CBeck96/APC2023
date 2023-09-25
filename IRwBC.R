# Incidence rates with respect to birth cohorts 

# Packages used:
# Epi
# popEpi
# mgcv

# Input:
# dat        : Data used
# eaoo       : Earliest age of onset (1,5,10)
# start_year : Starting year for the first birth cohort. Default is 1924.

# Output:
#   - Returns a list containing:
#       1) A list which has a data frame for each birth cohort:
#           - Each data frame consists of the number of counts and person years:  
#                 - The count of cases at time t (D)
#                 - The sum of person years at time t (Y)
#                 - Time given in ages (A)
#                 - Group of the birth cohort
#       2) The Generalized Additive Model fitted
#       3) A data frame with prediction values
#           - Age
#           - Estimate of age and birth cohort
#           - Lower limit of estimate
#           - Upper limit of estimate
#           - Birth cohort group
#       4) A data frame 
#                 - The count of cases at time t (D)
#                 - The sum of person years at time t (Y)
#                 - Time given in ages (A)
#                 - Group of the birth cohort

IR_birth_cohort <- function(dat, eaoo, start_year = 1924){
  # Checks if the eaoo values are valid values
  if(sum(eaoo == c(1,5,10)) != 1)  stop("eaoo is not equal to either (1,5,10)!")
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
    
    # Counts the number of events and person-years.
    iss <- c(1,2,5,10)
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
        stop("Number of cases is to small.")
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
  # Fits a GAM model
  gam <- gam(cbind(D,Y) ~ s(A,B),
             family = poisreg,
             data = DATA_DY)
  # Prepares the data frame used for predictions 
  df_out <- data.frame("age" = c(),
                       "est" = c(),
                       "lb" = c(),
                       "ub" = c(),
                       "B" = c())
  
  for(i in 1:(length(bth_cohort) - 1)){
    # Chooses the ages used for predictions for each birth cohort
    ndf <- subset(data.frame(A = seq(eaoo,80,0.25), B = i),
                  A + bth_cohort[i+1] > 2004 & A + bth_cohort[i] <= 2021 )
    # Predicts from the GAM 
    pdf <- ci.pred(gam,ndf)
    # Saves the predicted values
    df_out <- rbind(df_out , data.frame("age" = ndf$A,
                                        "est" = as.numeric(pdf[,1]),
                                        "lb" = as.numeric(pdf[,2]),
                                        "ub" = as.numeric(pdf[,3]),
                                        "B" = i))
  }
  # Saves all the output into one list
  out <- list(lbc,gam,df_out,DATA_DY)
  return(out)
}
