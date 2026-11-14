# Starts the GLM tool with the exact package versions listed in renv.lock.
# Packages go into a private library under tools::R_user_dir("GLM_UI", "cache"), so the
# user's own R library is neither used nor changed. The first run installs them
# (several minutes); later runs start straight away.
# Windows: double-click run_app.bat.  macOS / Linux: Rscript run_app.R /path/to/this/folder

args <- commandArgs(trailingOnly = TRUE)
app_dir <- normalizePath(if (length(args)) args[1] else getwd(), winslash = "/")
lock <- file.path(app_dir, "renv.lock")
if (!file.exists(lock)) stop("renv.lock not found in ", app_dir)

# Posit Package Manager serves ready-built Windows packages, including older versions
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"))

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
wrong <- names(pk)[!vapply(names(pk), function(n) {
  v <- tryCatch(packageVersion(n, lib.loc = .libPaths()), error = function(e) NULL)
  !is.null(v) && v == package_version(pk[[n]]$Version)
}, logical(1))]
if (length(wrong)) {
  message("Installing ", length(wrong), " package(s) at the versions in renv.lock: ", paste(wrong, collapse = ", "))
  renv::restore(lockfile = lock, library = lib, packages = wrong, prompt = FALSE, clean = FALSE)
}

message("Starting the GLM tool. Close this window to stop it.")
shiny::runApp(app_dir, launch.browser = TRUE)
