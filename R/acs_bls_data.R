library(tidyverse)
library(tidycensus)
library(gdata)
library(readxl)

#A Census API key is required.  Obtain one at http://api.census.gov/data/key_signup.html,
#and then supply the key to the `census_api_key` function to use it throughout your tidycensus session.

#enter your key below to use tidycensus
#census_api_key(key = " ", install = TRUE)

#get acs data via tidy census
state_acs_data_breakdowns <- get_estimates(geography = "state", product = "characteristics",
                                           breakdown = c("AGEGROUP", "RACE", "HISP"),
                                           breakdown_labels = TRUE,
                                           year = 2019) 

state_acs_data_medincome <- get_acs(geography = "state",
                                    variables = c(medincome = "B19013_001"),
                                    year = 2019) %>% 
  select(-GEOID, -variable) %>% 
  rename(medincome = estimate,
         medincome_moe = moe)

state_acs_population <- get_estimates(geography = "state", product = "population", year = 2019) %>% 
  filter(variable == "POP") %>% 
  rename(total_population = value) %>% 
  select(NAME, total_population)

state_acs_data <- state_acs_data_breakdowns %>% 
  left_join(state_acs_data_medincome, by = "NAME") %>% 
  left_join(state_acs_population, by = "NAME")


#read in employment data for healthcare and education sector estimates (May 2019)
if(!file.exists("input/oes_research_2019_sec_61.xlsx")){
  download.file("https://www.bls.gov/oes/special.requests/oes_research_2019_sec_61.xlsx",
                "input/oes_research_2019_sec_61.xlsx",
                mode = "wb")
}

if(!file.exists("input/oes_research_2019_sec_62.xlsx")){
  download.file("https://www.bls.gov/oes/special.requests/oes_research_2019_sec_62.xlsx",
                "input/oes_research_2019_sec_62.xlsx",
                mode = "wb")
}


employment_OLS_education_raw <- read_excel("input/oes_research_2019_sec_61.xlsx") 
employment_OLS_healthcare_raw <- read_excel("input/oes_research_2019_sec_62.xlsx") 

employment_OLS_education <- employment_OLS_education_raw %>% 
  filter(o_group == "total") %>% 
  filter(i_group == "sector") %>% 
  mutate(NAME = area_title,
         total_employment_education = as.numeric(tot_emp)) %>% 
  select(NAME, total_employment_education)

employment_OLS_healthcare <- employment_OLS_healthcare_raw %>% 
  filter(o_group == "total") %>% 
  filter(i_group == "sector") %>% 
  mutate(NAME = area_title,
         total_employment_healthcare = as.numeric(tot_emp)) %>% 
  select(NAME, total_employment_healthcare)

#create two data sets for easier manipulation in Tableau

state_age_groups <- state_acs_data_breakdowns %>%
  group_by(AGEGROUP) %>% 
  summarize(n = n())

state_acs_data_1 <- state_acs_data_breakdowns %>% 
  filter(RACE %in% c("All races", 
                     "American Indian and Alaska Native alone",
                     "Asian alone",
                     "Black alone",
                     "Native Hawaiian and Other Pacific Islander alone",
                     "Two or more races",
                     "White alone")) %>% 
  filter(AGEGROUP %in% c("All ages",
                         "18 years and over",
                         "65 years and over"))
  
write_csv(state_acs_data_1, "output/state_acs_data_1.csv")

#new revised state-level output without vaccination data

state_acs_data_2 <- state_acs_data_medincome %>% 
  inner_join(state_acs_population, by = "NAME") %>% 
  inner_join(employment_OLS_education, by = "NAME") %>% 
  inner_join(employment_OLS_healthcare, by = "NAME") %>% 
  mutate(percent_education_employment = total_employment_education/total_population) %>% 
  mutate(percent_healthcare_employment = total_employment_healthcare/total_population) %>% 
  select(NAME, everything())

write_csv(state_acs_data_2, "output/state_acs_data_2.csv")

