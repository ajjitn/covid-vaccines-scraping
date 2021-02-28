library(googlesheets4)
library(dotenv)
library(jsonlite)
library(tidyverse)





## --- Get secrets from .env -------
getwd()
list.files()

load_dot_env()

google_sheet_id = Sys.getenv("google_sheets_id")
google_service_account_json = Sys.getenv("google_key")  

# Set up service account auth
gs4_deauth()
gs4_auth(path = google_service_account_json)




## --- Read in and select data -------
state_df =
  read_csv("data/current/state_vaccinations.csv")

us_df =
  read_csv("data/current/us_vaccinations.csv")



state_df = state_df %>% 
  select(Date, Location, LongName, Doses_Administered,
         Administered_Dose1_Pop_Pct, Administered_Dose2_Pop_Pct,
         Administered_Dose1_Recip_18PlusPop_Pct, Administered_Dose2_Recip_18PlusPop_Pct) 

us_df = us_df %>% 
  select(Date, Location, LongName, Doses_Administered,
         Administered_Dose1_Pop_Pct, Administered_Dose2_Pop_Pct,
         Administered_Dose1_Recip_18PlusPop_Pct, Administered_Dose2_Recip_18PlusPop_Pct)



## --- Write to Google Sheets -------
state_df %>% 
  sheet_write(ss = google_sheet_id, sheet = "state")


us_df %>% 
  sheet_write(ss = google_sheet_id, sheet = "us")

