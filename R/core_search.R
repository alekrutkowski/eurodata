#' Search Eurostat datasets and see the result as a table in a browser
#'
#' @param subs An expression to be passed to \code{\link[base]{subset}}.
#' The column names of the table of datasets can be used -- those with spaces should be
#' backtick (`) quoted. See the examples below.
#' @return
#' \itemize{
#'   \item Side effect (via \code{print}) -- a table opened in a browser via \code{\link[utils]{browseURL}}.
#'   \item Value -- a list with:
#'   \itemize{
#'     \item criteria -- a string, search criteria,
#'     \item time -- the time of the query,
#'     \item df -- a data.frame, imported via \code{\link[eurodata]{importDataList}} and
#'     filtered based on the conditions specified in \code{subs}.
#'     \item html -- a string, with the HTML code that generated the table in a browser.
#'   }
#' }
#' @examples
#' \dontrun{
#' browseDataList(grepl('servic',`Dataset name`))
#' browseDataList(grepl('bop',Code) & !grepl('its',Code))
#' }
#' @useDynLib eurodata
#' @export
browseDataList <- function(subs) {
    SearchCriteria <-
        substitute(subs) %>%
        deparse %>%
        paste(collapse=" ")
    t_ <- Sys.time()
    Table <-
        bquote(subset(importDataList(),  # due to non-standard eval in subset
                      .(substitute(subs)))) %>%
        eval
    NRow <- nrow(Table)
    html <- (if (NRow==0)
        data.frame(`Nothing found` = character(0),
                   check.names=FALSE) else
                       Table %>%
                           within({
                               Link <- link(Link, 'click here')
                               Row <- seq_along(Code) %>% as.character
                               Code <- '<tt><b>' %++% Code %++% '</b></tt>'
                               `Dataset name` <- '<b>' %++% `Dataset name` %++% '</b>'}) %>%
                           moveColLeft('Row') %>%
                           Filter(function(x)
                               not(all(x=="")), .)) %>%
        xtable::xtable() %>%
        print(type='html',
              sanitize.text.function = force,
              include.rownames = FALSE,
              html.table.attributes='class="gridtable"',
              print.results=FALSE) %>%
        paste(CssStyle,
              p('&#9632; Generated on:&nbsp;' %++% t_ %++% ' &#9632; ' %++%
                    'Number of datasets/tables found:&nbsp;' %++% NRow %++% ' &#9632; ' %++%
                    'Search criteria:&nbsp;' %++% SearchCriteria),
              .,
              '</body></html>', collapse="") %>%
        Reduce(function(str,char)  # minimise html file for faster rendering
            gsub(char,"",str,fixed=TRUE),
            x=c('\n','\t',"  "),
            init=.)
    list(criteria=SearchCriteria,
         time=t_,
         df=Table,
         html=html) %>%
        addClass('BrowsedEurostatDatasetList')
}


#' Search Eurostat datasets and see the result as text
#'
#' A tool for a quick ad-hoc search.
#' @param ... A series of unquoted words to be searched either in Eurostat dataset
#' codes or in dataset full names. All words not preceded by minus (-) will be linked
#' with logical AND; all words preceded by a minus entail exclusion (logical NOT),
#'  a bit like in Google search. It is possible to search also with
#' phrases that include spaces -- in such a case the phrases should be
#' quoted. Partial word/phrase match is applied. See the examples below.
#' @return
#' \itemize{
#'   \item Side effect (via \code{print}) -- a text report file opened via \code{\link{file.show}}.
#'   \item Value -- a list with:
#'   \itemize{
#'     \item criteria -- a string, search criteria,
#'     \item time -- the time of the query,
#'     \item df -- a data.frame, imported via \code{\link[eurodata]{importDataList}} and
#'     filtered based on the conditions specified in \code{...},
#'     \item report -- a string, with the text report.
#'   }
#' }
#' @examples
#' \dontrun{
#' find(bop, its)
#' find(bop,-ybk,its)
#' find(nama_)
#' find(nama,10,64)
#' find('economic indic')
#' }
#' @export
find <- function(...) {
    Critera <- substitute(list(...)) %>%
        as.list %>%
        tail(-1) %>%
        lapply(as.list) %>%
        Reduce(function(x,y)
            cond(# and case:
                length(y)<=1,
                list(and=c(x$and,y[[1]]),not=x$not),
                # not case (with minus):
                length(y)==2 && y[[1]]==quote(`-`),
                list(and=x$and,not=c(x$not,y[[2]])),
                # else:
                stop(call.=FALSE,
                     paste("",'Every argument in find(...) must be either just a single unquoted word',
                           'or a single unquoted word preceded just by a minus!',
                           'E.g. find(bop, its, -ybk)', sep='\n'))),
            x=.,
            init=list(and=NULL,not=NULL)) %>%
        lapply(function(x) x %>% as.character)
    t_ <- Sys.time()
    Table <- importDataList() %>%
        extractRows(union(intersect(Critera$and %And% .$Code,
                                    Critera$not %Not% .$Code),
                          intersect(Critera$and %And% .$`Dataset name`,
                                    Critera$not %Not% .$`Dataset name`))) %>%
        Filter(function(x)
            not(all(x=="")), .) # drop empty columns
    NRow <- nrow(Table)
    criteria <- substitute(list(...)) %>%
        tail(-1) %>%
        paste(collapse=", ")
    info_message <- paste(t_,
                          NRow %++% ' dataset(s)/table(s) found.',
                          'Keywords: ' %++% criteria,
                          sep='\n')
    report <- Table %>%
        dfToLines(info_message)
    list(criteria=criteria,
         time=t_,
         df=Table,
         report=report %>%
             addClass('FoundEurostatDatasetListReport')) %>%
        addClass('FoundEurostatDatasetList')
}
