# FIXTURE FILES

### Avro

- `one_complex.avro` : Downloaded from [here](https://github.com/GoogleCloudPlatform/google-cloud-dotnet/blob/master/apis/Google.Cloud.BigQuery.V2/Google.Cloud.BigQuery.V2.IntegrationTests/one_complex.avro). Contains schema for Imaginary number representation.
- `twitter.avro` : Downloaded from [here](https://github.com/miguno/avro-hadoop-starter/blob/master/src/test/resources/avro/twitter.avro). An AVRO schema with simple fields for Twitter users like `username`, `timestamp`, `tweet`.
- `users.avro` : Downloaded from [here](https://github.com/apache/spark/blob/master/examples/src/main/resources/users.avro). A generic AVRO schema with fields like `name`, `favorite_color` and `favorite_numbers`.

### JSON

- `allsets.json` : An ultra-truncated version of the huge zip file available [here](http://mtgjson.com/json/AllSets.json.zip). Contains nested hashes.
- `got.json` : API response for the popular Game of Thrones series, by TV-Maze website found [here](http://api.tvmaze.com/singlesearch/shows?q=game-of-thrones&embed=episodes). A fairly small data source with nested hashes.
- `jsonvat.json` : Nested hash response from [this website](http://jsonvat.com/). A fairly small data source.
- `nasadata.json` : JSON response of Array of hashes, from [NASA website](https://data.nasa.gov/resource/2vr3-k9wn.json). Not complexly nested, but helps to select few keys of the hash without using json-xpath.
- `temp.json` : Time-series response for Average temperature data, from [this website](https://www.ncdc.noaa.gov/cag/time-series/us/110/00/tavg/ytd/12/1895-2016.json?base_prd=true&begbaseyear=1901&endbaseyear=2000). A fairly small data source, with relatively simple nesting - to directly get a dataframe from the response field.

### RData

- `ACScounty.RData` : Downloaded from [here](https://github.com/floswald/Rdata/blob/master/out/ACScounty.RData). Contains two datasets - `ACS3` and `ACS5`.
- `case-shiller.RData` : Downloaded from [here](https://github.com/floswald/Rdata/blob/master/out/case-shiller.RData). Contains a single dataset called `case.shiller`.
- `Filings-by-state.rdata` :  Downloaded from [here](https://github.com/floswald/Rdata/blob/master/out/Filings-by-state.RData). Contains a single dataset called `bk.rates`.
- `Ownership.rdata` : Downloaded from [here](https://github.com/floswald/Rdata/blob/master/out/Ownership.RData). Contains two datasets - `ownership.state.qtr` and `ownership.age`.
- `state-migration.rdata` :  Downloaded from [here](https://github.com/floswald/Rdata/blob/master/out/state-migration.RData). Contains a single dataset called `state.migration`.
- `zip-county.rdata` : Downloaded from [here](https://github.com/floswald/Rdata/blob/master/out/zip-county.RData). Contains a single dataset called `m`.

### RDS

- `bc_sites.rds` : Contains data about geological attributes. Can potentially create `<1113*25> Daru::DataFrame`. Downloaded from [here](https://github.com/eriqande/rep-res-course/blob/master/data/bc_sites.rds)
- `chicago.rds` : Contains data about city and temperatures. Can potentially create a `<6940*8> Daru::DataFrame`. Downloaded from [here](https://github.com/DataScienceSpecialization/courses/blob/master/03_GettingData/dplyr/chicago.rds)
- `healthexp.rds` : Contains data comparing health expectancies among various countries. Can potentially create a `<3030*6> Daru::DataFrame`. Downloaded from [here](https://github.com/jcheng5/googleCharts/blob/master/inst/examples/bubble/healthexp.Rds)
- `heights.rds` : Contains data as individual-wise, with attributes such as income, education, height, weight, etc. Can potentially create a `<3988*10> Daru::DataFrame`. Downloaded from [here](https://github.com/hadley/r4ds/blob/master/data/heights.RDS) 
- `maacs_env.rds` : Contains data about Marine Air Command and Control System (MAACS) Environment. Can potentially create a `<750*27> Daru::DataFrame`. Downloaded from [here](https://github.com/DataScienceSpecialization/courses/blob/master/04_ExploratoryAnalysis/PlottingLattice/maacs_env.rds) 
- `RPPdataConverted.rds`: Contains data about author, citations and more of such fields. A fairly large dataset, which can potentially create a `<168*138> Daru::DataFrame`. Downloaded from [here](https://github.com/CenterForOpenScience/rpp/blob/master/data_allformats/RPPdataConverted.rds)

### NOTE FOR FUTURE MAINTAINERS

If you're having difficulty in finding fixtures files for a certain format, search in google for a specific filetype and keyword. The search url usually comes in a format like https://www.google.co.in/search?q=filetype:{filetype}+{keyword}. For example, https://www.google.co.in/search?q=filetype:avro+github

Go through the search results, to check if the file is feasible (not too large) to be added as a fixture file to this repository. 