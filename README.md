eurodata – R package for fast and easy Eurostat data import and search
================
Aleksander Rutkowski

#### *NEW (January 2023):*

**_Use [eurodata_codegen](https://github.com/alekrutkowski/eurodata_codegen), a point-and-click app
for rapid and easy generation of richly-commented R code, to import a Eurostat dataset or it's subset
(based on the `eurodata::importData()` function)._**

The package is fully compatible with the new [Eurostat’s API SDMX
2.1](https://wikis.ec.europa.eu/display/EUROSTATHELP/Transition+-+from+Eurostat+Bulk+Download+to+API)
and no longer relies on the old Eurostat’s Bulk Download Facility.

The core API of the `eurodata` package contains just 6 functions – 4 for
data or metadata imports and 2 for search:

Import functionality:

-   **importData** – fast thanks to
    [data.table](https://CRAN.R-project.org/package=data.table)::[fread](https://www.rdocumentation.org/packages/data.table/functions/fread/)
-   **importDataLabels** – as above
-   **importMetabase** – as above
-   **importDataList** – reflects the hierarchical structure of the
    Eurostat tree of datasets – fast transformation of the raw [Table of
    Contents
    file](https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?file=table_of_contents_en.txt)
    is based on a C++ code snippet compiled via
    [Rcpp](https://CRAN.R-project.org/package=Rcpp)

Search functionality:

-   **browseDataList** – based on importDataList, shows an HTML table
    (generated with
    [xtable](https://CRAN.R-project.org/package=xtable)::[xtable](https://www.rdocumentation.org/packages/xtable/functions/xtable/))
    in a browser with a list of the found datasets
-   **find** – based on importDataList, shows a textual report on the
    found datasets – a \`\`quick-n-dirty’’ way to find a Eurostat
    dataset without much typing (with a keyword or a few keywords)

#### NEW (December 2022):

Parameter `filters` in `importData()` allows to download only the
selected values of dimensions, instead of downloading the full dataset.
See the example close to the end below.

#### NEW (August 2022) Extra functionality:

-   **describe** – describe a given Eurostat dataset on the basis of
    information from Metabase
-   **compare** – compare specific Eurostat datasets on the basis of
    information from Metabase

See the usage example at the very end below.

## Installation

``` r
install.packages('eurodata') # from CRAN
# or
remotes::install_github('alekrutkowski/eurodata') # package 'remotes' needs to be installed
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

    ## Classes 'EurostatDataset' and 'data.frame':  1164237 obs. of  8 variables:
    ##  $ freq       : Factor w/ 1 level "A": 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ unit       : Factor w/ 28 levels "CLV_I05","CLV_I10",..: 5 5 5 5 5 5 5 5 5 5 ...
    ##  $ nace_r2    : Factor w/ 12 levels "A","B-E","C",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ na_item    : Factor w/ 4 levels "B1G","D1","D11",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ geo        : Factor w/ 45 levels "AL","AT","BA",..: 2 3 4 5 6 7 8 9 10 11 ...
    ##  $ TIME_PERIOD: Factor w/ 47 levels "1975","1976",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ value_     : num  NA NA NA NA NA ...
    ##  $ flags_     : chr  ":" ":" ":" ":" ...
    ##  - attr(*, "EurostatDatasetCode")= chr "nama_10_a10"
    ##  - attr(*, "DownloadTime")= POSIXct[1:1], format: "2022-12-14 14:52:11"

``` r
head(x,10)
```

    ##    freq       unit nace_r2 na_item geo TIME_PERIOD value_ flags_
    ## 1     A CLV05_MEUR       A     B1G  AT        1975     NA      :
    ## 2     A CLV05_MEUR       A     B1G  BA        1975     NA      :
    ## 3     A CLV05_MEUR       A     B1G  BE        1975     NA      :
    ## 4     A CLV05_MEUR       A     B1G  BG        1975     NA      :
    ## 5     A CLV05_MEUR       A     B1G  CH        1975     NA      :
    ## 6     A CLV05_MEUR       A     B1G  CY        1975     NA      :
    ## 7     A CLV05_MEUR       A     B1G  CZ        1975     NA      :
    ## 8     A CLV05_MEUR       A     B1G  DE        1975     NA      :
    ## 9     A CLV05_MEUR       A     B1G  DK        1975 1031.4       
    ## 10    A CLV05_MEUR       A     B1G  EA        1975     NA      :

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
    ##  $ Last update of data        : chr "2022-12-08"
    ##  $ Last table structure change: chr "2022-03-22"
    ##  $ Data start                 : chr "1975"
    ##  $ Data end                   : chr "2021"
    ##  $ Link                       : chr "https://ec.europa.eu/eurostat/databrowser/view/nama_10_a10/default/table?lang=en"

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
find(gdp,main,international,-quarterly)
```

    ## 2022-12-14 14:52:22
    ## 2 dataset(s)/table(s) found.
    ## Keywords: gdp, main, international, -quarterly
    ## 
    ##  Database by themes >>
    ##  Economy and finance >>
    ##  National accounts (ESA 2010) >>
    ##  National accounts - international data cooperation >>
    ##  Annual national accounts- international data cooperation
    ## 
    ## No : 1
    ## Dataset name : GDP and main aggregates- international data cooperation annual data
    ## Code : naida_10_gdp
    ## Type : dataset
    ## Last update of data : 2022-12-07
    ## Last table structure change : 2022-01-14
    ## Data start : 1975
    ## Data end : 2021
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/naida_10_gdp/default/table?lang=en
    ## 
    ##  Database by themes >>
    ##  Economy and finance >>
    ##  Balance of payments - International transactions (BPM6) >>
    ##  Balance of payments statistics and international investment positions (BPM6)
    ## 
    ## No : 2
    ## Dataset name : Main Balance of Payments and International Investment Position items as share of GDP (BPM6)
    ## Code : bop_gdp6_q
    ## Type : dataset
    ## Last update of data : 2022-10-20
    ## Last table structure change : 2022-10-05
    ## Data start : 1991
    ## Data end : 2022Q2
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_gdp6_q/default/table?lang=en
    ## 
    ## 2022-12-14 14:52:22
    ## 2 dataset(s)/table(s) found.
    ## Keywords: gdp, main, international, -quarterly
    ## 
    ## End.

``` r
# Search based on the parts of the dataset codes
find(bop, its)
```

    ## 2022-12-14 14:52:23
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
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its_det/default/table?lang=en
    ## 
    ## No : 2
    ## Dataset name : International trade in services (1985-2003)
    ## Code : bop_its_deth
    ## Type : dataset
    ## Last update of data : 2014-05-16
    ## Last table structure change : 2021-02-08
    ## Data start : 1985
    ## Data end : 2003
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its_deth/default/table?lang=en
    ## 
    ## No : 3
    ## Dataset name : International trade in services - market integration indicators (1992-2013)
    ## Code : bop_its_str
    ## Type : dataset
    ## Last update of data : 2014-05-28
    ## Last table structure change : 2021-02-08
    ## Data start : 1992
    ## Data end : 2013
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its_str/default/table?lang=en
    ## 
    ## No : 4
    ## Dataset name : Total services, detailed geographical breakdown by EU Member States (2002-2012)
    ## Code : bop_its_tot
    ## Type : dataset
    ## Last update of data : 2014-05-27
    ## Last table structure change : 2021-02-08
    ## Data start : 2002
    ## Data end : 2012
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its_tot/default/table?lang=en
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
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its6_det/default/table?lang=en
    ## 
    ## No : 6
    ## Dataset name : Total services, detailed geographical breakdown by EU Member States (since 2010) (BPM6)
    ## Code : bop_its6_tot
    ## Type : dataset
    ## Last update of data : 2022-01-28
    ## Last table structure change : 2022-01-28
    ## Data start : 2010
    ## Data end : 2020
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its6_tot/default/table?lang=en
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
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its6_det/default/table?lang=en
    ## 
    ## 2022-12-14 14:52:23
    ## 7 dataset(s)/table(s) found.
    ## Keywords: bop, its
    ## 
    ## End.

``` r
find(bop,-ybk,its)
```

    ## 2022-12-14 14:52:24
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
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its_det/default/table?lang=en
    ## 
    ## No : 2
    ## Dataset name : International trade in services (1985-2003)
    ## Code : bop_its_deth
    ## Type : dataset
    ## Last update of data : 2014-05-16
    ## Last table structure change : 2021-02-08
    ## Data start : 1985
    ## Data end : 2003
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its_deth/default/table?lang=en
    ## 
    ## No : 3
    ## Dataset name : International trade in services - market integration indicators (1992-2013)
    ## Code : bop_its_str
    ## Type : dataset
    ## Last update of data : 2014-05-28
    ## Last table structure change : 2021-02-08
    ## Data start : 1992
    ## Data end : 2013
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its_str/default/table?lang=en
    ## 
    ## No : 4
    ## Dataset name : Total services, detailed geographical breakdown by EU Member States (2002-2012)
    ## Code : bop_its_tot
    ## Type : dataset
    ## Last update of data : 2014-05-27
    ## Last table structure change : 2021-02-08
    ## Data start : 2002
    ## Data end : 2012
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its_tot/default/table?lang=en
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
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its6_det/default/table?lang=en
    ## 
    ## No : 6
    ## Dataset name : Total services, detailed geographical breakdown by EU Member States (since 2010) (BPM6)
    ## Code : bop_its6_tot
    ## Type : dataset
    ## Last update of data : 2022-01-28
    ## Last table structure change : 2022-01-28
    ## Data start : 2010
    ## Data end : 2020
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its6_tot/default/table?lang=en
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
    ## Link : https://ec.europa.eu/eurostat/databrowser/view/bop_its6_det/default/table?lang=en
    ## 
    ## 2022-12-14 14:52:24
    ## 7 dataset(s)/table(s) found.
    ## Keywords: bop, -ybk, its
    ## 
    ## End.

``` r
browseDataList(grepl('GDP',`Dataset name`) &
                   grepl('main',`Dataset name`) &
                   grepl('international',`Dataset name`) &
                   !grepl('quarterly',`Dataset name`))
```

<html>
<body>
<p>
<tt>■ Generated on: 2022-12-14 14:52:25 ■ Number of datasets/tables
found: 1 ■ Search criteria: grepl(“GDP”, `Dataset name`) & grepl(“main”,
`Dataset name`) &grepl(“international”, `Dataset name`) &
!grepl(“quarterly”,`Dataset name`)</tt>
</p>
<!-- html table generated in R 4.1.3 by xtable 1.8-4 package --><!-- Wed Dec 14 14:52:26 2022 -->
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
Annual national accounts- international data cooperation
</td>
<td>
<b>GDP and main aggregates- international data cooperation annual
data</b>
</td>
<td>
<tt><b>naida\_10\_gdp</b></tt>
</td>
<td>
dataset
</td>
<td>
2022-12-07
</td>
<td>
2022-01-14
</td>
<td>
1975
</td>
<td>
2021
</td>
<td>
<a href="https://ec.europa.eu/eurostat/databrowser/view/naida_10_gdp/default/table?lang=en" target="_blank">click
here</a>
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
<tt>■ Generated on: 2022-12-14 14:52:26 ■ Number of datasets/tables
found: 7 ■ Search criteria: grepl(“bop”, Code) & grepl(“its”, Code)</tt>
</p>
<!-- html table generated in R 4.1.3 by xtable 1.8-4 package --><!-- Wed Dec 14 14:52:26 2022 -->
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
<tt><b>bop\_its\_det</b></tt>
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
<a href="https://ec.europa.eu/eurostat/databrowser/view/bop_its_det/default/table?lang=en" target="_blank">click
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
<tt><b>bop\_its\_deth</b></tt>
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
<a href="https://ec.europa.eu/eurostat/databrowser/view/bop_its_deth/default/table?lang=en" target="_blank">click
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
<tt><b>bop\_its\_str</b></tt>
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
<a href="https://ec.europa.eu/eurostat/databrowser/view/bop_its_str/default/table?lang=en" target="_blank">click
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
<tt><b>bop\_its\_tot</b></tt>
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
<a href="https://ec.europa.eu/eurostat/databrowser/view/bop_its_tot/default/table?lang=en" target="_blank">click
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
<tt><b>bop\_its6\_det</b></tt>
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
<a href="https://ec.europa.eu/eurostat/databrowser/view/bop_its6_det/default/table?lang=en" target="_blank">click
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
<tt><b>bop\_its6\_tot</b></tt>
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
<a href="https://ec.europa.eu/eurostat/databrowser/view/bop_its6_tot/default/table?lang=en" target="_blank">click
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
<tt><b>bop\_its6\_det</b></tt>
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
<a href="https://ec.europa.eu/eurostat/databrowser/view/bop_its6_det/default/table?lang=en" target="_blank">click
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
<tt>■ Generated on: 2022-12-14 14:52:31 ■ Number of datasets/tables
found: 7 ■ Search criteria: those including data on firms with fewer
than 10 employees and NACE Rev.2 disaggregation</tt>
</p>
<!-- html table generated in R 4.1.3 by xtable 1.8-4 package --><!-- Wed Dec 14 14:52:31 2022 -->
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
Labour costs survey - NACE Rev. 2 activity
</td>
<td>
<b>Labour cost, wages and salaries, direct remuneration (excluding
apprentices) by NACE Rev. 2 activity</b>
</td>
<td>
<tt><b>lc\_ncost\_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
2022-12-08
</td>
<td>
2022-09-15
</td>
<td>
2008
</td>
<td>
2020
</td>
<td>
<a href="https://ec.europa.eu/eurostat/databrowser/view/lc_ncost_r2/default/table?lang=en" target="_blank">click
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
Labour costs survey - NACE Rev. 2 activity
</td>
<td>
<b>Structure of labour cost by NACE Rev. 2 activity - % of total
cost</b>
</td>
<td>
<tt><b>lc\_nstruc\_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
2022-12-08
</td>
<td>
2022-09-15
</td>
<td>
2008
</td>
<td>
2020
</td>
<td>
<a href="https://ec.europa.eu/eurostat/databrowser/view/lc_nstruc_r2/default/table?lang=en" target="_blank">click
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
Labour costs survey - NACE Rev. 2 activity
</td>
<td>
<b>Number of employees, hours worked and paid, by working time and NACE
Rev. 2 activity</b>
</td>
<td>
<tt><b>lc\_nnum1\_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
2022-12-08
</td>
<td>
2022-09-15
</td>
<td>
2008
</td>
<td>
2020
</td>
<td>
<a href="https://ec.europa.eu/eurostat/databrowser/view/lc_nnum1_r2/default/table?lang=en" target="_blank">click
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
Labour costs survey - NACE Rev. 2 activity
</td>
<td>
<b>Average hours worked and paid per employee, by working time and NACE
Rev. 2 activity</b>
</td>
<td>
<tt><b>lc\_nnum2\_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
2022-12-08
</td>
<td>
2022-09-15
</td>
<td>
2008
</td>
<td>
2020
</td>
<td>
<a href="https://ec.europa.eu/eurostat/databrowser/view/lc_nnum2_r2/default/table?lang=en" target="_blank">click
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
Labour costs survey - NACE Rev. 2 activity
</td>
<td>
<b>Number of statistical units selected for the survey, by NACE Rev. 2
activity</b>
</td>
<td>
<tt><b>lc\_nstu\_r2</b></tt>
</td>
<td>
dataset
</td>
<td>
2022-12-08
</td>
<td>
2022-09-15
</td>
<td>
2008
</td>
<td>
2020
</td>
<td>
<a href="https://ec.europa.eu/eurostat/databrowser/view/lc_nstu_r2/default/table?lang=en" target="_blank">click
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
International trade
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
<tt><b>ext\_tec01</b></tt>
</td>
<td>
dataset
</td>
<td>
2022-11-11
</td>
<td>
2022-11-07
</td>
<td>
2012
</td>
<td>
2020
</td>
<td>
<a href="https://ec.europa.eu/eurostat/databrowser/view/ext_tec01/default/table?lang=en" target="_blank">click
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
International trade
</td>
<td>
International trade in services
</td>
<td>
</td>
<td>
</td>
<td>
</td>
<td>
<b>Services trade by enterprise characteristics (STEC) by NACE Rev.2
activities and enterprise size class</b>
</td>
<td>
<tt><b>ext\_stec01</b></tt>
</td>
<td>
dataset
</td>
<td>
2022-08-15
</td>
<td>
</td>
<td>
2013
</td>
<td>
2019
</td>
<td>
<a href="https://ec.europa.eu/eurostat/databrowser/view/ext_stec01/default/table?lang=en" target="_blank">click
here</a>
</td>
</tr>
</table>
</body>
</html>

## New parameter `filters`

To reduce the download size and time if full dataset not needed, e.g.:

``` r
subset_of__bop_its6_det <-
    importData('bop_its6_det',
               # New -- download only subset of available data
               filters = list(geo=c('AT','BG'), # these two countries
                              TIME_PERIOD=2014:2020, # only that period
                              bop_item='SC')) # only "Services: Transport"
```

    ## Downloading Eurostat dataset bop_its6_det

    ## Importing (reading into memory)

``` r
str(subset_of__bop_its6_det)
```

    ## Classes 'EurostatDataset' and 'data.frame':  4368 obs. of  9 variables:
    ##  $ freq       : Factor w/ 1 level "A": 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ currency   : Factor w/ 1 level "MIO_EUR": 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ bop_item   : Factor w/ 1 level "SC": 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ stk_flow   : Factor w/ 3 levels "BAL","CRE","DEB": 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ partner    : Factor w/ 117 levels "ACP","ACP_AFR",..: 1 2 3 4 5 5 6 6 7 7 ...
    ##  $ geo        : Factor w/ 2 levels "AT","BG": 2 2 2 2 1 2 1 2 1 2 ...
    ##  $ TIME_PERIOD: Factor w/ 7 levels "2014","2015",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ value_     : num  -220.7 -110.7 -62.7 -47.3 -241 ...
    ##  $ flags_     : chr  "" "" "" "" ...
    ##  - attr(*, "EurostatDatasetCode")= chr "bop_its6_det"
    ##  - attr(*, "DownloadTime")= POSIXct[1:1], format: "2022-12-14 14:52:33"

## Extras

``` r
describe('nama_10_gdp')
```

    ## Downloading Eurostat Metabase

    ## Uncompressing (extracting)

    ## Importing (reading into memory)

    ## Downloading Eurostat labels for geo

    ## Downloading Eurostat labels for na_item

    ## Downloading Eurostat labels for time

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
