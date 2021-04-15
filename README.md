# covid-vaccines-scraping


This repostitory scrapes vaccination data daily from the [CDC vaccination
tracker](https://covid.cdc.gov/covid-data-tracker/#vaccinations). It makes use
of the following API from the CDC, which appears to be undocumented:

https://covid.cdc.gov/covid-data-tracker/COVIDData/getAjaxData?id=vaccination_data.

It also downloads time series data from the Our World in Data [COVID vaccination repository](https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations).

The scripts run daily on a cronjob with the help of Github Actions (see
`.github/workflows/docker.yaml` for the setup). These data power a public
Tableu dashboard made by the Urban Institute in collaboration with Health Data
Viz. You can read more about our data sources for the dashboard [here](https://datacatalog.urban.org/dataset/vaccinating-us):, you can view the dashboard [here](insert dashboard
link):, and you can access all of our public data at [this](https://docs.google.com/spreadsheets/d/1tJR8Z3Yk4pQH-cZDXzFwbaEfgQhremZ9LM4kwDW_V68/edit#gid=396517478) Google Sheet link.

Below is a description of each of the scripts within the `R/` folder

- `generate_vaccine_data.R`: Scrapes data from the CDC and Our Our World in Data
  daily and stores them locally 
- `upload_vaccine_data_to_google_sheets.R`: Uploads the data into different tabs
  of our Google Sheet for easy import into our Tableau dashboard

The above two scripts are run on a cronjob with Github actions. The below script
was only run once, and the results were pasted into the same Google Sheet into a
different tab.

- `acs_bls_data.R`: Download data from the American Community Survey and the BLS
  to provide demographic data and the employment data by healthcare and
  education industries by state. This data was used in a few places in our
  dashboard 




Again all of the output data can be downloaded daily at this public Google Sheet: https://docs.google.com/spreadsheets/d/1tJR8Z3Yk4pQH-cZDXzFwbaEfgQhremZ9LM4kwDW_V68/edit#gid=396517478
