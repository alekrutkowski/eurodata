% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extras.R
\name{compare}
\alias{compare}
\title{Compare specific Eurostat datasets on the basis of information from Metabase}
\usage{
compare(..., import_labels = TRUE, import_dim_labels = TRUE)
}
\arguments{
\item{...}{Two or more Eurostat dataset code names, e.g. \code{"nama_10_gdp"} or \code{"bop_its6_det"}, as strings.}

\item{import_labels}{Boolean: should labels for the codes inside dimensions be imported. Default: \code{TRUE}.}

\item{import_dim_labels}{Boolean: should the dimensions (e.g. \code{geo}, \code{indic_is}, or \code{nace_r2}) be labelled with a descriptive
name (via \code{\link{importDimLabel}}). Default: \code{TRUE}.}
}
\value{
A \link[data.table]{data.table} with columns \code{Dim_name}, \code{Dim_name_label} (if \code{import_dim_labels}=\code{TRUE}),
\code{Dim_val}, \code{Dim_val_label} (if \code{import_labels}=\code{TRUE}), and logical columns corresponding to the dataset names
in \code{...} indicating in which dataset a given dimension and dimension value appears and in which it does not.
}
\description{
Compare specific Eurostat datasets on the basis of information from Metabase
}
\examples{
\dontrun{
compare('nama_10_gdp', 'nama_10_pe')
}
}
