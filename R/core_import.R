#' @import data.table magrittr
#' @importFrom stringr str_locate
NULL

#' Download and import a Eurostat dataset
#'
#' @param EurostatDatasetCode A string (upper/lower-case difference is not relevant) with Eurostat dataset code name,
#' e.g. \code{nama_10_gdp} or \code{bop_its6_det}. See \url{https://ec.europa.eu/eurostat/databrowser/explore/all/all_themes}
#' to find a dataset code -- the dataset codes are in tiny font in square brackets.
#' @param filters Optional: a list of atomic vectors. The names of the elements of the list should correspond to the
#' names of the dimensions of the dataset (defined in \code{EurostatDatasetCode}), e.g. \code{geo}, \code{nace_r2},
#' \code{indic_esb} etc. The elements of each vector in that list should correspond to each respective dimension's values
#' available in the dataset. Only these dimension values will be downloaded. For \code{TIME_PERIOD} it's enough to provide
#' 1 or 2 values -- the lowest one will be used as a start of the data period and the highest as the end of the data
#' period downloaded. Use \code{filters} if you need only a few dimension values as it will be faster than downloading the
#' full dataset.
#' @return A Eurostat dataset as a `flat' data.frame.
#' A `flat' dataset has all numeric values in one column, with each row representing one of the available combinations
#' of all dimensions (e.g. if dimensions are: countries, years, sectors, and indicators, there can be a row for value
#' added in retail in Germany in 2013).
#' @examples
#' \dontrun{
#' # Full dataset import:
#' importData('nama_10_gdp')
#' # Import only a subset of a dataset:
#' importData('bop_its6_det',
#'            filters = list(geo=c('AT','BG'),
#'                           TIME_PERIOD=2014:2020,
#'                           bop_item='SC'))
#' }
#' @export
importData <- function(EurostatDatasetCode, filters=NULL) {
    stopifnot(is.character(EurostatDatasetCode),
              length(EurostatDatasetCode)==1,
              is.null(filters) || is.list(filters) && length(filters)>0)
    if (is.list(filters) && any(names(filters)==""))
        stop('All elements of `filters` must be named.')
    url_prefix <-
        EurostatBaseUrl %++% 'data/' %++%
        toupper(EurostatDatasetCode)
    url_suffix <-
        if (is.list(filters))
            urlStructure(EurostatDatasetCode) %>%
        .[.!='freq' & .!='TIME_PERIOD'] %T>%
        {not_present_dims <- setdiff(names(filters),c(.,'TIME_PERIOD'))
        if (length(not_present_dims)>0)
            warning('`filters` contains dimension(s) not present in the dataset, ignored:\n',
                    paste(not_present_dims, collapse=', '),
                    call.=FALSE, immediate.=TRUE)} %>%
        filters[.] %>%
        lapply(paste,collapse='+') %>%
        {do.call(paste,c(.,sep='.'))} %>%
        paste0("/.",.,"?format=TSV",
               if ('TIME_PERIOD' %in% names(filters))
                   paste0("&startPeriod=",min(filters$TIME_PERIOD),
                          "&endPeriod=",max(filters$TIME_PERIOD)) else "")
    # Download
    message('Downloading Eurostat dataset ', EurostatDatasetCode)
    t <- Sys.time()
    if (is.null(filters)) {
        TempGZfileName <- tempfile(fileext='.gz')
        utils::download.file(url_prefix %++% '?format=TSV&compressed=true',
                             TempGZfileName,
                             method='curl')
        # Uncompress
        message('Uncompressing (extracting)')
        TempTSVfileName <- R.utils::gunzip(TempGZfileName)
    }
    # Read into RAM
    RawData <-
        `if`(is.null(filters), TempTSVfileName,
             paste0(url_prefix,url_suffix)) %>%
        message_('Importing (reading into memory)') %>%
        data.table::fread(sep='\t',
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

urlStructure <- function(ds_code)
    ds_code %>%
    toupper(.) %>%
    paste0('https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/datastructure/estat/',.) %>%
    xml2::read_xml() %>%
    xml2::as_list() %>%
    {.$Structure$
            Structures$
            DataStructures$
            DataStructure$
            DataStructureComponents$
            DimensionList} %>%
    sapply(function(x) attr(x$ConceptIdentity$Ref,'id'))

#' Import Eurostat code list: labels (descriptions) for a given dimension code
#'
#' Import the appropriate `code list' from
#' for the selected Eurostat dimension, e.g. \code{geo} (countries or other geographic entities),
#' \code{nace_r2} (sectors), \code{indic_sb} (indicators), etc.
#' @param EurostatDimCode A string -- the code name of the Eurostat dimension, e.g. \code{geo} or \code{nace_r2}
#' or \code{indic_sb}.
#' @return A data.frame with 2 columns: codes (with a name determined by \code{EurostatDimCode})
#' and corresponding labels (named with suffix \code{_labels}).
#' @examples
#' \dontrun{
#' importLabels('nace_r2')
#' }
#' @export
importLabels <- function(EurostatDimCode) {
    stopifnot(EurostatDimCode %>% is.character,
              length(EurostatDimCode)==1)
    Url <- EurostatBaseUrl %++% 'codelist/ESTAT/' %++%
        toupper(EurostatDimCode) %++%
        '?format=TSV&lang=en'
    t <- Sys.time()
    message('Downloading Eurostat labels for ', EurostatDimCode)
    try(data.table::fread(Url,
                          sep='\t',
                          stringsAsFactors=TRUE,
                          header=FALSE)) %>%
        `if`(inherits(.,'try-error'),
             stop('Cannot download ',Url,'\n',
                  attr(.,'condition')$message, call.=FALSE),
             .) %>%
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
#' @examples
#' \dontrun{
#' importDataList()
#' }
#' @export
importDataList <- function() {
    RawTable <-
        data.table::fread(EurostatBaseUrl %>%
                              sub('sdmx/2.1/',"",.,fixed=TRUE) %++%
                              'catalogue/toc/txt?lang=EN',
                          colClasses = 'character',
                          head=TRUE, encoding="UTF-8") %>%
        as.data.frame %>%
        within({if (exists('values'))
            values <- NULL
        `last update of data` <-
            invertDate(`last update of data`)
        `last table structure change` <-
            invertDate(`last table structure change`)
        txtpos <- stringr::str_locate(title, "[a-zA-Z0-9'%\\.\\-]") %>%
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
#' @examples
#' \dontrun{
#' importMetabase()
#' }
#' @export
importMetabase <- function() {
    # Download
    message('Downloading Eurostat Metabase')
    TempGZfileName <- tempfile(fileext='.gz')
    t <- Sys.time()
    utils::download.file(EurostatBaseUrl %>%
                             sub('sdmx/2.1/',"",.,fixed=TRUE) %++%
                             'catalogue/metabase.txt.gz?labels=no',
                         TempGZfileName,
                         method='curl') # method='curl' needed otherwise error in readBin inside gunzip below
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

