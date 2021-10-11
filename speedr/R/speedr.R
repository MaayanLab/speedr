pkg.env <- new.env()
pkg.env$server_url <- "http://localhost:8666/enrichrapi"
pkg.env$background_cache <- list()

#' @title list_libraries
#'
#' @description List libraries hosted by Speedrichr instance.
#'
#' @return array
#'
#' @examples
#' libraries <- speedr::list_libraries()
#'
#' @export

list_libraries <- function()
{
  res = GET(paste0(pkg.env$server_url,"/api/listlibs"))
  return(sort(fromJSON(rawToChar(res$content))$library))
}

#' @title add_background
#'
#' @description Upload a background gene list. The background will define the scope of all possible genes. All uploaded gene sets and gene sets in gene set libraries will first be filtered by the background before calculating significance of overlap.
#'
#' @param gene_array
#'
#' @return array
#'
#' @examples
#' libraries <- speedr::add_background(c("SOX2", "NANOG", "RUNX2", "GATA4"))
#'
#' @export

add_background <- function(gene_array)
{
  gene_array = sort(unique(gene_array))
  request_body_json = list(background = paste(gene_array, collapse = "\n"))

  res <- POST(paste0(pkg.env$server_url,"/api/addbackground"),
              body = request_body_json)

  return(fromJSON(rawToChar(res$content))$backgroundid)
}

#' @title enrichr
#'
#' @description Run enrichment analysis for a given gene set and gene set library.
#'
#' @param library
#'
#' @param gene_array
#'
#' @return array
#'
#' @examples
#' # enrichment analysis without background correction
#' library = "GO_Biological_Process_2021"
#' genes = c('PTPN18','EGF','HSP90AA1','GAB1','NRG1','MATK','PTPN12','NRG2','PTK6','PRKCA','ERBIN','EREG','BTC','NRG4','PIK3R1','PIK3CA','CDC37','GRB2','STUB1','HBEGF','GRB7')
#' result <- speedr::enrich(library, genes)
#'
#' # enrichment analysis with background correction
#' library = "GO_Biological_Process_2021"
#' background = c('TGFB1', 'EOMES', 'TGFB2', 'DDX17', 'NOG', 'FOXF2', 'WNT5A', 'HGF', 'HMGA2', 'HNRNPAB', 'PTPN18','EGF','HSP90AA1','GAB1','NRG1','MATK','PTPN12','NRG2','PTK6','PRKCA','ERBIN','EREG','BTC','NRG4','PIK3R1','PIK3CA','CDC37','GRB2','STUB1','HBEGF','GRB7')
#' genes = c('TGFB1', 'EOMES', 'TGFB2', 'DDX17', 'NOG', 'FOXF2', 'WNT5A', 'HGF', 'HMGA2', 'HNRNPAB', 'PTPN18','EGF','HSP90AA1','GAB1','NRG1','MATK','PTPN12','NRG2','PTK6','PRKCA','ERBIN','EREG','BTC','NRG4','PIK3R1','PIK3CA','CDC37','GRB2','STUB1','HBEGF','GRB7')
#' result <- speedr::enrich(library, genes, background)
#'
#' @export

enrich <- function(library, gene_array, background=NA)
{
  gene_array = sort(unique(gene_array))
  enrichment_result = NA
  if(length(background) == 1){
    request_body_json = list(library = library, geneset = paste(gene_array, collapse = "\n"))
    res <- POST(paste0(pkg.env$server_url,"/api/enrich"), body = request_body_json)
  }
  else{
    background = sort(unique(background))
    hv = digest(background)
    if(!(hv %in% names(pkg.env$background_cache))){
      request_body_json = list(background = paste(background, collapse = "\n"))
      res <- POST(paste0(pkg.env$server_url,"/api/addbackground"), body = request_body_json)
      backgroundid = fromJSON(rawToChar(res$content))[["backgroundid"]]
      pkg.env$background_cache[[hv]]= backgroundid
    }
    request_body_json = list(library = library, geneset = paste(gene_array, collapse = "\n"), backgroundid=pkg.env$background_cache[[hv]])
    res <- POST(paste0(pkg.env$server_url,"/api/backgroundenrich"), body = request_body_json)
  }

  enrichment_result = fromJSON(rawToChar(res$content))[[library]]

  ll = list()
  for(e in enrichment_result){
    e[6]= paste(e[[6]], collapse=",")
    ll[[length(ll)+1]] = (unlist(e)[c(1,2,3,7,4,5,6)])
  }

  df = data.frame(t(sapply(ll, c)))
  colnames(df) = c("rank", "term", "pval", "fdr", "odds", "escore", "overlap")

  return(df)
}
