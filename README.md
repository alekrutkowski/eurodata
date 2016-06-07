# eurodata -- R package for fast and easy Eurostata data import and search
Aleksander Rutkowski  

<style type="text/css">
.main-container {
  max-width: 1280px;
}
</style>



The package relies on [Eurostat's Bulk Download Facility](http://ec.europa.eu/eurostat/data/bulkdownload).

The API contains just 5 functions -- 3 for data or metadata imports and 2 for search:

Import functionality:

- **importData** -- fast thanks to [data.table](https://cran.r-project.org/web/packages/data.table/index.html)::[fread](http://www.rdocumentation.org/packages/data.table/functions/fread)
- **importDataLabels** -- as above
- **importDataList** -- reflects the hierarchical structure of the Eurostat tree of datasets --
fast transformation of the raw [Table of Contents file](http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?file=table_of_contents_en.txt)
is based on a C++ code snipped compiled via [Rcpp](https://cran.r-project.org/web/packages/Rcpp/index.html)  

Search functionality:

- **browseDataList** -- based on importDataList, shows an HTML table
(generated with [xtable](https://cran.r-project.org/web/packages/xtable/index.html)::[xtable](http://www.rdocumentation.org/packages/xtable/functions/xtable)) in a browser with a list of the found datasets
- **find** -- based on importDataList, shows a textal report on the found datasets --
a ``quick-n-dirty'' way to find a Eurostat dataset witout much typing (with a keyword or a few keywords)

## Installation


```r
devtools::install_github('alekrutkowski/eurodata') # package 'devtools' needs to be installed
```

## Functionality demo


```r
library(eurodata)
```

```
## 
## Attaching package: 'eurodata'
## 
## The following object is masked from 'package:utils':
## 
##     find
```

### Imports




```r
x <- importData('nama_10_a10')  # actual dataset
```

```
## Downloading Eurostat dataset nama_10_a10
## Uncompressing (extracting)
## Verifying the code
## Importing (reading into memory)
## Splitting the column of identifiers
## Reshaping into long format (single value column)
## Separating values and flags
## Converting codes to factors
```

```r
str(x)
```

```
## Classes 'EurostatDataset' and 'data.frame':	794170 obs. of  7 variables:
##  $ unit   : Factor w/ 23 levels "CLV_I05","CLV_I10",..: 4 4 4 4 4 4 4 4 4 4 ...
##  $ nace_r2: Factor w/ 12 levels "A","B-E","C",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ na_item: Factor w/ 4 levels "B1G","D1","D11",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ geo    : Factor w/ 42 levels "AL","AT","BE",..: 2 3 4 5 6 7 8 9 10 11 ...
##  $ time   : Factor w/ 41 levels "2015","2014",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ value_ : num  3269 2506 1382 NA 294 ...
##  $ flags_ : chr  "" "" "" ":" ...
##  - attr(*, "EurostatDatasetCode")= chr "nama_10_a10"
##  - attr(*, "DownloadTime")= POSIXct, format: "2016-06-07 16:01:06"
```

```r
head(x,10)
```

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
```

```r
# Friendly error if a wrong data code (similar for importLabels):
tryCatch(importData('nama_10_a10_XXX'),
         error = function(e) cat(geterrmessage()))
```

```
## Downloading Eurostat dataset nama_10_a10_XXX
## Uncompressing (extracting)
## Verifying the code
```

```
## 
## Probably a wrong dataset code:  nama_10_a10_XXX
## Check if you can find  nama_10_a10_XXX.tsv.gz  at
## http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?dir=data&start=all
```

```r
y <- importDataList()  # matadata
colnames(y)
```

```
##  [1] "Data subgroup, level 0"      "Data subgroup, level 1"      "Data subgroup, level 2"     
##  [4] "Data subgroup, level 3"      "Data subgroup, level 4"      "Data subgroup, level 5"     
##  [7] "Data subgroup, level 6"      "Dataset name"                "Code"                       
## [10] "Type"                        "Last update of data"         "Last table structure change"
## [13] "Data start"                  "Data end"                    "Link"
```

```r
str(y[y$Code=='nama_10_a10',])  # matadata on x
```

```
## 'data.frame':	1 obs. of  15 variables:
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
##  $ Last update of data        : chr "07.06.2016"
##  $ Last table structure change: chr "14.01.2016"
##  $ Data start                 : chr "1975"
##  $ Data end                   : chr "2015"
##  $ Link                       : chr "http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=nama_10_a10&lang=en"
```

```r
z <- importLabels('geo')
```

```
## Verifying the code
## Downloading Eurostat labels for geo
```

```r
head(z,10)
```

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
```

### Search


```r
find(bop, its)
```

```
## 2016-06-07 16:01:12 
##  7 dataset(s)/table(s) found.
##  Keywords: bop, its 
##  
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
## 
##  2016-06-07 16:01:12 
##  7 dataset(s)/table(s) found.
##  Keywords: bop, its 
##  
## End.
```

```r
find(bop,-ybk,its)
```

```
## 2016-06-07 16:01:13 
##  6 dataset(s)/table(s) found.
##  Keywords: bop, -ybk, its 
##  
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
## 
##  2016-06-07 16:01:13 
##  6 dataset(s)/table(s) found.
##  Keywords: bop, -ybk, its 
##  
## End.
```


```r
browseDataList(grepl('bop',Code) & grepl('its',Code))
```

<!DOCTYPE html><html><head><style type="text/css">table.gridtable {font-family: verdana,arial,sans-serif;font-size:11px;color:#333333;border-width: 1px;border-color: #666666;border-collapse: collapse;}table.gridtable th {border-width: 1px;padding: 4px;border-style: solid;border-color: #666666;background-color: #dedede;}table.gridtable td {border-width: 1px;padding: 4px;border-style: solid;border-color: #666666;background-color: #ffffff;}</style></head><body> <p><tt>&#9632; Generated on:&nbsp;2016-06-07 16:01:14 &#9632; Number of datasets/tables found:&nbsp;7 &#9632; Search criteria:&nbsp;grepl("bop", Code) & grepl("its", Code)</tt></p> <!-- html table generated in R 3.2.3 by xtable 1.7-4 package --><!-- Tue Jun 07 16:01:14 2016 --><table class="gridtable"><tr> <th> Row </th> <th> Data subgroup, level 0 </th> <th> Data subgroup, level 1 </th> <th> Data subgroup, level 2 </th> <th> Data subgroup, level 3 </th> <th> Dataset name </th> <th> Code </th> <th> Type </th> <th> Last update of data </th> <th> Last table structure change </th> <th> Data start </th> <th> Data end </th> <th> Link </th></tr><tr> <td> 1 </td> <td> Database by themes </td> <td> Economy and finance </td> <td> Balance of payments - International transactions </td> <td> International trade in services, geographical breakdown </td> <td> <b>International trade in services (since 2004)</b> </td> <td> <tt><b>bop_its_det</b></tt> </td> <td> dataset </td> <td> 16.05.2014 </td> <td> 16.05.2014 </td> <td> 2004 </td> <td> 2013 </td> <td> <a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_det&lang=en" target="_blank">click here</a> </td> </tr><tr> <td> 2 </td> <td> Database by themes </td> <td> Economy and finance </td> <td> Balance of payments - International transactions </td> <td> International trade in services, geographical breakdown </td> <td> <b>International trade in services (1985-2003)</b> </td> <td> <tt><b>bop_its_deth</b></tt> </td> <td> dataset </td> <td> 16.05.2014 </td> <td> 16.05.2014 </td> <td> 1985 </td> <td> 2003 </td> <td> <a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_deth&lang=en" target="_blank">click here</a> </td> </tr><tr> <td> 3 </td> <td> Database by themes </td> <td> Economy and finance </td> <td> Balance of payments - International transactions </td> <td> International trade in services, geographical breakdown </td> <td> <b>International trade in services - market integration indicators</b> </td> <td> <tt><b>bop_its_str</b></tt> </td> <td> dataset </td> <td> 28.05.2014 </td> <td> 28.05.2014 </td> <td> 1992 </td> <td> 2013 </td> <td> <a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_str&lang=en" target="_blank">click here</a> </td> </tr><tr> <td> 4 </td> <td> Database by themes </td> <td> Economy and finance </td> <td> Balance of payments - International transactions </td> <td> International trade in services, geographical breakdown </td> <td> <b>Total services, detailed geographical breakdown by EU Member States (since 2002)</b> </td> <td> <tt><b>bop_its_tot</b></tt> </td> <td> dataset </td> <td> 27.05.2014 </td> <td> 27.05.2014 </td> <td> 2002 </td> <td> 2012 </td> <td> <a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_tot&lang=en" target="_blank">click here</a> </td> </tr><tr> <td> 5 </td> <td> Database by themes </td> <td> Economy and finance </td> <td> Balance of payments - International transactions </td> <td> International trade in services, geographical breakdown </td> <td> <b>International trade in services - Data for the Eurostat yearbook</b> </td> <td> <tt><b>bop_its_ybk</b></tt> </td> <td> dataset </td> <td> 06.06.2014 </td> <td> 06.06.2014 </td> <td> 1992 </td> <td> 2013 </td> <td> <a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its_ybk&lang=en" target="_blank">click here</a> </td> </tr><tr> <td> 6 </td> <td> Database by themes </td> <td> Economy and finance </td> <td> Balance of payments - International transactions (BPM6) </td> <td> International trade in services, geographical breakdown (BPM6) </td> <td> <b>International trade in services (since 2010) (BPM6)</b> </td> <td> <tt><b>bop_its6_det</b></tt> </td> <td> dataset </td> <td> 01.06.2016 </td> <td> 01.06.2016 </td> <td> 2010 </td> <td> 2015 </td> <td> <a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_det&lang=en" target="_blank">click here</a> </td> </tr><tr> <td> 7 </td> <td> Database by themes </td> <td> Economy and finance </td> <td> Balance of payments - International transactions (BPM6) </td> <td> International trade in services, geographical breakdown (BPM6) </td> <td> <b>Total services, detailed geographical breakdown by EU Member States (since 2010) (BPM6)</b> </td> <td> <tt><b>bop_its6_tot</b></tt> </td> <td> dataset </td> <td> 01.06.2016 </td> <td> 01.06.2016 </td> <td> 2010 </td> <td> 2015 </td> <td> <a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=bop_its6_tot&lang=en" target="_blank">click here</a> </td> </tr> </table> </body></html>

## Speed demo

eurodata::**importData** compared to [eurostat](https://cran.r-project.org/web/packages/eurostat/index.html)::[get_eurostat](http://www.rdocumentation.org/packages/eurostat/functions/get_eurostat):


```r
y <- importDataList()  # matadata

d <- unique(y[y$Type=='dataset','Code']) # dataset codes

set.seed(1234)  # for replicability

d30 <- sample(d, 30) # a random sample of 30 datasets

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


```r
L <- lapply(d30, compileInfo)
```


```r
Res <- do.call(rbind, L)

Res2 <- within(Res,
       ratio <- get_eurostat/importData)

row.names(Res2) <- NULL # to eliminate the visual noise

Res2 # lower = faster (in seconds)
```

```
##      Data code name importData get_eurostat     ratio
## 1           vit_bs2       5.85        25.78  4.406838
## 2      yth_incl_090       0.09         0.37  4.111111
## 3       spr_exp_eur       0.53         3.53  6.660377
## 4      yth_incl_130       0.09         0.51  5.666667
## 5      mar_sg_am_cv       0.08         0.08  1.000000
## 6        sts_inpi_q       2.85        30.03 10.536842
## 7         ei_isrt_q       0.09         0.25  2.777778
## 8       demo_nsinrt       0.50         3.73  7.460000
## 9       sbs_ins_5d2       0.06         0.20  3.333333
## 10    earn_ses06_18       0.19           NA        NA
## 11         iss_barr       0.34           NA        NA
## 12     lmp_expme_lu       0.13         0.72  5.538462
## 13    hlth_ehis_hc1       0.32           NA        NA
## 14         nrg_122m       0.53         6.52 12.301887
## 15      hlth_dsi050       0.06           NA        NA
## 16     road_eqr_bum       0.05         0.13  2.600000
## 17       hlth_dp050       0.06           NA        NA
## 18        hlth_hlye       0.08         0.22  2.750000
## 19    naio_agg_aimp       0.45         4.21  9.355556
## 20         migr_lct       0.21         2.15 10.238095
## 21     hsw_aw_inaag       0.15         0.80  5.333333
## 22      hlth_dhc060       0.12         0.50  4.166667
## 23     nasa_10_f_bs      21.06       167.26  7.942070
## 24 htec_emp_risced2       0.95         7.63  8.031579
## 25       bop_gdp6_q       0.64           NA        NA
## 26  ext_lt_intertrd       0.27         2.17  8.037037
## 27   earn_ses_agt15       0.27           NA        NA
## 28      env_wat_cat       0.09         0.36  4.000000
## 29  rail_go_natdist       0.23         2.23  9.695652
## 30    hlth_cd_ysdr1      10.24        10.93  1.067383
```

```r
# How many times eurodata::importData is faster on average?

mean(Res2$ratio, na.rm=TRUE)
```

```
## [1] 5.956985
```

```r
median(Res2$ratio, na.rm=TRUE)
```

```
## [1] 5.538462
```
