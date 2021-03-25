# covid-vaccines-scraping
This repostitory scrapes vaccination data faily from the CDC vaccination tracker: https://covid.cdc.gov/covid-data-tracker/#vaccinations. It makes use of the following API from the CDC, which appears to be undocumented: https://covid.cdc.gov/covid-data-tracker/COVIDData/getAjaxData?id=vaccination_data.

The scripts run daily on a cronjob with the help of Github Actions (see `.github/workflows/docker.yaml` for the setup). These data powers a public Tableu dashboard made by the Urban Insitute in collabaration with Health Data Viz. You can read more about our other data sources for the dashboard here: [insert data catalog link] and can view the dashboard here: [insert dashboard link].
