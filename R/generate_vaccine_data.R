library(tidyverse)
library(googlesheets4)
library(jsonlite)
library(dotenv)
library(testit)


## --- Set parameters -------

## Define CDC API fields to include in google sheet
fields_to_include <- c(
  "Date",
  "Location",
  "LongName",
  "ShortName",
  "Census2019",
  "Doses_Distributed",
  "Doses_Administered",
  "Dist_Per_100K",
  "Admin_Per_100K",
  "Administered_Dose1_Pop_Pct",
  "Administered_Dose2_Pop_Pct",
  "date_type",
  "Administered_Dose1_Recip",
  "Administered_Dose2_Recip",
  "Administered_Dose1_Recip_18Plus",
  "Administered_Dose2_Recip_18Plus",
  "Administered_Dose1_Recip_18PlusPop_Pct",
  "Administered_Dose2_Recip_18PlusPop_Pct",
  "Distributed_Per_100k_18Plus",
  "Administered_18Plus",
  "Admin_Per_100k_18Plus",
  "Series_Complete_Yes",
  "Series_Complete_Pop_Pct",
  "Series_Complete_18Plus",
  "Series_Complete_18PlusPop_Pct"
)

## --- Read in vaccination data from CDC -------

# Got this url from inspecting network tab on the CDC vaccine tracker page
vaccination_data_url <- "https://covid.cdc.gov/covid-data-tracker/COVIDData/getAjaxData?id=vaccination_data"

d <- jsonlite::read_json(vaccination_data_url)["vaccination_data"][[1]]


# 1 item in the returned JSON has a different structure from all the others,
# which corresponds to the data about vaccines given in Long Term Care
# facilities. So we exclude this item from our JSON
ltc_position <- d %>%
  map(~ .x %>% pluck("ShortName") == "LTC") %>%
  unlist() %>%
  which()
d <- d[-ltc_position]

# Convert all fields in JSON into dataframe
df_all <- d %>%
  map_df(as.tibble)

# current_day <- format(Sys.time(), "%Y_%m_%d-%X")
colnames_df <- tibble(colnames = df_all %>%
  colnames() %>%
  sort())

# If the field types aren't the same as those in the cache, then stop the GH Action
if (!dplyr::all_equal(colnames_df, read_csv("data/cdc_schema_db/fields.csv"))) {
  # If all of the fields in the Google Sheets are in the data, then write out
  # schema and stop with a waarning. The next GH action trigger will update
  # succesfully
  if (all(fields_to_include %in% (colnames_df$colnames))) {
    colnames_df %>%
      write_csv("data/cdc_schema_db/fields.csv")

    # get list of new columns in data
    new_cols <- colnames_df$colnames[!colnames_df$colnames %in% fields_to_include] %>%
      paste0(collapse = ", ")
    stop(str_glue("New fields were added to the CDC API schema: {new_cols}. All old fields are stil in API output, so next GH action trigger wil update the data succesfully."))

    # If some of the fields in the Google Sheet is not in the data, then stop
    # with a more forceful plea for help. Every ensuing GH action will also fail
  } else {
    # x = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE)
    old_cols_not_in_data <- fields_to_include[!fields_to_include %in% (colnames_df$colnames)] %>%
      paste0(collapse = ", ")
    stop(str_glue("CDC API schema has changed. Some old fields are not in the new API schema: {old_cols_not_in_data}. This needs to be fixed before GH actions updates will work."))
  }
}


us_df <- df_all %>%
  select(all_of(fields_to_include)) %>%
  filter(ShortName == "USA")

state_df <- df_all %>%
  select(all_of(fields_to_include)) %>%
  filter(ShortName != "USA")


# CDC for some reason reports New York as New York State. Based on Lindsays' request, we update this
state_df <- state_df %>%
  mutate(LongName = if_else(LongName == "New York State", "New York", LongName))



## --- Write out data -------

# Write out current data
dir.create("data/current/", recursive = T, showWarnings = FALSE)

state_df %>%
  write_csv("data/current/state_vaccinations.csv")

us_df %>%
  write_csv("data/current/us_vaccinations.csv")




# Write out timeseries data
if (!file.exists("data/timeseries/state_vaccinations.csv")) {
  dir.create("data/timeseries/", recursive = T, showWarnings = FALSE)
}

owid <- read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/us_state_vaccinations.csv") %>%
  select(date, location, daily_vaccinations_raw, daily_vaccinations, everything())

us_ts <- owid %>%
  filter(location == "United States")

state_ts <- owid %>%
  filter(location != "United States")


us_ts %>%
  write_csv("data/timeseries/us_vaccinations.csv")

state_ts %>%
  write_csv("data/timeseries/state_vaccinations.csv")