eurodata &ndash; R package for fast and easy Eurostat data import and search
================
Aleksander Rutkowski

The package relies on [Eurostat's Bulk Download Facility](http://ec.europa.eu/eurostat/data/bulkdownload).

The core API contains just 6 functions &ndash; 4 for data or metadata imports and 2 for search:

Import functionality:

-   [**importData**](https://rdrr.io/github/alekrutkowski/eurodata/man/importData.html) &ndash; fast thanks to [data.table](https://cran.r-project.org/web/packages/data.table/index.html)::[fread](http://www.rdocumentation.org/packages/data.table/functions/fread)
-   [**importLabels**](https://rdrr.io/github/alekrutkowski/eurodata/man/importLabels.html) &ndash; as above
-   [**importMetabase**](https://rdrr.io/github/alekrutkowski/eurodata/man/importMetabase.html) &ndash; as above
-   [**importDataList**](https://rdrr.io/github/alekrutkowski/eurodata/man/importDataList.html) &ndash; reflects the hierarchical structure of the Eurostat tree of datasets &ndash; fast transformation of the raw [Table of Contents file](http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?file=table_of_contents_en.txt) is based on a C++ code snippet compiled via [Rcpp](https://cran.r-project.org/web/packages/Rcpp/index.html)

Search functionality:

-   [**browseDataList**](https://rdrr.io/github/alekrutkowski/eurodata/man/browseDataList.html) &ndash; based on importDataList, shows an HTML table (generated with [xtable](https://cran.r-project.org/web/packages/xtable/index.html)::[xtable](http://www.rdocumentation.org/packages/xtable/functions/xtable)) in a browser with a list of the found datasets
-   [**find**](https://rdrr.io/github/alekrutkowski/eurodata/man/find.html) &ndash; based on importDataList, shows a textual report on the found datasets &ndash; a &ldquo;quick-n-dirty&rdquo; way to find a Eurostat dataset without much typing (with a keyword or a few keywords)

Installation
------------

From source:

``` r
devtools::install_github('alekrutkowski/eurodata')
```

Precompiled binary for Windows (useful for those who don't have Rtools):

``` r
installr::install.packages.zip('https://github.com/alekrutkowski/eurodata/releases/download/v1.3.0/eurodata_1.3.0.zip')
```

Functionality demo
------------------

``` r
library(eurodata)
```

    ## 
    ## Attaching package: 'eurodata'
    ## 
    ## The following object is masked from 'package:utils':
    ## 
    ##     find

### Imports

``` r
x <- importData('nama_10_a10')  # actual dataset
str(x)
```

    ## Classes 'EurostatDataset' and 'data.frame':  794170 obs. of  7 variables:
    ##  $ unit   : Factor w/ 23 levels "CLV_I05","CLV_I10",..: 4 4 4 4 4 4 4 4 4 4 ...
    ##  $ nace_r2: Factor w/ 12 levels "A","B-E","C",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ na_item: Factor w/ 4 levels "B1G","D1","D11",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ geo    : Factor w/ 42 levels "AL","AT","BE",..: 2 3 4 5 6 7 8 9 10 11 ...
    ##  $ time   : Factor w/ 41 levels "2015","2014",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ value_ : num  3269 2506 1382 NA 294 ...
    ##  $ flags_ : chr  "" "" "" ":" ...
    ##  - attr(*, "EurostatDatasetCode")= chr "nama_10_a10"
    ##  - attr(*, "DownloadTime")= POSIXct, format: "2016-06-24 11:19:36"

``` r
head(x,10)
```

    ##          unit nace_r2 na_item  geo time   value_ flags_
    ## 1  CLV05_MEUR       A     B1G   AT 2015   3268.7       
    ## 2  CLV05_MEUR       A     B1G   BE 2015   2506.5       
    ## 3  CLV05_MEUR       A     B1G   BG 2015   1381.9       
    ## 4  CLV05_MEUR       A     B1G   CH 2015       NA      :
    ## 5  CLV05_MEUR       A     B1G   CY 2015    294.0      p
    ## 6  CLV05_MEUR       A     B1G   CZ 2015   2011.4       
    ## 7  CLV05_MEUR       A     B1G   DE 2015  16810.1       
    ## 8  CLV05_MEUR       A     B1G   DK 2015   2624.8       
    ## 9  CLV05_MEUR       A     B1G   EA 2015 152297.8       
    ## 10 CLV05_MEUR       A     B1G EA12 2015 146140.6

``` r
# Friendly error if a wrong data code (similarly for importLabels):
tryCatch(importData('nama_10_a10_XXX'),
         error = function(e) cat(geterrmessage()))
```

    ## 
    ## Probably a wrong dataset code:  nama_10_a10_XXX
    ## Check if you can find  nama_10_a10_XXX.tsv.gz  at
    ## http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?dir=data&start=all

``` r
y <- importDataList()  # metadata
colnames(y)
```

    ##  [1] "Data subgroup, level 0"      "Data subgroup, level 1"      "Data subgroup, level 2"     
    ##  [4] "Data subgroup, level 3"      "Data subgroup, level 4"      "Data subgroup, level 5"     
    ##  [7] "Data subgroup, level 6"      "Dataset name"                "Code"                       
    ## [10] "Type"                        "Last update of data"         "Last table structure change"
    ## [13] "Data start"                  "Data end"                    "Link"

``` r
str(y[y$Code=='nama_10_a10',])  # metadata on x
```

    ## Classes 'EurostatDataList' and 'data.frame': 1 obs. of  15 variables:
    ##  $ Data subgroup, level 0     : chr "Database by themes"
    ##  $ Data subgroup, level 1     : chr "Economy and finance"
    ##  $ Data subgroup, level 2     : chr "National accounts (ESA 2010)"
    ##  $ Data subgroup, level 3     : chr "Annual national accounts"
    ##  $ Data subgroup, level 4     : chr "Basic breakdowns of main GDP aggregates and employment (by industry and by assets)"
    ##  $ Data subgroup, level 5     : chr ""
    ##  $ Data subgroup, level 6     : chr ""
    ##  $ Dataset name               : chr "Gross value added and income by A*10 industry breakdowns"
    ##  $ Code                       : chr "nama_10_a10"
    ##  $ Type                       : chr "dataset"
    ##  $ Last update of data        : chr "22.06.2016"
    ##  $ Last table structure change: chr "14.01.2016"
    ##  $ Data start                 : chr "1975"
    ##  $ Data end                   : chr "2015"
    ##  $ Link                       : chr "http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=nama_10_a10&lang=en"

``` r
z <- importLabels('geo')
head(z,10)
```

    ##          geo                                                                                       geo_labels
    ## 1        EUR                                                                                           Europe
    ## 2         EU European Union (EU6-1972, EU9-1980, EU10-1985, EU12-1994, EU15-2004, EU25-2006, EU27-2013, EU28)
    ## 3       EU_V                                     European Union (aggregate changing according to the context)
    ## 4       EU28                                                                    European Union (28 countries)
    ## 5       EU27                                                                    European Union (27 countries)
    ## 6  EU27_X_FR                                                      European Union except France (26 countries)
    ## 7       EU25                                                                    European Union (25 countries)
    ## 8       EU15                                                                    European Union (15 countries)
    ## 9    EU15_NO                                                         European Union (15 countries) and Norway
    ## 10     NMS13                                                                 New Member States (13 countries)

### Search

``` r
# Free-style text search based on the parts of words in the dataset names
find(gdp,main,selected,-quarterly)
```

    ## 2016-06-24 11:19:42
    ## 1 dataset(s)/table(s) found.
    ## Keywords: gdp, main, selected, -quarterly
    ## 
    ##  Database by themes >>
    ##  Economy and finance >>
    ##  National accounts (ESA 2010) >>
    ##  National accounts - international data cooperation >>
    ##  Annual national accounts
    ## 
    ## No : 1
    ## Dataset name : GDP and main aggregates - selected international annual data
    ## Code : naida_10_gdp
    ## Type : dataset
    ## Last update of data : 23.06.2016
    ## Last table structure change : 03.03.2016
    ## Data start : 1975
    ## Data end : 2015
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=naida_10_gdp&lang=en
    ## 
    ## 2016-06-24 11:19:42
    ## 1 dataset(s)/table(s) found.
    ## Keywords: gdp, main, selected, -quarterly
    ## 
    ## End.

``` r
# Search based on the parts of the dataset codes
find(bop, its)
```

    ## 2016-06-24 11:19:43
    ## 7 dataset(s)/table(s) found.
    ## Keywords: bop, its
    ## 
    ##  Database by themes >>
    ##  Economy and finance >>
    ##  Balance of payments - International transactions >>
    ##  International trade in services, geographical breakdown
    ## 
    ## No : 1
    ## Dataset name : International trade in services (since 2004)
    ## Code : bop_its_det
    ## Type : dataset
    ## Last update of data : 16.05.2014
    ## Last table structure change : 16.05.2014
    ## Data start : 2004
    ## Data end : 2013
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_det&lang=en
    ## 
    ## No : 2
    ## Dataset name : International trade in services (1985-2003)
    ## Code : bop_its_deth
    ## Type : dataset
    ## Last update of data : 16.05.2014
    ## Last table structure change : 16.05.2014
    ## Data start : 1985
    ## Data end : 2003
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_deth&lang=en
    ## 
    ## No : 3
    ## Dataset name : International trade in services - market integration indicators
    ## Code : bop_its_str
    ## Type : dataset
    ## Last update of data : 28.05.2014
    ## Last table structure change : 28.05.2014
    ## Data start : 1992
    ## Data end : 2013
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_str&lang=en
    ## 
    ## No : 4
    ## Dataset name : Total services, detailed geographical breakdown by EU Member States (since 2002)
    ## Code : bop_its_tot
    ## Type : dataset
    ## Last update of data : 27.05.2014
    ## Last table structure change : 27.05.2014
    ## Data start : 2002
    ## Data end : 2012
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_tot&lang=en
    ## 
    ## No : 5
    ## Dataset name : International trade in services - Data for the Eurostat yearbook
    ## Code : bop_its_ybk
    ## Type : dataset
    ## Last update of data : 06.06.2014
    ## Last table structure change : 06.06.2014
    ## Data start : 1992
    ## Data end : 2013
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_ybk&lang=en
    ## 
    ##  Database by themes >>
    ##  Economy and finance >>
    ##  Balance of payments - International transactions (BPM6) >>
    ##  International trade in services, geographical breakdown (BPM6)
    ## 
    ## No : 6
    ## Dataset name : International trade in services (since 2010) (BPM6)
    ## Code : bop_its6_det
    ## Type : dataset
    ## Last update of data : 01.06.2016
    ## Last table structure change : 01.06.2016
    ## Data start : 2010
    ## Data end : 2015
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_det&lang=en
    ## 
    ## No : 7
    ## Dataset name : Total services, detailed geographical breakdown by EU Member States (since 2010) (BPM6)
    ## Code : bop_its6_tot
    ## Type : dataset
    ## Last update of data : 01.06.2016
    ## Last table structure change : 01.06.2016
    ## Data start : 2010
    ## Data end : 2015
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_tot&lang=en
    ## 
    ## 2016-06-24 11:19:43
    ## 7 dataset(s)/table(s) found.
    ## Keywords: bop, its
    ## 
    ## End.

``` r
find(bop,-ybk,its)
```

    ## 2016-06-24 11:19:43
    ## 6 dataset(s)/table(s) found.
    ## Keywords: bop, -ybk, its
    ## 
    ##  Database by themes >>
    ##  Economy and finance >>
    ##  Balance of payments - International transactions >>
    ##  International trade in services, geographical breakdown
    ## 
    ## No : 1
    ## Dataset name : International trade in services (since 2004)
    ## Code : bop_its_det
    ## Type : dataset
    ## Last update of data : 16.05.2014
    ## Last table structure change : 16.05.2014
    ## Data start : 2004
    ## Data end : 2013
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_det&lang=en
    ## 
    ## No : 2
    ## Dataset name : International trade in services (1985-2003)
    ## Code : bop_its_deth
    ## Type : dataset
    ## Last update of data : 16.05.2014
    ## Last table structure change : 16.05.2014
    ## Data start : 1985
    ## Data end : 2003
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_deth&lang=en
    ## 
    ## No : 3
    ## Dataset name : International trade in services - market integration indicators
    ## Code : bop_its_str
    ## Type : dataset
    ## Last update of data : 28.05.2014
    ## Last table structure change : 28.05.2014
    ## Data start : 1992
    ## Data end : 2013
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_str&lang=en
    ## 
    ## No : 4
    ## Dataset name : Total services, detailed geographical breakdown by EU Member States (since 2002)
    ## Code : bop_its_tot
    ## Type : dataset
    ## Last update of data : 27.05.2014
    ## Last table structure change : 27.05.2014
    ## Data start : 2002
    ## Data end : 2012
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_tot&lang=en
    ## 
    ##  Database by themes >>
    ##  Economy and finance >>
    ##  Balance of payments - International transactions (BPM6) >>
    ##  International trade in services, geographical breakdown (BPM6)
    ## 
    ## No : 5
    ## Dataset name : International trade in services (since 2010) (BPM6)
    ## Code : bop_its6_det
    ## Type : dataset
    ## Last update of data : 01.06.2016
    ## Last table structure change : 01.06.2016
    ## Data start : 2010
    ## Data end : 2015
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_det&lang=en
    ## 
    ## No : 6
    ## Dataset name : Total services, detailed geographical breakdown by EU Member States (since 2010) (BPM6)
    ## Code : bop_its6_tot
    ## Type : dataset
    ## Last update of data : 01.06.2016
    ## Last table structure change : 01.06.2016
    ## Data start : 2010
    ## Data end : 2015
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_tot&lang=en
    ## 
    ## 2016-06-24 11:19:43
    ## 6 dataset(s)/table(s) found.
    ## Keywords: bop, -ybk, its
    ## 
    ## End.

``` r
browseDataList(grepl('GDP',`Dataset name`) &
                   grepl('main',`Dataset name`) &
                   grepl('selected',`Dataset name`) &
                   !grepl('quarterly',`Dataset name`))
```

<html>
<body>
<p>
<tt>■ Generated on: 2016-06-24 11:19:44 ■ Number of datasets/tables found: 1 ■ Search criteria: grepl("GDP", `Dataset name`) & grepl("main", `Dataset name`) &grepl("selected", `Dataset name`) & !grepl("quarterly", `Dataset name`)</tt>
</p>
<!-- html table generated in R 3.2.4 by xtable 1.7-4 package --><!-- Fri Jun 24 11:19:45 2016 -->
<table class="gridtable">
<tr>
<th>
Row
</th>
<th>
Data subgroup, level 0
</th>
<th>
Data subgroup, level 1
</th>
<th>
Data subgroup, level 2
</th>
<th>
Data subgroup, level 3
</th>
<th>
Data subgroup, level 4
</th>
<th>
Dataset name
</th>
<th>
Code
</th>
<th>
Type
</th>
<th>
Last update of data
</th>
<th>
Last table structure change
</th>
<th>
Data start
</th>
<th>
Data end
</th>
<th>
Link
</th>
</tr>
<tr>
<td>
1
</td>
<td>
Database by themes
</td>
<td>
Economy and finance
</td>
<td>
National accounts (ESA 2010)
</td>
<td>
National accounts - international data cooperation
</td>
<td>
Annual national accounts
</td>
<td>
<b>GDP and main aggregates - selected international annual data</b>
</td>
<td>
<tt><b>naida_10_gdp</b></tt>
</td>
<td>
dataset
</td>
<td>
23.06.2016
</td>
<td>
03.03.2016
</td>
<td>
1975
</td>
<td>
2015
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=naida_10_gdp&lang=en" target="_blank">click here</a>
</td>
</tr>
</table>
</body>
</html>

``` r
browseDataList(grepl('bop',Code) & grepl('its',Code))
```

<html>
<body>
<p>
<tt>■ Generated on: 2016-06-24 11:19:45 ■ Number of datasets/tables found: 7 ■ Search criteria: grepl("bop", Code) & grepl("its", Code)</tt>
</p>
<!-- html table generated in R 3.2.4 by xtable 1.7-4 package --><!-- Fri Jun 24 11:19:45 2016 -->
<table class="gridtable">
<tr>
<th>
Row
</th>
<th>
Data subgroup, level 0
</th>
<th>
Data subgroup, level 1
</th>
<th>
Data subgroup, level 2
</th>
<th>
Data subgroup, level 3
</th>
<th>
Dataset name
</th>
<th>
Code
</th>
<th>
Type
</th>
<th>
Last update of data
</th>
<th>
Last table structure change
</th>
<th>
Data start
</th>
<th>
Data end
</th>
<th>
Link
</th>
</tr>
<tr>
<td>
1
</td>
<td>
Database by themes
</td>
<td>
Economy and finance
</td>
<td>
Balance of payments - International transactions
</td>
<td>
International trade in services, geographical breakdown
</td>
<td>
<b>International trade in services (since 2004)</b>
</td>
<td>
<tt><b>bop_its_det</b></tt>
</td>
<td>
dataset
</td>
<td>
16.05.2014
</td>
<td>
16.05.2014
</td>
<td>
2004
</td>
<td>
2013
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_det&lang=en" target="_blank">click here</a>
</td>
</tr>
<tr>
<td>
2
</td>
<td>
Database by themes
</td>
<td>
Economy and finance
</td>
<td>
Balance of payments - International transactions
</td>
<td>
International trade in services, geographical breakdown
</td>
<td>
<b>International trade in services (1985-2003)</b>
</td>
<td>
<tt><b>bop_its_deth</b></tt>
</td>
<td>
dataset
</td>
<td>
16.05.2014
</td>
<td>
16.05.2014
</td>
<td>
1985
</td>
<td>
2003
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_deth&lang=en" target="_blank">click here</a>
</td>
</tr>
<tr>
<td>
3
</td>
<td>
Database by themes
</td>
<td>
Economy and finance
</td>
<td>
Balance of payments - International transactions
</td>
<td>
International trade in services, geographical breakdown
</td>
<td>
<b>International trade in services - market integration indicators</b>
</td>
<td>
<tt><b>bop_its_str</b></tt>
</td>
<td>
dataset
</td>
<td>
28.05.2014
</td>
<td>
28.05.2014
</td>
<td>
1992
</td>
<td>
2013
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_str&lang=en" target="_blank">click here</a>
</td>
</tr>
<tr>
<td>
4
</td>
<td>
Database by themes
</td>
<td>
Economy and finance
</td>
<td>
Balance of payments - International transactions
</td>
<td>
International trade in services, geographical breakdown
</td>
<td>
<b>Total services, detailed geographical breakdown by EU Member States (since 2002)</b>
</td>
<td>
<tt><b>bop_its_tot</b></tt>
</td>
<td>
dataset
</td>
<td>
27.05.2014
</td>
<td>
27.05.2014
</td>
<td>
2002
</td>
<td>
2012
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_tot&lang=en" target="_blank">click here</a>
</td>
</tr>
<tr>
<td>
5
</td>
<td>
Database by themes
</td>
<td>
Economy and finance
</td>
<td>
Balance of payments - International transactions
</td>
<td>
International trade in services, geographical breakdown
</td>
<td>
<b>International trade in services - Data for the Eurostat yearbook</b>
</td>
<td>
<tt><b>bop_its_ybk</b></tt>
</td>
<td>
dataset
</td>
<td>
06.06.2014
</td>
<td>
06.06.2014
</td>
<td>
1992
</td>
<td>
2013
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_ybk&lang=en" target="_blank">click here</a>
</td>
</tr>
<tr>
<td>
6
</td>
<td>
Database by themes
</td>
<td>
Economy and finance
</td>
<td>
Balance of payments - International transactions (BPM6)
</td>
<td>
International trade in services, geographical breakdown (BPM6)
</td>
<td>
<b>International trade in services (since 2010) (BPM6)</b>
</td>
<td>
<tt><b>bop_its6_det</b></tt>
</td>
<td>
dataset
</td>
<td>
01.06.2016
</td>
<td>
01.06.2016
</td>
<td>
2010
</td>
<td>
2015
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_det&lang=en" target="_blank">click here</a>
</td>
</tr>
<tr>
<td>
7
</td>
<td>
Database by themes
</td>
<td>
Economy and finance
</td>
<td>
Balance of payments - International transactions (BPM6)
</td>
<td>
International trade in services, geographical breakdown (BPM6)
</td>
<td>
<b>Total services, detailed geographical breakdown by EU Member States (since 2010) (BPM6)</b>
</td>
<td>
<tt><b>bop_its6_tot</b></tt>
</td>
<td>
dataset
</td>
<td>
01.06.2016
</td>
<td>
01.06.2016
</td>
<td>
2010
</td>
<td>
2015
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_tot&lang=en" target="_blank">click here</a>
</td>
</tr>
</table>
</body>
</html>

``` r
# Producing a table of datasets which (1) include a dimension `sizeclas`
# (i.e. firm size class) and (2) some data for firms with fewer than 10 employees
# (`sizeclas` code "LT10") and (3) have sectorial data (i.e. include a
# dimension `nace_r2`).
library(magrittr)
metab <- importMetabase()
```

    ## Downloading Eurostat Metabase
    ## Uncompressing (extracting)
    ## Importing (reading into memory)

``` r
codes_with_nace <- metab %>% 
    subset(Dim_name=='nace_r2') %>%
    extract2('Code') %>%
    unique
final_codes <- metab %>%
    subset(Dim_name=='sizeclas' & Dim_val=='LT10' &
               Code %in% codes_with_nace) %>%
    extract2('Code') %>%
    unique
```

``` r
importDataList() %>%
    subset(Code %in% final_codes) %>%
    as.EurostatDataList %>%
    # the `SearchCriteria` argument below is optional
    print(SearchCriteria =
              'those including data on firms with fewer than 10 employees and NACE Rev.2 disaggregation') 
```

<html>
<body>
<p>
<tt>■ Generated on: 2016-06-24 11:19:47 ■ Number of datasets/tables found: 7 ■ Search criteria: those including data on firms with fewer than 10 employees and NACE Rev.2 disaggregation</tt>
</p>
<!-- html table generated in R 3.2.4 by xtable 1.7-4 package --><!-- Fri Jun 24 11:19:47 2016 -->
<table class="gridtable">
<tr>
<th>
Row
</th>
<th>
Data subgroup, level 0
</th>
<th>
Data subgroup, level 1
</th>
<th>
Data subgroup, level 2
</th>
<th>
Data subgroup, level 3
</th>
<th>
Data subgroup, level 4
</th>
<th>
Data subgroup, level 5
</th>
<th>
Dataset name
</th>
<th>
Code
</th>
<th>
Type
</th>
<th>
Last update of data
</th>
<th>
Last table structure change
</th>
<th>
Data start
</th>
<th>
Data end
</th>
<th>
Link
</th>
</tr>
<tr>
<td>
1
</td>
<td>
Database by themes
</td>
<td>
Population and social conditions
</td>
<td>
Labour market
</td>
<td>
Labour costs
</td>
<td>
Labour cost surveys
</td>
<td>
Labour costs survey 2008 and 2012 - NACE Rev. 2
</td>
<td>
<b>Labour cost, wages and salaries, direct remuneration (excluding apprentices) - NACE Rev. 2</b>
</td>
<td>
<tt><b>lc_ncost_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
25.05.2016
</td>
<td>
17.12.2015
</td>
<td>
2008
</td>
<td>
2012
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=lc_ncost_r2&lang=en" target="_blank">click here</a>
</td>
</tr>
<tr>
<td>
2
</td>
<td>
Database by themes
</td>
<td>
Population and social conditions
</td>
<td>
Labour market
</td>
<td>
Labour costs
</td>
<td>
Labour cost surveys
</td>
<td>
Labour costs survey 2008 and 2012 - NACE Rev. 2
</td>
<td>
<b>Structure of labour cost as % of total cost - NACE Rev. 2</b>
</td>
<td>
<tt><b>lc_nstruc_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
25.05.2016
</td>
<td>
17.12.2015
</td>
<td>
2008
</td>
<td>
2012
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=lc_nstruc_r2&lang=en" target="_blank">click here</a>
</td>
</tr>
<tr>
<td>
3
</td>
<td>
Database by themes
</td>
<td>
Population and social conditions
</td>
<td>
Labour market
</td>
<td>
Labour costs
</td>
<td>
Labour cost surveys
</td>
<td>
Labour costs survey 2008 and 2012 - NACE Rev. 2
</td>
<td>
<b>Number of employees, hours actually worked and paid - NACE Rev. 2</b>
</td>
<td>
<tt><b>lc_nnum1_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
25.05.2016
</td>
<td>
17.12.2015
</td>
<td>
2008
</td>
<td>
2012
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=lc_nnum1_r2&lang=en" target="_blank">click here</a>
</td>
</tr>
<tr>
<td>
4
</td>
<td>
Database by themes
</td>
<td>
Population and social conditions
</td>
<td>
Labour market
</td>
<td>
Labour costs
</td>
<td>
Labour cost surveys
</td>
<td>
Labour costs survey 2008 and 2012 - NACE Rev. 2
</td>
<td>
<b>Number of hours actually worked and paid per employee - NACE Rev. 2</b>
</td>
<td>
<tt><b>lc_nnum2_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
25.05.2016
</td>
<td>
17.12.2015
</td>
<td>
2008
</td>
<td>
2012
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=lc_nnum2_r2&lang=en" target="_blank">click here</a>
</td>
</tr>
<tr>
<td>
5
</td>
<td>
Database by themes
</td>
<td>
Population and social conditions
</td>
<td>
Labour market
</td>
<td>
Labour costs
</td>
<td>
Labour cost surveys
</td>
<td>
Labour costs survey 2008 and 2012 - NACE Rev. 2
</td>
<td>
<b>Number of statistical units - NACE Rev. 2</b>
</td>
<td>
<tt><b>lc_nstu_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
25.05.2016
</td>
<td>
17.12.2015
</td>
<td>
2008
</td>
<td>
2012
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=lc_nstu_r2&lang=en" target="_blank">click here</a>
</td>
</tr>
<tr>
<td>
6
</td>
<td>
Cross cutting topics
</td>
<td>
Entrepreneurship indicators program
</td>
<td>
Enterprise population
</td>
<td>
</td>
<td>
</td>
<td>
</td>
<td>
<b>Annual enterprise statistics by size class and NACE Rev. 2 activity (B-N_X_K)</b>
</td>
<td>
<tt><b>eip_pop1</b></tt>
</td>
<td>
dataset
</td>
<td>
07.04.2016
</td>
<td>
07.04.2016
</td>
<td>
2010
</td>
<td>
2013
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=eip_pop1&lang=en" target="_blank">click here</a>
</td>
</tr>
<tr>
<td>
7
</td>
<td>
Cross cutting topics
</td>
<td>
Entrepreneurship indicators program
</td>
<td>
</td>
<td>
</td>
<td>
</td>
<td>
</td>
<td>
<b>International trade by size class and NACE Rev. 2 activity (B-N_X_K)</b>
</td>
<td>
<tt><b>eip_ext1</b></tt>
</td>
<td>
dataset
</td>
<td>
07.04.2016
</td>
<td>
07.04.2016
</td>
<td>
2008
</td>
<td>
2013
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=eip_ext1&lang=en" target="_blank">click here</a>
</td>
</tr>
</table>
</body>
</html>

Speed demo
----------

eurodata::**importData** compared to [eurostat](https://cran.r-project.org/web/packages/eurostat/index.html)::[get_eurostat](http://www.rdocumentation.org/packages/eurostat/functions/get_eurostat):

``` r
y <- importDataList()  # metadata

d <- unique(y[y$Type=='dataset','Code']) # dataset codes

set.seed(1234)  # for replicability

d50 <- sample(d, 50) # a random sample of 50 datasets

get_eurostat <- eurostat::get_eurostat  # package 'eurostat' needs to be installed

FUNS <- c('importData', 'get_eurostat')

timeit <- function(funname, code)
    tryCatch(system.time(get(funname)(code))['elapsed'],
             error = function(e) as.numeric(NA)) # due to errors in some 'eurostat' package imports

compileInfo <-
    function(code) {
        FUNS2 <- if (sample(c(TRUE,FALSE), 1))
            FUNS else rev(FUNS) # so that the execution order is random
        res <- data.frame(code,
                          timeit(FUNS2[1], code),
                          timeit(FUNS2[2], code))
        colnames(res) <- c('Data code name',FUNS2)
        res
    }
```

``` r
L <- lapply(d50, compileInfo)
```

``` r
Res <- do.call(rbind, L)

Res2 <- within(Res,
               ratio <- get_eurostat/importData)

row.names(Res2) <- NULL # to eliminate the visual noise

Res2 # lower = faster (in seconds)
```

    ##      Data code name importData get_eurostat      ratio
    ## 1           vit_bs1       1.08         6.74  6.2407407
    ## 2      yth_incl_060       0.13           NA         NA
    ## 3      spr_exp_pens       0.54         3.37  6.2407407
    ## 4      yth_incl_100       0.12         0.43  3.5833333
    ## 5     mar_sg_am_ewx       0.08         0.06  0.7500000
    ## 6      sts_inppnd_q      10.51       127.64 12.1446242
    ## 7         ei_isrt_q       0.11         0.25  2.2727273
    ## 8         migr_acqs       0.04         0.10  2.5000000
    ## 9        sbs_ins_5b       0.19         1.31  6.8947368
    ## 10    earn_ses06_15       0.35           NA         NA
    ## 11         iss_ctry       0.23           NA         NA
    ## 12     lmp_expme_lv       0.13         0.57  4.3846154
    ## 13    hlth_ehis_hc6       0.10         0.12  1.2000000
    ## 14         nrg_122m       0.49         6.55 13.3673469
    ## 15     hlth_dpeh200       0.06           NA         NA
    ## 16    road_eqr_carm       0.10         0.28  2.8000000
    ## 17     hlth_silc_15       2.92        24.95  8.5445205
    ## 18      cens_91typb       0.04           NA         NA
    ## 19    naio_18_agg_6       0.08         0.20  2.5000000
    ## 20     migr_emi1ctz      31.26       354.30 11.3339731
    ## 21     hsw_aw_nnasz       0.08         0.11  1.3750000
    ## 22      hlth_dhc010       0.10         0.38  3.8000000
    ## 23       nasa_10_ki       0.12         0.25  2.0833333
    ## 24 htec_emp_risced2       1.05         8.94  8.5142857
    ## 25        bop_eu6_m       0.31         2.41  7.7741935
    ## 26  ext_lt_intertrd       0.26         2.16  8.3076923
    ## 27   earn_ses_agt12       0.33           NA         NA
    ## 28      env_wat_pop       0.06         0.03  0.5000000
    ## 29  rail_go_intunld       0.33           NA         NA
    ## 30    hlth_cd_ysdr1      10.60        10.90  1.0283019
    ## 31     lfsa_enewasn       0.23         1.81  7.8695652
    ## 32      cens_91actz       0.26         2.26  8.6923077
    ## 33      hlth_dhc070       0.22         0.52  2.3636364
    ## 34    earn_ses10_20       0.90           NA         NA
    ## 35        nasa_f_of      10.33        72.29  6.9980639
    ## 36     ef_mpmachine       0.08         0.20  2.5000000
    ## 37     ert_eff_ex_m       0.25         1.14  4.5600000
    ## 38     cens_01nsctz       0.90           NA         NA
    ## 39      ipr_trn_tot       0.17         0.06  0.3529412
    ## 40       fish_ld_es       9.96       118.86 11.9337349
    ## 41    lmp_partme_es       0.14         0.50  3.5714286
    ## 42       sts_inlb_a       0.89         7.38  8.2921348
    ## 43    hlth_cd_ainfr       0.31         2.25  7.2580645
    ## 44     yth_empl_040       0.34         2.71  7.9705882
    ## 45          hsw_pb7       0.09         0.17  1.8888889
    ## 46  earn_nt_unemtrp       0.07         0.04  0.5714286
    ## 47        bs_bs7_04       0.08         0.04  0.5000000
    ## 48  lfso_06opskisco       0.08           NA         NA
    ## 49       migr_eipre       2.82        28.61 10.1453901
    ## 50     ef_ov_luob99       0.25         1.61  6.4400000

``` r
# How many times eurodata::importData is faster on average?

mean(Res2$ratio, na.rm=TRUE)
```

    ## [1] 5.251208

``` r
median(Res2$ratio, na.rm=TRUE)
```

    ## [1] 4.472308
