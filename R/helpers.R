#' @import magrittr Rcpp
NULL

'%++%' <- function(x,y) paste0(x,y)

tail <- utils::tail
head <- utils::head

message_ <- function(x, ...) { # to be used inside pipes
    message(...)
    x
}

addClass <- function(obj, ClassName)
    if (inherits(obj, ClassName))
        obj else
            `class<-`(obj,
                      c(ClassName,
                        class(obj)))

addAttr <- `attr<-`

verifyFile <- function(FileName, EurostatCode, FileType) {
    message('Verifying the code')
    if (FileName %>%
        readLines(n=1) %>%
        pmatch('<!DOCTYPE html',.) %>%
        is.na %>% not)
        list(error=TRUE,
             message=paste0('\nProbably a wrong ', ifelse(FileType=='tsv.gz','dataset ',""), 'code:  ', EurostatCode, '\n',
                            'Check if you can find  ', EurostatCode %++% '.', FileType, '  at\n',
                            EurostatBaseUrl %>% sub('?file=','?dir=',.,fixed=TRUE),
                            ifelse(FileType=='tsv.gz','data','dic/en'), '&start=all')) else
                                list(error=FALSE)
}

invertDate <- function(x)
    # inspiered by https://stackoverflow.com/a/46834350/
    sub('^(\\d{2})\\.(\\d{2})\\.(\\d{4})$','\\3-\\2-\\1',x)

p <- function(str)
    '<p><tt>' %++% str %++% '</tt></p>'

link <- function(url, str)
    '<a href="' %++%
    url %++%
    '" target="_blank">' %++%
    str %++% '</a>'

moveColLeft <- function(df, ColName)
    df %>%
    extract(c(ColName,
              setdiff(colnames(.),
                      ColName)))

grepv <- Vectorize(function(p,x)
    grep(pattern=p, x=x, ignore.case=TRUE),
    'p', SIMPLIFY=FALSE)

'%And%' <- function(Strings, vec)
    # returns positions in vec of observations
    # where each String is found (partial match)
    if (length(Strings)==0) seq_along(vec) else
        Strings %>%
    paste0('.*',.,'.*') %>%
    grepv(vec) %>%
    Reduce(intersect,.)

'%Not%' <- function(Strings, vec)
    # returns positions in vec of observations
    # where none of Strings is found (partial match)
    if (length(Strings)==0) seq_along(vec) else
        setdiff(seq_along(vec),
                Strings %>%
                    paste0('.*',.,'.*') %>%
                    grepv(vec) %>%
                    unlist %>%
                    unique)

dfToLines <- function(df, info_message)
    (if (nrow(df)>0) {
        HierarchyCols <- df %>%
            colnames %>%
            grep('Data subgroup.*',.)
        Hierarchy <- df %>%
            extract(HierarchyCols) %>%
            apply(MARGIN=1, paste, collapse=" >>\n ") %>%
            gsub(' >>\n  >>\n', "", ., fixed=TRUE) %>%
            sub(' >>\n $',"",.) %++%
            '\n'
        df %>%
            extract(-HierarchyCols) %>%
            cbind(Hierarchy) %>%
            within({
                No <- seq_along(Code)}) %>%
            merge(stats::aggregate(.$No,
                                   by=list(.$Hierarchy),
                                   mean) %>%
                      set_colnames(c('Hierarchy','meanNo'))) %>%
            within({
                Hierarchy <- # to preserve order in split below
                    paste(formatC(round(meanNo),
                                  digits=4,
                                  flag=0),
                          Hierarchy)
                meanNo <- NULL
            }) %>%
            moveColLeft('No') %>%
            extractRows(order(.$No)) %>%
            split(.$Hierarchy %>%
                      as.factor) %>%
            Reduce(function(x,y) {
                heading <- y$Hierarchy %>%
                    unique %>%
                    as.character %>%
                    sub('^\\w+ ',"",.)
                y %>%
                    within(Hierarchy <- NULL) %>%
                    extractRows(order(.$No)) %>%
                    split(.$No) %>%
                    sapply(function(d)
                        paste(colnames(d),':',d,collapse='\n')) %>%
                    paste(collapse='\n\n') %>%
                    paste(x,"\n " %++% heading,.,sep='\n',collapse="")},
                x=.,
                init="") %>%
            paste(info_message,.,"",sep="",collapse="") %++%
            '\n\n'}) %>%
        paste(info_message,'\n\nEnd.',sep="",collapse="")

#' @export
print.FoundEurostatDatasetList <- function(x, ...) {
    tmpf <- tempfile(fileext = '.txt')
    cat(x$report, file=tmpf, sep="\n")
    file.show(tmpf, title = "Results for 'found'")
    invisible(x)
}

#' @export
print.FoundEurostatDatasetListReport <- function(x, ...) {
    cat(x, sep="\n")
    invisible(x)
}

#' @export
print.BrowsedEurostatDatasetList <- function(x, ...) {
    tf <- tempfile(fileext='.html')
    cat(x$html, file=tf)
    utils::browseURL(tf)
    invisible(x)
}

#' @export
print.EurostatDataList <- function(x,
                                   SearchCriteria =
                                       `if`(attr(x,'SearchCriteria') %>% is.null,
                                            "",
                                            attr(x,'SearchCriteria')),
                                   ...) {
    stopifnot(SearchCriteria %>% is.character,
              length(SearchCriteria)==1)
    x %>%
        tableToHtml(Sys.time(), SearchCriteria) %>%
        list(html=.) %>%
        print.BrowsedEurostatDatasetList
    invisible(x)
}

#' Coerce a data.frame to a EurostatDataList
#'
#' Some manipulations of the \code{EurostatDataList} data.frame
#' (imported with \code{\link[eurodata]{importDataList}})
#' e.g. filtering with package \pkg{dplyr} may remove the S3 class tag
#' \code{EurostatDataList}. This function coerces it back to \code{EurostatDataList}
#' after checking that the critical columns
#' (\code{PCode}, \code{Dataset name},\code{Link}) are present. This is useful
#' if a user wants to print and browse this filtered data.frame as a specially
#' formatted HTML table.
#' @param x A (most likely filtered subset of) \code{EurostatDataList} data.frame
#' returned by \code{\link[eurodata]{importDataList}}.
#' @param SearchCriteria A string describing the search criteria used for
#' filtering/subsetting.
#' @param ... Additional arguments to be passed to or from methods
#' (currently not used).
#' @return A data.frame of S3 class \code{EurostatDataList}.
#' @export
as.EurostatDataList <- function(x, SearchCriteria="", ...) {
    stopifnot(x %>% is.data.frame,
              all(c('Code','Dataset name','Link') %in% names(x)),
              SearchCriteria %>% is.character,
              length(SearchCriteria)==1)
    x %>%
        addAttr('SearchCriteria',SearchCriteria) %>%
        addClass('EurostatDataList')
}

tableToHtml <- function(Table, t_, SearchCriteria) {
    NRow <- nrow(Table)
    (if (NRow==0)
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
                    'Number of datasets/tables found:&nbsp;' %++% NRow %++%
                    `if`(SearchCriteria != "",
                         ' &#9632; Search criteria:&nbsp;' %++% SearchCriteria,
                         "")),
              .,
              '</body></html>', collapse="") %>%
        Reduce(function(str,char)  # minimise html file for faster rendering
            gsub(char,"",str,fixed=TRUE),
            x=c('\n','\t',"  "),
            init=.)
}

cond <- function(...) {
    # Clojure-style cond macro in R -- creates nested if-else calls
    # arguments: pairs -- condition1, what-if-true1,
    #                     condition2, what-if-true2,
    #                     etc...
    #                                 what-if-all-contitions-false
    e <- parent.frame()
    substitute(list(...)) %>%
        as.list %T>%
        {if (length(.) < 4)
            stop('\ncond requires at least 3 arguments!')} %>%
        tail(-1) %T>%
        {if (length(.) %% 2 != 1)
            stop('\ncond requires an uneven number of arguments!')} %>%
        split(((seq_along(.) + 1)/2) %>%
                  floor) %>%
        rev %>%
        {c(.[[1]], tail(., -1))} %>%
        Reduce(function(x,y)
            list(`if`, y[[1]], y[[2]], x) %>%
                as.call, .) %>%
        eval(envir=e)
}

extractRows <- function(df, expr)
    df[expr, ]
