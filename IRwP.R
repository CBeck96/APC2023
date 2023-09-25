# Incidence rates with respect to calender period 

# Packages used:
# Epi
# popEpi
# mgcv

# Input:
# dat     : Data used
# eaoo    : Earliest age of onset (1,5,10)
# max_age : Maximum age. Default 80 years.

# Output:
#   - Returns a list containing:
#       1) A list which has a data frame for each calender period:
#           - Each data frame consists of the number of counts and person years:  
#                 - The count of cases at time t (D)
#                 - The sum of person years at time t (Y)
#                 - Time given in ages (A)
#                 - Group of the calender period
#       2) The Generalized Additive Model fitted
#       3) A data frame with prediction values
#           - Age
#           - Estimate of age and calender period
#           - Lower limit of estimate
#           - Upper limit of estimate
#           - Birth cohort group
#       4) A data frame 
#                 - The count of cases at time t (D)
#                 - The sum of person years at time t (Y)
#                 - Time given in ages (A)
#                 - Group of the calender period

IR_period <- function(dat,eaoo,max_age = 80){
  # Checks if the eaoo values are valid values
  if(sum(eaoo == c(1,5,10)) != 1)  stop("eaoo is not equal to either (1,5,10)!")
  
  # Checks if the max age is between 1 and 80
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
    # Picks data of individuals born in the chosen calender period
    dat_b <- dat[round(dat$doinc,2) < diag_cohort[i+1] & 
                   round(dat$doend,2) >=  diag_cohort[i], 
                 c(1,3,4,5,6)]
    dat_b$censor_stat[round(dat_b$doend,2) > diag_cohort[i+1]] <- 0
    # Transforms the data into lexis format
    Ldat <- Lexis(entry = list(age = doinc - dobth, per = doinc),
                  exit = list(per = doend),
                  exit.status = factor(censor_stat, labels = c("Well", "Event",
                                                               "Emigration", "Dead")),
                  data = dat_b)
    
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
        stop("Number of cases is to small.")
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
  
  
  for(i in 1:(length(diag_cohort) - 1)){
    # Chooses the ages used for predictions for each birth cohort
    ndf <- data.frame(A = seq(eaoo,max_age,0.25), B = i)
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
