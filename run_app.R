# Starts the GLM tool with the exact package versions listed in renv.lock.
# Packages go into a private library under tools::R_user_dir("GLM_UI", "cache"), so the
# user's own R library is neither used nor changed. The first run installs them
# (several minutes); later runs start straight away.
# Windows: double-click run_app.bat.  macOS / Linux: Rscript run_app.R /path/to/this/folder

args <- commandArgs(trailingOnly = TRUE)
app_dir <- normalizePath(if (length(args)) args[1] else getwd(), winslash = "/")
lock <- file.path(app_dir, "renv.lock")
if (!file.exists(lock)) stop("renv.lock not found in ", app_dir)

# A dated snapshot of CRAN from Posit Package Manager. Ready-built (binary) Windows packages exist
# only for the versions that were current on that date, so the date is chosen to match renv.lock:
# then nothing needs compiling and Rtools is not needed. Update it whenever renv.lock is re-made.
snapshot <- "2024-10-28"
options(repos = c(CRAN = paste0("https://packagemanager.posit.co/cran/", snapshot)))

r_ver <- paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = ".")
lib <- file.path(tools::R_user_dir("GLM_UI", "cache"), "library", paste0("R-", r_ver))
dir.create(lib, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(lib, .Library))            # private library first, then R's own base packages only

if (!requireNamespace("renv", lib.loc = lib, quietly = TRUE))
  install.packages("renv", lib = lib)
lf <- renv::lockfile_read(lock)

if (!identical(lf$R$Version, as.character(getRversion())))
  message("NOTE: renv.lock was made with R ", lf$R$Version, " but this is R ", getRversion(),
          ". The app should still run, but results are only guaranteed on the same R version.")

# install anything missing or at a different version, then start the app
pk <- lf$Packages
pk <- pk[setdiff(names(pk), "renv")]   # renv only installs the others; its own version does not matter
wrong <- names(pk)[!vapply(names(pk), function(n) {
  v <- tryCatch(packageVersion(n, lib.loc = .libPaths()), error = function(e) NULL)
  !is.null(v) && v == package_version(pk[[n]]$Version)
}, logical(1))]
if (length(wrong)) {
  message("First start: installing ", length(wrong), " package(s) at the versions in renv.lock. ",
          "This takes a few minutes; the screen may look still while files download.")
  renv::restore(lockfile = lock, library = lib, packages = wrong, repos = getOption("repos"),
                prompt = FALSE, clean = FALSE)
}

message("Starting the GLM tool. Close this window to stop it.")
shiny::runApp(app_dir, launch.browser = TRUE)
