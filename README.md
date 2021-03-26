# covid-vaccines-scraping
This repostitory scrapes vaccination data faily from the CDC vaccination tracker: https://covid.cdc.gov/covid-data-tracker/#vaccinations. It makes use of the following API from the CDC, which appears to be undocumented: https://covid.cdc.gov/covid-data-tracker/COVIDData/getAjaxData?id=vaccination_data. It also downloads time series data from the Our World in Data COVID data repo: https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations. 

The scripts run daily on a cronjob with the help of Github Actions (see `.github/workflows/docker.yaml` for the setup). These data powers a public Tableu dashboard made by the Urban Insitute in collabaration with Health Data Viz. You can read more about our other data sources for the dashboard here: [insert data catalog link] and can view the dashboard here: [insert dashboard link].

All the data can be downloaded at this public Google Sheet: https://docs.google.com/spreadsheets/d/1tJR8Z3Yk4pQH-cZDXzFwbaEfgQhremZ9LM4kwDW_V68/edit#gid=396517478
