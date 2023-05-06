#' @import data.table
#' @importFrom xml2 read_xml xml_find_all xml_attr xml_text
#' @importFrom memoise memoise
#' @importFrom stats as.formula
NULL

memImportMetabase <-
    memoise::memoise(importMetabase)

memImportLabels <-
    memoise::memoise(importLabels)

#' Import Eurostat label (description) of a given dimension code
#'
#' Import the appropriate description file
#' for the selected Eurostat dimension, e.g. for \code{"geo"} it is \code{"Geopolitical entity (reporting)"},
#' for \code{"nace_r2"} it is \code{"Classification of economic activities - NACE Rev.2"},
#' for \code{"indic_sb"} it is \code{"Economical indicator for structural business statistics"} etc.
#' Click on "Code lists" just under "Apply download operations on" at \url{https://ec.europa.eu/eurostat/databrowser/bulk?lang=en}
#' for the list of all codes.
#' Each description is imported from inside the XML file
#' (via the path: \emph{m:Structure / m:Structures / s:Codelists / s:Codelist / c:Name xml:lang="en"})
#' from the respective URL, e.g. for \code{"geo"} it is
#' \url{https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/codelist/ESTAT/GEO}.
#' @param EurostatDimCode A string -- the code name of the Eurostat dimension, e.g. \code{"geo"} or \code{"nace_r2"}
#' or \code{"indic_sb"}, etc.
#' @return A character vector of length 1: the label/description of \code{EurostatDimCode}.
#' @examples
#' \dontrun{
#' importDimLabel('nace_r2')
#' }
#' @export
importDimLabel <- function(EurostatDimCode) {
    stopifnot(EurostatDimCode %>% is.character,
              length(EurostatDimCode)==1)
    EurostatDimCode %>%
        toupper() %>%
        paste0(EurostatBaseUrl,"codelist/ESTAT/",.) %>%
        xml2::read_xml() %>%
        xml2::xml_find_all(".//s:Codelist/c:Name") %>%
        .[xml2::xml_attr(.,"lang")=="en"] %>%
        xml2::xml_text()
}

memImportDimLabel <-
    memoise::memoise(importDimLabel)

attachDimLabels <- function(dt)
    dt$Dim_name %>%
    unique() %>%
    sapply(memImportDimLabel) %>%
    data.table::data.table(Dim_name=names(.),Dim_name_label=.) %>%
    merge(dt,.,by='Dim_name')

attachLabels <- function(dt)
    dt %>%
    split(.$Dim_name) %>%
    lapply(function(sub_dt) {
        dn <-
            unique(sub_dt$Dim_name)
        lbls <-
            memImportLabels(dn) %>%
            data.table::as.data.table() %>%
            data.table::setnames(c(dn,paste0(dn,'_labels')),
                                 c('Dim_val','Dim_val_label')) %>%
            .[, Dim_val_label := as.character(Dim_val_label)]
        merge(x=sub_dt, y=lbls,
              all.x=TRUE,
              by='Dim_val')
    }) %>%
    data.table::rbindlist()

#' Describe a given Eurostat dataset on the basis of information from Metabase
#'
#' @param EurostatDatasetCode A string with Eurostat dataset code name, e.g. \code{"nama_10_gdp"} or \code{"bop_its6_det"}.
#' See e.g.: \url{https://ec.europa.eu/eurostat/databrowser/explore/all/all_themes} where, once you follow one of the "branches"
#' of the "tree" of datasets, the dataset codes are in tiny grey font in square brackets just under the full names of the datasets
#' (the names are in navy blue and preceded by a cube icon).
#' @param import_labels Boolean: should labels for the codes inside dimensions be imported. Default: if \code{wide} is
#' \code{FALSE} then \code{import_labels} is TRUE and vice versa.
#' @param wide Boolean: should each dimension be compressed to one row and all values within each dimension to a single,
#' comma-separated string. Default: \code{FALSE}.
#' @param import_dim_labels Boolean: should the dimensions (e.g. \code{geo}, \code{indic_is}, or \code{nace_r2}) be labelled with a descriptive
#' name (via \code{\link{importDimLabel}}). Default: \code{TRUE}.
#' @return A \link[data.table]{data.table} with columns \code{Dim_name}, \code{Dim_name_label} (if \code{import_dim_labels}=\code{TRUE}),
#' either \code{Dim_val} (if \code{wide=FALSE}) or \code{Dim_values} (if \code{wide=TRUE}),
#' \code{Dim_val_label} (if \code{import_labels}=\code{TRUE}), and a column with a name = \code{EurostatDatasetCode} with all
#' its values = \code{TRUE}.
#' @examples
#' \dontrun{
#' describe('nama_10_gdp')
#' }
#' @export
describe <- function(EurostatDatasetCode, import_labels=!wide, wide=FALSE, import_dim_labels=TRUE) {
    stopifnot(EurostatDatasetCode %>% is.character,
              length(EurostatDatasetCode)==1,
              is.logical(import_labels),
              length(import_labels)==1,
              is.logical(wide),
              length(wide)==1,
              is.logical(import_dim_labels),
              length(import_dim_labels)==1,
              !(import_labels && wide))
    mb <-
        memImportMetabase() %>%
        data.table::as.data.table() %>%
        .[Code==EurostatDatasetCode]
    if (nrow(mb)==0)
        stop("Eurostat's MetaBase doesn't contain dataset code '",
             EurostatDatasetCode,"'")
    mb %>%
        .[, Code := !is.na(Code)] %>%
        data.table::setnames('Code',EurostatDatasetCode) %>% {
            `if`(import_labels,
                 attachLabels(.),
                 `if`(wide,
                      data.table::dcast(.,
                                        as.formula(paste(EurostatDatasetCode,'+ Dim_name ~ .')),
                                        fun.aggregate = function(x) paste(x,collapse=', '),
                                        value.var = 'Dim_val') %>%
                          data.table::setnames('.','Dim_values'),
                      .))
        } %>%
        data.table::setcolorder(c(EurostatDatasetCode,
                                  'Dim_name',
                                  if (!wide) 'Dim_val')) %>%
        `if`(import_dim_labels,
             attachDimLabels(.),.) %>%
        data.table::setcolorder(intersect(c('Dim_name',
                                            'Dim_name_label',
                                            'Dim_val',
                                            'Dim_val_label'),
                                          colnames(.))) %>%
        print()
}

# from https://stackoverflow.com/a/54136863/9563034
quietly <- function(x) {
    sink(tempfile())
    on.exit(sink())
    invisible(force(x))
}

#' Compare specific Eurostat datasets on the basis of information from Metabase
#'
#' @param ... Two or more Eurostat dataset code names, e.g. \code{"nama_10_gdp"} or \code{"bop_its6_det"}, as strings.
#' @param import_labels Boolean: should labels for the codes inside dimensions be imported. Default: \code{TRUE}.
#' @param import_dim_labels Boolean: should the dimensions (e.g. \code{geo}, \code{indic_is}, or \code{nace_r2}) be labelled with a descriptive
#' name (via \code{\link{importDimLabel}}). Default: \code{TRUE}.
#' @return A \link[data.table]{data.table} with columns \code{Dim_name}, \code{Dim_name_label} (if \code{import_dim_labels}=\code{TRUE}),
#' \code{Dim_val}, \code{Dim_val_label} (if \code{import_labels}=\code{TRUE}), and logical columns corresponding to the dataset names
#' in \code{...} indicating in which dataset a given dimension and dimension value appears and in which it does not.
#' @examples
#' \dontrun{
#' compare('nama_10_gdp', 'nama_10_pe')
#' }
#' @export
compare <- function(..., import_labels=TRUE, import_dim_labels=TRUE) {
    EDC <- # Eurostat Dataset Codes
        list(...) %>%
        as.character() %>%
        unique()
    if (length(EDC)<2)
        stop('Function `compare` needs at least 2 arguments (dataset code names as strings)')
    descriptions <-
        EDC %>%
        lapply(function(x)
            quietly(describe(x,
                             import_labels=FALSE,
                             import_dim_labels=FALSE)))
    mrg <- function(x,y)
        merge(x,y,
              by=c('Dim_name','Dim_val'),
              all=TRUE)
    Reduce(mrg,
           x = descriptions %>% tail(-2),
           init = descriptions %>% {mrg(.[[1]],.[[2]])}) %>%
        .[, lapply(., function(col)
            if (is.logical(col)) !is.na(col) else col)] %>%
        `if`(import_labels,
             attachLabels(.),
             .) %>%
        `if`(import_dim_labels,
             attachDimLabels(.),
             .) %>%
        data.table::setcolorder(intersect(c('Dim_name',
                                            'Dim_name_label',
                                            'Dim_val',
                                            'Dim_val_label'),
                                          colnames(.))) %>%
        print()
}
