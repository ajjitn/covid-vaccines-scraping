library(googlesheets4)
library(dotenv)
library(jsonlite)
library(tidyverse)





## --- Get secrets from .env -------

# When using GH actions, env vars won't be in .env file 
# and will instead be laoded in as a repository secret.
# So we safely use load_dot_env for local development
load_dot_env_safely = purrr::possibly(load_dot_env, 
                                      otherwise = ".env file was not found and therefore not loaded")


load_dot_env_safely()



google_sheet_id = Sys.getenv("google_sheets_id")
google_service_account_json = Sys.getenv("google_key")  

# Set up service account auth
gs4_deauth()
gs4_auth(path = google_service_account_json)




## --- Read in and select daily data -------
state_df =
  read_csv("data/current/state_vaccinations.csv")

us_df =
  read_csv("data/current/us_vaccinations.csv")



state_df = state_df %>% 
  select(Date, Location, LongName, 
         Doses_Distributed, Dist_Per_100K,
         Doses_Administered, Admin_Per_100K,
         Administered_18Plus, Admin_Per_100k_18Plus,
         Administered_Dose1_Recip, Administered_Dose1_Pop_Pct,
         Administered_Dose1_Recip_18Plus, Administered_Dose1_Recip_18PlusPop_Pct,
         Administered_Dose2_Recip, Administered_Dose2_Pop_Pct,
         Administered_Dose2_Recip_18Plus, Administered_Dose2_Recip_18PlusPop_Pct, 
         Census2019)



us_df = us_df %>% 
  select(Date, Location, LongName, 
         Doses_Distributed,
         Doses_Administered,
         Administered_18Plus, Admin_Per_100k_18Plus,
         Administered_Dose1_Recip, Administered_Dose1_Pop_Pct,
         Administered_Dose1_Recip_18Plus, Administered_Dose1_Recip_18PlusPop_Pct,
         Administered_Dose2_Recip, Administered_Dose2_Pop_Pct,
         Administered_Dose2_Recip_18Plus, Administered_Dose2_Recip_18PlusPop_Pct,
         Census2019)





## --- Daily Data Dictionary ----0-

data_dic = tribble(~column_name, ~cdc_description, ~in_cdc_dashboard,
                   "Date", "Date the data was updated", 0,
                   "Location", "2 Letter State abbreviation. Some locations are departments and can be 3 letter abbvs", 0,
                   "LongName", "Full name of state or department", 1,
                   "Doses_Distributed", "Total Delivered", 1,
                   "Dist_Per_100k", "Total Delivered per 100k", 1,
                   "Doses_Administered", "Total Doses Administered", 1,
                   "Admin_Per_100K", "Total Doees Administered per 100k", 1,
                   "Administered_18Plus", "Total Doses Administered 18+", 1,
                   "Admin_Per_100k_18Plus", "Total Doses Administered 18+ per 100k", 1,
                   "Administered_Dose1_Recip", "People receiving 1 or more doses", 1,
                   "Administered_Dose1_Pop_Pct", "Percent of total population receiving 1 or more doses", 1,
                   "Administered_Dose1_Recip_18Plus", "People 18+ Receiving 1 or more doses", 1,
                   "Administered_Dose1_Recip_18PlusPop_Pct", "Percent of 18+ population receiving 1 or more doses", 1,
                   "Administered_Dose2_Recip", "People receiving 2 doses", 1,
                   "Administered_Dose2_Pop_Pct", "Percent of total population receiving 2 doses", 1,
                   "Administered_Dose2_Recip_18Plus", "People 18+ receiving 2 doses",  1,
                   "Administered_Dose2_Recip_18PlusPop_Pct", "Percent of 18+ population receiving 2 doses", 1,
                   "Census2019", "Census 2019 population", 0)

data_dic_ts = tribble(~"See the section marked `US Vaccination Data` on this page:", "https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations")



## --- Read in and select timeseries data -------
state_df_ts = read_csv("data/timeseries/state_vaccinations.csv")
us_df_ts = read_csv("data/timeseries/us_vaccinations.csv")

# For data dictionary of these data, please see https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations and the section marked `United States vaccination data`




## --- Write to Google Sheets -------
state_df %>% 
  sheet_write(ss = google_sheet_id, sheet = "state")

us_df %>% 
  sheet_write(ss = google_sheet_id, sheet = "us")

data_dic %>% 
  sheet_write(ss = google_sheet_id, sheet = "data_dictionary")


state_df_ts %>% 
  sheet_write(ss = google_sheet_id, sheet = "state_timeseries")

us_df_ts %>% 
  sheet_write(ss = google_sheet_id, sheet = "us_timseries")

data_dic_ts %>% 
  sheet_write(ss = google_sheet_id, sheet = "data_dictionary_timseries")










