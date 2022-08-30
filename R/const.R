EurostatBaseUrl <-
    'https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/'

EurostatBaseUrl_old <-
    'https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?file='

CssStyle <- '
    <!DOCTYPE html>
    <html>
        <head>
            <style type="text/css">
            table.gridtable {
                font-family: verdana,arial,sans-serif;
                font-size:11px;
                color:#333333;
                border-width: 1px;
                border-color: #666666;
                border-collapse: collapse;
            }
            table.gridtable th {
                border-width: 1px;
                padding: 4px;
                border-style: solid;
                border-color: #666666;
                background-color: #dedede;
            }
            table.gridtable td {
                border-width: 1px;
                padding: 4px;
                border-style: solid;
                border-color: #666666;
                background-color: #ffffff;
            }
            </style>
        </head>
    <body>'

# To avoid CRAN NOTE:
. <- NULL
Code <- NULL
Dim_val_label <- NULL
code <- NULL
flags_ <- NULL
type <- NULL
value_ <- NULL
