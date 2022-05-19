#' @import data.table magrittr
#' @importFrom stringr str_locate
NULL

#' Download and import a Eurostat dataset
#'
#' @param EurostatDatasetCode A string with Eurostat dataset code name, e.g. \code{nama_10_gdp} or \code{bop_its6_det}.
#' See e.g.:
#' \url{http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&file=table_of_contents_en.pdf}
#' @return A Eurostat dataset as a `flat' data.frame.
#' A `flat' dataset has all numeric values in one column, with each row representing one of the available combinations
#' of all dimensions (e.g. if dimensions are: countries, years, sectors, and indicators, there can be a row for value
#' added in retail in Germany in 2013).
#' @export
importData <- function(EurostatDatasetCode) {
    stopifnot(EurostatDatasetCode %>% is.character,
              length(EurostatDatasetCode)==1)
    # Download
    message('Downloading Eurostat dataset ', EurostatDatasetCode)
    TempGZfileName <- tempfile(fileext='.gz')
    t <- Sys.time()
    utils::download.file(EurostatBaseUrl %++% 'data/' %++%
                             EurostatDatasetCode %++%
                             '.tsv.gz',
                         TempGZfileName)
    # Uncompress and verify
    message('Uncompressing (extracting)')
    TempTSVfileName <- R.utils::gunzip(TempGZfileName)
    v <- verifyFile(TempTSVfileName, EurostatDatasetCode, 'tsv.gz')
    if (v$error) stop(v$message)
    # Read into RAM
    RawData <- TempTSVfileName %>%
        message_('Importing (reading into memory)') %>%
        data.table::fread(sep='\t',
                          sep2=',',
                          colClasses='character',
                          header=TRUE)
    # Extract column names
    FirstColName <- RawData %>%
        colnames %>%
        extract(1)
    IdNames <- FirstColName %>%
        strsplit(',|\\\\') %>%
        unlist
    ColIdName <- IdNames %>%
        tail(1)
    RowIdNames <- IdNames %>%
        head(-1)
    # Clean up and reformat data, add metadata
    RawData %>%
        as.data.table() %>%
        .[, (RowIdNames) := tstrsplit(get(FirstColName), split=',')] %>%
        .[, (FirstColName) := NULL] %>%
        melt(id.vars=RowIdNames,
             variable.name=ColIdName,
             value.name='value_') %>%
        .[, flags_ := gsub('[0-9\\.-]', "", value_)] %>%
        .[, value_ := gsub('[^0-9\\.-]', "", value_) %>% as.numeric] %>%
        .[, (RowIdNames) := lapply(.SD, as.factor), .SDcols=RowIdNames] %>%
        as.data.frame() %>%
        addAttr('EurostatDatasetCode', EurostatDatasetCode) %>%
        addAttr('DownloadTime', t) %>%
        addClass('EurostatDataset')
}

#' Import Eurostat labels (descriptions) for a given dimension code
#'
#' Import the appropriate \code{.dic} file from
#'  \url{http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?dir=dic/en}
#' for the selected Eurostat dimension, e.g. \code{geo} (countries or other geographic entities),
#' \code{nace_r2} (sectors), \code{indic_sb} (indicators), etc.
#' @param EurostatDimCode A string -- the code name of the Eurostat dimension, e.g. \code{geo} or \code{nace_r2}
#' or \code{indic_sb}.
#' @return A data.frame with 2 columns: codes (with a name determined by \code{EurostatDimCode})
#' and corresponding labels (named with suffix \code{_labels}).
#' @export
importLabels <- function(EurostatDimCode) {
    stopifnot(EurostatDimCode %>% is.character,
              length(EurostatDimCode)==1)
    Url <- EurostatBaseUrl %++% 'dic/en/' %++%
        EurostatDimCode %++%
        '.dic'
    v <- verifyFile(Url,
                    EurostatDimCode,
                    'dic')
    if (v$error) stop(v$message)
    t <- Sys.time()
    message('Downloading Eurostat labels for ', EurostatDimCode)
    data.table::fread(Url,
                      sep='\t',
                      stringsAsFactors=TRUE,
                      header=FALSE) %>%
        as.data.frame %>%
        set_colnames(c(EurostatDimCode,
                       EurostatDimCode %++% '_labels')) %>%
        addAttr('EurostatDimCode', EurostatDimCode) %>%
        addAttr('DownloadTime', t) %>%
        addClass('EurostatLabels')
}

#' Import and reshape Eurostat inventory of datasets
#'
#' @return The imported data.frame reflects the hierarchical
#' structure of datasets (see the columns \code{Data subgroup, level 0},
#' \code{Data subgroup, level 1}, \code{Data subgroup, level 2}, etc.).
#' It is tagged with S3 class \code{EurostatDataList}.
#' @export
importDataList <- function() {
    RawTable <-
        data.table::fread(EurostatBaseUrl %++%
                              'table_of_contents_en.txt',
                          colClasses = 'character',
                          head=TRUE, encoding="UTF-8") %>%
        as.data.frame %>%
        within({if (exists('values'))
            values <- NULL
        `last update of data` <-
            invertDate(`last update of data`)
        `last table structure change` <-
            invertDate(`last table structure change`)
        txtpos <- stringr::str_locate(title, "[a-zA-Z0-9\'%]") %>%
            extract(, 'start')
        level <- floor((txtpos - 1)/4) %>% as.integer()
        id <- seq_along(level)
        title <- substring(title, txtpos)
        txtpos <- NULL}) %>%
        as.data.table() %>%
        dcast(id + ... ~ level, fill="",
              value.var='title',
              fun.aggregate=identity) %>%
        as.data.frame() %>%
        within(id <- NULL) %>%
        set_colnames(colnames(.) %>%
                         sapply(function(x)
                             suppressWarnings(if (x %>%
                                                  as.numeric %>%
                                                  is.na) x else
                                                      paste('Data subgroup, level', x))))
    newcols <- RawTable %>%
        colnames %>%
        grep('Data subgroup.+',.)
    RawTable[, newcols] <- RawTable[, newcols] %>%
        as.matrix %>%
        myRecursFill
    RawTable %>%
        subset(type %in% c('dataset','table')) %>%
        set_colnames({Names <- colnames(.)
        Names %>%
            extract(max(newcols)) %>%
            sub('Dataset name', Names, fixed=TRUE)}) %>%
        extract(c(newcols, colnames(.) %>%
                      seq_along %>%
                      setdiff(newcols))) %>%
        within(Link <-
                   'https://ec.europa.eu/eurostat/databrowser/view/' %++%
                   code %++%
                   '/default/table?lang=en') %>%
        set_colnames(colnames(.) %>%
                         sub("(^|[[:space:]])([[:alpha:]])", "\\1\\U\\2", # upper case first char
                             ., perl=TRUE)) %>%
        addClass('EurostatDataList')
}

#' Import Eurostat ``Metabase''
#'
#' The Eurostat ``Metabase'' shows which datasets contain which
#' dimensions (where a dimension is e.g. \code{geo} or \code{nace_r2}
#' or \code{indic_sb}) and, within each dataset and dimension,
#' which codes (e.g. which countries for the \code{geo} dimension).
#' @return The imported data.frame which reflects the hierarchical
#' structure described above. It is a `flat' data.frame with 3 columns, where
#' each row corresponds to the combination of:
#' \itemize{
#'   \item \code{Code} -- Eurostat dataset code names,
#'   e.g. \code{"nama_10_a64"}
#'   \item \code{Dim_name} -- Eurostat dimension code names,
#'   e.g. \code{"nace_r2"}
#'   \item \code{Dim_val} -- Eurostat dimension code values,
#'   e.g. \code{"EU28"} if \code{Dim_name} is \code{"geo"};
#'   not to be confused with the actual numeric values
#'   in the actual datasets
#' }
#' @export
importMetabase <- function() {
    # Download
    message('Downloading Eurostat Metabase')
    TempGZfileName <- tempfile(fileext='.gz')
    t <- Sys.time()
    utils::download.file(EurostatBaseUrl %++% 'metabase.txt.gz',
                         TempGZfileName)
    # Uncompress and verify
    message('Uncompressing (extracting)')
    TempTSVfileName <- R.utils::gunzip(TempGZfileName)
    # Read into RAM
    TempTSVfileName %>%
        message_('Importing (reading into memory)') %>%
        data.table::fread(sep='\t',
                          sep2=',',
                          colClasses='character',
                          header=FALSE) %>%
        data.table::setnames(c('Code','Dim_name','Dim_val')) %>%
        as.data.frame
}

