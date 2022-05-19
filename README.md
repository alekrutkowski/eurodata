eurodata – R package for fast and easy Eurostata data import and search
================
Aleksander Rutkowski

The package relies on [Eurostat’s Bulk Download
Facility](http://ec.europa.eu/eurostat/data/bulkdownload).

The core API contains just 6 functions – 4 for data or metadata imports
and 2 for search:

Import functionality:

-   **importData** – fast thanks to
    [data.table](https://cran.r-project.org/web/packages/data.table/index.html)::[fread](http://www.rdocumentation.org/packages/data.table/functions/fread)
-   **importDataLabels** – as above
-   **importMetabase** – as above
-   **importDataList** – reflects the hierarchical structure of the
    Eurostat tree of datasets – fast transformation of the raw [Table of
    Contents
    file](http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?file=table_of_contents_en.txt)
    is based on a C++ code snippet compiled via
    [Rcpp](https://cran.r-project.org/web/packages/Rcpp/index.html)

Search functionality:

-   **browseDataList** – based on importDataList, shows an HTML table
    (generated with
    [xtable](https://cran.r-project.org/web/packages/xtable/index.html)::[xtable](http://www.rdocumentation.org/packages/xtable/functions/xtable))
    in a browser with a list of the found datasets
-   **find** – based on importDataList, shows a textual report on the
    found datasets – a \`\`quick-n-dirty’’ way to find a Eurostat
    dataset without much typing (with a keyword or a few keywords)

NEW! Extra functionality:

-   **describe** – describe a given Eurostat dataset on the basis of
    information from Metabase
-   **compare** – compare specific Eurostat datasets on the basis of
    information from Metabase

## Installation

``` r
devtools::install_github('alekrutkowski/eurodata') # package 'devtools' needs to be installed
```

## Functionality demo

``` r
library(eurodata)
```

    ## 
    ## Attaching package: 'eurodata'

    ## The following object is masked from 'package:utils':
    ## 
    ##     find

### Imports

``` r
x <- importData('nama_10_a10')  # actual dataset
str(x)
```

    ## Classes 'EurostatDataset' and 'data.frame':  1164237 obs. of  7 variables:
    ##  $ unit   : Factor w/ 28 levels "CLV_I05","CLV_I10",..: 5 5 5 5 5 5 5 5 5 5 ...
    ##  $ nace_r2: Factor w/ 12 levels "A","B-E","C",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ na_item: Factor w/ 4 levels "B1G","D1","D11",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ geo    : Factor w/ 45 levels "AL","AT","BA",..: 2 3 4 5 6 7 8 9 10 11 ...
    ##  $ time   : Factor w/ 47 levels "2021","2020",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ value_ : num  4063 865 2577 1590 2634 ...
    ##  $ flags_ : chr  "" "" " p" " p" ...
    ##  - attr(*, "EurostatDatasetCode")= chr "nama_10_a10"
    ##  - attr(*, "DownloadTime")= POSIXct[1:1], format: "2022-05-19 10:18:31"

``` r
head(x,10)
```

    ##          unit nace_r2 na_item geo time   value_ flags_
    ## 1  CLV05_MEUR       A     B1G  AT 2021   4063.0       
    ## 2  CLV05_MEUR       A     B1G  BA 2021    865.1       
    ## 3  CLV05_MEUR       A     B1G  BE 2021   2576.6      p
    ## 4  CLV05_MEUR       A     B1G  BG 2021   1590.4      p
    ## 5  CLV05_MEUR       A     B1G  CH 2021   2634.5       
    ## 6  CLV05_MEUR       A     B1G  CY 2021    289.4      p
    ## 7  CLV05_MEUR       A     B1G  CZ 2021   2561.0       
    ## 8  CLV05_MEUR       A     B1G  DE 2021  18520.3      p
    ## 9  CLV05_MEUR       A     B1G  DK 2021   2977.6       
    ## 10 CLV05_MEUR       A     B1G  EA 2021 158523.1

``` r
y <- importDataList()  # metadata
colnames(y)
```

    ##  [1] "Data subgroup, level 0"      "Data subgroup, level 1"      "Data subgroup, level 2"     
    ##  [4] "Data subgroup, level 3"      "Data subgroup, level 4"      "Data subgroup, level 5"     
    ##  [7] "Data subgroup, level 6"      "Data subgroup, level 7"      "Dataset name"               
    ## [10] "Code"                        "Type"                        "Last update of data"        
    ## [13] "Last table structure change" "Data start"                  "Data end"                   
    ## [16] "Link"

``` r
str(y[y$Code=='nama_10_a10',])  # metadata on x
```

    ## Classes 'EurostatDataList' and 'data.frame': 1 obs. of  16 variables:
    ##  $ Data subgroup, level 0     : chr "Database by themes"
    ##  $ Data subgroup, level 1     : chr "Economy and finance"
    ##  $ Data subgroup, level 2     : chr "National accounts (ESA 2010)"
    ##  $ Data subgroup, level 3     : chr "Annual national accounts"
    ##  $ Data subgroup, level 4     : chr "Basic breakdowns of main GDP aggregates and employment (by industry and by assets)"
    ##  $ Data subgroup, level 5     : chr ""
    ##  $ Data subgroup, level 6     : chr ""
    ##  $ Data subgroup, level 7     : chr ""
    ##  $ Dataset name               : chr "Gross value added and income by A*10 industry breakdowns"
    ##  $ Code                       : chr "nama_10_a10"
    ##  $ Type                       : chr "dataset"
    ##  $ Last update of data        : chr "2022-05-16"
    ##  $ Last table structure change: chr "2022-03-22"
    ##  $ Data start                 : chr "1975"
    ##  $ Data end                   : chr "2021"
    ##  $ Link                       : chr "http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=nama_10_a10&lang=en"

``` r
z <- importLabels('geo')
head(z,10)
```

    ##               geo
    ## 1             EUR
    ## 2              EU
    ## 3            EU_V
    ## 4  EU27_2020_EFTA
    ## 5  EU27_2020_IS_K
    ## 6       EU27_2020
    ## 7       EU28_EFTA
    ## 8       EU28_IS_K
    ## 9            EU28
    ## 10      EU27_2007
    ##                                                                                                          geo_labels
    ## 1                                                                                                            Europe
    ## 2  European Union (EU6-1958, EU9-1973, EU10-1981, EU12-1986, EU15-1995, EU25-2004, EU27-2007, EU28-2013, EU27-2020)
    ## 3                                                      European Union (aggregate changing according to the context)
    ## 4                    European Union - 27 countries (from 2020) and European Free Trade Association (EFTA) countries
    ## 5                                    European Union - 27 countries (from 2020) and Iceland under the Kyoto Protocol
    ## 6                                                                         European Union - 27 countries (from 2020)
    ## 7                    European Union - 28 countries (2013-2020) and European Free Trade Association (EFTA) countries
    ## 8                                    European Union - 28 countries (2013-2020) and Iceland under the Kyoto Protocol
    ## 9                                                                         European Union - 28 countries (2013-2020)
    ## 10                                                                        European Union - 27 countries (2007-2013)

### Search

``` r
# Free-style text search based on the parts of words in the dataset names
find(gdp,main,selected,-quarterly)
```

    ## 2022-05-19 10:18:55
    ## 0 dataset(s)/table(s) found.
    ## Keywords: gdp, main, selected, -quarterly
    ## 
    ## End.

``` r
# Search based on the parts of the dataset codes
find(bop, its)
```

    ## 2022-05-19 10:18:58
    ## 7 dataset(s)/table(s) found.
    ## Keywords: bop, its
    ## 
    ##  Database by themes >>
    ##  Economy and finance >>
    ##  Balance of payments - International transactions >>
    ##  International trade in services, geographical breakdown - Historical data
    ## 
    ## No : 1
    ## Dataset name : International trade in services (2004-2013)
    ## Code : bop_its_det
    ## Type : dataset
    ## Last update of data : 2014-05-16
    ## Last table structure change : 2021-02-08
    ## Data start : 2004
    ## Data end : 2013
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_det&lang=en
    ## 
    ## No : 2
    ## Dataset name : International trade in services (1985-2003)
    ## Code : bop_its_deth
    ## Type : dataset
    ## Last update of data : 2014-05-16
    ## Last table structure change : 2021-02-08
    ## Data start : 1985
    ## Data end : 2003
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_deth&lang=en
    ## 
    ## No : 3
    ## Dataset name : International trade in services - market integration indicators (1992-2013)
    ## Code : bop_its_str
    ## Type : dataset
    ## Last update of data : 2014-05-28
    ## Last table structure change : 2021-02-08
    ## Data start : 1992
    ## Data end : 2013
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_str&lang=en
    ## 
    ## No : 4
    ## Dataset name : Total services, detailed geographical breakdown by EU Member States (2002-2012)
    ## Code : bop_its_tot
    ## Type : dataset
    ## Last update of data : 2014-05-27
    ## Last table structure change : 2021-02-08
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
    ## Last update of data : 2022-05-10
    ## Last table structure change : 2022-05-10
    ## Data start : 2010
    ## Data end : 2021
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_det&lang=en
    ## 
    ## No : 6
    ## Dataset name : Total services, detailed geographical breakdown by EU Member States (since 2010) (BPM6)
    ## Code : bop_its6_tot
    ## Type : dataset
    ## Last update of data : 2022-01-28
    ## Last table structure change : 2022-01-28
    ## Data start : 2010
    ## Data end : 2020
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_tot&lang=en
    ## 
    ##  Database by themes >>
    ##  Population and social conditions >>
    ##  Culture >>
    ##  International trade in cultural services
    ## 
    ## No : 7
    ## Dataset name : International trade in services (since 2010) (BPM6)
    ## Code : bop_its6_det
    ## Type : dataset
    ## Last update of data : 2022-05-10
    ## Last table structure change : 2022-05-10
    ## Data start : 2010
    ## Data end : 2021
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_det&lang=en
    ## 
    ## 2022-05-19 10:18:58
    ## 7 dataset(s)/table(s) found.
    ## Keywords: bop, its
    ## 
    ## End.

``` r
find(bop,-ybk,its)
```

    ## 2022-05-19 10:19:01
    ## 7 dataset(s)/table(s) found.
    ## Keywords: bop, -ybk, its
    ## 
    ##  Database by themes >>
    ##  Economy and finance >>
    ##  Balance of payments - International transactions >>
    ##  International trade in services, geographical breakdown - Historical data
    ## 
    ## No : 1
    ## Dataset name : International trade in services (2004-2013)
    ## Code : bop_its_det
    ## Type : dataset
    ## Last update of data : 2014-05-16
    ## Last table structure change : 2021-02-08
    ## Data start : 2004
    ## Data end : 2013
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_det&lang=en
    ## 
    ## No : 2
    ## Dataset name : International trade in services (1985-2003)
    ## Code : bop_its_deth
    ## Type : dataset
    ## Last update of data : 2014-05-16
    ## Last table structure change : 2021-02-08
    ## Data start : 1985
    ## Data end : 2003
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_deth&lang=en
    ## 
    ## No : 3
    ## Dataset name : International trade in services - market integration indicators (1992-2013)
    ## Code : bop_its_str
    ## Type : dataset
    ## Last update of data : 2014-05-28
    ## Last table structure change : 2021-02-08
    ## Data start : 1992
    ## Data end : 2013
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_str&lang=en
    ## 
    ## No : 4
    ## Dataset name : Total services, detailed geographical breakdown by EU Member States (2002-2012)
    ## Code : bop_its_tot
    ## Type : dataset
    ## Last update of data : 2014-05-27
    ## Last table structure change : 2021-02-08
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
    ## Last update of data : 2022-05-10
    ## Last table structure change : 2022-05-10
    ## Data start : 2010
    ## Data end : 2021
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_det&lang=en
    ## 
    ## No : 6
    ## Dataset name : Total services, detailed geographical breakdown by EU Member States (since 2010) (BPM6)
    ## Code : bop_its6_tot
    ## Type : dataset
    ## Last update of data : 2022-01-28
    ## Last table structure change : 2022-01-28
    ## Data start : 2010
    ## Data end : 2020
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_tot&lang=en
    ## 
    ##  Database by themes >>
    ##  Population and social conditions >>
    ##  Culture >>
    ##  International trade in cultural services
    ## 
    ## No : 7
    ## Dataset name : International trade in services (since 2010) (BPM6)
    ## Code : bop_its6_det
    ## Type : dataset
    ## Last update of data : 2022-05-10
    ## Last table structure change : 2022-05-10
    ## Data start : 2010
    ## Data end : 2021
    ## Link : http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_det&lang=en
    ## 
    ## 2022-05-19 10:19:01
    ## 7 dataset(s)/table(s) found.
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
<tt>■ Generated on: 2022-05-19 10:19:04 ■ Number of datasets/tables
found: 0 ■ Search criteria: grepl(“GDP”, `Dataset name`) & grepl(“main”,
`Dataset name`) &grepl(“selected”, `Dataset name`) & !grepl(“quarterly”,
`Dataset name`)</tt>
</p>
<!-- html table generated in R 4.2.0 by xtable 1.8-4 package --><!-- Thu May 19 10:19:10 2022 -->
<table class="gridtable">
<tr>
<th>
Nothing found
</th>
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
<tt>■ Generated on: 2022-05-19 10:19:10 ■ Number of datasets/tables
found: 7 ■ Search criteria: grepl(“bop”, Code) & grepl(“its”, Code)</tt>
</p>
<!-- html table generated in R 4.2.0 by xtable 1.8-4 package --><!-- Thu May 19 10:19:16 2022 -->
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
International trade in services, geographical breakdown - Historical
data
</td>
<td>
<b>International trade in services (2004-2013)</b>
</td>
<td>
<tt><b>bop_its_det</b></tt>
</td>
<td>
dataset
</td>
<td>
2014-05-16
</td>
<td>
2021-02-08
</td>
<td>
2004
</td>
<td>
2013
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_det&lang=en" target="_blank">click
here</a>
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
International trade in services, geographical breakdown - Historical
data
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
2014-05-16
</td>
<td>
2021-02-08
</td>
<td>
1985
</td>
<td>
2003
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_deth&lang=en" target="_blank">click
here</a>
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
International trade in services, geographical breakdown - Historical
data
</td>
<td>
<b>International trade in services - market integration indicators
(1992-2013)</b>
</td>
<td>
<tt><b>bop_its_str</b></tt>
</td>
<td>
dataset
</td>
<td>
2014-05-28
</td>
<td>
2021-02-08
</td>
<td>
1992
</td>
<td>
2013
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_str&lang=en" target="_blank">click
here</a>
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
International trade in services, geographical breakdown - Historical
data
</td>
<td>
<b>Total services, detailed geographical breakdown by EU Member States
(2002-2012)</b>
</td>
<td>
<tt><b>bop_its_tot</b></tt>
</td>
<td>
dataset
</td>
<td>
2014-05-27
</td>
<td>
2021-02-08
</td>
<td>
2002
</td>
<td>
2012
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_tot&lang=en" target="_blank">click
here</a>
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
2022-05-10
</td>
<td>
2022-05-10
</td>
<td>
2010
</td>
<td>
2021
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_det&lang=en" target="_blank">click
here</a>
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
<b>Total services, detailed geographical breakdown by EU Member States
(since 2010) (BPM6)</b>
</td>
<td>
<tt><b>bop_its6_tot</b></tt>
</td>
<td>
dataset
</td>
<td>
2022-01-28
</td>
<td>
2022-01-28
</td>
<td>
2010
</td>
<td>
2020
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_tot&lang=en" target="_blank">click
here</a>
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
Population and social conditions
</td>
<td>
Culture
</td>
<td>
International trade in cultural services
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
2022-05-10
</td>
<td>
2022-05-10
</td>
<td>
2010
</td>
<td>
2021
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_det&lang=en" target="_blank">click
here</a>
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
<tt>■ Generated on: 2022-05-19 10:19:33 ■ Number of datasets/tables
found: 6 ■ Search criteria: those including data on firms with fewer
than 10 employees and NACE Rev.2 disaggregation</tt>
</p>
<!-- html table generated in R 4.2.0 by xtable 1.8-4 package --><!-- Thu May 19 10:19:33 2022 -->
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
Labour costs survey 2008, 2012 and 2016 - NACE Rev. 2 activity
</td>
<td>
<b>Labour cost, wages and salaries, direct remuneration (excluding
apprentices) by NACE Rev. 2 activity ) - LCS surveys 2008, 2012 and
2016</b>
</td>
<td>
<tt><b>lc_ncost_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
2020-03-24
</td>
<td>
2021-02-08
</td>
<td>
2008
</td>
<td>
2016
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=lc_ncost_r2&lang=en" target="_blank">click
here</a>
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
Labour costs survey 2008, 2012 and 2016 - NACE Rev. 2 activity
</td>
<td>
<b>Structure of labour cost by NACE Rev. 2 activity - % of total cost,
LCS surveys 2008, 2012 and 2016</b>
</td>
<td>
<tt><b>lc_nstruc_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
2020-03-24
</td>
<td>
2021-02-08
</td>
<td>
2008
</td>
<td>
2016
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=lc_nstruc_r2&lang=en" target="_blank">click
here</a>
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
Labour costs survey 2008, 2012 and 2016 - NACE Rev. 2 activity
</td>
<td>
<b>Number of employees, hours worked and paid, by working time and NACE
Rev. 2 activity - LCS surveys 2008, 2012 and 2016</b>
</td>
<td>
<tt><b>lc_nnum1_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
2020-03-24
</td>
<td>
2021-02-08
</td>
<td>
2008
</td>
<td>
2016
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=lc_nnum1_r2&lang=en" target="_blank">click
here</a>
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
Labour costs survey 2008, 2012 and 2016 - NACE Rev. 2 activity
</td>
<td>
<b>Average hours worked and paid per employee, by working time and NACE
Rev. 2 activity - LCS surveys 2008, 2012 and 2016</b>
</td>
<td>
<tt><b>lc_nnum2_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
2020-03-24
</td>
<td>
2021-02-08
</td>
<td>
2008
</td>
<td>
2016
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=lc_nnum2_r2&lang=en" target="_blank">click
here</a>
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
Labour costs survey 2008, 2012 and 2016 - NACE Rev. 2 activity
</td>
<td>
<b>Number of statistical units selected for the survey, by NACE Rev. 2
activity - LCS surveys 2008, 2012 and 2016</b>
</td>
<td>
<tt><b>lc_nstu_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
2020-03-24
</td>
<td>
2021-02-08
</td>
<td>
2008
</td>
<td>
2016
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=lc_nstu_r2&lang=en" target="_blank">click
here</a>
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
International trade in goods
</td>
<td>
International trade in goods - trade by enterprise characteristics (TEC)
</td>
<td>
</td>
<td>
</td>
<td>
</td>
<td>
<b>Trade by NACE Rev. 2 activity and enterprise size class</b>
</td>
<td>
<tt><b>ext_tec01</b></tt>
</td>
<td>
dataset
</td>
<td>
2022-05-05
</td>
<td>
2022-02-15
</td>
<td>
2012
</td>
<td>
2020
</td>
<td>
<a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=ext_tec01&lang=en" target="_blank">click
here</a>
</td>
</tr>
</table>
</body>
</html>

## Extras

``` r
describe('nama_10_gdp')
```

    ## Downloading Eurostat Metabase

    ## Uncompressing (extracting)

    ## Importing (reading into memory)

    ## Verifying the code

    ## Downloading Eurostat labels for geo

    ## Verifying the code

    ## Downloading Eurostat labels for na_item

    ## Verifying the code

    ## Downloading Eurostat labels for time

    ## Verifying the code

    ## Downloading Eurostat labels for unit

    ##      Dim_name                  Dim_name_label        Dim_val
    ##   1:      geo Geopolitical entity (reporting)             AL
    ##   2:      geo Geopolitical entity (reporting)             AT
    ##   3:      geo Geopolitical entity (reporting)             BA
    ##   4:      geo Geopolitical entity (reporting)             BE
    ##   5:      geo Geopolitical entity (reporting)             BG
    ##  ---                                                        
    ## 154:     unit                 Unit of measure       PD15_NAC
    ## 155:     unit                 Unit of measure PD_PCH_PRE_EUR
    ## 156:     unit                 Unit of measure PD_PCH_PRE_NAC
    ## 157:     unit                 Unit of measure       PYP_MEUR
    ## 158:     unit                 Unit of measure       PYP_MNAC
    ##                                                                                 Dim_val_label nama_10_gdp
    ##   1:                                                                                  Albania        TRUE
    ##   2:                                                                                  Austria        TRUE
    ##   3:                                                                   Bosnia and Herzegovina        TRUE
    ##   4:                                                                                  Belgium        TRUE
    ##   5:                                                                                 Bulgaria        TRUE
    ##  ---                                                                                                     
    ## 154:                             Price index (implicit deflator), 2015=100, national currency        TRUE
    ## 155:              Price index (implicit deflator), percentage change on previous period, euro        TRUE
    ## 156: Price index (implicit deflator), percentage change on previous period, national currency        TRUE
    ## 157:                                                       Previous year prices, million euro        TRUE
    ## 158:                                 Previous year prices, million units of national currency        TRUE

``` r
describe('nama_10_gdp', wide=TRUE)
```

    ##    Dim_name                         Dim_name_label nama_10_gdp
    ## 1:      geo        Geopolitical entity (reporting)        TRUE
    ## 2:  na_item National accounts indicator (ESA 2010)        TRUE
    ## 3:     time                         Period of time        TRUE
    ## 4:     unit                        Unit of measure        TRUE
    ##                                                                                                                                                                                                                                                                                                                               Dim_values
    ## 1:                                                                                                                                     EU27_2020, EU28, EU15, EA, EA19, EA12, BE, BG, CZ, DK, DE, EE, IE, EL, ES, FR, HR, IT, CY, LV, LT, LU, HU, MT, NL, AT, PL, PT, RO, SI, SK, FI, SE, IS, LI, NO, CH, UK, ME, MK, AL, RS, TR, BA, XK
    ## 2:                                                                                              B1GQ, B1G, P3, P3_S13, P31_S13, P32_S13, P31_S14_S15, P31_S14, P31_S15, P41, P5G, P51G, P52_P53, P52, P53, P6, P61, P62, P7, P71, P72, B11, B111, B112, D1, D11, D12, B2A3G, D2X3, D2, D3, D21X31, D21, D31, YA1, YA0, YA2, P3_P5, P3_P6
    ## 3:                                              2021, 2020, 2019, 2018, 2017, 2016, 2015, 2014, 2013, 2012, 2011, 2010, 2009, 2008, 2007, 2006, 2005, 2004, 2003, 2002, 2001, 2000, 1999, 1998, 1997, 1996, 1995, 1994, 1993, 1992, 1991, 1990, 1989, 1988, 1987, 1986, 1985, 1984, 1983, 1982, 1981, 1980, 1979, 1978, 1977, 1976, 1975
    ## 4: CLV_I15, CLV_I10, CLV_I05, PC_GDP, PC_EU27_2020_MEUR_CP, PC_EU27_2020_MPPS_CP, CP_MEUR, CP_MNAC, CP_MPPS_EU27_2020, CLV15_MEUR, CLV10_MEUR, CLV05_MEUR, CLV15_MNAC, CLV10_MNAC, CLV05_MNAC, CLV_PCH_PRE, PYP_MEUR, PYP_MNAC, CON_PPCH_PRE, PD15_EUR, PD10_EUR, PD05_EUR, PD15_NAC, PD10_NAC, PD05_NAC, PD_PCH_PRE_EUR, PD_PCH_PRE_NAC

``` r
compare('nama_10_gdp', 'nama_10_a64')
```

    ##      Dim_name        Dim_val nama_10_gdp
    ##   1:      geo      EU27_2020        TRUE
    ##   2:      geo           EU28        TRUE
    ##   3:      geo           EU15        TRUE
    ##   4:      geo             EA        TRUE
    ##   5:      geo           EA19        TRUE
    ##  ---                                    
    ## 154:     unit       PD15_NAC        TRUE
    ## 155:     unit       PD10_NAC        TRUE
    ## 156:     unit       PD05_NAC        TRUE
    ## 157:     unit PD_PCH_PRE_EUR        TRUE
    ## 158:     unit PD_PCH_PRE_NAC        TRUE
    ##      Dim_name        Dim_val nama_10_a64
    ##   1:      geo      EU27_2020        TRUE
    ##   2:      geo           EU28        TRUE
    ##   3:      geo           EU15        TRUE
    ##   4:      geo             EA        TRUE
    ##   5:      geo           EA19        TRUE
    ##  ---                                    
    ## 206:     unit       PD10_EUR        TRUE
    ## 207:     unit       PD15_NAC        TRUE
    ## 208:     unit       PD10_NAC        TRUE
    ## 209:     unit PD_PCH_PRE_EUR        TRUE
    ## 210:     unit PD_PCH_PRE_NAC        TRUE

    ## Verifying the code

    ## Downloading Eurostat labels for nace_r2

    ##      Dim_name                  Dim_name_label        Dim_val
    ##   1:      geo Geopolitical entity (reporting)             AL
    ##   2:      geo Geopolitical entity (reporting)             AT
    ##   3:      geo Geopolitical entity (reporting)             BA
    ##   4:      geo Geopolitical entity (reporting)             BE
    ##   5:      geo Geopolitical entity (reporting)             BG
    ##  ---                                                        
    ## 251:     unit                 Unit of measure       PD15_NAC
    ## 252:     unit                 Unit of measure PD_PCH_PRE_EUR
    ## 253:     unit                 Unit of measure PD_PCH_PRE_NAC
    ## 254:     unit                 Unit of measure       PYP_MEUR
    ## 255:     unit                 Unit of measure       PYP_MNAC
    ##                                                                                 Dim_val_label nama_10_gdp nama_10_a64
    ##   1:                                                                                  Albania        TRUE        TRUE
    ##   2:                                                                                  Austria        TRUE        TRUE
    ##   3:                                                                   Bosnia and Herzegovina        TRUE        TRUE
    ##   4:                                                                                  Belgium        TRUE        TRUE
    ##   5:                                                                                 Bulgaria        TRUE        TRUE
    ##  ---                                                                                                                 
    ## 251:                             Price index (implicit deflator), 2015=100, national currency        TRUE        TRUE
    ## 252:              Price index (implicit deflator), percentage change on previous period, euro        TRUE        TRUE
    ## 253: Price index (implicit deflator), percentage change on previous period, national currency        TRUE        TRUE
    ## 254:                                                       Previous year prices, million euro        TRUE        TRUE
    ## 255:                                 Previous year prices, million units of national currency        TRUE        TRUE
