% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/core_import.R
\name{importLabels}
\alias{importLabels}
\title{Import Eurostat labels (descriptions) for a given dimension code}
\usage{
importLabels(EurostatDimCode)
}
\arguments{
\item{EurostatDimCode}{A string -- the code name of the Eurostat dimension, e.g. \code{geo} or \code{nace_r2}
or \code{indic_sb}.}
}
\value{
A data.frame with 2 columns: codes (with a name determined by \code{EurostatDimCode})
and corresponding labels (named with suffix \code{_labels}).
}
\description{
Import the appropriate \code{.dic} file from
 \url{http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?dir=dic/en}
for the selected Eurostat dimension, e.g. \code{geo} (countries or other geographic entities),
\code{nace_r2} (sectors), \code{indic_sb} (indicators), etc.
}
