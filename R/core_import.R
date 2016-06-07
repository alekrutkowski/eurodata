#' Download and import a EuroStat dataset
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
        message_('Splitting the column of identifiers') %>%
        tidyr::separate_(col = FirstColName,
                         into = RowIdNames,
                         sep = ',') %>%
        message_('Reshaping into long format (single value column)') %>%
        tidyr::gather_(key_col=ColIdName,
                       value_col='value_',
                       gather_cols = colnames(.) %>%
                           setdiff(RowIdNames),
                       convert = FALSE) %>%
        message_('Separating values and flags') %>%
        within({
            flags_ <- gsub('[0-9\\.-]', "", value_)
            value_ <- gsub('[^0-9\\.-]', "", value_) %>%
                as.numeric}) %>%
        message_('Converting codes to factors') %>%
        {df <- .
        lapply(RowIdNames, function(x)
            if (x %>% is.numeric) x else
                df[[x]] %>% as.factor) %>%
            as.data.frame %>%
            set_colnames(RowIdNames) %>%
            cbind(df[c(ColIdName, 'value_', 'flags_')])} %>%
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
#' structure of datasets (see the columns "Data subgroup, level 0",
#' "Data subgroup, level 1", "Data subgroup, level 2", etc.).
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
        txtpos <- stringr::str_locate(title, "[a-zA-Z0-9\'%]") %>%
            extract(, 'start')
        level <- floor((txtpos - 1)/4)
        id <- seq_along(level)
        title <- substring(title, txtpos)
        txtpos <- NULL}) %>%
        tidyr::spread(key=level, value=title, fill="") %>%
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
                   ifelse(nchar(code)==8 & substr(code,1,1)=='t',
                          'http://epp.eurostat.ec.europa.eu/tgm/table.do?tab=table&init=1&language=en&pcode=' %++%
                              code[nchar(code)==8 & substr(code,1,1)=='t'] %++% '&plugin=1',
                          'http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=' %++%
                              code %++%
                              '&lang=en')) %>%
        set_colnames(colnames(.) %>%
                         sub("(^|[[:space:]])([[:alpha:]])", "\\1\\U\\2", # upper case first char
                             ., perl=TRUE))
}




