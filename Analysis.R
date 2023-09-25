
# This script shows how the analysis is run. The first section shows the code for
# the calculations of the incidence rate with respect to birth cohort, the second 
# section is for the incidence rate with respect to calender period. In each 
# the computation is done for both sexes (F/M). 
# Note this is only an example of the code. The diagnosis of interest is 
# referred as DXX. The EAOO is the 'Earliest Age Of Onset' for the given 
# diagnosis. This is not possible to do for all diagnosis, if there is to few 
# observations for the GAM to fit the data.  
# In compliant with data governance the code secures that there is not less than 
# five individuals for each count. 

# Packages used:
# Epi
# popEpi
# mgcv

# Incidence rate with respect to birth cohort -----------------------------

# Female
RES_DXXF_IR <- IR_birth_cohort(datDXXF, EAOO)

# The predicted values for the fitted model:
Res_IR_DXXF <- RES_DXXF_IR[[3]]
# The number of cases counted and person-years:
Res_DY_DXXF <- RES_DXXF_IR[[4]]
# Make sure we do not plot any point with less than 5 counts.
Res_DY_DXXF <- Res_DY_DXXF[Res_DY_DXXF$D >= 5,]

# Female
RES_DXXM_IR <- IR_birth_cohort(datDXXM, EAOO)

# The predicted values for the fitted model:
Res_IR_DXXM <- RES_DXXM_IR[[3]]
# The number of cases counted and person-years:
Res_DY_DXXM <- RES_DXXM_IR[[4]]
# Make sure we do not plot any point with less than 5 counts.
Res_DY_DXXM <- Res_DY_DXXM[Res_DY_DXXM$D >= 5,]

# Incidence rate with respect to calender period  -------------------------

# Female
IRP_DXXF <- IR_period(datDXXF, EAOO)

# The predicted values for the fitted model:
res_IRP_DXXF <- IRP_DXXF[[3]]
# The number of cases counted and person-years:
res_DYP_DXXF <- IRP_DXXF[[4]]
# Make sure we do not plot any point with less than 5 counts.
res_DYP_DXXF <- res_DYP_DXXF[res_DYP_DXXF$D >= 5,]

# Male
IRP_DXXM <- IR_period(datDXXM, EAOO)

# The predicted values for the fitted model:
res_IRP_DXXM <- IRP_DXXM[[3]]
# The number of cases counted and person-years:
res_DYP_DXXM <- IRP_DXXM[[4]]
# Make sure we do not plot any point with less than 5 counts.
res_DYP_DXXM <- res_DYP_DXXM[res_DYP_DXXM$D >= 5,]
