#' Get J-Stage Volumes and Issues List
#'
#' @description
#' Retrieves a list of volumes and issues published on J-STAGE.
#'
#' @param pubyearfrom
#'   An integer specifying the starting publication year (in YYYY format).
#' @param pubyearto
#'   An integer specifying the ending publication year (in YYYY format).
#' @param material
#'   A character string specifying the material name (exact match search).
#' @param issn
#'   A character string specifying the ISSN (exact match search in XXXX-XXXX
#'   format).
#' @param cdjournal
#'   A character string specifying the journal code.
#' @param volorder
#'   An integer specifying the order of volumes: 1 for ascending, 2 for
#'   descending (default is 1).
#' @param lang
#'   A character string specifying the language for column names: "ja" for
#'   Japanese (default is "ja").
#' @return A list containing metadata and entry data frames with the search
#'   results.
#' @export
get_jstage_volumes <- function(pubyearfrom = NA,
                               pubyearto = NA,
                               material = "",
                               issn = "",
                               cdjournal = "",
                               volorder = NA,
                               lang = "ja") {

  x <- get_jstage(pubyearfrom = pubyearfrom,
                  pubyearto = pubyearto,
                  material = material,
                  issn = issn,
                  cdjournal = cdjournal,
                  volorder = volorder,
                  service = 2)

  dm <- xml_meta(x)
  de <- xml_entry2(x)

  if (dm$status == "ERR_001") {
    warning("\u691c\u7d22\u7d50\u679c\u306f 0 \u4ef6\u3067\u3059\u3002")
  }

  if (lang == "ja") {
    names(dm) <- c("\u51e6\u7406\u7d50\u679c\u30b9\u30c6\u30fc\u30bf\u30b9",
                   "\u51e6\u7406\u7d50\u679c\u30e1\u30c3\u30bb\u30fc\u30b8",
                   "\u30d5\u30a3\u30fc\u30c9\u540d",
                   "\u30af\u30a8\u30ea\u306eURL",
                   "\u30af\u30a8\u30ea\u306eURI",
                   "\u30b5\u30fc\u30d3\u30b9\u30b3\u30fc\u30c9",
                   "\u53d6\u5f97\u65e5\u6642",
                   "\u691c\u7d22\u7d50\u679c\u7dcf\u6570",
                   "\u958b\u59cb\u4ef6\u6570",
                   "\u4ef6\u6570")
    names(de) <- c("\u5dfb\u53f7\u4e00\u89a7\u8868\u793a\u540d(\u82f1)",
                   "\u5dfb\u53f7\u4e00\u89a7\u8868\u793a\u540d(\u65e5)",
                   "\u76ee\u6b21\u4e00\u89a7URL(\u82f1)",
                   "\u76ee\u6b21\u4e00\u89a7URL(\u65e5)",
                   "Print ISSN", "Online ISSN",
                   "\u5b66\u5354\u4f1a\u540d(\u82f1)",
                   "\u5b66\u5354\u4f1a\u540d(\u65e5)",
                   "\u5b66\u5354\u4f1aURL(\u82f1)",
                   "\u5b66\u5354\u4f1aURL(\u65e5)",
                   "\u8cc7\u6599\u30b3\u30fc\u30c9",
                   "\u8cc7\u6599\u540d(\u82f1)",
                   "\u8cc7\u6599\u540d(\u65e5)",
                   "\u5dfb", "\u5206\u518a", "\u53f7",
                   "\u958b\u59cb\u30da\u30fc\u30b8",
                   "\u7d42\u4e86\u30da\u30fc\u30b8",
                   "\u767a\u884c\u5e74",
                   "\u30b7\u30b9\u30c6\u30e0\u30b3\u30fc\u30c9",
                   "\u30b7\u30b9\u30c6\u30e0\u540d",
                   "\u30b5\u30d6\u30d5\u30a3\u30fc\u30c9\u540d",
                   "\u30b5\u30d6\u30d5\u30a3\u30fc\u30c9URL",
                   "\u30b5\u30d6\u30d5\u30a3\u30fc\u30c9ID",
                   "\u6700\u65b0\u516c\u958b\u65e5")
  }

  return(list(metadata = dm, entry = de))

}

get_jstage <- function(pubyearfrom = NA,
                       pubyearto = NA,
                       material = "",
                       article = "",
                       author = "",
                       affil = "",
                       keyword = "",
                       abst = "",
                       text = "",
                       issn = "",
                       cdjournal = "",
                       volorder = NA,
                       sortflg = NA,
                       vol = NA,
                       no = NA,
                       start = NA,
                       count = NA,
                       service,
                       retries = 1,
                       sleep_time = 5) {

  params <- list()
  params <- add_param(params, "pubyearfrom", pubyearfrom)
  params <- add_param(params, "pubyearto", pubyearto)
  params <- add_param(params, "material", material, TRUE)
  params <- add_param(params, "article", article, TRUE)
  params <- add_param(params, "author", author, TRUE)
  params <- add_param(params, "affil", affil, TRUE)
  params <- add_param(params, "keyword", keyword, TRUE)
  params <- add_param(params, "abst", abst, TRUE)
  params <- add_param(params, "text", text, TRUE)
  params <- add_param(params, "issn", issn)
  params <- add_param(params, "cdjournal", cdjournal)
  params <- add_param(params, "volorder", volorder)
  params <- add_param(params, "sortflg", sortflg)
  params <- add_param(params, "vol", vol)
  params <- add_param(params, "no", no)
  params <- add_param(params, "start", start)
  params <- add_param(params, "count", count)

  query_string <- if (length(params) > 0) {
    paste0("&", paste(names(params), params, sep = "=", collapse = "&"))
  } else {
    ""
  }

  url <- paste0("https://api.jstage.jst.go.jp/searchapi/do?service=", service, query_string)
  xml_content <- retry_request(url, retries, sleep_time)

  x <- xml2::read_xml(x = xml_content)

  return(x)

}

add_param <- function(params, param_name, param_value, encode = FALSE) {

  if (!is.na(param_value) && param_value != "") {
    if (encode) {
      param_value <- utils::URLencode(param_value)
    }
    params[[param_name]] <- param_value
  }

  return(params)

}

retry_request <- function(url, retries = 1, sleep_time = 5) {
  for (i in 1:retries) {
    response <- try(httr::GET(url), silent = TRUE)
    if (inherits(response, "try-error") || httr::http_error(response)) {
      message("Attempt ", i, " failed. Retrying in ", sleep_time, " seconds...")
      Sys.sleep(sleep_time)
    } else {
      return(httr::content(response, as = "text", encoding = "UTF-8"))
    }
  }
  stop("All attempts failed.")
}

xml_meta <- function(meta) {

  dm <- tibble::tibble(
    status = get_xml_text(meta, "//d1:result/d1:status"),
    message = get_xml_text(meta, "//d1:result/d1:message"),
    title = get_xml_text(meta, "//d1:title"),
    link = get_xml_text(meta, "//d1:link"),
    id = get_xml_text(meta, "//d1:id"),
    servicecd = get_xml_text(meta, "//d1:servicecd"),
    updated = get_xml_text(meta, "//d1:updated"),
    totalResults = get_xml_text(meta, "//opensearch:totalResults"),
    startIndex = get_xml_text(meta, "//opensearch:startIndex"),
    itemsPerPage = get_xml_text(meta, "//opensearch:itemsPerPage")
  )

  dm <- convert_numeric_columns(dm, c("totalResults", "startIndex", "itemsPerPage"))

  return(dm)

}

xml_entry2 <- function(x) {

  entries <- xml2::xml_find_all(x = x, xpath = "//d1:entry")
  data_list <- list()

  for (entry in entries) {
    vols_title_en <- get_xml_text(entry, "d1:vols_title/d1:en")
    vols_title_ja <- get_xml_text(entry, "d1:vols_title/d1:ja")
    vols_link_en <- get_xml_text(entry, "d1:vols_link/d1:en")
    vols_link_ja <- get_xml_text(entry, "d1:vols_link/d1:ja")

    issn <- get_xml_text(entry, "d1:issn")
    eIssn <- get_xml_text(entry, "d1:eIssn")

    publisher_name_en <- get_xml_text(entry, "d1:publisher/d1:name/d1:en")
    publisher_name_ja <- get_xml_text(entry, "d1:publisher/d1:name/d1:ja")
    publisher_url_en <- get_xml_text(entry, "d1:publisher/d1:url/d1:en")
    publisher_url_ja <- get_xml_text(entry, "d1:publisher/d1:url/d1:ja")

    cdjournal <- get_xml_text(entry, "d1:cdjournal")
    material_title_en <- get_xml_text(entry, "d1:material_title/d1:en")
    material_title_ja <- get_xml_text(entry, "d1:material_title/d1:ja")

    volume <- get_xml_text(entry, "prism:volume")
    cdvols <- get_xml_text(entry, "prism:cdvols")
    number <- get_xml_text(entry, "prism:number")
    startingPage <- get_xml_text(entry, "prism:startingPage")
    endingPage <- get_xml_text(entry, "prism:endingPage")

    pubyear <- get_xml_text(entry, "d1:pubyear")

    systemcode <- get_xml_text(entry, "d1:systemcode")
    systemname <- get_xml_text(entry, "d1:systemname")
    title <- get_xml_text(entry, "d1:title")
    link <- get_xml_text(entry, "d1:link")
    id <- get_xml_text(entry, "d1:id")
    updated <- get_xml_text(entry, "d1:updated")

    data_list[[length(data_list) + 1]] <- tibble::tibble(
      vols_title_en = vols_title_en,
      vols_title_ja = vols_title_ja,
      vols_link_en = vols_link_en,
      vols_link_ja = vols_link_ja,
      issn = issn,
      eIssn <- eIssn,
      publisher_name_en = publisher_name_en,
      publisher_name_ja = publisher_name_ja,
      publisher_url_en = publisher_url_en,
      publisher_url_ja = publisher_url_ja,
      cdjournal = cdjournal,
      material_title_en = material_title_en,
      material_title_ja = material_title_ja,
      volume = volume,
      cdvols = cdvols,
      number = number,
      startingPage = startingPage,
      endingPage = endingPage,
      pubyear = pubyear,
      systemcode = systemcode,
      systemname = systemname,
      title = title,
      link = link,
      id = id,
      updated = updated
    )
  }

  de <- dplyr::bind_rows(data_list)
  de <- convert_numeric_columns(de, c("volume", "cdvols", "number", "startingPage", "endingPage", "pubyear"))

  return(de)

}

get_xml_text <- function(x, xpath) {
  xml2::xml_text(xml2::xml_find_first(x = x, xpath = xpath))
}

convert_numeric_columns <- function(df, columns) {

  for (i in columns) {
    numeric_col <- suppressWarnings(as.numeric(df[[i]]))
    if (all(is.na(df[[i]]) | !is.na(numeric_col))) {
      df[[i]] <- as.numeric(df[[i]])
    }
  }

  return(df)

}
