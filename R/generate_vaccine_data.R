library(tidyverse)
library(googlesheets4)
library(jsonlite)
library(dotenv)


## --- Read in vaccination data from CDC -------

# Got this url from inspecting network tab on the CDC vaccine tracker page
vaccination_data_url = "https://covid.cdc.gov/covid-data-tracker/COVIDData/getAjaxData?id=vaccination_data"


d = jsonlite::read_json(vaccination_data_url)['vaccination_data'][[1]]


# item 64 = US national avg and item 65 = Long Term Care, which are formatted differently
df = d %>% 
  head(63) %>% 
  map_df(~tibble(
    Date = .x %>% pluck("Date") %>% as.Date(),
    Location = .x %>% pluck("Location"),
    LongName = .x %>% pluck("LongName"),
    ShortName = .x %>% pluck("ShortName"),                            
    Census2019 = .x %>% pluck("Census2019"),                            
    Doses_Distributed = .x %>% pluck("Doses_Distributed"),                     
    Doses_Administered = .x %>% pluck("Doses_Administered"),                    
    Dist_Per_100K = .x %>% pluck("Dist_Per_100K"),                         
    Admin_Per_100K = .x %>% pluck("Admin_Per_100K"),                        
    Administered_Dose1 = .x %>% pluck("Administered_Dose1"),                    
    Administered_Dose1_Per_100K = .x %>% pluck("Administered_Dose1_Per_100K"),           
    Administered_Dose2 = .x %>% pluck("Administered_Dose2"),                    
    Administered_Dose2_Per_100K = .x %>% pluck("Administered_Dose2_Per_100K"),           
    Administered_Dose1_Pop_Pct = .x %>% pluck("Administered_Dose1_Pop_Pct"),            
    Administered_Dose2_Pop_Pct = .x %>% pluck("Administered_Dose2_Pop_Pct"),            
    date_type = .x %>% pluck("date_type"),                             
    Recip_Administered = .x %>% pluck("Recip_Administered"),                    
    Administered_Dose1_Recip = .x %>% pluck("Administered_Dose1_Recip"),              
    Administered_Dose2_Recip = .x %>% pluck("Administered_Dose2_Recip"),              
    Administered_Dose1_Recip_18Plus = .x %>% pluck("Administered_Dose1_Recip_18Plus"),       
    Administered_Dose2_Recip_18Plus = .x %>% pluck("Administered_Dose2_Recip_18Plus"),       
    Administered_Dose1_Recip_18PlusPop_Pct = .x %>% pluck("Administered_Dose1_Recip_18PlusPop_Pct"),
    Administered_Dose2_Recip_18PlusPop_Pct = .x %>% pluck("Administered_Dose2_Recip_18PlusPop_Pct"),
    Census2019_18PlusPop = .x %>% pluck("Census2019_18PlusPop"),                  
    Distributed_Per_100k_18Plus = .x %>% pluck("Distributed_Per_100k_18Plus"),           
    Administered_18Plus = .x %>% pluck("Administered_18Plus"),                   
    Admin_Per_100k_18Plus = .x %>% pluck("Admin_Per_100k_18Plus"), 
  ))




us_df = d[64]  %>% 
  map_df(~tibble(
    Date = .x %>% pluck("Date") %>% as.Date(),
    Location = .x %>% pluck("Location"),
    LongName = .x %>% pluck("LongName"),
    ShortName = .x %>% pluck("ShortName"),                            
    Census2019 = .x %>% pluck("Census2019"),                            
    Doses_Distributed = .x %>% pluck("Doses_Distributed"),                     
    Doses_Administered = .x %>% pluck("Doses_Administered"),                    
    Administered_Dose1 = .x %>% pluck("Administered_Dose1"),                    
    Administered_Dose2 = .x %>% pluck("Administered_Dose2"),                    
    Administered_Dose1_Pop_Pct = .x %>% pluck("Administered_Dose1_Pop_Pct"),            
    Administered_Dose2_Pop_Pct = .x %>% pluck("Administered_Dose2_Pop_Pct"),            
    date_type = .x %>% pluck("date_type"),                             
    Recip_Administered = .x %>% pluck("Recip_Administered"),                    
    Administered_Dose1_Recip = .x %>% pluck("Administered_Dose1_Recip"),              
    Administered_Dose2_Recip = .x %>% pluck("Administered_Dose2_Recip"),              
    Administered_Dose1_Recip_18Plus = .x %>% pluck("Administered_Dose1_Recip_18Plus"),       
    Administered_Dose2_Recip_18Plus = .x %>% pluck("Administered_Dose2_Recip_18Plus"),       
    Administered_Dose1_Recip_18PlusPop_Pct = .x %>% pluck("Administered_Dose1_Recip_18PlusPop_Pct"),
    Administered_Dose2_Recip_18PlusPop_Pct = .x %>% pluck("Administered_Dose2_Recip_18PlusPop_Pct"),
    Census2019_18PlusPop = .x %>% pluck("Census2019_18PlusPop"),                  
    Distributed_Per_100k_18Plus = .x %>% pluck("Distributed_Per_100k_18Plus"),           
    Administered_18Plus = .x %>% pluck("Administered_18Plus"),                   
    Admin_Per_100k_18Plus = .x %>% pluck("Admin_Per_100k_18Plus"), 
  ))



## --- Write out data -------


# Write out current data
dir.create("data/current/", recursive = T, showWarnings = FALSE)

df %>% 
  write_csv("data/current/state_vaccinations.csv")

us_df %>% 
  write_csv("data/current/us_vaccinations.csv")




# Write out timeseries data
if (!file.exists("data/timeseries/state_vaccinations.csv")){
    
  dir.create("data/timeseries/", recursive = T, showWarnings = FALSE)
  
  df %>% 
    write_csv("data/timeseries/state_vaccinations.csv")
  
  us_df %>% 
    write_csv("data/timeseries/us_vaccinations.csv")
  
} else if(file.exists("data/timeseries/state_vaccinations.csv")){
  
  old_file_states = read_csv("data/timeseries/state_vaccinations.csv")
  
  new_file_states = old_file_states %>% 
    bind_rows(df) %>% 
    distinct(.keep_all = TRUE)
  
  new_file_states %>% 
    write_csv("data/timeseries/state_vaccinations.csv")
  
  
  
  old_file_us = read_csv("data/timeseries/us_vaccinations.csv")
  
  new_file_us = old_file_us %>% 
    bind_rows(us_df) %>% 
    distinct(.keep_all = TRUE)
  
  new_file_us %>% 
    write_csv("data/timeseries/us_vaccinations.csv")
  
  
}





