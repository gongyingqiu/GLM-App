# GLM Modelling Studio - helper functions
# Run this file before app.R.
#
# install.packages(c("shiny","tidyverse","data.table","Hmisc","plotly","htmlwidgets","shinyWidgets","DT",
#                    "shinyjs","shinyalert","readxl","writexl","arrow","statmod"))

require(shiny)
require(tidyverse)
require(data.table)
require(Hmisc)
require(plotly)
require(htmlwidgets)
require(shinyWidgets)
require(DT)
require(shinyjs)
require(shinyalert)

options(dplyr.summarise.inform = FALSE)
options(shiny.maxRequestSize = 30 * 1024^3)


# data partitions ---------------------------------------------------------------------------------------------------------
# A GLM needs a modelling partition (1) and usually a holdout (2); a validation partition (3) is optional.
# Always returns three data frames (an empty one for a partition that is not in the data).
partition_data_factor <- function(in_data, in_partition_factor) {
  p <- suppressWarnings(as.integer(as.character(in_data[[in_partition_factor]])))
  list(in_data[p %in% 1, , drop = FALSE],
       in_data[p %in% 2, , drop = FALSE],
       in_data[p %in% 3, , drop = FALSE])
}
mt_partition_names <- c("Modelling", "Holdout", "Validation")

summarise_fun<-function (in_data, in_fac_list,in_exposure,in_response) {
  result<-list()
  in_exp <- sym(in_exposure)
  in_res <- sym(in_response)
  
  for(fac in in_fac_list) {
    fac_sym <- sym(fac)
    
    result[[fac]]<-in_data %>% group_by(!!fac_sym) %>%
      summarise(exp_sum = sum(!!in_exp),
                res_sum = sum(!!in_res))  %>%
      mutate(actual=res_sum/exp_sum,
             prediction = NA_real_,        # no model yet: the chart leaves these lines out
             AW_shap_premium = NA_real_)
    setnames(result[[fac]], old = c(fac,'exp_sum'), new = c('factor_name','exposure'))
    
  }
  return(result)
}


summarise_fun_actual<-function (in_data, in_fac_list,in_exposure,in_response) {
  result<-list()
  in_exp <- sym(in_exposure)
  in_res <- sym(in_response)
  
  for(fac in in_fac_list) {
    fac_sym <- sym(fac)
    
    result[[fac]]<-in_data %>% group_by(!!fac_sym) %>%
      summarise(exp_sum = sum(!!in_exp),
                res_sum = sum(!!in_res))  %>%
      mutate(actual=res_sum/exp_sum)
    setnames(result[[fac]], old = c(fac,'exp_sum'), new = c('factor_name','exposure'))
    
  }
  return(result)
}


# chart styling --------------------------------------------------------------------------------------------------------------
# One palette and one layout shared by every chart so the app looks consistent.

mt_chart_colours <- list(
  exposure      = "#c7d2fe",   # soft indigo bars
  exposure_line = "#a5b4fc",
  actual        = "#e11d48",   # rose
  expected      = "#2563eb",   # blue
  shap          = "#0d9488",   # teal
  expected_ref  = "#f59e0b",   # amber
  shap_ref      = "#7c3aed",   # violet
  text          = "#374151",
  grid          = "#eef1f5",
  axis          = "#d5dbe5"
)

mt_font_family <- "Segoe UI, -apple-system, Helvetica Neue, Arial, sans-serif"

# ggplot theme used by the gains chart and as the default for other ggplot charts
theme_mt <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      text             = element_text(colour = mt_chart_colours$text),
      axis.title       = element_text(colour = "#6b7280", size = rel(0.95)),
      axis.text        = element_text(colour = "#4b5563"),
      panel.grid.major = element_line(colour = mt_chart_colours$grid, linewidth = 0.5),
      panel.grid.minor = element_blank(),
      axis.line        = element_line(colour = mt_chart_colours$axis, linewidth = 0.5),
      legend.position  = "top",
      legend.title     = element_blank(),
      plot.background  = element_rect(fill = "white", colour = NA),
      panel.background = element_rect(fill = "white", colour = NA)
    )
}
theme_set(theme_mt())

# shared plotly layout for the one-way exposure / actual / expected charts
mt_oneway_layout <- function(p, fac, n_levels) {
  p %>%
    layout(
      font          = list(family = mt_font_family, size = 12, color = mt_chart_colours$text),
      paper_bgcolor = "white",
      plot_bgcolor  = "white",
      hovermode     = "x unified",
      bargap        = 0.25,
      margin        = list(l = 60, r = 60, t = 40, b = 60),
      legend        = list(orientation = "h", x = 0, y = 1.02, xanchor = "left", yanchor = "bottom",
                           traceorder = "normal",
                           font = list(size = 11.5), bgcolor = "rgba(0,0,0,0)"),
      xaxis  = list(title = list(text = fac, standoff = 12),
                    type = "category",
                    tickangle = if (n_levels > 12) -45 else 0,
                    tickfont = list(size = 11),
                    showgrid = FALSE,
                    linecolor = mt_chart_colours$axis,
                    ticks = "outside", tickcolor = mt_chart_colours$axis),
      yaxis  = list(title = list(text = "Exposure", standoff = 10),
                    gridcolor = mt_chart_colours$grid,
                    zeroline = FALSE,
                    tickformat = "~s",
                    rangemode = "tozero"),
      yaxis2 = list(title = list(text = "Rate", standoff = 10),   # set from the model type by mt_set_rate_label()
                    overlaying = "y",
                    side = "right",
                    showgrid = FALSE,
                    zeroline = FALSE,
                    rangemode = "tozero"),
      barmode = "stack"
    ) %>%
    config(displaylogo = FALSE,
           modeBarButtonsToRemove = c("lasso2d", "select2d", "autoScale2d", "hoverClosestCartesian",
                                      "hoverCompareCartesian", "toggleSpikelines"),
           toImageButtonOptions = list(format = "png", filename = fac, scale = 2))
}

# right-hand axis title for the one-way charts, from the model type chosen on the Model structure tab
mt_rate_label <- function(model_type) {
  if (is.null(model_type) || !length(model_type) || is.na(model_type)) return("Rate")
  switch(as.character(model_type),
         "1" = "Claim frequency",
         "2" = "Average claim cost",
         "3" = "Burning cost",
         "4" = "Probability",
         "Rate")
}
mt_set_rate_label <- function(p, model_type) {
  p %>% layout(yaxis2 = list(title = list(text = mt_rate_label(model_type))))
}

# builds the chart: exposure bars plus one line per entry in `lines`
mt_oneway_plot <- function(in_data, fac, lines) {
  n_lv <- length(unique(in_data[['factor_name']]))
  if (n_lv > MT_MAX_CHART_LEVELS) return(mt_too_many_levels_plot(fac, n_lv))
  # text levels sort naturally so bands like "[1000,2000)" come before "[10000,11000)"; factors keep their own order
  fn <- in_data[['factor_name']]
  in_data[['factor_name']] <- if (is.character(fn)) factor(fn, levels = c(stringr::str_sort(unique(fn[!is.na(fn)]), numeric = TRUE), if (anyNA(fn)) NA), exclude = NULL)
                              else factor(fn, exclude = NULL)
  levels(in_data[['factor_name']])[is.na(levels(in_data[['factor_name']]))] <- "NA"
  # draw points in axis order: the summary is sorted case-sensitively ("DFSK" before "Dacia") but the axis follows
  # the factor levels, so without this the line jumps back and forth and crosses itself
  in_data <- in_data[order(in_data[['factor_name']]), ]

  p <- in_data %>%
    plot_ly(x = ~factor_name) %>%
    add_trace(y = ~exposure,
              name = "Exposure",
              type = 'bar',
              marker = list(color = mt_chart_colours$exposure,
                            line = list(color = mt_chart_colours$exposure_line, width = 1)),
              hovertemplate = "%{y:,.0f}")

  for (ln in lines) {
    # a line with no values yet (e.g. SHAP not calculated for this model) is left out rather than drawn flat
    if (!ln$col %in% names(in_data) || all(is.na(in_data[[ln$col]]))) next
    p <- p %>%
      add_trace(y = in_data[[ln$col]],
                name = ln$name,
                yaxis = "y2",
                type = 'scatter',
                mode = 'lines+markers',
                line = list(color = ln$colour, width = 2.2, dash = ln$dash %||% "solid"),
                marker = list(color = ln$colour, size = 6, symbol = ln$symbol %||% "circle",
                              line = list(color = "white", width = 1)),
                hovertemplate = "%{y:.4f}")
  }

  n_levels <- nlevels(in_data[['factor_name']])
  p <- mt_oneway_layout(p, fac, n_levels)
  # label every level up to 50 (plotly otherwise skips some labels on busy axes)
  if (n_levels <= 50) p <- p %>% layout(xaxis = list(tickmode = "linear", tick0 = 0, dtick = 1))
  p
}


Actual_Plt <- function(in_data, in_exposure, fac){
  mt_oneway_plot(in_data[[fac]], fac, list(
    list(col = "actual", name = "Actual", colour = mt_chart_colours$actual)
  ))
}


# the lines drawn on an AvsE chart (with_ref adds the reference model's lines)
mt_avse_lines <- function(with_ref = FALSE) {
  ln <- list(
    list(col = "actual",          name = "Actual",            colour = mt_chart_colours$actual),
    list(col = "prediction",      name = "Expected",          colour = mt_chart_colours$expected))
  if (with_ref) ln <- c(ln, list(
    list(col = "prediction_ref",  name = "Expected (reference)", colour = mt_chart_colours$expected_ref, dash = "dash")))
  ln <- c(ln, list(
    list(col = "AW_shap_premium", name = "SHAP (own effect)", colour = mt_chart_colours$shap, dash = "dot", symbol = "diamond")))
  if (with_ref) ln <- c(ln, list(
    list(col = "AW_shap_premium_ref", name = "SHAP (reference)", colour = mt_chart_colours$shap_ref, dash = "dot", symbol = "diamond-open")))
  ln
}

AvsE_Plt <- function(in_data, in_partition, in_exposure, fac){
  mt_oneway_plot(in_data[[as.numeric(in_partition)]][[fac]], fac, mt_avse_lines(FALSE))
}

AvsE_with_ref_Plt <- function(in_data, in_partition, in_exposure, fac){
  mt_oneway_plot(in_data[[as.numeric(in_partition)]][[fac]], fac, mt_avse_lines(TRUE))
}


# palette for charts with many series (two-way investigation); recycled if there are more levels than colours
mt_series_palette <- c("#2563eb", "#e11d48", "#0d9488", "#f59e0b", "#7c3aed", "#0891b2",
                       "#db2777", "#65a30d", "#ea580c", "#4f46e5", "#475569", "#b45309")
mt_discrete_scales <- function() {
  list(scale_colour_manual(values = rep(mt_series_palette, 10)),
       scale_fill_manual(values = rep(mt_series_palette, 10)))
}

# converts a ggplot to plotly with the shared font, legend and toolbar settings
mt_ggplotly <- function(g, filename = "chart", legend_top = TRUE) {
  p <- ggplotly(g) %>%
    layout(font = list(family = mt_font_family, size = 12, color = mt_chart_colours$text),
           paper_bgcolor = "white",
           plot_bgcolor  = "white",
           margin = list(l = 60, r = 30, t = 40, b = 60))
  if (legend_top) {
    p <- p %>% layout(legend = list(orientation = "h", x = 0, y = 1.02, xanchor = "left", yanchor = "bottom",
                                    title = list(text = ""), bgcolor = "rgba(0,0,0,0)"))
  }
  p <- p %>% config(displaylogo = FALSE,
                    modeBarButtonsToRemove = c("lasso2d", "select2d", "autoScale2d", "hoverClosestCartesian",
                                               "hoverCompareCartesian", "toggleSpikelines"),
                    toImageButtonOptions = list(format = "png", filename = filename, scale = 2))
  # ggplotly labels legend entries like "(Annual,1)" when several aesthetics are mapped; tidy them to "Annual"
  p <- plotly_build(p)
  for (i in seq_along(p$x$data)) {
    for (fld in c("name", "legendgroup")) {
      if (!is.null(p$x$data[[i]][[fld]])) {
        p$x$data[[i]][[fld]] <- sub("^\\((.*),[0-9]+\\)$", "\\1", p$x$data[[i]][[fld]])
      }
    }
  }
  p
}

# auto banding ---------------------------------------------------------------------------------------------------------------
# Builds the editable mapping table for automatic numeric banding.
# Band edges come from Hmisc::cut2 quantile cuts; each band's new level is the mean of the values in that band.
# Edges and means are derived from the same intervals, so the columns always line up (previously the means came
# from a second cut2 call that could return one more group than the edges and crash the app).
# Bands are left-closed [left, right); the top edge is nudged up by 1 so the maximum value falls in the last band,
# matching how the "Apply mapping" button applies the table.
auto_band_table <- function(x, n_bands) {
  cuts <- Hmisc::cut2(x, g = n_bands, onlycuts = TRUE)
  cuts <- sort(unique(cuts))
  if (length(cuts) < 2) return(NULL)

  left  <- head(cuts, -1)
  right <- tail(cuts, -1)
  right[length(right)] <- right[length(right)] + 1

  band  <- cut(x, breaks = c(left, right[length(right)]), right = FALSE)
  means <- as.numeric(tapply(x, band, mean, na.rm = TRUE))
  empty <- is.na(means)
  means[empty] <- left[empty]   # an empty band keeps its lower edge as its level

  data.frame(current_factor_level_left  = left,
             current_factor_level_right = right,
             new_factor_level           = signif(means, 6))
}

# Read a data file for the Import tab. Format is taken from the original file name
# (Shiny's temp datapath may not keep it). Always returns a plain data.frame.
# Read a data file for the Import tab. `type` is the data type chosen in the app ("rds", "csv" or "parquet");
# without it the type is taken from the file name. Shiny's temp datapath may not keep the extension, so the original
# name is passed separately. Always returns a plain data.frame.
read_data_file <- function(path, name = path, type = NULL, csv_sep = "auto", csv_header = TRUE) {
  ext <- tolower(tools::file_ext(name))
  ext_type <- switch(ext, rds = "rds", csv = "csv", txt = "csv", parquet = "parquet", pq = "parquet", NA_character_)
  if (is.null(type)) type <- ext_type
  if (is.na(type)) stop("unsupported file type '.", ext, "' - use .rds, .csv or .parquet")
  if (!is.na(ext_type) && ext_type != type)
    stop(sprintf("you chose %s, but '%s' is a .%s file - change the data type or pick another file",
                 toupper(type), name, ext))
  out <- switch(type,
    rds     = readRDS(path),
    csv     = data.table::fread(path, data.table = FALSE, showProgress = FALSE,
                                sep = if (is.null(csv_sep) || identical(csv_sep, "auto")) "auto" else csv_sep,
                                header = !isFALSE(csv_header)),
    parquet = {
      if (!requireNamespace("arrow", quietly = TRUE))
        stop("the 'arrow' package is needed to read parquet files")
      arrow::read_parquet(path)
    },
    stop("unsupported data type '", type, "'")
  )
  if (!is.data.frame(out)) stop("file does not contain a data table")
  as.data.frame(out)
}


# factor mapping --------------------------------------------------------------------------------------------------------------
# A mapping table is either
#   manual: current_factor_level, new_factor_level                      (one row per original level)
#   auto  : current_factor_level_left, current_factor_level_right, new_factor_level   (bands [left, right))
is_band_mapping <- function(tb) all(c("current_factor_level_left", "current_factor_level_right") %in% names(tb))

# numbers stay numbers; anything else (e.g. "Group A") is kept as text
mt_as_level <- function(v) {
  v   <- as.character(v)
  num <- suppressWarnings(as.numeric(v))
  if (all(is.na(num) == is.na(v))) num else v
}

# applies a mapping table to the original values of one factor
apply_factor_mapping <- function(x, tb) {
  if (is.null(tb)) return(x)
  if (is_band_mapping(tb)) {
    # each band is [From, To); bands need not touch (custom bands may leave gaps), the first matching band wins
    L <- suppressWarnings(as.numeric(tb$current_factor_level_left))
    R <- suppressWarnings(as.numeric(tb$current_factor_level_right))
    lab <- as.character(tb$new_factor_level)
    out <- rep(NA_character_, length(x))
    for (i in seq_len(nrow(tb))) {
      if (is.na(L[i]) || is.na(R[i])) next
      idx <- is.na(out) & !is.na(x) & x >= L[i] & x < R[i]
      out[idx] <- lab[i]
    }
    # the type comes from the table, not the data, so every partition (even an empty one) gets the same type;
    # named bands keep the band order (by From) rather than alphabetical order in charts and the model
    if (is.numeric(mt_as_level(tb$new_factor_level))) suppressWarnings(as.numeric(out))
    else factor(out, levels = unique(lab[order(L)][!is.na(lab[order(L)])]))
  } else {
    tb$new_factor_level[match(x, tb$current_factor_level)]
  }
}

# custom bands -----------------------------------------------------------------------------------------------------------------
# text from the editor -> number ("1,000" and "Inf" are accepted)
mt_edge_num <- function(v) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(v)))))
mt_edge_txt <- function(v) vapply(v, function(z) if (is.na(z)) "" else if (is.infinite(z)) as.character(z)
                                  else format(z, scientific = FALSE, digits = 15, trim = TRUE), "")

# builds a band table from the editor's three columns; a blank new level takes the band's From value
band_table_from <- function(left, right, new) {
  L <- mt_edge_num(left); R <- mt_edge_num(right)
  N <- trimws(as.character(new)); N[is.na(N)] <- ""
  blank <- N == ""
  N[blank] <- ifelse(is.na(L[blank]), NA, mt_edge_txt(L[blank]))
  data.frame(current_factor_level_left = L, current_factor_level_right = R,
             new_factor_level = mt_as_level(N), stringsAsFactors = FALSE)
}

# checks a band table against the data: errors block "Apply mapping", warnings don't
band_mapping_check <- function(x, w, tb) {
  L <- suppressWarnings(as.numeric(tb$current_factor_level_left))
  R <- suppressWarnings(as.numeric(tb$current_factor_level_right))
  N <- as.character(tb$new_factor_level)
  lst <- function(i) paste(i, collapse = ", ")
  err <- character(0); wrn <- character(0)
  if (!nrow(tb)) return(list(errors = "Add at least one band", warnings = character(0)))
  miss <- which(is.na(L) | is.na(R))
  if (length(miss)) err <- c(err, sprintf("Band %s: From and To must both be numbers", lst(miss)))
  bad <- which(!is.na(L) & !is.na(R) & L >= R)
  if (length(bad)) err <- c(err, sprintf("Band %s: From must be below To", lst(bad)))
  ok <- which(!is.na(L) & !is.na(R) & L < R)
  o  <- ok[order(L[ok])]
  if (length(o) > 1) {
    ov <- which(L[o[-1]] < R[o[-length(o)]])
    for (k in ov) err <- c(err, sprintf("Bands %d and %d overlap", o[k], o[k + 1]))
  }
  nn <- which(is.na(N) | trimws(N) == "")
  if (length(nn)) err <- c(err, sprintf("Band %s: give it a new level", lst(nn)))
  # values that fall in no band become NA
  have <- !is.na(x)
  if (any(have) && length(ok)) {
    out <- have & is.na(apply_factor_mapping(x, tb[ok, , drop = FALSE]))
    if (any(out)) {
      pct <- 100 * sum(w[out]) / sum(w[have])
      msg <- sprintf("%s%% of exposure (values %s to %s) is in no band and becomes NA",
                     formatC(pct, format = "f", digits = if (pct < 0.1) 3 else 1),
                     mt_edge_txt(min(x[out])), mt_edge_txt(max(x[out])))
      if (any(x[out] == max(R[ok]))) msg <- paste0(msg, ". To is exclusive: use a To above the largest value, or Inf")
      wrn <- c(wrn, msg)
    }
  }
  list(errors = err, warnings = wrn)
}

# exposure / claims / actual frequency by level of one (mapped) factor
mapping_level_summary <- function(x, exposure, response) {
  data.frame(factor_name = x, e = exposure, r = response) %>%
    group_by(factor_name) %>%
    summarise(exposure = sum(e), res_sum = sum(r), .groups = "drop") %>%
    mutate(actual = res_sum / exposure)
}

# one-way chart for the small mapping previews: same look, tighter margins
mapping_oneway_plot <- function(level_summary, fac, compact = FALSE) {
  p <- mt_oneway_plot(level_summary, fac, list(
    list(col = "actual", name = "Actual", colour = mt_chart_colours$actual)))
  if (compact) {
    p <- p %>% layout(margin = list(l = 45, r = 45, t = 30, b = 45),
                      font = list(size = 10.5),
                      yaxis2 = list(title = list(text = "Actual")),
                      xaxis = list(title = list(text = NULL),
                                   tickangle = if (nrow(level_summary) > 5) -45 else 0))
  } else {
    p <- p %>% layout(yaxis2 = list(title = list(text = "Actual")))
  }
  p
}


# mapping sets in Excel --------------------------------------------------------------------------------------------------------
# A mapping table needs new_factor_level plus either current_factor_level (manual) or the two band edges (auto).
valid_mapping_table <- function(tb) {
  is.data.frame(tb) && nrow(tb) > 0 && "new_factor_level" %in% names(tb) &&
    ("current_factor_level" %in% names(tb) || is_band_mapping(tb))
}

# Excel tab names: at most 31 characters, none of [ ] : * ? / \, no leading/trailing apostrophe, unique ignoring case.
# A long or clashing name is cut and numbered (_2, _3, ...) so it still fits; callers record the full names in an index tab.
xl_sheet_names <- function(x, reserved = character(0)) {
  x <- gsub("[][*?:/\\\\]", "_", x)
  x <- gsub("^'+|'+$", "", x)
  x[!nzchar(x)] <- "Sheet"
  out <- character(length(x)); used <- tolower(reserved)
  for (i in seq_along(x)) {
    s <- substr(x[i], 1, 31); k <- 1
    while (tolower(s) %in% used) {
      k <- k + 1; suf <- paste0("_", k)
      s <- paste0(substr(x[i], 1, 31 - nchar(suf)), suf)
    }
    out[i] <- s; used <- c(used, tolower(s))
  }
  out
}

# one tab per factor; Excel limits tab names to 31 characters, so a 'factor_index' tab records the full factor names
mapping_set_to_sheets <- function(lst) {
  if (!length(lst)) return(list(factor_index = data.frame(sheet = character(0), factor = character(0))))
  sheets <- xl_sheet_names(names(lst), reserved = "factor_index")
  out <- setNames(lapply(lst, as.data.frame), sheets)
  c(list(factor_index = data.frame(sheet = sheets, factor = names(lst))), out)
}

# reads a workbook saved by mapping_set_to_sheets() or an old Factor_formats_simple.xlsx (tab name = factor name)
read_mapping_workbook <- function(path) {
  sheets <- readxl::excel_sheets(path)
  index  <- NULL
  if ("factor_index" %in% sheets) {
    index  <- as.data.frame(readxl::read_excel(path, sheet = "factor_index"))
    sheets <- setdiff(sheets, "factor_index")
  }
  out <- lapply(sheets, function(s) as.data.frame(readxl::read_excel(path, sheet = s)))
  nm  <- sheets
  if (!is.null(index)) nm <- ifelse(sheets %in% index$sheet, index$factor[match(sheets, index$sheet)], sheets)
  setNames(out, nm)
}


# GLM levels ---------------------------------------------------------------------------------------------------------------------
# Level order of one rating factor: factors keep their own order, numbers sort numerically, text sorts naturally
# ("[1000,2000)" before "[10000,11000)"). Missing values become a final "NA" level so no rows are lost in the fit.
glm_factor_levels <- function(x) {
  has_na <- anyNA(x)
  u <- unique(x[!is.na(x)])
  lv <- if (is.factor(x)) intersect(levels(x), as.character(u))
        else if (is.numeric(u)) as.character(sort(u))
        else stringr::str_sort(as.character(u), numeric = TRUE)
  if (has_na || "NA" %in% lv) lv <- c(setdiff(lv, "NA"), "NA")
  lv
}
glm_as_factor <- function(x, lv) {
  v <- as.character(x)
  v[is.na(v)] <- "NA"
  factor(v, levels = lv)
}


# =================================================================================================================================
# GLM ENGINE
# =================================================================================================================================
# A factor enters the model in one of three ways (set on the Model tab):
#   plain    : its own (mapped) levels as a categorical term                              -> f
#   variate  : a number per level, fitted as a polynomial of order 1-3                     -> f_var + I(f_var^2) + I(f_var^3)
#   custom   : levels grouped into custom groups, fitted as a categorical term             -> f_custom
# Variate and custom can be used together (e.g. a curve plus a few level adjustments), as in the Excel workflow.
# Every categorical term uses its highest-exposure level / group as the base, so coefficients are relative to it.

# Tweedie family with log link (no extra package needed); 1 < p < 2
glm_tweedie_family <- function(p = 1.5) {
  fam <- poisson(link = "log")
  fam$family     <- sprintf("Tweedie(p = %s)", p)
  fam$variance   <- function(mu) mu^p
  fam$validmu    <- function(mu) all(is.finite(mu)) && all(mu > 0)
  fam$dev.resids <- function(y, mu, wt) {
    2 * wt * (pmax(y, 0)^(2 - p) / ((1 - p) * (2 - p)) - y * mu^(1 - p) / (1 - p) + mu^(2 - p) / (2 - p))
  }
  fam$aic        <- function(...) NA_real_
  fam$initialize <- expression({ n <- rep.int(1, nobs); mustart <- y + 0.1 * (y == 0) })
  fam
}

glm_family_for <- function(model_type, tweedie_p = 1.5) {
  switch(as.character(model_type),
         "1" = poisson(link = "log"),
         "2" = Gamma(link = "log"),
         "3" = glm_tweedie_family(tweedie_p),
         "4" = binomial(link = "logit"))
}
glm_family_label <- function(model_type, tweedie_p = 1.5) {
  switch(as.character(model_type),
         "1" = "Poisson · log link", "2" = "Gamma · log link",
         "3" = sprintf("Tweedie p=%s · log link", tweedie_p), "4" = "Binomial · logit link")
}

# default variate value of each level: the number itself, the mid-point of a band like "[1000,2000)",
# the number in labels like "3+" or "<10", otherwise NA (to be filled in by the user)
glm_default_variate <- function(levels) {
  levels <- as.character(levels)
  v <- suppressWarnings(as.numeric(levels))
  num <- "\\s*(-?[0-9.]+(?:[eE][-+]?[0-9]+)?)\\s*"
  m <- regmatches(levels, regexec(paste0("^[\\[(]", num, ",", num, "[])]$"), levels, perl = TRUE))
  for (i in which(is.na(v))) if (length(m[[i]]) == 3) v[i] <- mean(as.numeric(m[[i]][2:3]))
  m2 <- regmatches(levels, regexec(paste0("^[<>]?=?", num, "\\+?$"), levels, perl = TRUE))
  for (i in which(is.na(v))) if (length(m2[[i]]) == 2) v[i] <- as.numeric(m2[[i]][2])
  v
}

# a fresh term definition for one factor
glm_new_term <- function(levels) {
  list(include   = FALSE,
       var_on    = FALSE, var_order = 1L,
       var_tb    = data.frame(level = levels, value = glm_default_variate(levels), stringsAsFactors = FALSE),
       cust_on   = FALSE,
       cust_tb   = data.frame(level = levels, group = levels, stringsAsFactors = FALSE))
}
glm_term_mode <- function(t) {
  if (!isTRUE(t$var_on) && !isTRUE(t$cust_on)) "plain"
  else paste(c(if (isTRUE(t$var_on)) "variate", if (isTRUE(t$cust_on)) "custom"), collapse = "+")
}
# formula terms of one factor
glm_term_formula <- function(f, t) {
  out <- character(0)
  if (isTRUE(t$var_on)) {
    out <- c(out, paste0(f, "_var"))
    if (t$var_order >= 2) out <- c(out, sprintf("I(%s_var^2)", f))
    if (t$var_order >= 3) out <- c(out, sprintf("I(%s_var^3)", f))
  }
  if (isTRUE(t$cust_on)) out <- c(out, paste0(f, "_custom"))
  if (!length(out)) out <- f
  out
}
# ---- interactions -------------------------------------------------------------------------------------------------------
# An interaction is list(a, ak, b, bk): factors a and b, each used through one of its representations (kind):
#   "var"    -> f_var     (the variate values)
#   "custom" -> f_custom  (the custom groups)
#   "plain"  -> f         (the factor's own levels)
# e.g. list(a = "Veh_Car_Age", ak = "var", b = "Veh_Vehicle_Value", bk = "var")  ->  Veh_Car_Age_var:Veh_Vehicle_Value_var
glm_new_interaction <- function(a, ak, b, bk) list(a = a, ak = ak, b = b, bk = bk)
glm_kind_col  <- function(f, kind) switch(kind, var = paste0(f, "_var"), custom = paste0(f, "_custom"), plain = f)
glm_inter_term  <- function(it) paste0(glm_kind_col(it$a, it$ak), ":", glm_kind_col(it$b, it$bk))
glm_inter_label <- function(it) paste0(it$a, " × ", it$b)
glm_inter_factors <- function(inters) unique(unlist(lapply(inters, function(it) c(it$a, it$b))))
# the kind a factor's main effect uses (default for a new interaction)
glm_main_kind <- function(t) if (isTRUE(t$var_on)) "var" else if (isTRUE(t$cust_on)) "custom" else "plain"

glm_formula_text <- function(terms, inters = list()) {
  inc <- names(terms)[vapply(terms, function(t) isTRUE(t$include), logical(1))]
  parts <- c(unlist(lapply(sort(inc), function(f) glm_term_formula(f, terms[[f]]))),
             vapply(inters, glm_inter_term, character(1)))
  if (!length(parts)) return("1")
  paste(parts, collapse = " +\n")
}
glm_inter_problem <- function(it, terms) {
  out <- character(0)
  for (side in list(c(it$a, it$ak), c(it$b, it$bk))) {
    f <- side[1]; k <- side[2]; t <- terms[[f]]
    if (is.null(t)) { out <- c(out, sprintf("%s: not a factor in this dataset", glm_inter_label(it))); next }
    if (k == "var" && anyNA(t$var_tb$value))
      out <- c(out, sprintf("%s: %s has levels without a variate value", glm_inter_label(it), f))
    if (k == "custom" && any(is.na(t$cust_tb$group) | trimws(t$cust_tb$group) == ""))
      out <- c(out, sprintf("%s: %s has levels without a custom group", glm_inter_label(it), f))
    if (k == "custom" && length(unique(t$cust_tb$group)) < 2)
      out <- c(out, sprintf("%s: %s has only one custom group", glm_inter_label(it), f))
    if (k == "plain" && nrow(t$var_tb) < 2)
      out <- c(out, sprintf("%s: %s has only one level", glm_inter_label(it), f))
  }
  if (it$a == it$b) out <- c(out, sprintf("%s: a factor cannot interact with itself", glm_inter_label(it)))
  if (length(out)) out else NULL
}

# problems that stop a term from being fitted (NULL = fine)
glm_term_problem <- function(f, t) {
  if (isTRUE(t$var_on) && anyNA(t$var_tb$value))
    return(sprintf("%s: variate value missing for level%s %s", f, if (sum(is.na(t$var_tb$value)) > 1) "s" else "",
                   paste(head(t$var_tb$level[is.na(t$var_tb$value)], 5), collapse = ", ")))
  if (isTRUE(t$cust_on) && any(is.na(t$cust_tb$group) | trimws(t$cust_tb$group) == ""))
    return(sprintf("%s: custom group missing for some levels", f))
  if (isTRUE(t$cust_on) && length(unique(t$cust_tb$group)) < 2)
    return(sprintf("%s: custom grouping puts every level in one group ('%s'), which adds nothing. Switch Custom off or use at least two groups",
                   f, t$cust_tb$group[1]))
  NULL
}

# exposure-weighted base: the level (or group) with the most exposure
glm_base_of <- function(x, w) {
  s <- tapply(w, x, sum)
  s[is.na(s)] <- 0
  names(s)[which.max(s)]
}

# one model-frame column of a factor in one representation (x = factor of mapped levels)
glm_kind_column <- function(f, t, x, bases, kind) {
  lv <- as.character(x)
  switch(kind,
         var    = t$var_tb$value[match(lv, t$var_tb$level)],
         custom = { g <- as.character(t$cust_tb$group[match(lv, t$cust_tb$level)])
                    grp <- unique(as.character(t$cust_tb$group))
                    factor(g, levels = c(bases$custom[[f]], setdiff(grp, bases$custom[[f]]))) },
         plain  = relevel(factor(lv, levels = levels(x)), ref = bases$plain[[f]]))
}
# columns of the model frame for one factor's main effect
glm_term_columns <- function(f, t, x, bases) {
  out <- list()
  if (isTRUE(t$var_on))  out[[paste0(f, "_var")]]    <- glm_kind_column(f, t, x, bases, "var")
  if (isTRUE(t$cust_on)) out[[paste0(f, "_custom")]] <- glm_kind_column(f, t, x, bases, "custom")
  if (!length(out))      out[[f]]                    <- glm_kind_column(f, t, x, bases, "plain")
  out
}

# fit the GLM on the modelling partition. Returns a light object (no copy of the data / QR) with what the app needs.
glm_fit_model <- function(dat, terms, response, exposure, offset_col = NULL, model_type = 1, tweedie_p = 1.5,
                          inters = list(), mustart = NULL) {
  # mustart: optional starting fitted means (on the scale of the fitted response), e.g. from a fuller model, so that
  # refits that drop one term converge in fewer iterations. The result does not depend on it.
  inc  <- sort(names(terms)[vapply(terms, function(t) isTRUE(t$include), logical(1))])
  used <- union(inc, glm_inter_factors(inters))
  w    <- dat[[exposure]]
  bases <- list(plain = list(), custom = list())
  for (f in used) {
    bases$plain[[f]]  <- glm_base_of(dat[[f]], w)
    t <- terms[[f]]
    bases$custom[[f]] <- glm_base_of(t$cust_tb$group[match(as.character(dat[[f]]), t$cust_tb$level)], w)
  }
  cols <- list()
  for (f in inc) cols <- c(cols, glm_term_columns(f, terms[[f]], dat[[f]], bases))
  # columns an interaction needs that the main effects do not already provide
  for (it in inters) for (side in list(c(it$a, it$ak), c(it$b, it$bk))) {
    cn <- glm_kind_col(side[1], side[2])
    if (is.null(cols[[cn]])) cols[[cn]] <- glm_kind_column(side[1], terms[[side[1]]], dat[[side[1]]], bases, side[2])
  }
  mf <- if (length(cols)) as.data.frame(cols, optional = TRUE) else data.frame(row.names = seq_len(nrow(dat)))
  off <- if (!is.null(offset_col)) log(dat[[offset_col]]) else rep(0, nrow(dat))
  if (as.character(model_type) == "1") {
    mf$.y <- dat[[response]]; mf$.w <- 1; off <- off + log(w)
  } else {
    mf$.y <- dat[[response]] / w; mf$.w <- w
  }
  mf$.off <- off
  rhs_parts <- c(unlist(lapply(inc, function(f) glm_term_formula(f, terms[[f]]))), vapply(inters, glm_inter_term, character(1)))
  rhs  <- if (length(rhs_parts)) paste(rhs_parts, collapse = " + ") else "1"
  form <- as.formula(paste(".y ~", rhs))
  fam  <- glm_family_for(model_type, tweedie_p)
  t0   <- Sys.time()
  fit  <- if (is.null(mustart)) {
    suppressWarnings(glm(form, family = fam, data = mf, weights = .w, offset = .off,
                         model = FALSE, x = FALSE, control = glm.control(maxit = 50)))
  } else {
    mf$.mu <- mustart
    suppressWarnings(glm(form, family = fam, data = mf, weights = .w, offset = .off, mustart = .mu,
                         model = FALSE, x = FALSE, control = glm.control(maxit = 50)))
  }
  s    <- summary(fit)
  cf   <- as.data.frame(s$coefficients)
  names(cf) <- c("estimate", "std_error", "statistic", "p_value")
  cf$term <- rownames(cf)
  b <- coef(fit)
  out <- list(terms = terms[used], included = inc, interactions = inters, bases = bases, formula = rhs,
              coef = setNames(ifelse(is.na(b), 0, b), names(b)),
              coef_table = cf[, c("term", "estimate", "std_error", "statistic", "p_value")],
              aliased = names(b)[is.na(b)],
              vcov = s$cov.scaled,   # small (parameters x parameters): used for relativity confidence intervals
              family = glm_family_label(model_type, tweedie_p), model_type = model_type, tweedie_p = tweedie_p,
              deviance = fit$deviance, null_deviance = fit$null.deviance, df_residual = fit$df.residual, df_null = fit$df.null,
              aic = fit$aic, dispersion = s$dispersion, converged = fit$converged, iterations = fit$iter,
              n = nrow(mf), n_params = sum(!is.na(b)), fit_seconds = as.numeric(difftime(Sys.time(), t0, units = "secs")),
              fitted_at = Sys.time(), response = response, exposure = exposure, offset = offset_col,
              linkinv = fam$linkinv,
              # R's own fitted values (same units as the response) on the modelling rows, kept for the relativity check
              fitted = as.numeric(fit$fitted.values * mf$.w))
  rm(fit, s, mf); invisible(gc(verbose = FALSE))
  out
}

# log-scale contribution of one factor's MAIN EFFECT at each of its levels (before rebasing; interactions excluded)
glm_level_lp <- function(model, f, levels) {
  t  <- model$terms[[f]]; b <- model$coef
  cf <- function(n) if (n %in% names(b)) b[[n]] else 0
  lv <- as.character(levels)
  lp <- rep(0, length(lv))
  if (!f %in% model$included) return(lp)
  if (isTRUE(t$var_on)) {
    v  <- t$var_tb$value[match(lv, t$var_tb$level)]
    lp <- lp + cf(paste0(f, "_var")) * v + cf(sprintf("I(%s_var^2)", f)) * v^2 + cf(sprintf("I(%s_var^3)", f)) * v^3
  }
  if (isTRUE(t$cust_on)) {
    g  <- t$cust_tb$group[match(lv, t$cust_tb$level)]
    lp <- lp + vapply(paste0(f, "_custom", g), cf, numeric(1))
  }
  if (!isTRUE(t$var_on) && !isTRUE(t$cust_on)) lp <- lp + vapply(paste0(f, lv), cf, numeric(1))
  unname(lp)
}

# one side of an interaction at each level: the coefficient-name part and the number it multiplies
#   var -> ("f_var", value) · custom -> ("f_custom<group>", 1) · plain -> ("f<level>", 1)
glm_side_parts <- function(model, f, kind, levels) {
  t <- model$terms[[f]]; lv <- as.character(levels)
  switch(kind,
         var    = list(name = rep(paste0(f, "_var"), length(lv)), num = t$var_tb$value[match(lv, t$var_tb$level)]),
         custom = list(name = paste0(f, "_custom", t$cust_tb$group[match(lv, t$cust_tb$level)]), num = rep(1, length(lv))),
         plain  = list(name = paste0(f, lv), num = rep(1, length(lv))))
}
# coefficient name of each (a, b) pair as R names it ("a:b", or "b:a" if R put b first); NA = not a coefficient (base level)
glm_inter_coef_names <- function(model, pa, pb) {
  n1 <- paste0(pa, ":", pb); n2 <- paste0(pb, ":", pa)
  ifelse(n1 %in% names(model$coef), n1, ifelse(n2 %in% names(model$coef), n2, NA_character_))
}
# log contribution of an interaction for every combination of levels: matrix length(la) x length(lb)
glm_inter_matrix <- function(model, it, la, lb) {
  A <- glm_side_parts(model, it$a, it$ak, la); B <- glm_side_parts(model, it$b, it$bk, lb)
  g <- expand.grid(i = seq_along(la), j = seq_along(lb))
  nm <- glm_inter_coef_names(model, A$name[g$i], B$name[g$j])
  cf <- numeric(length(nm)); has <- !is.na(nm)
  cf[has] <- model$coef[nm[has]]
  v  <- cf * A$num[g$i] * B$num[g$j]
  matrix(v, nrow = length(la), ncol = length(lb), dimnames = list(as.character(la), as.character(lb)))
}

# relativities, rebased to each factor's highest-exposure level, plus the base value. With interactions:
#   factor table      : main effect + each interaction evaluated at the partner factor's base level
#   interaction table : I(a,b) - I(a,b0) - I(a0,b) + I(a0,b0)   (1 along the base row and column)
#   base              : intercept + every factor at its base + every interaction at both bases
# so base x factor relativities x interaction relativities reproduces every prediction exactly.
# base_override: optional list(factor = level) to rebase a factor somewhere other than its highest-exposure level.
# Changing a base only re-expresses the relativities (and the base value); predictions are unchanged.
glm_relativities <- function(model, factor_levels, base_override = list()) {
  inters  <- if (is.null(model$interactions)) list() else model$interactions
  facs    <- union(model$included, glm_inter_factors(inters))
  base_of <- function(f) {
    l <- factor_levels[[f]]
    o <- base_override[[f]]
    if (!is.null(o) && o %in% l$level) o else l$level[which.max(l$exposure)]
  }
  rel <- list(); inter_rel <- list(); base_lp <- model$coef[["(Intercept)"]]
  for (f in facs) {
    lvt <- factor_levels[[f]]
    lp  <- glm_level_lp(model, f, lvt$level)
    for (it in inters) {
      if (it$a == f) lp <- lp + glm_inter_matrix(model, it, lvt$level, base_of(it$b))[, 1]
      if (it$b == f) lp <- lp + glm_inter_matrix(model, it, base_of(it$a), lvt$level)[1, ]
    }
    b    <- base_of(f)
    b_lp <- lp[match(b, lvt$level)]
    base_lp <- base_lp + b_lp
    rel[[f]] <- data.frame(level = lvt$level, exposure = lvt$exposure, relativity = exp(lp - b_lp),
                           is_base = lvt$level == b, stringsAsFactors = FALSE)
  }
  for (k in seq_along(inters)) {
    it <- inters[[k]]
    la <- factor_levels[[it$a]]$level; lb <- factor_levels[[it$b]]$level
    a0 <- base_of(it$a); b0 <- base_of(it$b)
    M  <- glm_inter_matrix(model, it, la, lb)
    ia <- match(a0, la); ib <- match(b0, lb)
    base_lp <- base_lp - M[ia, ib]     # each factor table above already carries I(a0,b0) once: take one copy back out
    R  <- M - M[, ib] - matrix(M[ia, ], nrow(M), ncol(M), byrow = TRUE) + M[ia, ib]
    g  <- expand.grid(level_a = la, level_b = lb, stringsAsFactors = FALSE)
    inter_rel[[glm_inter_label(it)]] <- data.frame(g, relativity = exp(as.vector(R)), it_index = k, stringsAsFactors = FALSE)
  }
  list(base = exp(base_lp), base_lp = base_lp, factors = rel, interactions = inter_rel,
       base_levels = setNames(lapply(facs, base_of), facs))
}

# expected response (same units as the response: claim counts, amounts, ...) for each row of a data partition
glm_predict <- function(model, dat) {
  if (!nrow(dat)) return(numeric(0))
  lp <- rep(model$coef[["(Intercept)"]], nrow(dat))
  for (f in model$included) lp <- lp + glm_level_lp(model, f, levels(dat[[f]]))[as.integer(dat[[f]])]
  for (it in model$interactions) {
    M  <- glm_inter_matrix(model, it, levels(dat[[it$a]]), levels(dat[[it$b]]))
    lp <- lp + M[cbind(as.integer(dat[[it$a]]), as.integer(dat[[it$b]]))]
  }
  w <- dat[[model$exposure]]
  if (!is.null(model$offset)) lp <- lp + log(dat[[model$offset]])
  if (as.character(model$model_type) == "1") return(exp(lp + log(w)))
  model$linkinv(lp) * w
}

# ---- relativity check (as relativity_check() in the old scripts) --------------------------------------------------------
# Rebuilds every prediction from the relativity tables alone: base x factor relativities x interaction relativities
# (x exposure, x offset), without touching the coefficients.
glm_predict_from_rel <- function(rel, model, dat) {
  if (!nrow(dat)) return(numeric(0))
  lp <- rep(log(rel$base), nrow(dat))
  for (f in names(rel$factors)) {
    r <- rel$factors[[f]]
    lp <- lp + log(r$relativity[match(as.character(dat[[f]]), r$level)])
  }
  for (k in seq_along(rel$interactions)) {
    r  <- rel$interactions[[k]]; it <- model$interactions[[r$it_index[1]]]
    key <- paste(r$level_a, r$level_b, sep = "\r")
    lp <- lp + log(r$relativity[match(paste(as.character(dat[[it$a]]), as.character(dat[[it$b]]), sep = "\r"), key)])
  }
  w <- dat[[model$exposure]]
  if (!is.null(model$offset)) lp <- lp + log(dat[[model$offset]])
  if (as.character(model$model_type) == "1") return(exp(lp) * w)
  model$linkinv(lp) * w
}
# one row per comparison: totals and the largest row-level relative difference
glm_check_row <- function(label, a, b, actual, tol = 1e-6) {
  d <- abs(a / b - 1); d[!is.finite(d)] <- ifelse(a[!is.finite(d)] == b[!is.finite(d)], 0, Inf)
  data.frame(check = label, rows = length(a), total_a = sum(a), total_b = sum(b), actual = sum(actual),
             max_rel_diff = if (length(d)) max(d) else 0, rows_off = sum(d > tol), pass = all(d <= tol),
             stringsAsFactors = FALSE)
}

# all relativities as one workbook, like the old relativity_output_creation(): a sheet per factor, a sheet per
# interaction (factor a, factor b, relativity) and a Base sheet; an Index sheet records the full names (Excel cuts at 31)
glm_relativity_sheets <- function(rel, model, ci = TRUE) {
  out <- list(); idx <- data.frame(sheet = character(0), content = character(0), stringsAsFactors = FALSE)
  add <- function(name, df, content) {
    sh <- xl_sheet_names(name, reserved = c(names(out), "Index", "Base"))
    out[[sh]] <<- df; idx[nrow(idx) + 1, ] <<- c(sh, content)
  }
  for (f in names(rel$factors)) {
    r <- rel$factors[[f]]
    df <- data.frame(r$level, r$exposure, r$relativity, check.names = FALSE, stringsAsFactors = FALSE)
    names(df) <- c(f, "exposure_modelling", "relativity")
    if (ci && !is.null(r$lower)) { df$lower_95 <- r$lower; df$upper_95 <- r$upper }
    df$base <- ifelse(r$is_base, "base", "")
    add(f, df, f)
  }
  for (k in seq_along(rel$interactions)) {
    r <- rel$interactions[[k]]; it <- model$interactions[[r$it_index[1]]]
    df <- data.frame(r$level_a, r$level_b, r$relativity, check.names = FALSE, stringsAsFactors = FALSE)
    names(df) <- c(it$a, it$b, "relativity")
    if (ci && !is.null(r$lower)) { df$lower_95 <- r$lower; df$upper_95 <- r$upper }
    add(paste0(substr(it$a, 1, 14), "&", substr(it$b, 1, 14)), df, glm_inter_label(it))
  }
  c(list(Index = idx,
         Base = data.frame(item = c("base", "note"),
                           value = c(format(rel$base, digits = 10),
                                     "prediction = base x factor relativities x interaction relativities (x exposure)"))),
    out)
}

# Gini from the gains curve: rows sorted by predicted rate (high first), cumulative exposure vs cumulative actual
# Same calculation as the GBM app (trap_integrate_gini / calculate_gini_score there), so the two tools agree:
#   gains curve  : rows sorted by predicted rate, highest first (stable sort); cumulative exposure vs cumulative response
#   raw Gini     : response read off the curve at exposure 0%, 1%, ..., 100% (linear interpolation), (sum - 0.5)/100 * 2 - 1
#   normalised   : raw Gini of the model / raw Gini of a perfect model that sorts the rows by their actual response
# `score` is the ranking: by default the predicted rate (prediction / exposure).
glm_gini_raw <- function(sort_key, expo, actual) {
  o  <- order(-sort_key)
  ce <- cumsum(expo[o]) / sum(expo); cr <- cumsum(actual[o]) / sum(actual)
  a  <- suppressWarnings(approx(x = ce, y = cr, xout = (0:100) * 0.01, method = "linear"))
  ((sum(a$y, na.rm = TRUE) - 0.5) / 100) * 2 - 1
}
glm_gini <- function(pred, expo, actual, score = pred / expo) {
  if (length(pred) < 2 || sum(actual) <= 0) return(NA_real_)
  glm_gini_raw(score, expo, actual) / glm_gini_raw(actual, expo, actual)
}

# actual / expected / rebased relativity by level of one factor (expected and relativity NA when not available)
glm_factor_summary <- function(dat, f, response, exposure, pred = NULL, rel = NULL, rebase_rate = NA_real_) {
  if (!nrow(dat)) return(NULL)
  d <- data.frame(factor_name = dat[[f]], e = dat[[exposure]], r = dat[[response]],
                  p = if (is.null(pred)) NA_real_ else pred)
  s <- d %>% group_by(factor_name) %>%
    summarise(exposure = sum(e), res_sum = sum(r), pred_sum = sum(p), .groups = "drop") %>%
    mutate(actual = res_sum / exposure, prediction = pred_sum / exposure)
  s <- as.data.frame(s)
  s$relativity_rebased <- if (!is.null(rel)) rebase_rate * rel$relativity[match(as.character(s$factor_name), rel$level)] else NA_real_
  s
}

# one-way fit preview for the editor: a single-factor GLM on level totals (cheap) with the variate / custom structure
glm_oneway_preview <- function(lvl, t, model_type = 1, tweedie_p = 1.5) {
  # lvl: data.frame(level, exposure, res_sum) for the modelling partition, in level order
  keep <- lvl$exposure > 0
  d <- lvl[keep, ]
  if (nrow(d) < 2) return(rep(NA_real_, nrow(lvl)))
  tt <- t; tt$include <- TRUE
  x  <- factor(d$level, levels = lvl$level)
  bases <- list(plain = list(f = glm_base_of(x, d$exposure)), custom = list())
  if (isTRUE(tt$cust_on)) bases$custom$f <- glm_base_of(tt$cust_tb$group[match(d$level, tt$cust_tb$level)], d$exposure)
  mf <- as.data.frame(glm_term_columns("f", tt, x, bases), optional = TRUE)
  if (any(vapply(mf, anyNA, logical(1)))) return(rep(NA_real_, nrow(lvl)))
  rhs <- paste(glm_term_formula("f", tt), collapse = " + ")
  tryCatch({
    if (as.character(model_type) == "1") {
      mf$.y <- d$res_sum; mf$.off <- log(d$exposure)
      fit <- suppressWarnings(glm(as.formula(paste(".y ~", rhs)), family = poisson(), data = mf, offset = .off))
    } else {
      mf$.y <- d$res_sum / d$exposure; mf$.w <- d$exposure
      fit <- suppressWarnings(glm(as.formula(paste(".y ~", rhs)), family = glm_family_for(model_type, tweedie_p),
                                  data = mf, weights = .w))
    }
    b  <- coef(fit)
    m  <- list(terms = list(f = tt), included = "f", coef = setNames(ifelse(is.na(b), 0, b), names(b)))
    lp <- b[["(Intercept)"]] + glm_level_lp(m, "f", lvl$level)
    if (as.character(model_type) == "4") plogis(lp) else exp(lp)
  }, error = function(e) rep(NA_real_, nrow(lvl)))
}

# old Excel workflow: Factor_formats_variate_*.xlsx (current_factor_level, variate_level_all) and
# Factor_formats_custom_*.xlsx (current_factor_level, custom_level_all); tabs named by raw or model name.
# Tables saved from the app (level + value / group) are read too.
read_term_workbook <- function(path) {
  sheets <- readxl::excel_sheets(path)
  out <- lapply(sheets, function(s) {
    x <- as.data.frame(readxl::read_excel(path, sheet = s, col_types = "text"))
    lcol <- intersect(c("current_factor_level", "level"), names(x))[1]
    if (is.na(lcol)) return(NULL)
    lvl <- x[[lcol]]; lvl[is.na(lvl) | lvl %in% c("NaN", "")] <- "NA"
    if ("variate_level_all" %in% names(x)) return(list(kind = "variate", level = lvl, value = suppressWarnings(as.numeric(x$variate_level_all))))
    if ("value" %in% names(x))             return(list(kind = "variate", level = lvl, value = suppressWarnings(as.numeric(x$value))))
    if ("custom_level_all" %in% names(x))  return(list(kind = "custom",  level = lvl, group = as.character(x$custom_level_all)))
    if ("group" %in% names(x))             return(list(kind = "custom",  level = lvl, group = as.character(x$group)))
    NULL
  })
  setNames(out, sheets)
}
# numbers read as text from Excel ("2" vs "2.0", "1e+05") are matched on their numeric value
glm_match_levels <- function(file_levels, levels) {
  i  <- match(file_levels, levels)
  fn <- suppressWarnings(as.numeric(file_levels)); ln <- suppressWarnings(as.numeric(levels))
  miss <- is.na(i) & !is.na(fn)
  if (any(miss)) i[miss] <- match(fn[miss], ln)
  i
}

# parse a formula like the old scripts' glm_formula_right into term definitions
glm_parse_formula <- function(txt) {
  parts <- trimws(unlist(strsplit(gsub("[\r\n]", " ", txt), "+", fixed = TRUE)))
  parts <- gsub("\\s", "", parts)
  parts <- parts[parts != "" & parts != "1"]
  res <- list(); skipped <- character(0); inters <- list()
  get <- function(f) if (is.null(res[[f]])) list(var = FALSE, order = 1L, cust = FALSE, plain = FALSE) else res[[f]]
  side <- function(s) {
    if (grepl("^I\\(", s)) return(NULL)                       # powers inside interactions are not supported
    if (grepl("_var$", s))    return(list(f = sub("_var$", "", s), k = "var"))
    if (grepl("_custom$", s)) return(list(f = sub("_custom$", "", s), k = "custom"))
    list(f = s, k = "plain")
  }
  for (p in parts) {
    if (grepl(":", p, fixed = TRUE)) {
      s <- strsplit(p, ":", fixed = TRUE)[[1]]
      if (length(s) != 2) { skipped <- c(skipped, p); next }     # two-way interactions only
      a <- side(s[1]); b <- side(s[2])
      if (is.null(a) || is.null(b) || a$f == b$f) { skipped <- c(skipped, p); next }
      inters[[length(inters) + 1]] <- glm_new_interaction(a$f, a$k, b$f, b$k)
      next
    }
    pat <- "^I\\((.+)_var\\^([23])\\)$"
    if (grepl(pat, p)) {
      f <- sub(pat, "\\1", p); r <- get(f)
      r$var <- TRUE; r$order <- max(r$order, as.integer(sub(pat, "\\2", p))); res[[f]] <- r; next
    }
    if (grepl("_var$", p))    { f <- sub("_var$", "", p);    r <- get(f); r$var  <- TRUE; res[[f]] <- r; next }
    if (grepl("_custom$", p)) { f <- sub("_custom$", "", p); r <- get(f); r$cust <- TRUE; res[[f]] <- r; next }
    r <- get(p); r$plain <- TRUE; res[[p]] <- r
  }
  list(terms = res, interactions = inters, skipped = skipped)
}


# =================================================================================================================================
# STAGE 3: confidence intervals, gains / lift, two-way, reference model
# =================================================================================================================================

# design of one factor: for each level, the derivative of its log contribution with respect to each of the factor's
# coefficients (the contribution is linear in the coefficients, so this is exact)
glm_level_design <- function(model, f, levels) {
  t  <- model$terms[[f]]
  lv <- as.character(levels)
  cols <- list()
  if (isTRUE(t$var_on)) {
    v <- t$var_tb$value[match(lv, t$var_tb$level)]
    cols[[paste0(f, "_var")]] <- v
    if (t$var_order >= 2) cols[[sprintf("I(%s_var^2)", f)]] <- v^2
    if (t$var_order >= 3) cols[[sprintf("I(%s_var^3)", f)]] <- v^3
  }
  if (isTRUE(t$cust_on)) {
    g <- t$cust_tb$group[match(lv, t$cust_tb$level)]
    for (grp in setdiff(unique(t$cust_tb$group), model$bases$custom[[f]])) cols[[paste0(f, "_custom", grp)]] <- as.numeric(g == grp)
  }
  if (!isTRUE(t$var_on) && !isTRUE(t$cust_on)) {
    for (l in setdiff(lv, model$bases$plain[[f]])) cols[[paste0(f, l)]] <- as.numeric(lv == l)
  }
  m <- do.call(cbind, cols)
  if (is.null(m)) m <- matrix(0, length(lv), 0)
  m[is.na(m)] <- 0
  m
}

# design of an interaction for paired level vectors la[i], lb[i]: one row per pair, one column per coefficient used
glm_inter_design <- function(model, it, la, lb) {
  A  <- glm_side_parts(model, it$a, it$ak, la); B <- glm_side_parts(model, it$b, it$bk, lb)
  nm <- glm_inter_coef_names(model, A$name, B$name)
  cols <- unique(nm[!is.na(nm)])
  m <- matrix(0, length(la), length(cols), dimnames = list(NULL, cols))
  ok <- !is.na(nm)
  if (any(ok)) m[cbind(which(ok), match(nm[ok], cols))] <- (A$num * B$num)[ok]
  m[is.na(m)] <- 0
  m
}
# adds two design matrices with the same rows, matching their columns by name
glm_mat_add <- function(m1, m2) {
  cn  <- union(colnames(m1), colnames(m2))
  out <- matrix(0, max(nrow(m1), nrow(m2)), length(cn), dimnames = list(NULL, cn))
  if (ncol(m1)) out[, colnames(m1)] <- out[, colnames(m1)] + m1
  if (ncol(m2)) out[, colnames(m2)] <- out[, colnames(m2)] + m2
  out
}
# standard errors from a matrix of contrasts (rows) over coefficient names (columns)
glm_contrast_se <- function(model, D) {
  if (is.null(model$vcov) || !ncol(D)) return(rep(NA_real_, nrow(D)))
  D <- D[, colnames(D) %in% colnames(model$vcov), drop = FALSE]
  if (!ncol(D)) return(rep(0, nrow(D)))
  V <- model$vcov[colnames(D), colnames(D), drop = FALSE]
  sqrt(pmax(rowSums((D %*% V) * D), 0))
}

# adds 95% confidence limits to the factor and interaction tables of glm_relativities()
glm_add_ci <- function(rel, model, z = qnorm(0.975)) {
  inters <- if (is.null(model$interactions)) list() else model$interactions
  b0 <- rel$base_levels
  for (f in names(rel$factors)) {
    r <- rel$factors[[f]]
    X <- if (f %in% model$included) glm_level_design(model, f, r$level) else matrix(0, nrow(r), 0)
    if (is.null(colnames(X))) colnames(X) <- character(0)
    for (it in inters) {
      if (it$a == f) X <- glm_mat_add(X, glm_inter_design(model, it, r$level, rep(b0[[it$b]], nrow(r))))
      if (it$b == f) X <- glm_mat_add(X, glm_inter_design(model, it, rep(b0[[it$a]], nrow(r)), r$level))
    }
    D  <- sweep(X, 2, X[which(r$is_base), ], "-")
    se <- glm_contrast_se(model, D)
    r$se <- se; r$lower <- r$relativity * exp(-z * se); r$upper <- r$relativity * exp(z * se)
    rel$factors[[f]] <- r
  }
  for (k in seq_along(rel$interactions)) {
    r  <- rel$interactions[[k]]; it <- inters[[r$it_index[1]]]
    a0 <- b0[[it$a]]; bb <- b0[[it$b]]; n <- nrow(r)
    D  <- glm_mat_add(glm_mat_add(glm_inter_design(model, it, r$level_a, r$level_b),
                                  -glm_inter_design(model, it, r$level_a, rep(bb, n))),
                      glm_mat_add(-glm_inter_design(model, it, rep(a0, n), r$level_b),
                                  glm_inter_design(model, it, rep(a0, n), rep(bb, n))))
    se <- glm_contrast_se(model, D)
    r$se <- se; r$lower <- r$relativity * exp(-z * se); r$upper <- r$relativity * exp(z * se)
    rel$interactions[[k]] <- r
  }
  rel
}

# gains curve: rows sorted by predicted rate (highest first); thinned to n points for drawing
glm_gains <- function(pred, expo, actual, n = 400, score = pred / expo) {
  if (!length(pred)) return(NULL)
  o  <- order(-score)
  ce <- c(0, cumsum(expo[o]) / sum(expo)); cr <- c(0, cumsum(actual[o]) / sum(actual))
  idx <- unique(round(seq(1, length(ce), length.out = min(n, length(ce)))))
  data.frame(cumulative_exposure = ce[idx], cumulative_response = cr[idx])
}

# lift table: exposure-weighted bands of predicted rate (band 1 = lowest), actual vs expected per band
glm_lift <- function(pred, expo, actual, n_bands = 10) {
  if (!length(pred)) return(NULL)
  rate <- pred / expo
  o    <- order(rate)
  cum  <- cumsum(expo[o]) / sum(expo)
  band <- integer(length(rate))
  band[o] <- pmin(n_bands, floor(cum * n_bands - 1e-9) + 1)
  data.frame(band = band, e = expo, a = actual, p = pred) %>%
    group_by(band) %>%
    summarise(exposure = sum(e), actual = sum(a) / sum(e), expected = sum(p) / sum(e), .groups = "drop") %>%
    as.data.frame()
}

mt_partition_colours <- c(Modelling = "#2563eb", Holdout = "#e11d48", Validation = "#0d9488")

mt_plotly_config <- function(p, filename) {
  p %>% config(displaylogo = FALSE,
               modeBarButtonsToRemove = c("lasso2d", "select2d", "autoScale2d", "hoverClosestCartesian",
                                          "hoverCompareCartesian", "toggleSpikelines"),
               toImageButtonOptions = list(format = "png", filename = filename, scale = 2))
}

# gains curves of every partition on one chart, Gini in the legend; optional reference model curves (dashed)
plot_glm_gains <- function(gains, gini, gains_ref = NULL, gini_ref = NULL, gains_perfect = NULL) {
  p <- plot_ly() %>%
    add_trace(x = c(0, 1), y = c(0, 1), type = "scatter", mode = "lines", name = "Random",
              line = list(color = "#cbd5e1", dash = "dash", width = 1.2), hoverinfo = "skip")
  # perfect model (rows sorted by actual response) for the modelling partition: the upper bound the Gini is scaled by
  if (!is.null(gains_perfect))
    p <- p %>% add_trace(x = gains_perfect$cumulative_exposure, y = gains_perfect$cumulative_response, type = "scatter",
                         mode = "lines", name = "Perfect (modelling)", line = list(color = "#94a3b8", width = 1.2, dash = "dot"),
                         hovertemplate = "Exposure %{x:.0%}<br>Response %{y:.1%}<extra>Perfect</extra>")
  for (k in names(gains)) {
    p <- p %>% add_trace(x = gains[[k]]$cumulative_exposure, y = gains[[k]]$cumulative_response, type = "scatter", mode = "lines",
                         name = sprintf("%s · Gini %.1f%%", k, 100 * gini[[k]]),
                         line = list(color = unname(mt_partition_colours[k]), width = 2.2),
                         hovertemplate = paste0("Exposure %{x:.0%}<br>Response %{y:.1%}<extra>", k, "</extra>"))
    if (!is.null(gains_ref[[k]]))
      p <- p %>% add_trace(x = gains_ref[[k]]$cumulative_exposure, y = gains_ref[[k]]$cumulative_response, type = "scatter",
                           mode = "lines", name = sprintf("%s (reference) · Gini %.1f%%", k, 100 * gini_ref[[k]]),
                           line = list(color = unname(mt_partition_colours[k]), width = 1.6, dash = "dot"),
                           hovertemplate = paste0("Exposure %{x:.0%}<br>Response %{y:.1%}<extra>", k, " reference</extra>"))
  }
  p %>% layout(font = list(family = mt_font_family, size = 12, color = mt_chart_colours$text),
               paper_bgcolor = "white", plot_bgcolor = "white", hovermode = "closest",
               margin = list(l = 60, r = 20, t = 20, b = 90),
               legend = list(orientation = "h", x = 0.5, y = -0.2, xanchor = "center", yanchor = "top", bgcolor = "rgba(0,0,0,0)"),
               xaxis = list(title = "Cumulative exposure (highest prediction first)", tickformat = ".0%", range = c(0, 1),
                            gridcolor = mt_chart_colours$grid, zeroline = FALSE),
               yaxis = list(title = "Cumulative response", tickformat = ".0%", range = c(0, 1.02),
                            gridcolor = mt_chart_colours$grid, zeroline = FALSE)) %>%
    mt_plotly_config("gains_curve")
}

# lift chart: exposure bars per band, actual and expected rate lines (+ reference expected)
plot_glm_lift <- function(lift, lift_ref = NULL, rate_label = "Rate") {
  d <- lift
  d$band <- factor(d$band)
  p <- plot_ly(d, x = ~band) %>%
    add_trace(y = ~exposure, type = "bar", name = "Exposure",
              marker = list(color = mt_chart_colours$exposure, line = list(color = mt_chart_colours$exposure_line, width = 1)),
              hovertemplate = "%{y:,.0f}") %>%
    add_trace(y = ~actual, type = "scatter", mode = "lines+markers", yaxis = "y2", name = "Actual",
              line = list(color = mt_chart_colours$actual, width = 2.2), marker = list(color = mt_chart_colours$actual, size = 6),
              hovertemplate = "%{y:.4f}") %>%
    add_trace(y = ~expected, type = "scatter", mode = "lines+markers", yaxis = "y2", name = "Expected",
              line = list(color = mt_chart_colours$expected, width = 2.2), marker = list(color = mt_chart_colours$expected, size = 6),
              hovertemplate = "%{y:.4f}")
  if (!is.null(lift_ref))
    p <- p %>% add_trace(x = factor(lift_ref$band), y = lift_ref$actual, type = "scatter", mode = "lines+markers", yaxis = "y2",
                         name = "Actual (reference bands)", line = list(color = mt_chart_colours$expected_ref, width = 1.6, dash = "dash"),
                         marker = list(color = mt_chart_colours$expected_ref, size = 5), hovertemplate = "%{y:.4f}")
  mt_oneway_layout(p, "Band of predicted rate (1 = lowest)", nrow(d)) %>%
    layout(yaxis2 = list(title = list(text = rate_label))) %>%
    mt_plotly_config("lift_chart")
}

# two-way actual vs expected: one colour per level of factor b; actual solid, expected dashed; exposure below
glm_two_way_summary <- function(dat, fa, fb, response, exposure, pred) {
  data.frame(a = dat[[fa]], b = dat[[fb]], e = dat[[exposure]], r = dat[[response]], p = pred) %>%
    group_by(a, b) %>%
    summarise(exposure = sum(e), actual = sum(r) / sum(e), expected = sum(p) / sum(e), .groups = "drop") %>%
    as.data.frame()
}
plot_glm_two_way <- function(s, fa, fb, rate_label = "Rate", show_expected = TRUE) {
  lv_b <- levels(droplevels(factor(s$b)))
  n_a  <- length(unique(s$a))
  if (n_a > MT_MAX_CHART_LEVELS) return(mt_too_many_levels_plot(fa, n_a))
  if (length(lv_b) > MT_MAX_TWO_WAY_LINES)
    return(mt_message_plot(sprintf("%s has %d levels: too many lines for a two-way chart (limit %d)", fb, length(lv_b), MT_MAX_TWO_WAY_LINES),
                           c("Swap the two factors so the one with fewer levels is drawn as lines,",
                             "or group its levels on the Factor mapping tab.")))
  cols <- rep(mt_series_palette, length.out = length(lv_b))
  top <- plot_ly()
  bot <- plot_ly()
  for (i in seq_along(lv_b)) {
    d <- s[as.character(s$b) == lv_b[i], ]
    top <- top %>% add_trace(x = d$a, y = d$actual, type = "scatter", mode = "lines+markers", name = lv_b[i], legendgroup = lv_b[i],
                             line = list(color = cols[i], width = 2), marker = list(color = cols[i], size = 5),
                             hovertemplate = paste0(fb, " ", lv_b[i], "<br>Actual %{y:.4f}<extra></extra>"))
    if (show_expected)
      top <- top %>% add_trace(x = d$a, y = d$expected, type = "scatter", mode = "lines", name = paste(lv_b[i], "expected"),
                               legendgroup = lv_b[i], showlegend = FALSE, line = list(color = cols[i], width = 1.6, dash = "dash"),
                               hovertemplate = paste0(fb, " ", lv_b[i], "<br>Expected %{y:.4f}<extra></extra>"))
    bot <- bot %>% add_trace(x = d$a, y = d$exposure, type = "bar", name = lv_b[i], legendgroup = lv_b[i], showlegend = FALSE,
                             marker = list(color = cols[i]), hovertemplate = paste0(fb, " ", lv_b[i], "<br>Exposure %{y:,.0f}<extra></extra>"))
  }
  subplot(top, bot, nrows = 2, shareX = TRUE, heights = c(0.68, 0.32), titleY = TRUE) %>%
    layout(font = list(family = mt_font_family, size = 12, color = mt_chart_colours$text),
           paper_bgcolor = "white", plot_bgcolor = "white", barmode = "stack", hovermode = "x unified",
           margin = list(l = 60, r = 20, t = 30, b = 60),
           legend = list(orientation = "h", x = 0, y = 1.04, xanchor = "left", yanchor = "bottom", bgcolor = "rgba(0,0,0,0)",
                         title = list(text = paste0(fb, ": "))),
           xaxis  = list(type = "category", showgrid = FALSE, categoryorder = "array", categoryarray = levels(droplevels(factor(s$a)))),
           xaxis2 = list(type = "category", title = fa, showgrid = FALSE, categoryorder = "array", categoryarray = levels(droplevels(factor(s$a)))),
           yaxis  = list(title = paste0(rate_label, if (show_expected) " (solid actual · dashed expected)"), gridcolor = mt_chart_colours$grid, zeroline = FALSE),
           yaxis2 = list(title = "Exposure", gridcolor = mt_chart_colours$grid, zeroline = FALSE, tickformat = "~s")) %>%
    mt_plotly_config(paste0(fa, "_by_", fb))
}


# relativity chart of one factor: exposure bars, relativity line with its 95% band, a line at 1, the base level marked,
# and optionally the reference model's relativity (dotted)
plot_glm_relativity <- function(r, fac, ref = NULL, show_ci = TRUE) {
  lv <- r$level
  if (length(lv) > MT_MAX_CHART_LEVELS) return(mt_too_many_levels_plot(fac, length(lv)))
  x  <- factor(lv, levels = lv)
  ok_ci <- !is.null(r$lower) & is.finite(r$upper / r$lower) & (r$upper / r$lower) <= 1e4   # drop exploding bands
  lo <- ifelse(ok_ci, r$lower, NA); hi <- ifelse(ok_ci, r$upper, NA)
  hov <- sprintf("<b>%s</b><br>Relativity %.4f%s<br>Exposure %s", lv, r$relativity,
                 ifelse(r$is_base, " (base)", ifelse(is.na(lo), "", sprintf("<br>95%%: %.3f – %.3f", lo, hi))),
                 formatC(r$exposure, format = "f", digits = 0, big.mark = ","))
  p <- plot_ly() %>%
    add_trace(x = x, y = r$exposure, type = "bar", name = "Exposure (modelling)", hoverinfo = "skip",
              marker = list(color = mt_chart_colours$exposure, line = list(color = mt_chart_colours$exposure_line, width = 1)))
  if (show_ci && any(!is.na(lo)))
    p <- p %>%
      add_trace(x = x, y = lo, type = "scatter", mode = "lines", yaxis = "y2", showlegend = FALSE, legendgroup = "ci",
                line = list(color = "rgba(22,163,74,0)", width = 0), hoverinfo = "skip", connectgaps = FALSE) %>%
      add_trace(x = x, y = hi, type = "scatter", mode = "lines", yaxis = "y2", name = "95% confidence band", legendgroup = "ci",
                fill = "tonexty", fillcolor = "rgba(22,163,74,0.13)", line = list(color = "rgba(22,163,74,0)", width = 0),
                hoverinfo = "skip", connectgaps = FALSE)
  p <- p %>%
    add_trace(x = x, y = rep(1, length(lv)), type = "scatter", mode = "lines", yaxis = "y2", name = "1 (base)",
              line = list(color = "#94a3b8", width = 1, dash = "dash"), hoverinfo = "skip", showlegend = FALSE)
  if (!is.null(ref))
    p <- p %>% add_trace(x = x, y = ref$relativity[match(lv, ref$level)], type = "scatter", mode = "lines+markers", yaxis = "y2",
                         name = "Reference model", line = list(color = "#7c3aed", width = 1.8, dash = "dot"),
                         marker = list(color = "#7c3aed", size = 5, symbol = "diamond-open"),
                         hovertemplate = "Reference %{y:.4f}<extra></extra>")
  p <- p %>%
    add_trace(x = x, y = r$relativity, type = "scatter", mode = "lines+markers", yaxis = "y2", name = "Relativity",
              line = list(color = "#16a34a", width = 2.6),
              marker = list(color = ifelse(r$is_base, "#f59e0b", "#16a34a"), size = ifelse(r$is_base, 12, 7),
                            symbol = ifelse(r$is_base, "star", "circle"), line = list(color = "white", width = 1)),
              text = hov, hoverinfo = "text")
  b <- which(r$is_base)
  p <- mt_oneway_layout(p, fac, length(lv)) %>%
    layout(yaxis  = list(title = list(text = "Exposure (modelling)")),
           yaxis2 = list(title = list(text = "Relativity"), rangemode = "normal", zeroline = FALSE),
           hovermode = "closest",
           xaxis = list(categoryorder = "array", categoryarray = lv),
           annotations = if (length(b)) list(list(x = b - 1, y = 1, xref = "x", yref = "y2", text = "base", showarrow = TRUE,
                                                  arrowhead = 0, ax = 0, ay = -28, font = list(color = "#b45309", size = 11),
                                                  bgcolor = "#fffbeb", bordercolor = "#fde68a", borderpad = 3)) else list())
  if (length(lv) <= 50) p <- p %>% layout(xaxis = list(tickmode = "linear", tick0 = 0, dtick = 1))
  p %>% mt_plotly_config(paste0(fac, "_relativity"))
}


# guards against factors with too many levels / models too big to fit ---------------------------------------------------
# Limits that keep the app responsive. Raise them on a machine with more memory.
MT_MAX_CHART_LEVELS  <- 500    # one-way / relativity charts: above this a message is shown instead of the chart
MT_MAX_TWO_WAY_LINES <- 30     # two-way chart: most levels allowed for the second factor (one line each)
MT_MAX_MAP_LEVELS    <- 3000   # mapping and variate / custom editors: hand-editable tables up to this many levels
MT_MAX_TABLE_LEVELS  <- 1000   # relativity table: rows shown before it is replaced by a message
MT_MAX_GLM_PARAMS    <- 1500   # most parameters a fit may have (fitting time grows with the square of this)
MT_GLM_COPIES        <- 4      # peak memory of glm() is about this many copies of the design matrix

# a blank chart that carries a message instead of data
mt_message_plot <- function(title, body = NULL) {
  txt <- paste0("<b>", htmltools::htmlEscape(title), "</b>",
                if (length(body)) paste0("<br><br>", paste(htmltools::htmlEscape(body), collapse = "<br>")))
  plotly_empty(type = "scatter", mode = "markers") %>%
    layout(xaxis = list(visible = FALSE), yaxis = list(visible = FALSE), yaxis2 = list(visible = FALSE),
           paper_bgcolor = "white", plot_bgcolor = "white",
           annotations = list(list(text = txt, x = 0.5, y = 0.5, xref = "paper", yref = "paper",
                                   showarrow = FALSE, align = "center",
                                   font = list(family = mt_font_family, size = 13, color = "#475569")))) %>%
    config(displayModeBar = FALSE)
}
mt_too_many_levels_plot <- function(fac, n_levels, limit = MT_MAX_CHART_LEVELS) {
  mt_message_plot(sprintf("%s has %s levels: too many to chart (limit %s)", fac,
                          formatC(n_levels, format = "d", big.mark = ","), formatC(limit, format = "d", big.mark = ",")),
                  c("Group it on the Factor mapping tab first:",
                    "Auto or custom banding for a numeric factor, or give levels the same new value for a categorical one.",
                    "Or leave it out of the rating factors (step 2)."))
}

# modal used when an action fails or is blocked: what happened, the error text, and what to change
mt_error_modal <- function(title, msg = NULL, hints = NULL, extra = NULL) {
  showModal(modalDialog(
    title = tagList(icon("triangle-exclamation", style = "color:#dc2626"), " ", title),
    if (length(msg)) div(style = "font-family: monospace; font-size: 12px; background: #fef2f2; border: 1px solid #fecaca; border-radius: 6px; padding: 8px 10px; margin-bottom: 12px; white-space: pre-wrap; max-height: 160px; overflow: auto;", msg),
    extra,
    if (length(hints)) tagList(tags$b("What you can do"), tags$ul(style = "margin-top: 6px;", lapply(hints, function(h) tags$li(HTML(h))))),
    easyClose = TRUE, footer = modalButton("OK")))
}

# number of GLM parameters each included term and interaction adds (intercept not counted)
glm_term_params <- function(t) {
  n <- 0
  if (isTRUE(t$var_on))  n <- n + t$var_order
  if (isTRUE(t$cust_on)) n <- n + length(unique(t$cust_tb$group)) - 1
  if (!isTRUE(t$var_on) && !isTRUE(t$cust_on)) n <- nrow(t$var_tb) - 1
  n
}
glm_kind_width <- function(t, kind) switch(kind, var = 1, custom = length(unique(t$cust_tb$group)), plain = nrow(t$var_tb))
# Checks a model definition before fitting: parameters per term, and whether the design matrix (rows x parameters,
# a few copies at peak) fits in the memory available now.
glm_fit_check <- function(terms, inters, n_rows) {
  inc <- names(terms)[vapply(terms, function(t) isTRUE(t$include), logical(1))]
  p <- c(vapply(inc, function(f) glm_term_params(terms[[f]]), numeric(1)),
         vapply(inters, function(it) {
           ta <- terms[[it$a]]; tb <- terms[[it$b]]
           if (is.null(ta) || is.null(tb)) return(0)
           as.numeric(glm_kind_width(ta, it$ak)) * glm_kind_width(tb, it$bk)   # upper bound
         }, numeric(1)))
  names(p)[seq_along(inters) + length(inc)] <- vapply(inters, glm_inter_label, character(1))
  n_par <- sum(p) + 1
  gb    <- n_rows * n_par * 8 / 1024^3
  avail <- tryCatch(ps::ps_system_memory()$avail / 1024^3, error = function(e) NA_real_)
  need  <- gb * MT_GLM_COPIES
  list(params = sort(p, decreasing = TRUE), n_params = n_par, n_rows = n_rows, gb = gb, need_gb = need, avail_gb = avail,
       too_many = n_par > MT_MAX_GLM_PARAMS, too_big = !is.na(avail) && need > 0.8 * avail)
}

# ---- feature importance ------------------------------------------------------------------------------------------------
# One row per model term (each factor's main effect and each interaction):
#   wald      : Wald chi-square of all the term's coefficients together (b' V^-1 b), from the stored covariance; no refit
#   spread    : exposure-weighted standard deviation over the modelling rows of the term's contribution to log(prediction),
#               i.e. how much the term moves the price (0.10 ~ a typical +/-10% effect)
#   drop-one  : deviance increase when the term is taken out and the model refitted (likelihood-ratio / "Type III");
#               the GLM counterpart of the GBM's share of gain. Scaled by the dispersion, so it is a chi-square for
#               every family (exact for Poisson).

# the terms of a fitted model: list(key, label, kind = "factor"/"interaction", factor or interaction index)
glm_model_terms <- function(model) {
  c(lapply(model$included, function(f) list(key = f, label = f, kind = "factor", f = f)),
    lapply(seq_along(model$interactions), function(k)
      list(key = paste0("ia", k), label = glm_inter_label(model$interactions[[k]]), kind = "interaction", k = k)))
}
# coefficient names that belong to a term (base levels / aliased coefficients left out)
glm_term_coef_names <- function(model, term) {
  nm <- if (term$kind == "factor") {
    colnames(glm_level_design(model, term$f, model$terms[[term$f]]$var_tb$level))
  } else {
    it <- model$interactions[[term$k]]
    la <- model$terms[[it$a]]$var_tb$level; lb <- model$terms[[it$b]]$var_tb$level
    g  <- expand.grid(i = seq_along(la), j = seq_along(lb))
    colnames(glm_inter_design(model, it, la[g$i], lb[g$j]))
  }
  intersect(nm, colnames(model$vcov))
}
# log-scale contribution of a term on every row of dat
glm_term_lp <- function(model, term, dat) {
  if (term$kind == "factor") {
    x <- dat[[term$f]]
    glm_level_lp(model, term$f, levels(x))[as.integer(x)]
  } else {
    it <- model$interactions[[term$k]]
    M  <- glm_inter_matrix(model, it, levels(dat[[it$a]]), levels(dat[[it$b]]))
    M[cbind(as.integer(dat[[it$a]]), as.integer(dat[[it$b]]))]
  }
}
# instant measures: Wald chi-square and spread, for every term
glm_importance_quick <- function(model, dat) {
  w <- dat[[model$exposure]]
  rows <- lapply(glm_model_terms(model), function(tm) {
    cn <- glm_term_coef_names(model, tm)
    wald <- if (length(cn)) tryCatch({
      b <- model$coef[cn]; V <- model$vcov[cn, cn, drop = FALSE]
      # standardise first: variate powers (e.g. mileage^3) give coefficients on wildly different scales, which makes
      # V look singular to solve(). The Wald statistic is unchanged by this rescaling.
      s <- sqrt(diag(V)); z <- b / s; R <- V / outer(s, s)
      as.numeric(crossprod(z, solve(R, z, tol = 1e-14)))
    }, error = function(e) NA_real_) else NA_real_
    lp <- glm_term_lp(model, tm, dat)
    ok <- is.finite(lp)
    mu <- sum(w[ok] * lp[ok]) / sum(w[ok])
    data.frame(key = tm$key, term = tm$label, kind = tm$kind, params = length(cn),
               wald = wald, wald_p = if (is.na(wald) || !length(cn)) NA_real_ else pchisq(wald, length(cn), lower.tail = FALSE),
               spread = sqrt(sum(w[ok] * (lp[ok] - mu)^2) / sum(w[ok])), stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, rows)
  out$wald_share <- out$wald / sum(out$wald, na.rm = TRUE)
  out
}
# drop-one refits. progress(i, n, label) is called before each refit. Returns key, deviance increase, df, chi-square, p.
glm_importance_drop_one <- function(model, dat, progress = NULL) {
  terms <- glm_model_terms(model)
  w  <- dat[[model$exposure]]
  # start each refit from the full model's fitted means (same scale as the fitted response)
  mu <- if (as.character(model$model_type) == "1") model$fitted else model$fitted / w
  if (length(mu) != nrow(dat)) mu <- NULL
  phi <- if (is.finite(model$dispersion) && model$dispersion > 0) model$dispersion else 1
  rows <- lapply(seq_along(terms), function(i) {
    tm <- terms[[i]]
    if (!is.null(progress)) progress(i, length(terms), tm$label)
    tl <- model$terms; ia <- model$interactions
    if (tm$kind == "factor") tl[[tm$f]]$include <- FALSE else ia <- ia[-tm$k]
    r <- glm_fit_model(dat, tl, model$response, model$exposure, model$offset, model$model_type, model$tweedie_p,
                       inters = ia, mustart = mu)
    dd <- r$deviance - model$deviance; df <- model$n_params - r$n_params
    data.frame(key = tm$key, dev_increase = dd, df = df, chisq = dd / phi,
               drop_p = if (df > 0) pchisq(max(dd / phi, 0), df, lower.tail = FALSE) else NA_real_,
               converged = isTRUE(r$converged), iterations = r$iterations, stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, rows)
  out$drop_share <- pmax(out$dev_increase, 0) / sum(pmax(out$dev_increase, 0))
  out
}
# horizontal bars, largest at the top (as the GBM app's importance chart); value = share (0-1) or spread
plot_glm_importance <- function(imp, value, measure = c("share", "spread"), xlab = "") {
  measure <- match.arg(measure)
  d <- data.frame(term = imp$term, kind = imp$kind, v = value, stringsAsFactors = FALSE)
  d <- d[is.finite(d$v), ]
  d <- d[order(d$v), ]
  d$term <- factor(d$term, levels = d$term)
  lab <- if (measure == "share") sprintf("%.1f%%", 100 * d$v) else sprintf("±%.1f%%", 100 * (exp(d$v) - 1))
  hov <- if (measure == "share") "%{y}<br>%{x:.1%} of total<extra></extra>" else "%{y}<br>spread %{x:.3f} on log scale<extra></extra>"
  plot_ly(d, x = ~v, y = ~term, type = "bar", orientation = "h",
          marker = list(color = ifelse(d$kind == "interaction", mt_chart_colours$shap_ref, mt_chart_colours$expected)),
          text = lab, textposition = "outside", cliponaxis = FALSE, hovertemplate = hov) %>%
    layout(font = list(family = mt_font_family, size = 12, color = mt_chart_colours$text),
           paper_bgcolor = "white", plot_bgcolor = "white", bargap = 0.3,
           margin = list(l = 10, r = 70, t = 10, b = 50),
           xaxis = list(title = xlab, tickformat = if (measure == "share") ".0%" else ".2f",
                        gridcolor = mt_chart_colours$grid, zeroline = FALSE),
           yaxis = list(title = "", automargin = TRUE, tickfont = list(size = 11))) %>%
    mt_plotly_config("glm_feature_importance")
}

# ---- interaction chart: actual vs rebased relativity by cell ----------------------------------------------------------
# One row per (level_a, level_b) cell of an interaction. Rebased relativity is the combined effect of the two factors
# (factor a relativity x factor b relativity x interaction relativity) times the average actual rate of the modelling
# data, the two-way version of the factor view's rebased relativity line. Actual is NA for cells with no exposure.
glm_inter_summary <- function(dat, it, response, exposure, rel, rate) {
  r  <- rel$interactions[[glm_inter_label(it)]]
  ra <- rel$factors[[it$a]]; rb <- rel$factors[[it$b]]
  s  <- data.frame(level_a = r$level_a, level_b = r$level_b, interaction = r$relativity, stringsAsFactors = FALSE)
  s$combined <- ra$relativity[match(s$level_a, ra$level)] * rb$relativity[match(s$level_b, rb$level)] * s$interaction
  s$relativity_rebased <- rate * s$combined
  s$exposure <- 0; s$res_sum <- 0
  if (nrow(dat)) {
    g <- data.frame(a = as.character(dat[[it$a]]), b = as.character(dat[[it$b]]),
                    e = dat[[exposure]], y = dat[[response]], stringsAsFactors = FALSE) %>%
      group_by(a, b) %>% summarise(e = sum(e), y = sum(y), .groups = "drop")
    k <- match(paste(s$level_a, s$level_b, sep = "\r"), paste(g$a, g$b, sep = "\r"))
    s$exposure <- ifelse(is.na(k), 0, g$e[k]); s$res_sum <- ifelse(is.na(k), 0, g$y[k])
  }
  s$actual <- ifelse(s$exposure > 0, s$res_sum / s$exposure, NA_real_)
  s
}

# one colour per level of the series factor: actual solid, rebased relativity dashed (one legend entry toggles both)
# x_col / s_col: "level_a" or "level_b", so the same summary draws either way round
plot_glm_inter_ave <- function(s, x_name, s_name, x_col, s_col, model_type = 1, show_actual = TRUE) {
  xl <- unique(s[[x_col]]); sl <- unique(s[[s_col]])
  cols <- rep(mt_series_palette, length.out = length(sl))
  ylab <- mt_rate_label(model_type)
  p <- plot_ly()
  for (j in seq_along(sl)) {
    d <- s[s[[s_col]] == sl[j], ]
    d <- d[match(xl, d[[x_col]]), ]
    xs <- factor(d[[x_col]], levels = xl)
    hv <- sprintf("%s %s<br>%s %s<br>Exposure %s", s_name, sl[j], x_name, d[[x_col]], formatC(d$exposure, format = "f", digits = 0, big.mark = ","))
    if (show_actual)
      p <- p %>% add_trace(x = xs, y = d$actual, type = "scatter", mode = "lines+markers", name = sl[j],
                           legendgroup = sl[j], connectgaps = FALSE,
                           line = list(color = cols[j], width = 1.8), marker = list(color = cols[j], size = 5),
                           text = hv, hovertemplate = "%{text}<br>Actual %{y:.4f}<extra></extra>")
    p <- p %>% add_trace(x = xs, y = d$relativity_rebased, type = "scatter", mode = "lines+markers",
                         name = if (show_actual) paste0(sl[j], " (rebased)") else sl[j],
                         legendgroup = sl[j], showlegend = !show_actual,
                         line = list(color = cols[j], width = 1.6, dash = "dash"),
                         marker = list(color = cols[j], size = 5, symbol = "diamond-open"),
                         text = sprintf("%s<br>Relativity (combined) %.4f", hv, d$combined),
                         hovertemplate = "%{text}<br>Rebased relativity %{y:.4f}<extra></extra>")
  }
  p %>% layout(font = list(family = mt_font_family, size = 12, color = mt_chart_colours$text),
               xaxis = list(title = x_name, type = "category", categoryorder = "array", categoryarray = xl),
               yaxis = list(title = ylab, gridcolor = mt_chart_colours$grid, zeroline = FALSE, rangemode = "tozero"),
               legend = list(title = list(text = paste0(s_name, ": "))), hovermode = "closest",
               margin = list(t = 30)) %>%
    mt_plotly_config(paste0("interaction_", x_name, "_by_", s_name))
}


# =================================================================================================================================
# Model report (as the GBM app's): interactive HTML or static PDF
# =================================================================================================================================
# glm_report_prepare() works out every number once; the HTML and PDF writers only draw it.
#   x: list(model, rel, pred (list of 3), data (list of 3), ref (or NULL), imp_quick, imp_drop (or NULL),
#           factors (to chart, in order), partitions, model_type, offset)
glm_report_prepare <- function(x, progress = function(v, d) NULL) {
  x$factors <- unique(x$factors)
  m <- x$model; resp <- m$response; expo <- m$exposure
  score <- function(p, d) { s <- p / d[[expo]]; if (!is.null(x$offset)) s <- s / d[[x$offset]]; s }
  has <- which(vapply(x$data, nrow, integer(1)) > 0)
  ks  <- intersect(x$partitions, has)
  nm  <- mt_partition_names
  out <- list(ks = ks)
  out$stats <- do.call(rbind, lapply(has, function(i) {
    d <- x$data[[i]]; p <- x$pred[[i]]
    data.frame(partition = nm[i], rows = nrow(d), exposure = sum(d[[expo]]), actual = sum(d[[resp]]), expected = sum(p),
               ae = sum(d[[resp]]) / sum(p), gini = glm_gini(p, d[[expo]], d[[resp]], score = score(p, d)), stringsAsFactors = FALSE)
  }))
  if (!is.null(x$ref)) out$stats$gini_ref <- vapply(has, function(i) {
    d <- x$data[[i]]; glm_gini(x$ref$pred[[i]], d[[expo]], d[[resp]], score = score(x$ref$pred[[i]], d)) }, numeric(1))
  progress(0.08, "Gains and lift")
  out$gains <- setNames(lapply(ks, function(i) { d <- x$data[[i]]; glm_gains(x$pred[[i]], d[[expo]], d[[resp]], score = score(x$pred[[i]], d)) }), nm[ks])
  out$gini  <- setNames(lapply(ks, function(i) out$stats$gini[out$stats$partition == nm[i]]), nm[ks])
  if (!is.null(x$ref)) {
    out$gains_ref <- setNames(lapply(ks, function(i) { d <- x$data[[i]]; glm_gains(x$ref$pred[[i]], d[[expo]], d[[resp]], score = score(x$ref$pred[[i]], d)) }), nm[ks])
    out$gini_ref  <- setNames(lapply(ks, function(i) out$stats$gini_ref[out$stats$partition == nm[i]]), nm[ks])
  }
  d1 <- x$data[[1]]
  out$perfect <- glm_gains(d1[[resp]], d1[[expo]], d1[[resp]], score = d1[[resp]])
  out$lift <- setNames(lapply(ks, function(i) { d <- x$data[[i]]; glm_lift(x$pred[[i]], d[[expo]], d[[resp]], 10) }), nm[ks])
  out$rate <- sum(d1[[resp]]) / sum(d1[[expo]])

  # importance: quick measures, plus drop-one when it was run on this fit
  imp <- x$imp_quick
  if (!is.null(imp) && !is.null(x$imp_drop)) imp <- merge(imp, x$imp_drop, by = "key", all.x = TRUE, sort = FALSE)
  if (!is.null(imp)) imp <- imp[order(-(if (!is.null(imp$drop_share)) imp$drop_share else imp$wald_share)), ]
  out$imp <- imp

  # one-way summaries: actual, expected, rebased relativity (and reference lines) per factor and partition
  out$avse <- list()
  for (j in seq_along(x$factors)) {
    f <- x$factors[j]
    progress(0.1 + 0.4 * j / length(x$factors), sprintf("Summaries: %s (%d of %d)", f, j, length(x$factors)))
    out$avse[[f]] <- lapply(seq_along(x$data), function(i) {
      if (!i %in% ks || !f %in% names(x$data[[i]])) return(NULL)
      s <- glm_factor_summary(x$data[[i]], f, resp, expo, x$pred[[i]], x$rel$factors[[f]], out$rate)
      if (!is.null(x$ref)) {
        sr <- glm_factor_summary(x$data[[i]], f, resp, expo, x$ref$pred[[i]], x$ref$rel$factors[[f]], out$rate)
        k  <- match(as.character(s$factor_name), as.character(sr$factor_name))
        s$prediction_ref <- sr$prediction[k]; s$relativity_ref <- sr$relativity_rebased[k]
      }
      s
    })
  }
  # interactions: cell summaries on the modelling data
  out$inter <- lapply(m$interactions, function(it) glm_inter_summary(x$data[[1]], it, resp, expo, x$rel, out$rate))
  out
}

glm_report_lines <- function(has_rel, with_ref) {
  ln <- list(list(col = "actual", name = "Actual", colour = mt_chart_colours$actual),
             list(col = "prediction", name = "Expected", colour = mt_chart_colours$expected))
  if (has_rel) ln <- c(ln, list(list(col = "relativity_rebased", name = "Rebased relativity", colour = "#16a34a", dash = "dash", symbol = "diamond")))
  if (with_ref) {
    ln <- c(ln, list(list(col = "prediction_ref", name = "Expected (reference)", colour = mt_chart_colours$expected_ref, dash = "dot")))
    if (has_rel) ln <- c(ln, list(list(col = "relativity_ref", name = "Rebased relativity (reference)", colour = "#7c3aed", dash = "dot", symbol = "diamond-open")))
  }
  ln
}

# which ways round an interaction can be drawn as lines (at most MT_MAX_TWO_WAY_LINES lines)
glm_report_inter_orients <- function(it, s) {
  na <- length(unique(s$level_a)); nb <- length(unique(s$level_b))
  o <- list()
  if (nb <= MT_MAX_TWO_WAY_LINES) o[[length(o) + 1]] <- list(x = it$a, s = it$b, x_col = "level_a", s_col = "level_b")
  if (na <= MT_MAX_TWO_WAY_LINES) o[[length(o) + 1]] <- list(x = it$b, s = it$a, x_col = "level_b", s_col = "level_a")
  o
}

glm_report_fmt <- function(x, d = 0) formatC(x, format = "f", digits = d, big.mark = ",")
glm_report_pct <- function(x, d = 1) ifelse(is.na(x), "–", paste0(formatC(100 * x, format = "f", digits = d), "%"))
glm_report_p   <- function(p) ifelse(is.na(p), "", ifelse(p < 1e-4, "<0.0001", formatC(p, format = "f", digits = 4)))
glm_report_ci  <- function(r) {
  bad <- r$exposure <= 0 | !is.finite(r$upper / r$lower) | r$upper / r$lower > 1e4
  ifelse(r$is_base, "base", ifelse(bad, "too little data",
                                   paste0(formatC(r$lower, format = "f", digits = 3), " – ", formatC(r$upper, format = "f", digits = 3))))
}
glm_report_ae_class <- function(ae) if (is.na(ae)) "" else if (abs(ae - 1) <= 0.02) "good" else if (abs(ae - 1) <= 0.05) "warn" else "bad"
glm_term_mode_label <- function(t) {
  if (isTRUE(t$var_on)) paste0("variate (order ", t$var_order %||% 1, ")") else if (isTRUE(t$cust_on)) "custom groups" else "own levels"
}

# key facts shown at the top of both formats
glm_report_facts <- function(x, prep) {
  m <- x$model
  hold <- prep$stats[prep$stats$partition == "Holdout", ]
  list(model = m$family, params = m$n_params,
       params_sub = paste0(if (m$converged) "converged" else "NOT converged", " · ", m$iterations, " iterations",
                           if (length(m$aliased)) paste0(" · ", length(m$aliased), " aliased") else ""),
       dev_expl = glm_report_pct(1 - m$deviance / m$null_deviance, 2),
       dev_sub = paste0(glm_report_fmt(m$deviance, 1), " of ", glm_report_fmt(m$null_deviance, 1)),
       aic_label = if (is.na(m$aic)) "Dispersion" else "AIC",
       aic = if (is.na(m$aic)) formatC(m$dispersion, format = "g", digits = 4) else glm_report_fmt(m$aic, 1),
       hold_gini = if (nrow(hold)) glm_report_pct(hold$gini) else "–",
       hold_ae = if (nrow(hold)) formatC(hold$ae, format = "f", digits = 3) else "–",
       n_factors = length(m$included), n_inter = length(m$interactions),
       base = formatC(x$rel$base, format = "g", digits = 6),
       formula = paste(m$response, "~", m$formula),
       response = m$response, exposure = m$exposure, offset = m$offset)
}

glm_report_css <- "
body { font-family: 'Segoe UI', -apple-system, 'Helvetica Neue', Arial, sans-serif; color: #1f2937; background: #f5f7fb; margin: 0; }
.wrap { max-width: 1200px; margin: 0 auto; padding: 28px 24px 60px 24px; }
h1 { font-size: 24px; margin: 0 0 4px 0; } h2 { font-size: 18px; margin: 34px 0 12px 0; border-bottom: 2px solid #dbe3ee; padding-bottom: 6px; }
h3 { font-size: 14.5px; margin: 0 0 8px 0; } h4 { font-size: 13px; margin: 12px 0 6px 0; color: #475569; }
.sub { color: #64748b; font-size: 13px; }
.card { background: #fff; border: 1px solid #e2e8f0; border-radius: 10px; padding: 14px 16px; margin-bottom: 16px; }
.tiles { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 10px; margin: 16px 0; }
.tile { background: #fff; border: 1px solid #e2e8f0; border-radius: 10px; padding: 10px 12px; }
.tile .l { font-size: 11px; text-transform: uppercase; letter-spacing: .04em; color: #64748b; }
.tile .v { font-size: 20px; font-weight: 600; margin-top: 2px; } .tile .s { font-size: 11.5px; color: #64748b; }
table { border-collapse: collapse; width: 100%; font-size: 13px; }
th, td { padding: 5px 10px; border-bottom: 1px solid #eef1f5; text-align: right; } th { color: #64748b; font-weight: 600; background: #f8fafc; position: sticky; top: 0; }
th:first-child, td:first-child { text-align: left; }
tr.base td { background: #eff6ff; font-weight: 600; }
.chips span { display: inline-block; background: #f1f5f9; border-radius: 12px; padding: 3px 10px; margin: 0 6px 6px 0; font-size: 12px; }
.chips span.ia { background: #f3e8ff; }
.toc { columns: 3 220px; font-size: 13px; } .toc a { color: #2563eb; text-decoration: none; display: block; padding: 2px 0; }
.good { color: #16a34a; font-weight: 600; } .warn { color: #d97706; font-weight: 600; } .bad { color: #dc2626; font-weight: 600; }
.grid2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; } @media (max-width: 900px) { .grid2 { grid-template-columns: 1fr; } }
code.f { display: block; white-space: pre-wrap; word-break: break-word; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 12px; font-size: 12.5px; }
details { margin-top: 8px; } summary { cursor: pointer; color: #2563eb; font-size: 13px; }
.scroll { max-height: 420px; overflow-y: auto; }
.note { color: #64748b; font-size: 12.5px; margin: 6px 0 0 0; }
.tag { display: inline-block; font-size: 11px; font-weight: 500; border-radius: 10px; padding: 1px 8px; background: #e0e7ff; color: #3730a3; margin-left: 6px; vertical-align: middle; }
"

# writes an HTML page with every script / stylesheet it needs written inline, so the file opens anywhere, offline
glm_save_selfcontained_html <- function(page, file, title = "Model report") {
  rendered <- htmltools::renderTags(page)
  deps <- htmltools::resolveDependencies(rendered$dependencies)
  read_txt <- function(f) paste(readLines(f, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  dep_html <- vapply(deps, function(d) {
    dir <- d$src$file
    if (is.null(dir)) return("")
    if (!is.null(d$package)) dir <- system.file(dir, package = d$package)
    out <- character(0)
    for (css in d$stylesheet) {
      f <- file.path(dir, if (is.list(css)) css$href else css)
      if (file.exists(f)) out <- c(out, paste0("<style>", read_txt(f), "</style>"))
    }
    for (js in d$script) {
      f <- file.path(dir, if (is.list(js)) js$src else js)
      if (file.exists(f)) out <- c(out, paste0("<script>", gsub("</script", "<\\/script", read_txt(f), fixed = TRUE), "</script>"))
    }
    if (!is.null(d$head)) out <- c(out, d$head)
    paste(out, collapse = "\n")
  }, "")
  html <- paste0("<!DOCTYPE html>\n<html lang=\"en\"><head><meta charset=\"utf-8\">",
                 "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
                 "<title>", htmltools::htmlEscape(title), "</title>\n",
                 paste(dep_html, collapse = "\n"), "\n", rendered$head,
                 "</head><body>\n", rendered$html, "\n</body></html>")
  con <- file(file, open = "w", encoding = "UTF-8")
  on.exit(close(con))
  writeLines(html, con, useBytes = TRUE)
}

# heatmap of an interaction's pure relativities (rows: series factor, columns: x factor)
plot_glm_inter_heat <- function(r, it, o) {
  xl <- unique(r[[o$x_col]]); sl <- unique(r[[o$s_col]])
  ord <- order(match(r[[o$x_col]], xl), match(r[[o$s_col]], sl)); rr <- r[ord, ]
  z <- matrix(rr$relativity, nrow = length(sl), ncol = length(xl))
  ci <- if (!is.null(rr$lower)) sprintf("<br>95%%: %.3f – %.3f", rr$lower, rr$upper) else ""
  txt <- matrix(sprintf("%s %s<br>%s %s<br>Relativity %.4f%s", it$a, rr$level_a, it$b, rr$level_b, rr$relativity, ci),
                nrow = length(sl), ncol = length(xl))
  lim <- max(abs(log(range(z, na.rm = TRUE))), 1e-6)
  plot_ly(x = factor(xl, levels = xl), y = factor(sl, levels = sl), z = log(z), type = "heatmap", text = txt, hoverinfo = "text",
          colorscale = list(c(0, "#2563eb"), c(0.5, "#f8fafc"), c(1, "#e11d48")), zmin = -lim, zmax = lim,
          colorbar = list(title = "Relativity", tickvals = log(c(0.8, 0.9, 1, 1.1, 1.25)), ticktext = c("0.8", "0.9", "1", "1.1", "1.25"))) %>%
    layout(font = list(family = mt_font_family, size = 12, color = mt_chart_colours$text),
           xaxis = list(title = o$x, type = "category"), yaxis = list(title = o$s, type = "category"),
           margin = list(l = 110, r = 20, t = 20, b = 90)) %>%
    mt_plotly_config(paste0("interaction_", o$x, "_by_", o$s))
}

# interactive HTML report: summary, importance, gains, lift, every factor (relativity + table + AvsE), interactions, coefficients
glm_write_report_html <- function(file, x, progress = function(v, d) NULL) {
  x$factors <- unique(x$factors)
  prep <- glm_report_prepare(x, progress)
  m <- x$model; fx <- glm_report_facts(x, prep)
  rate_label <- mt_rate_label(x$model_type)
  with_ref <- !is.null(x$ref)
  slug <- function(s) paste0("f-", gsub("[^A-Za-z0-9]+", "-", s))
  widget <- function(p, h) { p$height <- h; p$sizingPolicy$defaultWidth <- "100%"; p$sizingPolicy$browser$fill <- FALSE
                             p$sizingPolicy$browser$defaultWidth <- "100%"; p }
  tile <- function(l, v, s = NULL) div(class = "tile", div(class = "l", l), div(class = "v", v), if (!is.null(s)) div(class = "s", s))
  fmt <- glm_report_fmt; pct <- glm_report_pct
  st <- prep$stats

  # ---- summary ----
  summary_tags <- tagList(
    div(class = "tiles",
        tile("Model", fx$model, paste(fx$n_factors, "factors ·", fx$n_inter, "interactions")),
        tile("Parameters", fx$params, fx$params_sub),
        tile("Deviance explained", fx$dev_expl, fx$dev_sub),
        tile(fx$aic_label, fx$aic),
        tile("Holdout Gini", fx$hold_gini, paste0("Modelling ", pct(st$gini[1]))),
        tile("Holdout A/E", fx$hold_ae, "actual ÷ expected")),
    div(class = "grid2",
        div(class = "card", h3("Validation by partition"),
            tags$table(tags$thead(tags$tr(lapply(c("Partition", "Rows", "Exposure", "Actual", "Expected", "A/E", "Gini",
                                                   if (with_ref) "Gini (ref.)"), tags$th))),
                       tags$tbody(lapply(seq_len(nrow(st)), function(i) {
                         p <- st[i, ]
                         tags$tr(tags$td(p$partition), tags$td(fmt(p$rows)), tags$td(fmt(p$exposure)), tags$td(fmt(p$actual, 1)),
                                 tags$td(fmt(p$expected, 1)),
                                 tags$td(span(class = glm_report_ae_class(p$ae), formatC(p$ae, format = "f", digits = 3))),
                                 tags$td(pct(p$gini)), if (with_ref) tags$td(pct(p$gini_ref)))
                       })))),
        div(class = "card", h3("Set-up"),
            div(class = "chips",
                span("Response: ", tags$b(fx$response)), span("Exposure: ", tags$b(fx$exposure)),
                if (!is.null(fx$offset)) span("Offset: ", tags$b(fx$offset)),
                span("Base value: ", tags$b(fx$base)),
                if (with_ref) span("Reference model: ", tags$b(x$ref$label))),
            p(class = "note", paste0("Prediction = base × factor relativities × interaction relativities × exposure",
              if (!is.null(fx$offset)) " × offset", ". Each factor's base level (relativity 1) is its highest-exposure level unless it was changed in the app.")))),
    div(class = "card", h3("Factors in the model"),
        div(class = "chips",
            lapply(m$included, function(f) span(f, span(class = "tag", glm_term_mode_label(m$terms[[f]])))),
            lapply(m$interactions, function(it) span(class = "ia", glm_inter_label(it)))),
        h4("Formula"), tags$code(class = "f", fx$formula))
  )

  # ---- importance ----
  imp <- prep$imp
  imp_tags <- NULL
  if (!is.null(imp) && nrow(imp)) {
    has_drop <- !is.null(imp$drop_share) && any(!is.na(imp$drop_share))
    val <- if (has_drop) imp$drop_share else imp$wald_share
    imp_tags <- div(class = "card",
      h3(if (has_drop) "Drop-one deviance (share of total)" else "Wald χ² (share of total)"),
      widget(plot_glm_importance(imp, val, "share", if (has_drop) "Share of the deviance increase" else "Share of Wald χ²"),
             max(260, 26 * nrow(imp) + 70)),
      p(class = "note", if (has_drop) "Deviance increase when the term is removed and the model refitted (likelihood-ratio test). Purple: interactions."
                        else paste("Wald χ² of each term. To rank by the exact drop-one deviance instead, run the drop-one check on the",
                                   "Validation tab before creating the report. Purple: interactions.")),
      tags$details(tags$summary("Table"),
        tags$table(tags$thead(tags$tr(lapply(c("Term", "Parameters", "Wald χ²", "p", if (has_drop) c("Drop-one χ²", "p"), "Spread"), tags$th))),
                   tags$tbody(lapply(seq_len(nrow(imp)), function(i) tags$tr(
                     tags$td(imp$term[i]), tags$td(imp$params[i]),
                     tags$td(if (is.na(imp$wald[i])) "" else formatC(imp$wald[i], format = "f", digits = 1)), tags$td(glm_report_p(imp$wald_p[i])),
                     if (has_drop) tagList(tags$td(formatC(imp$chisq[i], format = "f", digits = 1)), tags$td(glm_report_p(imp$drop_p[i]))),
                     tags$td(sprintf("±%.1f%%", 100 * (exp(imp$spread[i]) - 1)))))))))
  }

  # ---- gains and lift ----
  progress(0.55, "Gains and lift charts")
  gains_tags <- div(class = "card", widget(plot_glm_gains(prep$gains, prep$gini, prep$gains_ref, prep$gini_ref, prep$perfect), 460))
  lift_tags <- div(class = "grid2", lapply(names(prep$lift), function(k)
    div(class = "card", h3(paste0(k, " · 10 bands of predicted rate")), widget(plot_glm_lift(prep$lift[[k]], NULL, rate_label), 380))))

  # ---- factors ----
  fac_tags <- list()
  for (j in seq_along(x$factors)) {
    f <- x$factors[j]
    progress(0.6 + 0.3 * j / length(x$factors), sprintf("Factor charts: %s (%d of %d)", f, j, length(x$factors)))
    r <- x$rel$factors[[f]]
    in_model <- !is.null(r)
    rr <- if (with_ref) x$ref$rel$factors[[f]] else NULL
    rel_part <- NULL
    if (in_model) {
      ci <- if (!is.null(r$lower)) glm_report_ci(r) else rep("", nrow(r))
      rel_part <- div(class = "card", h3("Relativity"),
        widget(plot_glm_relativity(r, f, rr, TRUE), 440),
        tags$details(tags$summary(paste0("Relativity table (", nrow(r), " levels)")),
          div(class = "scroll", tags$table(
            tags$thead(tags$tr(lapply(c("Level", "Exposure (modelling)", "Relativity", "95% interval", if (!is.null(rr)) "Reference"), tags$th))),
            tags$tbody(lapply(seq_len(nrow(r)), function(i)
              tags$tr(class = if (r$is_base[i]) "base", tags$td(r$level[i]), tags$td(fmt(r$exposure[i])),
                      tags$td(formatC(r$relativity[i], format = "f", digits = 4)), tags$td(ci[i]),
                      if (!is.null(rr)) tags$td(formatC(rr$relativity[match(r$level[i], rr$level)], format = "f", digits = 4)))))))))
    }
    charts <- lapply(prep$ks, function(i) {
      s <- prep$avse[[f]][[i]]
      if (is.null(s)) return(NULL)
      div(class = "card", h3(paste0("Actual vs expected · ", mt_partition_names[i])),
          widget(mt_oneway_plot(s, f, glm_report_lines(in_model, with_ref)) %>% layout(yaxis2 = list(title = list(text = rate_label))), 460))
    })
    fac_tags[[j]] <- tagList(tags$h2(id = slug(f), f, span(class = "tag", if (in_model) glm_term_mode_label(m$terms[[f]]) else "not in the model")),
                             rel_part, charts)
  }

  # ---- interactions ----
  progress(0.92, "Interaction charts")
  inter_tags <- lapply(seq_along(m$interactions), function(k) {
    it <- m$interactions[[k]]; s <- prep$inter[[k]]
    r <- x$rel$interactions[[glm_inter_label(it)]]
    os <- glm_report_inter_orients(it, s)
    heat_o <- list(x = it$b, s = it$a, x_col = "level_b", s_col = "level_a")
    tagList(tags$h2(id = slug(paste0("ia-", glm_inter_label(it))), glm_inter_label(it),
                    span(class = "tag", style = "background:#f3e8ff;color:#6b21a8;", "interaction")),
            lapply(os, function(o) div(class = "card", h3(paste0("Actual vs rebased relativity · ", o$x, " on the x-axis (modelling)")),
                                       widget(plot_glm_inter_ave(s, o$x, o$s, o$x_col, o$s_col, x$model_type), 540),
                                       p(class = "note", "Solid: actual. Dashed: rebased relativity = both factor relativities × interaction relativity × average actual rate. ",
                                         "Click a legend entry to hide a level, double-click to show it alone."))),
            if (!length(os)) div(class = "card", p(class = "note", "Both factors have more than ", MT_MAX_TWO_WAY_LINES, " levels: shown as a heatmap only.")),
            div(class = "card", h3("Interaction relativity (pure effect: 1 along each factor's base level)"),
                widget(plot_glm_inter_heat(r, it, heat_o), max(380, min(900, 16 * length(unique(r$level_a)) + 140)))))
  })

  # ---- coefficients ----
  ct <- m$coef_table
  coef_tags <- div(class = "card", tags$details(tags$summary(paste0("Show all ", nrow(ct), " coefficients")),
    div(class = "scroll", tags$table(
      tags$thead(tags$tr(lapply(c("Term", "Estimate", "exp(Estimate)", "Std. error", "Statistic", "p-value"), tags$th))),
      tags$tbody(lapply(seq_len(nrow(ct)), function(i) tags$tr(
        tags$td(ct$term[i]), tags$td(formatC(ct$estimate[i], format = "g", digits = 5)), tags$td(formatC(exp(ct$estimate[i]), format = "f", digits = 4)),
        tags$td(formatC(ct$std_error[i], format = "g", digits = 5)), tags$td(formatC(ct$statistic[i], format = "f", digits = 2)),
        tags$td(span(class = if (is.na(ct$p_value[i])) "" else if (ct$p_value[i] < 0.01) "good" else if (ct$p_value[i] < 0.05) "warn" else "bad",
                     glm_report_p(ct$p_value[i]))))))))))

  in_mod <- x$factors[x$factors %in% names(x$rel$factors)]; others <- setdiff(x$factors, in_mod)
  ia_labs <- vapply(m$interactions, glm_inter_label, character(1))
  page <- tagList(
    tags$style(HTML(glm_report_css)),
    div(class = "wrap",
        h1("GLM model report"),
        div(class = "sub", paste0(fx$model, " · fitted ", format(m$fitted_at, "%d %b %Y %H:%M"),
                                  " · report created ", format(Sys.time(), "%d %b %Y %H:%M"))),
        summary_tags,
        if (!is.null(imp_tags)) tagList(tags$h2("Feature importance"), imp_tags),
        tags$h2("Gains curves"), gains_tags,
        tags$h2("Lift charts"), lift_tags,
        tags$h2("Contents"),
        div(class = "card",
            h3(paste0(length(in_mod), " factors in the model", if (length(ia_labs)) paste0(" · ", length(ia_labs), " interactions"),
                      if (length(others)) paste0(" · ", length(others), " not in the model"))),
            div(class = "toc",
                lapply(in_mod, function(f) tags$a(href = paste0("#", slug(f)), f)),
                lapply(ia_labs, function(l) tags$a(href = paste0("#", slug(paste0("ia-", l))), style = "color:#7c3aed", l)),
                lapply(others, function(f) tags$a(href = paste0("#", slug(f)), style = "color:#64748b", f)))),
        fac_tags[x$factors %in% in_mod],
        if (length(inter_tags)) inter_tags,
        if (length(others)) tagList(tags$h2("Factors not in the model", style = "margin-top: 46px; border-color: #94a3b8;"), fac_tags[!x$factors %in% in_mod]),
        tags$h2("Coefficients"), coef_tags)
  )
  progress(0.96, "Writing file")
  glm_save_selfcontained_html(page, file, "GLM model report")
}

# ---- static PDF report (A4 landscape) -------------------------------------------------------------------------------
# one-way chart: exposure bars on the left axis, lines on the right
glm_oneway_gg <- function(in_data, fac, lines, rate_label = "Rate", title = NULL) {
  fn <- in_data[['factor_name']]
  in_data[['factor_name']] <- if (is.character(fn)) factor(fn, levels = c(stringr::str_sort(unique(fn[!is.na(fn)]), numeric = TRUE), if (anyNA(fn)) NA), exclude = NULL)
                              else factor(fn, exclude = NULL)
  levels(in_data[['factor_name']])[is.na(levels(in_data[['factor_name']]))] <- "NA"
  in_data <- in_data[order(in_data[['factor_name']]), ]
  lines <- Filter(function(ln) ln$col %in% names(in_data) && !all(is.na(in_data[[ln$col]])), lines)
  rate_max <- max(c(unlist(lapply(lines, function(ln) in_data[[ln$col]])), 0), na.rm = TRUE)
  expo_max <- max(in_data$exposure, na.rm = TRUE)
  k <- if (rate_max > 0) expo_max / rate_max else 1
  long <- do.call(rbind, lapply(lines, function(ln) data.frame(factor_name = in_data$factor_name, series = ln$name, y = in_data[[ln$col]] * k)))
  cols <- setNames(vapply(lines, `[[`, "", "colour"), vapply(lines, `[[`, "", "name"))
  ltys <- setNames(vapply(lines, function(ln) switch(ln$dash %||% "solid", dash = "dashed", dot = "dotted", "solid"), ""), names(cols))
  n_lv <- nlevels(in_data$factor_name)
  g <- ggplot(in_data, aes(x = factor_name)) +
    geom_col(aes(y = exposure), fill = mt_chart_colours$exposure, colour = mt_chart_colours$exposure_line, width = 0.75)
  if (!is.null(long) && nrow(long)) {
    long$series <- factor(long$series, levels = names(cols))
    g <- g + geom_line(data = long, aes(y = y, colour = series, linetype = series, group = series), linewidth = 0.8, na.rm = TRUE) +
      geom_point(data = long, aes(y = y, colour = series), size = 1.6, na.rm = TRUE) +
      scale_colour_manual(values = cols) + scale_linetype_manual(values = ltys)
  }
  g <- g + scale_y_continuous(name = "Exposure", labels = scales::label_comma(),
                              sec.axis = sec_axis(~ . / k, name = rate_label), expand = expansion(mult = c(0, 0.05))) +
    labs(x = fac, title = title) + theme_mt(10) + theme(plot.title = element_text(face = "bold", size = 12))
  if (n_lv > 50) g <- g + scale_x_discrete(breaks = levels(in_data$factor_name)[seq(1, n_lv, by = ceiling(n_lv / 50))])
  if (n_lv > 12) g <- g + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  g
}
# relativity chart: relativity line with its 95% band, base level starred, exposure bars behind (right axis)
glm_relativity_gg <- function(r, fac, ref = NULL, title = NULL) {
  lv <- r$level
  ok <- if (!is.null(r$lower)) is.finite(r$upper / r$lower) & (r$upper / r$lower) <= 1e4 else rep(FALSE, length(lv))
  d <- data.frame(x = factor(lv, levels = lv), rel = r$relativity,
                  lo = if (!is.null(r$lower)) ifelse(ok, r$lower, NA) else NA_real_,
                  hi = if (!is.null(r$upper)) ifelse(ok, r$upper, NA) else NA_real_,
                  ref = if (!is.null(ref)) ref$relativity[match(lv, ref$level)] else NA_real_,
                  base = r$is_base, expo = r$exposure)
  rmax <- max(c(d$rel, d$hi, d$ref, 1), na.rm = TRUE); k <- max(d$expo, 1) / rmax
  g <- ggplot(d, aes(x = x)) +
    geom_col(aes(y = expo / k), fill = mt_chart_colours$exposure, colour = mt_chart_colours$exposure_line, width = 0.75, alpha = 0.7) +
    geom_hline(yintercept = 1, linetype = "dashed", colour = "#94a3b8")
  if (any(!is.na(d$lo))) g <- g + geom_ribbon(aes(ymin = lo, ymax = hi, group = 1), fill = "#16a34a", alpha = 0.15, na.rm = TRUE)
  if (!is.null(ref)) g <- g + geom_line(aes(y = ref, group = 1, colour = "Reference model"), linetype = "dotted", linewidth = 0.8, na.rm = TRUE)
  g <- g + geom_line(aes(y = rel, group = 1, colour = "Relativity"), linewidth = 1) +
    geom_point(aes(y = rel, colour = "Relativity"), size = 1.6) +
    geom_point(data = d[d$base, , drop = FALSE], aes(y = rel), shape = 8, size = 3.5, colour = "#f59e0b") +
    scale_colour_manual(values = c(Relativity = "#16a34a", `Reference model` = "#7c3aed")) +
    scale_y_continuous(name = "Relativity", sec.axis = sec_axis(~ . * k, name = "Exposure (modelling)", labels = scales::label_comma())) +
    labs(x = fac, title = title, subtitle = "star: base level · shaded: 95% confidence band") +
    theme_mt(10) + theme(plot.title = element_text(face = "bold", size = 12))
  n_lv <- length(lv)
  if (n_lv > 50) g <- g + scale_x_discrete(breaks = lv[seq(1, n_lv, by = ceiling(n_lv / 50))])
  if (n_lv > 12) g <- g + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  g
}
# interaction on paper: one small panel per level of the series factor, actual vs rebased relativity across the x factor
# (the HTML report draws all levels on one interactive chart instead, where levels can be switched on and off)
glm_inter_gg <- function(s, o, rate_label, title) {
  xl <- unique(s[[o$x_col]]); sl <- unique(s[[o$s_col]])
  d <- data.frame(x = factor(s[[o$x_col]], levels = xl), g = factor(paste0(o$s, ": ", s[[o$s_col]]), levels = paste0(o$s, ": ", sl)),
                  actual = s$actual, rebased = s$relativity_rebased, expo = s$exposure)
  long <- rbind(data.frame(d[, c("x", "g")], series = "Actual", y = d$actual),
                data.frame(d[, c("x", "g")], series = "Rebased relativity", y = d$rebased))
  # the actual rate of a cell with almost no exposure is noise: only cells with at least 0.1% of the exposure are drawn
  thin <- d$expo < 0.001 * sum(d$expo)
  long$y[long$series == "Actual"][thin] <- NA
  nb <- max(1, ceiling(length(xl) / 6))
  g <- ggplot(long, aes(x = x, y = y, colour = series, linetype = series, group = series)) +
    geom_line(linewidth = 0.6, na.rm = TRUE) + geom_point(size = 0.7, na.rm = TRUE) +
    facet_wrap(~ g, ncol = min(7, ceiling(sqrt(length(sl) * 1.6)))) +
    scale_colour_manual(values = c(Actual = mt_chart_colours$actual, `Rebased relativity` = "#16a34a")) +
    scale_linetype_manual(values = c(Actual = "solid", `Rebased relativity` = "dashed")) +
    scale_x_discrete(breaks = xl[seq(1, length(xl), by = nb)]) +
    labs(x = o$x, y = rate_label, title = title,
         subtitle = "modelling data · actual hidden in cells with less than 0.1% of the exposure") +
    theme_mt(9) + theme(plot.title = element_text(face = "bold", size = 12), strip.text = element_text(face = "bold", size = 8),
                        axis.text.x = element_text(angle = 45, hjust = 1, size = 6.5), axis.text.y = element_text(size = 7),
                        panel.border = element_rect(colour = "#e2e8f0", fill = NA))
  g
}
glm_inter_heat_gg <- function(r, it, title) {
  la <- unique(r$level_a); lb <- unique(r$level_b)
  d <- data.frame(a = factor(r$level_a, levels = la), b = factor(r$level_b, levels = lb), z = log(r$relativity))
  lim <- max(abs(d$z), 1e-6, na.rm = TRUE)
  g <- ggplot(d, aes(b, a, fill = z)) + geom_tile() +
    scale_fill_gradient2(low = "#2563eb", mid = "#f8fafc", high = "#e11d48", limits = c(-lim, lim), name = "Relativity",
                         breaks = log(c(0.8, 0.9, 1, 1.1, 1.25)), labels = c("0.8", "0.9", "1", "1.1", "1.25")) +
    labs(x = it$b, y = it$a, title = title) + theme_mt(10) +
    theme(plot.title = element_text(face = "bold", size = 12), legend.position = "right", legend.title = element_text())
  if (length(lb) > 12) g <- g + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  if (length(lb) > 50) g <- g + scale_x_discrete(breaks = lb[seq(1, length(lb), by = ceiling(length(lb) / 50))])
  if (length(la) > 50) g <- g + scale_y_discrete(breaks = la[seq(1, length(la), by = ceiling(length(la) / 50))])
  g
}

glm_write_report_pdf <- function(file, x, progress = function(v, d) NULL) {
  x$factors <- unique(x$factors)
  prep <- glm_report_prepare(x, progress)
  m <- x$model; fx <- glm_report_facts(x, prep)
  rate_label <- mt_rate_label(x$model_type); with_ref <- !is.null(x$ref)
  fmt <- glm_report_fmt; pct <- glm_report_pct
  grDevices::pdf(file, width = 11.69, height = 8.27, onefile = TRUE)
  on.exit(grDevices::dev.off())
  tt   <- gridExtra::ttheme_minimal(base_size = 9, core = list(fg_params = list(hjust = 1, x = 0.95)),
                                    colhead = list(fg_params = list(fontface = "bold", hjust = 1, x = 0.95)))
  tt_l <- gridExtra::ttheme_minimal(base_size = 9, core = list(fg_params = list(hjust = 0, x = 0.04)),
                                    colhead = list(fg_params = list(fontface = "bold", hjust = 0, x = 0.04)))
  top_left <- function(g, heading) {
    g <- gtable::gtable_add_rows(g, grid::unit(1.6, "lines"), pos = 0)
    g <- gtable::gtable_add_grob(g, grid::textGrob(heading, x = 0, hjust = 0, gp = grid::gpar(fontsize = 11, fontface = "bold", col = "#334155")),
                                 t = 1, l = 1, r = ncol(g))
    g$vp <- grid::viewport(x = 0.02, y = 0.98, width = sum(g$widths), height = sum(g$heights), just = c("left", "top"))
    g
  }
  heading <- function(txt, size = 15) grid::textGrob(txt, x = 0.02, hjust = 0, gp = grid::gpar(fontsize = size, fontface = "bold"))
  # long tables run over as many pages as needed
  table_pages <- function(df, title, rows_per_page = 30, theme = tt) {
    n <- nrow(df); if (!n) return(invisible())
    for (s in seq(1, n, by = rows_per_page)) {
      part <- df[s:min(n, s + rows_per_page - 1), , drop = FALSE]
      gridExtra::grid.arrange(heading(if (s == 1) title else paste(title, "(continued)"), 13),
                              top_left(gridExtra::tableGrob(part, rows = NULL, theme = theme), ""), ncol = 1, heights = c(0.08, 0.92))
    }
  }

  # ---- summary page ----
  progress(0.55, "Summary page")
  st <- prep$stats
  part_tab <- data.frame(Partition = st$partition, Exposure = fmt(st$exposure), Actual = fmt(st$actual, 1),
                         Expected = fmt(st$expected, 1), `A/E` = formatC(st$ae, format = "f", digits = 3), Gini = pct(st$gini), check.names = FALSE)
  if (with_ref) part_tab$`Gini (ref.)` <- pct(st$gini_ref)
  facts <- data.frame(Item = c("Model", "Parameters", "Deviance explained", fx$aic_label, "Response", "Exposure",
                               if (!is.null(fx$offset)) "Offset", "Base value", "Factors / interactions", if (with_ref) "Reference model"),
                      Value = c(fx$model, paste0(fx$params, " (", fx$params_sub, ")"), paste0(fx$dev_expl, " (", fx$dev_sub, ")"), fx$aic,
                                fx$response, fx$exposure, if (!is.null(fx$offset)) fx$offset, fx$base,
                                paste(fx$n_factors, "/", fx$n_inter), if (with_ref) x$ref$label))
  fl <- data.frame(Term = c(m$included, vapply(m$interactions, glm_inter_label, "")),
                   Structure = c(vapply(m$included, function(f) glm_term_mode_label(m$terms[[f]]), ""), rep("interaction", length(m$interactions))))
  gridExtra::grid.arrange(heading(paste0("GLM model report\n", fx$model, " · fitted ", format(m$fitted_at, "%d %b %Y %H:%M"))),
                          gridExtra::arrangeGrob(top_left(gridExtra::tableGrob(facts, rows = NULL, theme = tt_l), "Model"),
                                                 top_left(gridExtra::tableGrob(fl, rows = NULL, theme = gridExtra::ttheme_minimal(base_size = 8,
                                                          core = list(fg_params = list(hjust = 0, x = 0.04)),
                                                          colhead = list(fg_params = list(fontface = "bold", hjust = 0, x = 0.04)))), "Terms in the model"),
                                                 top_left(gridExtra::tableGrob(part_tab, rows = NULL, theme = tt), "Validation by partition"),
                                                 layout_matrix = rbind(c(1, 2), c(3, 2)), heights = c(0.55, 0.45), widths = c(0.6, 0.4)),
                          ncol = 1, heights = c(0.13, 0.87))
  # formula
  grid::grid.newpage()
  grid::grid.draw(grid::textGrob("Formula", x = 0.02, y = 0.95, hjust = 0, gp = grid::gpar(fontsize = 13, fontface = "bold")))
  grid::grid.text(paste(strwrap(fx$formula, 140), collapse = "\n"), x = 0.02, y = 0.9, hjust = 0, vjust = 1,
                  gp = grid::gpar(fontsize = 9, fontfamily = "mono"))

  # ---- importance and gains ----
  progress(0.6, "Importance and gains")
  imp <- prep$imp; g_imp <- NULL
  if (!is.null(imp) && nrow(imp)) {
    has_drop <- !is.null(imp$drop_share) && any(!is.na(imp$drop_share))
    d <- data.frame(term = imp$term, kind = imp$kind, v = if (has_drop) imp$drop_share else imp$wald_share)
    d <- d[is.finite(d$v), ]; d <- d[order(d$v), ]; d$term <- factor(d$term, levels = d$term)
    g_imp <- ggplot(d, aes(v, term, fill = kind)) + geom_col(width = 0.7) +
      scale_fill_manual(values = c(factor = mt_chart_colours$expected, interaction = mt_chart_colours$shap_ref), guide = "none") +
      scale_x_continuous(labels = scales::percent) +
      labs(x = if (has_drop) "Drop-one deviance (share of total)" else "Wald chi-square (share of total)", y = NULL,
           title = "Feature importance", subtitle = "purple: interactions") +
      theme_mt(10) + theme(plot.title = element_text(face = "bold", size = 12))
  }
  gl <- do.call(rbind, lapply(names(prep$gains), function(k)
    data.frame(series = sprintf("%s · Gini %.1f%%", k, 100 * prep$gini[[k]]), key = k, prep$gains[[k]])))
  gl$series <- factor(gl$series, levels = unique(gl$series))   # legend in partition order
  g_gain <- ggplot(gl, aes(cumulative_exposure, cumulative_response, colour = series)) +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "#cbd5e1") +
    geom_line(data = prep$perfect, aes(cumulative_exposure, cumulative_response), inherit.aes = FALSE, colour = "#94a3b8", linetype = "dotted") +
    geom_line(linewidth = 0.9) +
    scale_colour_manual(values = setNames(unname(mt_partition_colours[unique(gl$key)]), unique(gl$series))) +
    scale_x_continuous(labels = scales::percent) + scale_y_continuous(labels = scales::percent) +
    labs(x = "Cumulative exposure (highest prediction first)", y = "Cumulative response", title = "Gains curves",
         subtitle = "dotted: perfect model (modelling)") +
    theme_mt(10) + theme(plot.title = element_text(face = "bold", size = 12), legend.position = "bottom")
  if (!is.null(g_imp)) gridExtra::grid.arrange(g_imp, g_gain, ncol = 2) else print(g_gain)
  lift_gg <- lapply(names(prep$lift), function(k) {
    l <- prep$lift[[k]]
    glm_oneway_gg(data.frame(factor_name = factor(l$band), exposure = l$exposure, actual = l$actual, prediction = l$expected),
                  "Band of predicted rate (1 = lowest)", glm_report_lines(FALSE, FALSE), rate_label, paste0("Lift · ", k))
  })
  if (length(lift_gg)) gridExtra::grid.arrange(grobs = lift_gg, ncol = length(lift_gg))

  # ---- factors: relativity page (chart + table), then one AvsE chart per partition ----
  rel_tab <- function(r) data.frame(Level = r$level, Exposure = fmt(r$exposure), Relativity = formatC(r$relativity, format = "f", digits = 4),
                                    `95% interval` = if (!is.null(r$lower)) glm_report_ci(r) else "", check.names = FALSE)
  draw_factor <- function(f) {
    r <- x$rel$factors[[f]]; in_model <- !is.null(r)
    if (in_model) {
      g_rel <- glm_relativity_gg(r, f, if (with_ref) x$ref$rel$factors[[f]] else NULL,
                                 paste0(f, " · relativity (", glm_term_mode_label(m$terms[[f]]), ")"))
      if (nrow(r) <= 32) {
        gridExtra::grid.arrange(g_rel, top_left(gridExtra::tableGrob(rel_tab(r), rows = NULL, theme = gridExtra::ttheme_minimal(base_size = 7)), ""),
                                ncol = 2, widths = c(0.66, 0.34))
      } else {
        print(g_rel)
        table_pages(rel_tab(r), paste0(f, " · relativities"), 30)
      }
    }
    for (i in prep$ks) {
      s <- prep$avse[[f]][[i]]
      if (is.null(s)) next
      print(glm_oneway_gg(s, f, glm_report_lines(in_model, with_ref), rate_label,
                          paste0(f, " · actual vs expected · ", mt_partition_names[i], if (!in_model) " (not in the model)" else "")))
    }
  }
  in_mod <- x$factors[x$factors %in% names(x$rel$factors)]; others <- setdiff(x$factors, in_mod)
  for (j in seq_along(in_mod)) {
    progress(0.65 + 0.2 * j / length(x$factors), sprintf("Factor pages: %s (%d of %d)", in_mod[j], j, length(x$factors)))
    draw_factor(in_mod[j])
  }
  # ---- interactions ----
  for (k in seq_along(m$interactions)) {
    it <- m$interactions[[k]]; s <- prep$inter[[k]]; lab <- glm_inter_label(it)
    progress(0.86, paste("Interaction", lab))
    for (o in glm_report_inter_orients(it, s)) print(glm_inter_gg(s, o, rate_label, paste0(lab, " · ", o$x, " on the x-axis")))
    print(glm_inter_heat_gg(x$rel$interactions[[lab]], it, paste0(lab, " · interaction relativity (pure effect, 1 along each base level)")))
  }
  for (j in seq_along(others)) {
    progress(0.88 + 0.08 * j / length(others), sprintf("Factors not in the model: %s (%d of %d)", others[j], j, length(others)))
    draw_factor(others[j])
  }
  # ---- coefficients ----
  ct <- m$coef_table
  table_pages(data.frame(Term = ct$term, Estimate = formatC(ct$estimate, format = "g", digits = 5),
                         `exp(Estimate)` = formatC(exp(ct$estimate), format = "f", digits = 4),
                         `Std. error` = formatC(ct$std_error, format = "g", digits = 5), `p-value` = glm_report_p(ct$p_value),
                         check.names = FALSE), "Coefficients", 32, tt_l)
  progress(0.98, "Writing file")
  invisible(file)
}
