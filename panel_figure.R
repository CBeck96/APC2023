
# Packages used:
# ggplot2
# ggnewscale

# Set-up ------------------------------------------------------------------

# In this section the birth cohort intervals are created based on the different 
# earliest age of onset (EAOO). The colors used is also chosen here.  

pbc10 <- c("1924-1939", "1940-1949", "1950-1959", "1960-1969", 
           "1970-1979", "1980-1989", "1990-1999", "2000-2011")
pbc5 <- c("1924-1939", "1940-1949", "1950-1959", "1960-1969",
          "1970-1979", "1980-1989", "1990-1999", "2000-2016")
pbc1 <- c("1924-1939", "1940-1949", "1950-1959", "1960-1969", "1970-1979",
          "1980-1989", "1990-1999", "2000-2009", "2010-2020")

col10 <- c("#002546", "#6B9AC4", "#97D8C4", "#994F00", 
           "#F4B942", "#A67484", "#6E285A", "#DC3220")
col5 <- c("#002546", "#6B9AC4", "#97D8C4", "#994F00",
          "#F4B942", "#A67484", "#6E285A", "#DC3220")
col1 <- c("#002546", "#6B9AC4", "#97D8C4", "#994F00", "#F4B942",
          "#A67484", "#6E285A", "#DC3220", "#000000")

# In this section the period intervals are created based on the different 
# earliest age of onset (EAOO). The colors used is also chosen here.  

period <- c("2004-2006", "2007-2009", "2010-2012",
            "2013-2015", "2016-2018", "2019-2021")

col_period <- c("#002546", "#6B9AC4", "#97D8C4",
                "#994F00", "#F4B942", "#A67484") 

# The colors chosen is chosen with regard of color blindness. 

# Panel figure ------------------------------------------------------------

DXX_IRwBC <- rbind(cbind(Res_IR_DXXF, 
                         "KQN" = "Female", "Effect" = "Birth cohort"),
                   cbind(Res_IR_DXXM, 
                         "KQN" = "Male", "Effect" = "Birth cohort"))

DXX_IRwCP <- rbind(cbind(res_IRP_DXXF, 
                         "KQN" = "Female", "Effect" = "Calender period"),
                   cbind(res_IRP_DXXM, 
                         "KQN" = "Male", "Effect" = "Calender period"))

DXX_DY_BC <- rbind(cbind(Res_DY_DXXF, 
                         "KQN" = "Female", "Effect" = "Birth cohort"),
                   cbind(Res_DY_DXXM, 
                         "KQN" = "Male", "Effect" = "Birth cohort"))

DXX_DY_CP <- rbind(cbind(res_DYP_DXXF, 
                         "KQN" = "Female", "Effect" = "Calender period"),
                   cbind(res_DYP_DXXM, 
                         "KQN" = "Male", "Effect" = "Calender period"))

# Note that in the case where it was not possible to fit the GAM, out-comment the
# code for creating the lines of the incidence rate. Also importantly use the
# function 'count_DY' to get the number of cases and the sum of person-years 
# for the diagnosis of interest. 

ggplot() +
  geom_point(data = DXX_DY_BC,
             aes(x = A,
                 y = D/Y*10000,
                 shape = factor(B)),
             size = 0.8) + 
  geom_line(data = DXX_IRwBC, aes(x = age,
                                  y = est*10000,
                                  col = factor(B))) +
  geom_ribbon(data = DXX_IRwBC, aes(x = age,
                                    ymin = lb,
                                    ymax = ub,
                                    fill = factor(B)),
              alpha = 0.3) +
  scale_shape_manual("Birth cohort",
                     values = c(1:8),
                     label = pbcEAOO) +
  scale_color_manual("Birth cohort",
                     values = c(colEAOO),
                     label = pbcEAOO,
                     aesthetics = c("colour", "fill")) +
  new_scale_color() +
  new_scale_fill() +
  new_scale("shape") +
  geom_point(data = DXX_DY_CP,
             aes(x = A,
                 y = D/Y*10000,
                 shape = factor(B)),
             size = 0.8) + 
  geom_line(data = DXX_IRwCP, aes(x = age,
                                  y = est*10000,
                                  col = factor(B))) +
  geom_ribbon(data = DXX_IRwCP, aes(x = age,
                                    ymin = lb,
                                    ymax = ub,
                                    fill = factor(B)),
              alpha = 0.3) +
  scale_shape_manual("Calender Period",
                     values = c(1:6),
                     label = period) +
  scale_color_manual("Calender Period",
                     values = c(col_period),
                     label = period,
                     aesthetics = c("colour", "fill")) +
  facet_grid(cols = vars(KQN),
             rows = vars(Effect),
             scale = "free_y") +
  labs(x = "Age",
       y = "Incidence rate per 10000 Person-years",
       title = "DXX") +
  scale_x_continuous(limits = c(0,80)) +
  theme(text = element_text(size = 15)) +
  theme_bw()
