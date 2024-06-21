library(dplyr)
library(ggplot2)
library(tidyr)

### Data cleaning ###

#**For DAC countries**
  
  #filter for after 2000
  ODA_filter <- read.csv("ODA_filter", stringsAsFactors = FALSE)
  
  
  #Create a vector with only DAC countries
  countries <- c("Australia", "Austria", "Belgium", "Canada", "China (People’s Republic of)", "Denmark", "European Union", "Finland", "France", "Germany", "Greece", "Ireland", "Italy", "Japan", "South Korea", "Luxembourg", "Netherlands", "New Zealand", "Norway", "Portugal", "Spain", "Sweden", "Switzerland", "United Kingdom", "United States")
  
  #Create a df with only DAC countries
  dac <- ODA_filter%>%
    filter(Donor%in% countries)
  
  
  # In order to conduct our regression analysis, we have to make sure that there is no unknown value.  Also, we only keep the sectors that the China dataset provides.
  
  #Transform it into a wide format
  dac_minimalist <- dac%>%
    select("Donor","SECTOR","Sector","TIME_PERIOD","OBS_VALUE")
  
  # List of sector codes to filter
  sector_codes <- c(110, 120, 130, 140, 150, 160,
                    210, 220, 230, 240, 250,
                    310, 320, 330, 331,
                    410, 420, 430,
                    510, 520, 530,
                    600,
                    720, 730, 740,
                    998)
  
  # Filter the dataframe
  dac_minimalistT <- dac_minimalist %>%
    filter(SECTOR %in% sector_codes)

  
   dac_reshaped <- dac_minimalistT %>%
    pivot_wider(names_from = Donor, values_from = OBS_VALUE)
  dac_cleaned <- dac_reshaped %>%
    filter(complete.cases(.))
  
  # Convert the data from wide to long format for plotting
  dac_long <- dac_cleaned %>%
    pivot_longer(cols = -c(Measure, SECTOR, Sector, TIME_PERIOD), 
                 names_to = "Donor", 
                 values_to = "OBS_VALUE")
  
  # Rename the dataframe
  dac_wide_cleaned <- dac_cleaned
  dac_long_cleaned <- dac_long
  
  
  
 # **For China**
    library(readxl)
  China_Aid <- read_excel("China Aid.xlsx")
  View(China_Aid)
  
  #Turn the column `Amount (Constant USD 2021)` to numerics and removing rows with unknown values
  
  China_Aid$`Amount (Constant USD 2021)` <- as.numeric(China_Aid$`Amount (Constant USD 2021)`)
  
  cleaned_data <- China_Aid[!is.na(China_Aid$`Amount (Constant USD 2021)`),]
  
  
  #Filter out unnecessary columns for this analysis and keep the columns `Description` and `Staff Comments`.  
  #Group by `Sector Name`, `Sector Code`, then summarize the total donations
  
  
  China_sector_cleaned <- cleaned_data %>%
    select(`AidData Record ID`, Recipient, `Recipient ISO-3`, `Recipient Region`, `Commitment Year`, `Implementation Start Year`, `Flow Type Simplified`, `Flow Class`, `Sector Code`, `Sector Name`, `Amount (Constant USD 2021)`, Description,`Staff Comments`,Intent) %>%
    group_by(`Sector Code`,`Commitment Year`,`Sector Name`) %>%
    summarize(total_amount = sum(`Amount (Constant USD 2021)`))
  
  
  
  ### Visualisation ###
  
  library(ggplot2)
  
  
 #** Visulalising top 5 receiving sectors of China’s donations**
    
    top_5_sectors <- c(
      "OTHER MULTISECTOR",
      "INDUSTRY, MINING, CONSTRUCTION",
      "ENERGY",
      "TRANSPORT AND STORAGE",
      "BANKING AND FINANCIAL SERVICES")
  
  # Filter the original data to include only the top 5 receiving sectors
  China_sector_top_5 <- China_sector_cleaned %>%
    filter(`Sector Name` %in% top_5_sectors)
  
  # Plotting
  ggplot(China_sector_top_5, aes(x = `Commitment Year`, y = total_amount, color = `Sector Name`, group = `Sector Name`)) +
    geom_line() +
    labs(title = "Total Amount by Top 5 Receiving Sectors Over the Years",
         x = "Commitment Year",
         y = "Total Amount (Constant USD 2021)",
         color = "Sector Name") +
    theme_minimal()
  
  
#  **Understanding whats behind "Other Multisector "**

China_other_multisector <- China_cleaned_necessary%>%
  filter(`Sector Code`== "430")

China_430_2017 <- China_other_multisector%>%
    filter(`Commitment Year`=="2017")
China_430_2017$Description.x

Af_430_2017 <- China_430_2017%>%
 filter(`Recipient Region`=="Africa")

Af_430_2017$Description.x




### Getting data ready for regression analysis ### 

#**Merging DAC ODA df and China ODA df 

#Rename China_cleaned_necessary to match the colnames

China_minimalist <- China_cleaned_necessary%>%
  select(Measure = `Flow Type Simplified`,
         SECTOR = `Sector Code`,
         Sector = `Sector Name`,
         TIME_PERIOD = `Commitment Year`,
         OBS_VALUE = `Amount (Constant USD 2021)`
         )%>%
  mutate(Donor = "China PRC")

# Combine the data frames
combined_df <- bind_rows(dac_long_cleaned, China_minimalist)


#**GDP**
GDP <- read.csv("GDP.csv")
China_GDP <- GDP %>%
  filter(REF_AREA == "CHN")

#Merge the data
China_GDP_ODA <- left_join(China_sector_cleaned, China_GDP, by = c("Commitment Year" = "TIME_PERIOD"))
                      

China_GDP_ODA <- China_GDP_ODA %>%
  rename(GDP = OBS_VALUE)

colnames(China_GDP_ODA)

#**Combining GDP and ODA df**
countries <- c("Australia", "Austria", "Belgium", "Canada", "China (People’s Republic of)", "Denmark", "European Union", "Finland", "France", "Germany", "Greece", "Ireland", "Italy", "Japan", "South Korea", "Luxembourg", "Netherlands", "New Zealand", "Norway", "Portugal", "Spain", "Sweden", "Switzerland", "United Kingdom", "United States")

GDP_cleaned <- GDP%>%
  filter(Reference.area %in% countries,
         UNIT_MEASURE == "USD_EXC")%>%
  select(Donor = Reference.area,
         TIME_PERIOD,
         GDP = OBS_VALUE
         )
GDP_cleaned$Donor <- replace(GDP_cleaned$Donor, GDP_cleaned$Donor == "China (People’s Republic of)", "China PRC")


merged_df <- combined_df %>%
  left_join(GDP_cleaned, by = c("Donor", "TIME_PERIOD"))

library(openxlsx)

# We save an excel of every stage of the df merging, starting from “Our baby blingbling” which does not contain the control variables yet.

write.xlsx(merged_df, "OUR_BABY_blingbling.xlsx")

#One df per group

China_combined_df <- merged_df%>%
  filter(Donor == "China PRC")

#Challenge w/ dac, one obs for the total donations per sector, per year 
dac_countries <- c("Australia", "Austria", "Belgium", "Canada", "Denmark", "European Union", "Finland", "France", "Germany", "Greece", "Ireland", "Italy", "Japan", "South Korea", "Luxembourg", "Netherlands", "New Zealand", "Norway", "Portugal", "Spain", "Sweden", "Switzerland", "United Kingdom", "United States")
DAC_combined_df <- merged_df%>%
  filter(Donor %in% countries)

DAC_COMBINED_df <- DAC_combined_df%>%
  group_by(TIME_PERIOD, SECTOR, Sector) %>%
  summarize(total_value = sum(OBS_VALUE, na.rm = TRUE))%>%
  ungroup()

#total gdp of DAC
DAC_gdp <- GDP_cleaned%>%
  group_by(TIME_PERIOD)%>%
  summarise(gdp = sum(GDP))

#Merge
DAC_COMBINED_DF <- DAC_COMBINED_df %>%
  left_join(DAC_gdp, by = c("TIME_PERIOD"))

write.xlsx(DAC_COMBINED_DF, "DAC_sector_year.xlsx")

ggplot(DAC_gdp, aes(x=TIME_PERIOD, y=gdp))+
         geom_line()

#**Control variables**

#**Employment**

#For some reason, I could only download the file in French…

countries_fr <-  c("Allemagne", "Autriche", "Australie", "Belgique", "Canada", "Corée", "Danemark", "Espagne", "États-Unis", "Finlande", "France", "Grèce", "Irlande", "Italie", "Japon", "Luxembourg", "Norvège", "Nouvelle-Zélande", "Pays-Bas", "Portugal", "Royaume-Uni", "Suède", "Suisse", "Union européenne")

OECD_employment_cleaned <- OECD_employment%>%
  select(STRUCTURE_NAME,
         `Zone de référence`,
         ` ge`,
         TIME_PERIOD,
         OBS_VALUE)%>%
  filter(`Zone de référence` %in% countries_fr)

average_employment <- OECD_employment_cleaned %>%
  group_by(TIME_PERIOD) %>%
  summarize(avg_employment_rate = mean(OBS_VALUE, na.rm = TRUE))

# Create the plot
ggplot(average_employment, aes(x = TIME_PERIOD, y = avg_employment_rate)) +
  geom_line() +
  labs(title = "Average Employment Rate Over Time",
       x = "Time Period",
       y = "Average Employment Rate") +
  theme_minimal()

write.xlsx(average_employment, "average_employment_dac.xlsx")

# Our baby blingbling upgrading to our toddler blingbling with now the average employment rate control variable
DAC_COMBINED_DFF <- DAC_COMBINED_DF%>%
  left_join(average_employment,DAC_COMBINED_DF, by = c("TIME_PERIOD"))
write.xlsx(DAC_COMBINED_DFF, "our_toddler_blingbling.xlsx")
            

#**HDI**
average_HDI <- HDI_dac %>%
  group_by(Year) %>%
  summarize(avg_HDI = mean(`Human Development Index`, na.rm = TRUE))

# From our toddler blingbling to our teen blingbling 
DAC_COMBINED_DFFF <- DAC_COMBINED_DFF%>%
  left_join(average_HDI,DAC_COMBINED_DFF, by = c("TIME_PERIOD" = "Year"))
write.xlsx(DAC_COMBINED_DFFF, "our_teen_blingbling.xlsx")

#**Public debt**
colnames(imf_dm_export_20240601)

# Reshape the dataframe
Pb_debt <- imf_dm_export_20240601 %>%
  pivot_longer(
    cols = -`Central Government Debt (Percent of GDP)`, # Columns to pivot (all years)
    names_to = "TIME_PERIOD", # Name of the new "time period" column
    values_to = "OBS_VALUE"   # Name of the new "value" column
  )

Pb_debt_cleaned <- Pb_debt%>%
  filter(`Central Government Debt (Percent of GDP)` %in% countries)

average_pb_debt <- Pb_debt_cleaned %>%
  filter(!is.na(OBS_VALUE)) %>%
  group_by(TIME_PERIOD) %>%
  summarize(Pb_debt_per_gdp = mean(OBS_VALUE, na.rm = TRUE))

#From our teen blingbling to our young adult blingbling

average_pb_debt <- average_pb_debt%>%
mutate(TIME_PERIOD = as.numeric(as.character(TIME_PERIOD)))

DAC_COMBINED_DFFFF <- DAC_COMBINED_DFFF%>%
  left_join(average_pb_debt,DAC_COMBINED_DFFF, by = c("TIME_PERIOD"))
write.xlsx(DAC_COMBINED_DFFFF, "our_youngadult_blingbling.xlsx")



#**Unemployment rate in China**
library(readxl)
library(openxlsx)

china_unemployment_rate$date <- format(china_unemployment_rate$date, "%Y")

china_unemployment_rate <- china_unemployment_rate%>%
  select(date,`Unemployment Rate (%)`)
write.xlsx(china_unemployment_rate,"china_unemployment_rate.xlsx")

#**gdp growth rate**
# Reshape the dataframe
GDP_growth_cleaned <- GDP_growth_rate_%>%
  select(`Country Name`,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68)


# Based on the column names, use the correct column name in the pivot_longer() function
GDP_growth_rate_reshaped <- GDP_growth_cleaned %>%
  pivot_longer(
    cols = -`Country Name`,   # Exclude the 'Country Name' column
    names_to = "year",      # Name of the new column for years
    values_to = "growth_rate" # Name of the new column for GDP growth rates
  )

GDP_growth_reshaped_cleaned <- GDP_growth_rate_reshaped%>%
  filter(`Country Name`%in% countries)

average_GDP_growth <- GDP_growth_reshaped_cleaned %>%
  group_by(TIME_PERIOD = year) %>%
  summarize(avg_gdp_growth = mean(growth_rate, na.rm = TRUE))

average_GDP_growth$`TIME_PERIOD` <- as.numeric(average_GDP_growth$`TIME_PERIOD`)


DAC_COMBINED_DFFFFF <- DAC_COMBINED_DFFFF %>%
  left_join(average_GDP_growth, DAC_COMBINED_DFFFF, by = c("TIME_PERIOD"))
write.xlsx(DAC_COMBINED_DFFFFF, "Grown_ass.xlsx")

##General plot
ggplot(DAC_COMBINED_DFFFFF,aes(x = TIME_PERIOD, y = avg_gdp_growth)) + geom_line()


##DAC COUNTRIES

#1.- Finding the priority sectors over 2000-2022

ODA_filter_allDAC_detailSectors<- ODA_filter%>%
  filter(DONOR=="DAC")%>%
  filter(SECTOR %% 10 == 0 & SECTOR %% 100 != 0 & SECTOR!=450)

ODA_filter_allDAC_detailSectors$TIME_PERIOD <- as.factor(ODA_filter_allDAC_detailSectors$TIME_PERIOD)

# Aggregate data by TIME_PERIOD and Sector to get sum OBS_VALUE
agg_data <- ODA_filter_allDAC_detailSectors %>%
  group_by(TIME_PERIOD, Sector) %>%
  summarise(sum_OBS_VALUE = sum(OBS_VALUE))

# Line plot showing evolution of sum OBS_VALUE for each sector over time
line_plot2 <- ggplot(agg_data, aes(x = TIME_PERIOD, y = sum_OBS_VALUE, color = Sector, group = Sector)) +
  geom_line() +
  geom_point() +
  ggtitle("Evolution of Sum OBS_VALUE by Sector") +
  xlab("Time Period") +
  ylab("Sum OBS_VALUE") +
  theme_minimal()+
  scale_color_viridis_d()  # Color scale

# Print the line plot
print(line_plot2)

#Now we get the **TOP 5 Sectors**

# Calculate total OBS_VALUE for each sector
total_by_sector <- ODA_filter_allDAC_detailSectors %>%
  group_by(SECTOR, Sector) %>%  
  summarise(total_OBS_VALUE = sum(OBS_VALUE), .groups = 'drop') %>%
  arrange(desc(total_OBS_VALUE))

top_5_sectors <- total_by_sector %>%
  top_n(5, wt = total_OBS_VALUE) %>%
  pull(SECTOR)

# Filter the data to keep only the top 5 sectors
filtered_data_top_5 <- ODA_filter_allDAC_detailSectors %>%
  filter(SECTOR %in% top_5_sectors)

# Aggregate data by TIME_PERIOD and Sector to get sum OBS_VALUE for top 5 sectors
agg_data_top_5 <- filtered_data_top_5 %>%
  group_by(TIME_PERIOD, SECTOR, Sector) %>%
  summarise(sum_OBS_VALUE = sum(OBS_VALUE), .groups = 'drop')

# Line plot showing evolution of sum OBS_VALUE for top 5 sectors over time
line_plot_top_5 <- ggplot(agg_data_top_5, aes(x = TIME_PERIOD, y = sum_OBS_VALUE, color = Sector, group = SECTOR)) +
  geom_line() +
  geom_point() +
  ggtitle("Evolution of Sum OBS_VALUE by Top 5 Sectors") +
  xlab("Time Period") +
  ylab("Sum OBS_VALUE") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 12, hjust = 0.5, face = "bold"),
    legend.position = "bottom"
  )

# Print the line plot for top 5 sectors
print(line_plot_top_5)



###########REGRESSION ANALYSIS##########
#Do a regression and INCLUDE CONTORL VAIRBALES

dac_countries <- c("Australia", "Austria", "Belgium", "Canada", "Denmark", "European Union", "Finland", "France", "Germany", "Greece", "Ireland", "Italy", "Japan", "South Korea", "Luxembourg", "Netherlands", "New Zealand", "Norway", "Portugal", "Spain", "Sweden", "Switzerland", "United Kingdom", "United States")

HDI_dac <- human_development_index_1_%>%
  filter(Year>=2004 & Year <= 2019)%>%
  filter(Entity %in% dac_countries)

if (!requireNamespace("openxlsx", quietly = TRUE)) {
  install.packages("openxlsx")
}
library(openxlsx)


write.xlsx(HDI_dac, "HDI_dac.xlsx")

#REGRESSION ANALYSIS
library(stats)

#First we filter from 2004-2019 because its the dates that have the less data missing
Grown_ass<-Grown_ass%>%
  filter(TIME_PERIOD>=2004 & TIME_PERIOD <= 2019)

#We have to delete some sectors that have too many data missing
sectors <- unique(Grown_ass$Sector)
deleted_sectors <-c(10,15,16)
sectors <- sectors[-deleted_sectors]

#Lets test our regression with 1 sector
EDUCATION_data <- Grown_ass %>% filter(Sector == "Education")

# Perform linear regression with control variables
lm_model_sector_controlled <- lm(total_value ~ avg_gdp_growth + avg_employment_rate + avg_HDI + Pb_debt_per_gdp, data = EDUCATION_data)
summary_model_controlled <- summary(lm_model_sector_controlled)
print(summary_model_controlled)

# Plot the regression line
plot <- ggplot(EDUCATION_data, aes(x = avg_gdp_growth, y = total_value)) +
  geom_point() +           # Scatter plot of data points
  geom_smooth(method = "lm", se = FALSE) +  # Regression line
  labs(title = "Regression for Sector: YourSectorName",
       x = "Average GDP Growth", y = "Total Value")  # Axis labels and plot title

print(plot)
# Save the plot as a PNG file
ggsave("Education_RegressionGROWTH.png", plot)


#Now that we did the regression on 1 sector, we can loop it in order to see all the sectors


# Initialize the regression results data frame
regression_results_controlled <- data.frame(
  Sector = character(), 
  Coefficient_GDP = numeric(), 
  Coefficient_Employment = numeric(),
  Coefficient_HDI = numeric(),
  Coefficient_Debt = numeric(),
  TStatistic_GDP = numeric(), 
  TStatistic_Employment = numeric(),
  TStatistic_HDI = numeric(),
  TStatistic_Debt = numeric(),
  PValue_GDP = numeric(), 
  PValue_Employment = numeric(),
  PValue_HDI = numeric(),
  PValue_Debt = numeric(),
  Significance_GDP = character(),
  Significance_Employment = character(),
  Significance_HDI = character(),
  Significance_Debt = character(),
  stringsAsFactors = FALSE
)

# Loop through each sector
for (sector in sectors_noPROBLEMATIC ) {
  # Filter data for the current sector
  sector_data <- Grown_ass %>% filter(Sector == sector)
  
  # Perform linear regression with control variables
  lm_model_sector_controlled <- lm(total_value ~ avg_gdp_growth + avg_employment_rate + avg_HDI + Pb_debt_per_gdp, data = sector_data)
  summary_model_controlled <- summary(lm_model_sector_controlled)
  
  # Extract coefficients, t-statistics, and p-values for avg_gdp_growth and control variables
  coefficients <- summary_model_controlled$coefficients
  
  # Perform linear regression with control variables
  growth_coeff <- coefficients["avg_gdp_growth", "Estimate"]
  growth_tstat <- coefficients["avg_gdp_growth", "t value"]
  growth_pval <- coefficients["avg_gdp_growth", "Pr(>|t|)"]
  
  # Extract coefficient, t-statistic, and p-value for Employment Rate
  employment_coeff <- coefficients["avg_employment_rate", "Estimate"]
  employment_tstat <- coefficients["avg_employment_rate", "t value"]
  employment_pval <- coefficients["avg_employment_rate", "Pr(>|t|)"]
  
  # Extract coefficient, t-statistic, and p-value for HDI
  hdi_coeff <- coefficients["avg_HDI", "Estimate"]
  hdi_tstat <- coefficients["avg_HDI", "t value"]
  hdi_pval <- coefficients["avg_HDI", "Pr(>|t|)"]
  
  # Extract coefficient, t-statistic, and p-value for Debt
  debt_coeff <- coefficients["Pb_debt_per_gdp", "Estimate"]
  debt_tstat <- coefficients["Pb_debt_per_gdp", "t value"]
  debt_pval <- coefficients["Pb_debt_per_gdp", "Pr(>|t|)"]
  
  # Determine significance level for GDP Growth
  if (growth_pval < 0.001) {
    significance_growth <- "***"
  } else if (growth_pval < 0.01) {
    significance_growth <- "**"
  } else if (growth_pval < 0.05) {
    significance_growth <- "*"
  } else if (growth_pval < 0.1) {
    significance_growth <- "."
  } else {
    significance_growth <- ""
  }
  
  # Determine significance level for Employment Rate
  if (employment_pval < 0.001) {
    significance_employment <- "***"
  } else if (employment_pval < 0.01) {
    significance_employment <- "**"
  } else if (employment_pval < 0.05) {
    significance_employment <- "*"
  } else if (employment_pval < 0.1) {
    significance_employment <- "."
  } else {
    significance_employment <- ""
  }
  
  # Determine significance level for HDI
  if (hdi_pval < 0.001) {
    significance_hdi <- "***"
  } else if (hdi_pval < 0.01) {
    significance_hdi <- "**"
  } else if (hdi_pval < 0.05) {
    significance_hdi <- "*"
  } else if (hdi_pval < 0.1) {
    significance_hdi <- "."
  } else {
    significance_hdi <- ""
  }
  
  # Determine significance level for Debt
  if (debt_pval < 0.001) {
    significance_debt <- "***"
  } else if (debt_pval < 0.01) {
    significance_debt <- "**"
  } else if (debt_pval < 0.05) {
    significance_debt <- "*"
  } else if (debt_pval < 0.1) {
    significance_debt <- "."
  } else {
    significance_debt <- ""
  }
  
  # Add regression results to the data frame
  regression_results_controlled <- rbind(
    regression_results_controlled,
    data.frame(
      Sector = sector, 
      Coefficient_Growth = growth_coeff, 
      Coefficient_Employment = employment_coeff,
      Coefficient_HDI = hdi_coeff,
      Coefficient_Debt = debt_coeff,
      TStatistic_Growth = growth_tstat, 
      TStatistic_Employment = employment_tstat,
      TStatistic_HDI = hdi_tstat,
      TStatistic_Debt = debt_tstat,
      PValue_Growth = growth_pval, 
      PValue_Employment = employment_pval,
      PValue_HDI = hdi_pval,
      PValue_Debt = debt_pval,
      Significance_Growth = significance_growth,
      Significance_Employment = significance_employment,
      Significance_HDI = significance_hdi,
      Significance_Debt = significance_debt
    )
  )
  
  # Print the summary of the linear model
  print(summary_model_controlled)
  
  # Plot the regression line
  plot <- ggplot(sector_data, aes(x = avg_gdp_growth, y = total_value)) +
    geom_point() +           # Scatter plot of data points
    geom_smooth(method = "lm", se = FALSE) +  # Regression line
    labs(title = paste("Regression for Sector:", sector),
         x = "Average GDP Growth", y = "Total Value")  # Axis labels and plot title
  
  # Save the plot as a PNG file
  ggsave(paste("Regression_Plot_", sector, ".png", sep = ""), plot)
  
  
}


sectors
#ONLY 1 REGRESSION
INDUSTRY_data <- Grown_ass %>% filter(Sector == "Industry, mining, construction")
# Perform linear regression with control variables
lm_model_sector_controlled <- lm(total_value ~ avg_gdp_growth + avg_employment_rate + avg_HDI + Pb_debt_per_gdp, data = INDUSTRY_data)
summary_model_controlled <- summary(lm_model_sector_controlled)
print(summary_model_controlled)
# Plot the regression line
plot <- ggplot(INDUSTRY_data, aes(x = avg_gdp_growth, y = total_value)) +
  geom_point() +           # Scatter plot of data points
  geom_smooth(method = "lm", se = FALSE) +  # Regression line
  labs(title = "Regression for Sector: Industry",
       x = "Average GDP Growth", y = "Total Value")  # Axis labels and plot title
print(plot)
# Save the plot as a PNG file
ggsave("Education_RegressionGROWTH.png", plot)

#NAAAN

#[18] "Energy"  
Energy_data <- Grown_ass %>% filter(Sector == "Energy")
# Perform linear regression with control variables
lm_model_sector_controlled <- lm(total_value ~ avg_gdp_growth + avg_employment_rate + avg_HDI + Pb_debt_per_gdp, data = Energy_data)
summary_model_controlled <- summary(lm_model_sector_controlled)
print(summary_model_controlled)
# Plot the regression line
plot <- ggplot(Energy_data, aes(x = avg_gdp_growth, y = total_value)) +
  geom_point() +           # Scatter plot of data points
  geom_smooth(method = "lm", se = FALSE) +  # Regression line
  labs(title = "Regression for Sector: Energy",
       x = "Average GDP Growth", y = "Total Value")  # Axis labels and plot title
print(plot)

regression_results_controlled_simple <- regression_results_controlled %>%
  select(Sector,Coefficient_Growth,TStatistic_Growth,PValue_Growth,Significance_Growth)

###Results visualisation###

#Top DAC sectors that are explained
BABY_TOP5 <- DAC_COMBINED_DFFFF %>%
  filter(Sector %in% c("Government and civil society", "Education", "Other social infrastructure and services"),
         TIME_PERIOD >= 2004 & TIME_PERIOD <= 2019)

ggplot(BABY_TOP5, aes(x = TIME_PERIOD, y = total_value, color = `Sector`)) + geom_line() 

#We want to visualise the evolution of gdp and donations, we need to rescale and use two different Y axis

# Check the ranges
range_total_value <- range(BABY_TOP5$total_value, na.rm = TRUE)
range_GDP <- range(BABY_TOP5$gdp, na.rm = TRUE)

# Create a transformation factor
trans_factor <- (range_total_value[2] - range_total_value[1]) / (range_GDP[2] - range_GDP[1])

# Plot with two y-axes
ggplot(BABY_TOP5, aes(x = TIME_PERIOD)) + 
  geom_line(aes(y = total_value, color = Sector)) + 
  geom_line(aes(y = gdp * trans_factor), color = "black", linetype = "dashed") +
  scale_y_continuous(
    name = "Total Value",
    sec.axis = sec_axis(~ . / trans_factor, name = "GDP")
  ) +
  labs(title = "Total Value and GDP Over Time", color = "Sector") +
  theme_minimal()


#China TOP 1 sector 
CN_transportation <- Chinese_general%>%
  filter(Sector == "TRANSPORT AND STORAGE")

range_china_transport <- range(CN_transportation$Amount, na.rm = TRUE)
range_china_GDP <- range(CN_transportation$GDP, na.rm = TRUE)

# Create a transformation factor
trans_factor <- (range_china_transport[2] - range_china_transport[1]) / (range_china_GDP[2] - range_china_GDP[1])

# Plot with two y-axes
ggplot(CN_transportation, aes(x = TIME_PERIOD)) + 
  geom_line(aes(y = Amount)) + 
  geom_line(aes(y = GDP * trans_factor), color = "black", linetype = "dashed") +
  scale_y_continuous(
    name = "ODA in Transport and Storage",
    sec.axis = sec_axis(~ . / trans_factor, name = "GDP")
  ) +
  labs(title = "ODA and GDP Over Time") +
  theme_minimal()

library(ggplot2)

# Assuming you have already defined trans_factor

ggplot(CN_transportation, aes(x = TIME_PERIOD)) + 
  geom_line(aes(y = Amount, color = "ODA in Transport and Storage")) + 
  geom_line(aes(y = GDP * trans_factor), color = "black", linetype = "dashed") +
  scale_color_manual(name = "Data", values = c("ODA in Transport and Storage" = "blue", "GDP" = "black")) +
  scale_y_continuous(
    name = "ODA in Transport and Storage",
    sec.axis = sec_axis(~ . / trans_factor, name = "GDP",
                        breaks = scales::pretty_breaks(), labels = scales::number_format())
  )+
  labs(title = "China ODA in Transport and Storage") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5, face = "bold", 
                              color = rainbow(7)[5]), # Rainbow gradient title color
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12),
    plot.background = element_rect(fill = "lightgray"),
    legend.position = "bottom"
  )

###Let's do the same for dac countries 
##Grown ass --> mature

DAC_mature <- DAC_COMBINED_DFFFFF %>%
  filter(Sector %in% c("Education", "Other social infrastructure and services")) %>%
  filter(TIME_PERIOD >= 2004 & TIME_PERIOD <= 2019)

range_DAC_top <- range(DAC_mature$total_value, na.rm = TRUE)
range_gdp_rate <- range(DAC_mature$avg_gdp_growth, na.rm = TRUE)

# Create a transformation factor
trans_factor <- (range_DAC_top[2] - range_DAC_top[1]) / (range_gdp_rate[2] - range_gdp_rate[1])


ggplot(DAC_mature, aes(x = TIME_PERIOD)) + 
  geom_line(aes(y = total_value, color = Sector)) + 
  geom_line(aes(y = avg_gdp_growth * trans_factor), color = "black", linetype = "dashed") +
  scale_color_manual(name = "Data", values = c("Education" = "blue", "GDP" = "black","Other social infrastructure and services" = "orange")) +
  scale_y_continuous(
    name = "ODA",
    sec.axis = sec_axis(~ . / trans_factor, name = "DAC GDP growth rate",
                        breaks = scales::pretty_breaks(), labels = scales::number_format())
  )+
  labs(title = "DAC ODA and GDP growth") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5, face = "bold", 
                              color = rainbow(7)[5]), # Rainbow gradient title color
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12),
    plot.background = element_rect(fill = "lightgray"),
    legend.position = "bottom"
  )




####China's code####
China_Aid<- read_xlsx("China Aid.xlsx")
China_GDP<-read_xls("China GDP.xls") 

BRI<-read_xlsx("BRI countries.xlsx")
# Remove rows with N/A values only in the "Amount (Constant USD 2021)" column
cleaned_data <- China_Aid[!is.na(China_Aid$`Amount (Constant USD 2021)`),]

# Now you can proceed with your desired operations on the cleaned data
China_sector <- cleaned_data |>
  group_by(`Sector Name`) |>
  summarize(total_amount = sum(`Amount (Constant USD 2021)`))

# filter to keep only the useful columns
China_cleaned_necessary <- cleaned_data |>
  select(`AidData Record ID`, Recipient, `Recipient ISO-3`, `Recipient Region`, `Commitment Year`, `Implementation Start Year`, `Flow Type Simplified`, `Flow Class`, `Sector Code`, `Sector Name`, COVID, `Amount (Constant USD 2021)`)

just_checking <- China_cleaned_necessary|>
  filter(`Financier Country` == "China (People's Republic of)")

China_cleaned_necessary <- China_cleaned_necessary |>
  filter(`Flow Class` == "ODA-like")
China_PRC<-China_cleaned_necessary |> select(`Commitment Year`,`Sector Code`,`Sector Name`,`Amount (Constant USD 2021)`) |>group_by(`Commitment Year`)
China_PRC<- left_join(China_PRC,China_GDP,by=c("Commitment Year"="Year"))
China_view<- China_PRC |> group_by(`Commitment Year`,`Sector Name`) |>
  summarise(Amount=sum(New_ODA),GDP=mean(New_GDP),Ratio=sum(ratio))
HDI<-read.csv("HDI.csv")
China_HDI<- HDI |> filter(Entity=="China",Year>=2000)
China_view<- left_join(China_view,China_HDI,by=c("TIME_PERIOD"="Year"))
China_view<-China_view |> select(-6)
China_view<-China_view|>rename(HDI=Human.Development.Index.y)
CUE<-read_xlsx("china_unemployment_rate.xlsx")
CUE<-CUE |> filter(date>=2000)
CUE$date<-as.numeric(CUE$date)
China_view <- left_join(China_view,CUE,by=c("TIME_PERIOD"="date"))
China_debt<-read_xls("China Debt.xls")
China_view<-left_join(China_view,China_debt,by=c("TIME_PERIOD"="Year"))
ggplot(China_view,aes(TIME_PERIOD, Amount, color = Sector)) + 
  geom_line() + 
  geom_point() + 
  gghighlight(Sector %in% c("TRANSPORT AND STORAGE", "Other Multisector","TRADE POLICIES AND REGULATIONS")) + 
  theme_minimal() + 
  scale_y_continuous(labels=scales::parse_format()) + 
  scale_x_continuous(breaks = NULL) + 
  theme(panel.background = element_rect(fill = "white",
                                        colour = "white",
                                        size = 0.5, linetype = "solid"))
china_trans<-China_view|> filter(Sector=="TRANSPORT AND STORAGE")
china_other<-China_view|> filter(Sector=="OTHER MULTISECTOR")

ggscatter(china_other, x = "Amount", y = "GDP", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Multisector", ylab = "GDP(Millions)")+ggtitle("Coefficient between Mutlisector and GDP")

ggscatter(china_trans, x = "GDP", y = "Amount", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "GDP(Millions)", ylab = "Transportation")+ggtitle("Coefficient between Trans ODA and GDP")

model<-lm(Amount~Sector+HDI,data = China_view)
model_1<-summary(model)
coefficients<-model_1$coefficients
results_reg<-as.data.frame(coefficients)
png("sectors_result.png",width=1000,height=1000)
grid.table(coefficients)
dev.off()

