# GLM Modelling Studio
# Starting the app (RStudio "Run App", runApp("App") or source("app.R")) loads functions.R from the same folder first,
# so every restart picks up the latest version of both files.
local({
  here <- if (file.exists("functions.R")) "." else if (file.exists(file.path("App", "functions.R"))) "App" else NULL
  if (is.null(here)) {
    # sourced from elsewhere: use the folder this file was sourced from
    of <- tryCatch(normalizePath(sys.frame(1)$ofile), error = function(e) NULL)
    if (!is.null(of) && file.exists(file.path(dirname(of), "functions.R"))) here <- dirname(of)
  }
  if (is.null(here)) stop("functions.R not found: run app.R from the GLM_UI/App folder")
  source(file.path(here, "functions.R"), local = globalenv())
})

# UI STYLING ---------------------------------------------------------------------------------------------------------------
# All styling lives here so the app looks the same however it is launched (Run App, runApp(), or sourcing this file).

app_css <- "
:root {
  --mt-navy: #16202e;
  --mt-navy-2: #223047;
  --mt-accent: #2563eb;
  --mt-accent-dark: #1d4ed8;
  --mt-bg: #f3f5f8;
  --mt-card: #ffffff;
  --mt-border: #e2e7ef;
  --mt-text: #1f2937;
  --mt-muted: #6b7280;
}

html, body {
  background: var(--mt-bg);
  color: var(--mt-text);
  font-family: 'Segoe UI', -apple-system, 'Helvetica Neue', Arial, sans-serif;
  font-size: 13px;
}
body { padding-top: 64px; }
.container-fluid { padding-left: 22px; padding-right: 22px; }
h1, h2, h3, h4, h5 { font-family: inherit; color: var(--mt-text); }

/* ---- Top navigation bar ---- */
.navbar-inverse {
  background: var(--mt-navy);
  border: none;
  box-shadow: 0 2px 6px rgba(15, 23, 42, .25);
  min-height: 52px;
}
.navbar-inverse .navbar-brand {
  color: #fff !important;
  font-weight: 600;
  font-size: 16px;
  letter-spacing: .2px;
  height: 52px;
  line-height: 22px;
}
.mt-brand-icon {
  display: inline-block;
  width: 26px; height: 26px; line-height: 26px;
  text-align: center;
  border-radius: 6px;
  background: var(--mt-accent);
  margin-right: 9px;
  font-size: 13px;
}
.mt-brand-sub { color: #94a3b8; font-weight: 400; font-size: 12px; margin-left: 10px; }
.navbar-inverse .navbar-nav > li > a {
  color: #cbd5e1;
  font-weight: 500;
  padding-top: 16px; padding-bottom: 16px;
  border-bottom: 3px solid transparent;
}
.navbar-inverse .navbar-nav > li > a:hover { color: #fff; background: var(--mt-navy-2); }
.navbar-inverse .navbar-nav > .active > a,
.navbar-inverse .navbar-nav > .active > a:hover,
.navbar-inverse .navbar-nav > .active > a:focus {
  color: #fff;
  background: var(--mt-navy-2);
  border-bottom: 3px solid var(--mt-accent);
}
.navbar-inverse .navbar-nav > li > a .fa,
.navbar-inverse .navbar-nav > li > a svg { margin-right: 6px; opacity: .85; }

/* ---- Page headers ---- */
.mt-page-header { margin: 14px 0 16px 0; }
.mt-page-header h2 { font-size: 20px; font-weight: 600; margin: 0 0 3px 0; }
.mt-page-header p { color: var(--mt-muted); margin: 0; }

/* ---- Secondary (workflow) tabs ---- */
.nav-tabs { border-bottom: 1px solid var(--mt-border); margin-bottom: 16px; }
.nav-tabs > li > a {
  color: var(--mt-muted);
  font-weight: 500;
  border: none !important;
  border-bottom: 2px solid transparent !important;
  background: transparent !important;
  padding: 10px 16px;
  margin-right: 4px;
}
.nav-tabs > li > a:hover { color: var(--mt-text); border-bottom-color: #cbd5e1 !important; }
.nav-tabs > li.active > a,
.nav-tabs > li.active > a:hover,
.nav-tabs > li.active > a:focus {
  color: var(--mt-accent) !important;
  border-bottom: 2px solid var(--mt-accent) !important;
}
.mt-step {
  display: inline-block;
  width: 20px; height: 20px; line-height: 20px;
  border-radius: 50%;
  background: #e5e9f0;
  color: var(--mt-muted);
  font-size: 11px; font-weight: 600;
  text-align: center;
  margin-right: 7px;
}
.nav-tabs > li.active .mt-step { background: var(--mt-accent); color: #fff; }

/* ---- Cards ---- */
.mt-card {
  background: var(--mt-card);
  border: 1px solid var(--mt-border);
  border-radius: 8px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, .04);
  margin-bottom: 18px;
}
.mt-card-header {
  padding: 11px 16px;
  border-bottom: 1px solid var(--mt-border);
  display: flex; align-items: center; gap: 8px;
}
.mt-card-header .fa, .mt-card-header svg { color: var(--mt-accent); }
.mt-card-title { font-weight: 600; font-size: 13.5px; }
.mt-card-subtitle { color: var(--mt-muted); font-size: 12px; margin-left: auto; }
.mt-card-body { padding: 14px 16px; }
.mt-card-body > .row:last-child .form-group,
.mt-card-body > .form-group:last-child { margin-bottom: 0; }

.mt-section-label {
  text-transform: uppercase;
  font-size: 10.5px;
  letter-spacing: .7px;
  font-weight: 600;
  color: var(--mt-muted);
  margin: 14px 0 8px 0;
}
.mt-section-label:first-child { margin-top: 0; }
.mt-divider { border-top: 1px solid var(--mt-border); margin: 14px -16px; }

/* ---- Form controls ---- */
.control-label, label { font-weight: 500; color: #374151; font-size: 12.5px; }
.form-control, .selectize-input, .bootstrap-select > .dropdown-toggle {
  border-radius: 6px !important;
  border-color: #d5dbe5 !important;
  box-shadow: none !important;
  font-size: 13px;
}
.form-control:focus { border-color: var(--mt-accent) !important; box-shadow: 0 0 0 3px rgba(37, 99, 235, .15) !important; }
select[multiple].form-control { padding: 4px; }
select[multiple].form-control option { padding: 3px 6px; border-radius: 3px; }
select[multiple].form-control option:checked {
  background: #dbe7ff linear-gradient(0deg, #dbe7ff 0%, #dbe7ff 100%);
  color: #1e3a8a;
  font-weight: 600;
}
.bootstrap-select > .dropdown-toggle { background: #fff !important; }
.input-group .btn { border-radius: 6px 0 0 6px; }
.progress { height: 6px; margin-bottom: 0; border-radius: 3px; }
.shiny-input-container:not(.shiny-input-container-inline) { width: 100%; }
.irs--shiny .irs-bar { background: var(--mt-accent); border-color: var(--mt-accent); }
.irs--shiny .irs-single { background: var(--mt-accent); }

/* ---- Buttons ---- */
.btn { border-radius: 6px; font-weight: 500; font-size: 12.5px; padding: 7px 14px; transition: all .12s ease; }
.btn-default { background: #fff; border-color: #d5dbe5; color: #374151; }
.btn-default:hover { background: #f5f7fa; border-color: #c3cbd8; }
/* Shiny action buttons always carry btn-default too, so these need higher specificity */
.btn.btn-primary { background: var(--mt-accent); border-color: var(--mt-accent); color: #fff; }
.btn.btn-primary:hover, .btn.btn-primary:focus, .btn.btn-primary:active { background: var(--mt-accent-dark) !important; border-color: var(--mt-accent-dark) !important; color: #fff; }
.btn.btn-success { background: #16a34a; border-color: #16a34a; color: #fff; }
.btn.btn-success:hover, .btn.btn-success:focus { background: #15803d; border-color: #15803d; color: #fff; }
.btn-block + .btn-block { margin-top: 8px; }
.mt-btn-row { display: flex; flex-wrap: wrap; gap: 8px; }
.mt-btn-row .btn { flex: 1 1 auto; }
.mt-btn-row-3 .btn { flex: 1 1 30%; padding-left: 6px; padding-right: 6px; }

/* ---- Status messages (server sends coloured spans; restyle them as badges) ---- */
.mt-status { margin-top: 10px; }
.mt-status span {
  display: inline-block;
  padding: 5px 10px 5px 26px;
  border-radius: 6px;
  font-size: 11.5px;
  font-weight: 600;
  letter-spacing: .3px;
  position: relative;
  line-height: 1.4;
}
.mt-status span::before {
  content: '';
  position: absolute;
  left: 10px; top: 50%;
  width: 8px; height: 8px;
  margin-top: -4px;
  border-radius: 50%;
  background: currentColor;
}
.mt-status span[style*='red']    { color: #b42318 !important; background: #fef3f2; border: 1px solid #fecdca; }
.mt-status span[style*='green']  { color: #067647 !important; background: #ecfdf3; border: 1px solid #abefc6; }
.mt-status span[style*='orange'] { color: #b54708 !important; background: #fffaeb; border: 1px solid #fedf89; }

/* ---- Dataset info tiles ---- */
.mt-kpi-row { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 12px; }
.mt-kpi {
  flex: 1 1 180px;
  background: #f8fafc;
  border: 1px solid var(--mt-border);
  border-radius: 6px;
  padding: 10px 14px;
  font-weight: 600;
  color: var(--mt-text);
}
.mt-kpi .shiny-text-output, .mt-kpi pre { margin: 0; }
/* keep empty tiles in the DOM (Shiny skips rendering hidden outputs) but make them invisible */
.mt-kpi:has(.shiny-text-output:empty) { background: transparent; border-color: transparent; padding: 0; }
.mt-gini-box .shiny-text-output:not(:empty) {
  display: inline-block;
  font-size: 15px;
  font-weight: 700;
  color: var(--mt-accent);
  background: #eff4ff;
  border: 1px solid #c7d7fe;
  border-radius: 6px;
  padding: 6px 14px;
  margin-top: 4px;
}

/* ---- Model workspace: fixed control panel ---- */
.mt-control-panel {
  position: fixed;
  top: 72px; bottom: 14px;
  width: calc(25% - 34px);
  overflow-y: auto;
  padding-right: 4px;
}
.mt-control-panel .mt-card { margin-bottom: 12px; }
@media (max-width: 767px) {
  .mt-control-panel { position: static; width: auto; }
}
.mt-control-panel .mt-section-label { margin-top: 14px; }
.mt-control-panel .shiny-input-container { margin-bottom: 8px; }

/* ---- Resizable Model panel: width (drag the right edge) and factor list height (drag the bar under it) ---- */
@media (min-width: 768px) {
  .mt-model-row > .mt-model-side { width: var(--mt-side, 25%); }
  .mt-model-row > .mt-model-main { width: calc(100% - var(--mt-side, 25%)); }
  .mt-model-row .mt-control-panel { width: calc(var(--mt-side, 25%) - 34px); }
  .mt-side-resizer {
    position: fixed; top: 72px; bottom: 14px; z-index: 20;
    left: calc(var(--mt-side, 25%) - 14px); width: 10px;
    cursor: col-resize;
  }
  .mt-side-resizer::after {
    content: ''; position: absolute; top: 0; bottom: 0; left: 4px; width: 2px;
    border-radius: 1px; background: transparent; transition: background .12s ease;
  }
  .mt-side-resizer:hover::after, .mt-resizing .mt-side-resizer::after { background: var(--mt-accent); }
}
@media (max-width: 767px) { .mt-side-resizer { display: none; } }
.mt-list-resizer {
  height: 12px; margin: 2px 0 -6px 0; cursor: row-resize;
  display: flex; align-items: center; justify-content: center;
}
.mt-list-resizer::before {
  content: ''; width: 36px; height: 4px; border-radius: 2px; background: #cbd5e1; transition: background .12s ease;
}
.mt-list-resizer:hover::before, .mt-resizing-list .mt-list-resizer::before { background: var(--mt-accent); }
/* Factor mapping tab: the factor browser can be made wider / narrower too */
@media (min-width: 768px) {
  .mt-map-layout > .mt-map-side { width: var(--mt-map-side, 25%); position: relative; }
  .mt-map-layout > .mt-map-main { width: calc(100% - var(--mt-map-side, 25%)); }
  .mt-map-side-resizer { position: absolute; top: 0; bottom: 12px; right: -5px; width: 10px; z-index: 5; cursor: col-resize; }
  .mt-map-side-resizer::after {
    content: ''; position: absolute; top: 0; bottom: 0; left: 4px; width: 2px;
    border-radius: 1px; background: transparent; transition: background .12s ease;
  }
  .mt-map-side-resizer:hover::after, .mt-resizing .mt-map-side-resizer::after { background: var(--mt-accent); }
}
@media (max-width: 767px) { .mt-map-side-resizer { display: none; } }
/* importance shown beside each factor when the list is ranked by importance */
.mt-factor-list .checkbox label > span { flex: 1 1 auto; min-width: 0; }
.mt-imp-tag {
  float: right; margin-left: 6px; font-size: 10.5px; font-weight: 600; color: #64748b;
  background: #f1f5f9; border-radius: 9px; padding: 0 6px; white-space: nowrap;
}
.mt-fgroup-head .mt-imp-tag { float: none; flex: 0 0 auto; margin-left: 0; }
.mt-imp-rank { color: #94a3b8; font-weight: 600; margin-right: 4px; font-size: 11px; }
.mt-report-opts .shiny-input-container { margin-bottom: 6px; }
@media (min-width: 992px) {
  .mt-chart-pair { display: flex; }
  .mt-chart-pair > .col-sm-6 { display: flex; }
  .mt-chart-pair .mt-card { flex: 1 1 auto; }
}
.mt-chart-pair .mt-empty-hint { min-height: 34px; }
body.mt-resizing, body.mt-resizing * { cursor: col-resize !important; user-select: none !important; }
body.mt-resizing-list, body.mt-resizing-list * { cursor: row-resize !important; user-select: none !important; }

/* ---- Import: data type tiles and steps ---- */
.mt-import-step { display: flex; align-items: center; font-weight: 600; font-size: 12.5px; color: #374151; margin: 4px 0 8px 0; }
.mt-import-step .mt-step { background: var(--mt-accent); color: #fff; }
.mt-import-step ~ .mt-import-step { margin-top: 14px; }
#import_type .shiny-options-group { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; margin-top: 0 !important; }
#import_type .radio { margin: 0; }
#import_type .radio label {
  display: flex; flex-direction: column; align-items: center; gap: 3px; height: 100%;
  padding: 10px 6px 9px 6px; border: 1px solid var(--mt-border); border-radius: 8px; background: #fff;
  cursor: pointer; text-align: center; transition: all .12s ease;
}
#import_type .radio label > span { display: flex; flex-direction: column; align-items: center; gap: 3px; }
#import_type .radio label:hover { border-color: #c3cbd8; background: #f8fafc; }
#import_type .radio input[type=radio] { position: absolute; opacity: 0; pointer-events: none; }
#import_type .radio label i, #import_type .radio label svg { font-size: 18px; color: #94a3b8; }
#import_type .mt-type-name { font-weight: 600; font-size: 12.5px; color: #374151; }
#import_type .mt-type-ext { font-size: 11px; color: var(--mt-muted); }
#import_type .radio label:has(input:checked) { border-color: var(--mt-accent); background: #eff4ff; box-shadow: 0 0 0 1px var(--mt-accent) inset; }
#import_type .radio label:has(input:checked) i, #import_type .radio label:has(input:checked) svg { color: var(--mt-accent); }
#import_type .radio label:has(input:checked) .mt-type-name { color: #1e3a8a; }
#import_type .radio label:has(input:focus-visible) { outline: 2px solid var(--mt-accent); outline-offset: 2px; }
.mt-csv-options { margin-top: 10px; padding: 10px 12px 2px 12px; background: #f8fafc; border: 1px solid var(--mt-border); border-radius: 8px; }
.mt-csv-options .form-group { margin-bottom: 8px; }
.mt-csv-header { padding-top: 26px; }
.mt-csv-header .checkbox { margin: 0; }
.mt-preview-table { min-height: 300px; }
.mt-preview-table .dataTables_wrapper { font-size: 12px; }

/* ---- Factor checklist (Model tab) ---- */
.mt-factor-card .mt-card-body { padding: 10px 12px 12px 12px; }
.mt-factor-card .mt-card-subtitle { font-weight: 600; color: var(--mt-accent); }
.mt-factor-toolbar { display: flex; flex-direction: column; gap: 7px; margin-bottom: 8px; }
.mt-factor-toolbar .form-group { margin: 0; }
.mt-factor-toolbar .radio-inline { font-size: 12px; padding-top: 0; }
.mt-factor-toolbar .btn-xs { font-size: 11.5px; padding: 4px 8px; }
#factor_search { height: 30px; font-size: 12.5px; }
.mt-factor-list {
  border: 1px solid var(--mt-border);
  border-radius: 6px;
  max-height: max(240px, calc(100vh - 560px));
  overflow-y: auto;
  background: #fff;
}
.mt-factor-list .form-group { margin: 0; }
/* Shiny pulls option groups up 10px under a (hidden) label, which clipped the first factor */
.mt-factor-list .shiny-options-group { padding: 2px 0; margin-top: 0 !important; }
.mt-factor-list .checkbox { margin: 0; }
.mt-factor-list .checkbox label {
  display: flex; align-items: flex-start; gap: 8px;
  width: 100%;
  padding: 5px 10px;
  font-size: 12px; font-weight: 400;
  color: #374151;
  overflow-wrap: anywhere;
  cursor: pointer;
}
.mt-factor-list .checkbox label:hover { background: #f5f7fb; }
.mt-factor-list .checkbox input[type=checkbox] {
  position: static; margin: 1px 0 0 0;
  width: 15px; height: 15px; flex: 0 0 15px;
  accent-color: var(--mt-accent);
  cursor: pointer;
}
.mt-factor-list .checkbox:has(input:checked) label { background: #eff4ff; color: #1e3a8a; font-weight: 600; }
.mt-factor-list .checkbox:has(input:checked) + .checkbox:not(:has(input:checked)) label { border-top: 1px solid var(--mt-border); }
.mt-factor-list:empty::before, .mt-factor-list .shiny-options-group:empty::before {
  content: 'Create the modelling dataset to list factors';
  display: block; padding: 12px; color: var(--mt-muted); font-size: 12px;
}

/* factor currently shown in the charts */
.mt-factor-list .checkbox.mt-viewing label { box-shadow: inset 3px 0 0 var(--mt-accent); background: #e0eaff; }
/* categorical factors: collapsible group of one-hot levels */
.mt-factor-list .mt-filtered { display: none !important; }
.mt-fgroup-head {
  display: flex; align-items: center; gap: 6px;
  padding: 5px 10px 5px 4px; font-size: 12px; color: #374151; cursor: pointer;
}
.mt-fgroup-head:hover { background: #f5f7fb; }
.mt-fgroup-head.has-checked { background: #eff4ff; color: #1e3a8a; font-weight: 600; }
.mt-fgroup-head.mt-viewing { box-shadow: inset 3px 0 0 var(--mt-accent); background: #e0eaff; }
.mt-fcaret { width: 16px; flex: 0 0 16px; text-align: center; color: #94a3b8; }
.mt-fcaret::before { content: '\\25B8'; display: inline-block; transition: transform .12s ease; }
.mt-fgroup-head.is-open .mt-fcaret::before, .mt-searching .mt-fcaret::before { transform: rotate(90deg); }
.mt-fgroup-cb {
  width: 15px; height: 15px; flex: 0 0 15px; border: 1.5px solid #9aa4b2; border-radius: 3px; background: #fff;
  position: relative;
}
.mt-fgroup-cb.is-checked, .mt-fgroup-cb.is-mixed { background: var(--mt-accent); border-color: var(--mt-accent); }
.mt-fgroup-cb.is-checked::after {
  content: ''; position: absolute; left: 4px; top: 1px; width: 4px; height: 8px;
  border: solid #fff; border-width: 0 2px 2px 0; transform: rotate(45deg);
}
.mt-fgroup-cb.is-mixed::after { content: ''; position: absolute; left: 2px; right: 2px; top: 5px; height: 2px; background: #fff; }
.mt-fgroup-name { flex: 1 1 auto; min-width: 0; overflow-wrap: anywhere; }
.mt-fgroup-count {
  flex: 0 0 auto; font-size: 10.5px; font-weight: 600; color: #64748b;
  background: #f1f5f9; border-radius: 9px; padding: 0 7px;
}
.mt-fgroup-head.has-checked .mt-fgroup-count { background: #dbe7ff; color: #1e3a8a; }
.mt-fgroup-kids { display: none; border-left: 1px solid #dbe3ee; margin-left: 12px; }
.mt-fgroup-head.is-open + .mt-fgroup-kids, .mt-searching .mt-fgroup-kids { display: block; }
.mt-fgroup-kids .checkbox label { padding-left: 22px; }
/* numeric factors keep an empty arrow column, so every tick box and name lines up with the categorical groups */
.mt-factor-list .shiny-options-group > .checkbox label { padding-left: 26px; }
.mt-fgroup-cb { margin-right: 2px; }
/* one 'viewing' pill on the group header rather than on every level */
.mt-fgroup-kids .checkbox.mt-viewing label::after { display: none; }
.mt-fgroup-kids .checkbox.mt-viewing label { box-shadow: none; }
.mt-fgroup-head.mt-viewing .mt-fgroup-name::after {
  content: 'viewing'; margin-left: 6px; padding: 1px 6px; vertical-align: 1px;
  border-radius: 8px; background: var(--mt-accent); color: #fff;
  font-size: 9.5px; font-weight: 600; letter-spacing: .3px; white-space: nowrap;
}
.mt-factor-list .checkbox.mt-viewing label::after {
  content: 'viewing';
  margin-left: auto; padding: 1px 6px;
  border-radius: 8px; background: var(--mt-accent); color: #fff;
  font-size: 9.5px; font-weight: 600; letter-spacing: .3px; white-space: nowrap;
}
.mt-current-factor {
  display: flex; align-items: center; gap: 8px;
  height: 34px; padding: 0 12px;
  border: 1px solid #c7d7fe; border-radius: 6px;
  background: #eff4ff; color: #1e3a8a; font-weight: 600;
  overflow: hidden; white-space: nowrap; text-overflow: ellipsis;
}
.mt-current-factor + .mt-empty-hint { margin-top: 4px; }

/* ---- Model summary (pop-up + Validation card) ---- */
.mt-sum-tiles { display: grid; grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); gap: 10px; margin-bottom: 6px; }
.modal-lg { width: min(1000px, 94vw); }
.mt-sum-tile { background: #f8fafc; border: 1px solid var(--mt-border); border-radius: 8px; padding: 10px 12px; }
.mt-sum-label { font-size: 10.5px; text-transform: uppercase; letter-spacing: .6px; color: var(--mt-muted); font-weight: 600; }
.mt-sum-value { font-size: 20px; font-weight: 700; color: var(--mt-text); margin-top: 2px; }
.mt-sum-sub { font-size: 11.5px; color: var(--mt-muted); margin-top: 2px; }
.mt-sum-table { margin-bottom: 4px; font-size: 12.5px; }
.mt-sum-table th { font-size: 11px; text-transform: uppercase; letter-spacing: .4px; color: var(--mt-muted); border-bottom: 1px solid var(--mt-border) !important; }
.mt-sum-table td, .mt-sum-table th { padding: 6px 8px !important; text-align: right; }
.mt-sum-table td:first-child, .mt-sum-table th:first-child { text-align: left; font-weight: 600; }
.mt-good, .mt-warn, .mt-bad { padding: 1px 7px; border-radius: 10px; font-weight: 600; }
.mt-good { background: #ecfdf3; color: #067647; }
.mt-warn { background: #fffaeb; color: #b54708; }
.mt-bad  { background: #fef3f2; color: #b42318; }
.mt-sum-metrics { display: flex; flex-wrap: wrap; gap: 6px; }
.mt-sum-chip { background: #f1f5f9; border-radius: 12px; padding: 3px 10px; font-size: 11.5px; color: #475569; }
.mt-sum-bar-row { display: grid; grid-template-columns: minmax(0, 1.4fr) 1fr 48px; gap: 8px; align-items: center; margin-bottom: 6px; font-size: 12px; }
.mt-sum-bar-name { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.mt-sum-bar-track { background: #eef2f7; border-radius: 4px; height: 8px; }
.mt-sum-bar-fill { background: var(--mt-accent); height: 8px; border-radius: 4px; }
.mt-sum-bar-val { text-align: right; color: var(--mt-muted); }
.modal-content { border-radius: 10px; border: none; box-shadow: 0 20px 50px rgba(15, 23, 42, .25); }
.modal-header { border-bottom: 1px solid var(--mt-border); }
.modal-title { font-weight: 600; }
.modal-footer { border-top: 1px solid var(--mt-border); }

/* ---- Progress bar (model fitting) ---- */
.shiny-notification { border-radius: 8px; border: 1px solid var(--mt-border); box-shadow: 0 8px 24px rgba(15, 23, 42, .15); font-family: inherit; }
.shiny-progress-notification .progress { height: 8px; margin-top: 6px; background: #e5e9f0; }
.shiny-progress-notification .progress-bar { background: var(--mt-accent); }
.shiny-progress-notification .progress-text .progress-message { font-weight: 600; }
.shiny-progress-notification .progress-text .progress-detail { color: var(--mt-muted); }
.shiny-notification-error { border-left: 4px solid #b42318; }

/* ---- Tree viewer ---- */
.mt-tree-nav { display: flex; gap: 8px; align-items: flex-end; flex-wrap: wrap; }
.mt-tree-nav .form-group { margin: 0; }
.mt-tree-nav .shiny-input-container:not(.shiny-input-container-inline) { width: 240px; flex: 0 0 240px; }
.mt-tree-nav .btn { height: 34px; }
.mt-tree-info { color: var(--mt-muted); font-size: 12px; margin-left: auto; align-self: center; }

/* ---- Tables ---- */
table.dataTable thead th { background: #f8fafc; font-weight: 600; color: #374151; border-bottom: 1px solid var(--mt-border) !important; }
table.dataTable tbody td { border-top: 1px solid #f0f2f6 !important; padding: 6px 10px !important; line-height: 1.35; white-space: nowrap; }
table.dataTable thead th { padding: 8px 18px 8px 10px !important; white-space: nowrap; }
.dataTables_wrapper .dataTables_filter input { border-radius: 6px; border: 1px solid #d5dbe5; padding: 3px 8px; }
.dt-buttons .dt-button, .dt-buttons .btn { border-radius: 6px !important; font-size: 12px; }
.mt-table-scroll { overflow-x: auto; }
.mt-table-scroll table.table { font-size: 12px; background: #fff; }

/* ---- Tooltips & alerts ---- */
.tooltip-inner { background: var(--mt-navy); border-radius: 5px; padding: 6px 10px; max-width: 260px; }
.tooltip.bottom .tooltip-arrow { border-bottom-color: var(--mt-navy); }

.mt-empty-hint { color: var(--mt-muted); font-size: 12px; margin: 4px 0 0 0; }

/* ---- Factor mapping: factor browser ---- */
.btn.btn-danger-outline { background: #fff; border-color: #fecdca; color: #b42318; }
.btn.btn-danger-outline:hover, .btn.btn-danger-outline:focus { background: #fef3f2; border-color: #fda29b; color: #912018; }
#map_search { height: 30px; font-size: 12.5px; }
.mt-map-list {
  border: 1px solid var(--mt-border); border-radius: 6px; background: #fff;
  max-height: max(260px, calc(100vh - 330px)); overflow-y: auto;
}
.mt-map-row {
  display: flex; align-items: center; gap: 6px;
  padding: 6px 8px 6px 10px; font-size: 12px; color: #374151;
  cursor: pointer; user-select: none; border-bottom: 1px solid #f3f5f8;
}
.mt-map-row:last-child { border-bottom: none; }
.mt-map-row:hover { background: #f5f7fb; }
.mt-map-name { flex: 1 1 auto; min-width: 0; overflow-wrap: anywhere; }
.mt-map-tag {
  flex: 0 0 auto; font-size: 9.5px; font-weight: 600; letter-spacing: .3px; text-transform: uppercase;
  color: #64748b; background: #f1f5f9; border-radius: 4px; padding: 1px 5px;
}
.mt-map-badge {
  flex: 0 0 auto; font-size: 10.5px; font-weight: 600; white-space: nowrap;
  color: #067647; background: #ecfdf3; border: 1px solid #abefc6; border-radius: 10px; padding: 0 7px;
}
.mt-map-edit {
  flex: 0 0 auto; border: none; background: transparent; color: #94a3b8;
  padding: 2px 5px; border-radius: 4px; visibility: hidden;
}
.mt-map-row:hover .mt-map-edit, .mt-map-row.mt-viewing .mt-map-edit { visibility: visible; }
.mt-map-edit:hover { background: #dbe7ff; color: var(--mt-accent); }
.mt-map-row.mt-mapped .mt-map-name { font-weight: 600; }
.mt-map-row.mt-viewing { background: #e0eaff; box-shadow: inset 3px 0 0 var(--mt-accent); color: #1e3a8a; }
.mt-map-empty { padding: 12px; color: var(--mt-muted); font-size: 12px; }
.mt-map-hint { margin-top: 8px; color: var(--mt-muted); font-size: 11.5px; }
.mt-map-hint i, .mt-map-hint svg { opacity: .7; }

/* ---- Factor mapping: workspace header ---- */
.mt-map-header { padding: 10px 14px; }
.mt-map-head { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.mt-map-head-name { font-size: 16px; font-weight: 600; }
.mt-map-head-meta { color: var(--mt-muted); font-size: 12px; }
.mt-map-head-actions { margin-left: auto; display: flex; gap: 8px; }
.mt-map-chip { font-size: 11px; font-weight: 600; border-radius: 10px; padding: 2px 9px; }
.mt-map-chip.on  { color: #067647; background: #ecfdf3; border: 1px solid #abefc6; }
.mt-map-chip.off { color: #64748b; background: #f1f5f9; border: 1px solid #e2e8f0; }

/* ---- Factor mapping: pop-out editor ---- */
.modal-dialog:has(.mt-map-modal) { width: min(1180px, 96vw); }
.mt-map-modal .mt-map-method { display: flex; align-items: flex-end; gap: 14px; flex-wrap: wrap; margin-bottom: 4px; }
.mt-map-modal .mt-map-method .form-group { margin-bottom: 0; }
.mt-map-modal .mt-map-method .shiny-input-container:not(.shiny-input-container-inline) { width: auto; }
.mt-map-auto { display: flex; align-items: flex-end; gap: 8px; }
.mt-map-auto .form-control { width: 90px; }
.mt-map-tools { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; margin-bottom: 8px; }
.mt-map-tools .btn { padding: 5px 10px; font-size: 12px; }
.mt-map-tools .form-group { margin: 0; }
.mt-map-tools .shiny-input-container:not(.shiny-input-container-inline) { width: auto; }
.mt-map-tools .input-group { width: 150px; }
.mt-map-tools .input-group .form-control { display: none; }
.mt-map-tools .input-group .btn { border-radius: 6px !important; }
.mt-map-tools .progress { display: none; }
.mt-map-table-wrap {
  border: 1px solid var(--mt-border); border-radius: 6px;
  max-height: 420px; overflow-y: auto; background: #fff;
}
table.mt-map-table { width: 100%; border-collapse: collapse; font-size: 12px; }
table.mt-map-table th {
  position: sticky; top: 0; z-index: 1; background: #f8fafc;
  font-weight: 600; color: #374151; text-align: left; padding: 7px 10px;
  border-bottom: 1px solid var(--mt-border); white-space: nowrap;
}
table.mt-map-table td { padding: 0 10px; height: 30px; border-bottom: 1px solid #f0f2f6; }
table.mt-map-table td.mt-locked { color: #475569; background: #fafbfc; }
table.mt-map-table td.mt-num { text-align: right; color: var(--mt-muted); font-variant-numeric: tabular-nums; }
table.mt-map-table th i, table.mt-map-table th svg { color: #94a3b8; margin-left: 6px; font-size: 10px; }
table.mt-map-table td.mt-new-cell { padding: 0; background: #fff; }
table.mt-map-table input.mt-new {
  width: 100%; height: 30px; border: none; padding: 0 10px; font-size: 12px;
  background: transparent; outline: none;
}
table.mt-map-table input.mt-new:focus { box-shadow: inset 0 0 0 2px var(--mt-accent); background: #f8fbff; }
table.mt-map-table input.mt-new.mt-edited { background: #fffbeb; }
table.mt-map-table tr.mt-changed td.mt-locked:first-child { box-shadow: inset 3px 0 0 #f59e0b; }
.mt-map-note { color: var(--mt-muted); font-size: 11.5px; margin-top: 6px; }
.btn.mt-copied, .btn.mt-copied:hover { background: #ecfdf3; border-color: #abefc6; color: #067647; }
.mt-copy-fallback { margin-bottom: 8px; padding: 8px 10px; border: 1px solid #fedf89; background: #fffaeb; border-radius: 6px; font-size: 12px; color: #b54708; }
.mt-copy-fallback textarea { width: 100%; height: 70px; margin-top: 6px; font-family: Consolas, monospace; font-size: 11px; border: 1px solid #fedf89; border-radius: 4px; }
.mt-map-preview-empty {
  height: 100%; min-height: 300px; display: flex; flex-direction: column; align-items: center; justify-content: center;
  gap: 10px; border: 1px dashed #cbd5e1; border-radius: 8px; color: var(--mt-muted); background: #fafbfc; text-align: center; padding: 20px;
}
.mt-map-preview-stats { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 6px; }
.mt-map-preview-title { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: .5px; color: var(--mt-muted); margin: 4px 0 0 2px; }
.mt-map-title { display: flex; align-items: center; gap: 8px; }
.mt-map-title > i, .mt-map-title > svg { color: var(--mt-accent); }
"

# Factor checklist behaviour: search filter and select / clear all (acts on the factors currently shown by the search)
factor_list_js <- "
$(function() {
  // model column -> raw factor, for the one-hot columns of categorical factors (sent by the server)
  window.mtFactorBase = {};
  window.mtExpanded   = {};
  window.mtViewing    = [];
  window.mtImp        = {};
  var list = function() { return $('#FactorList .shiny-options-group'); };

  // group the one-hot columns of each categorical factor under a collapsible header row.
  // The header's tick box is a styled span (not an input) so it is never sent to the server as a factor.
  function buildGroups() {
    var box = list();
    if (!box.length) return;
    box.find('.mt-fgroup-head').remove();
    box.find('.mt-fgroup-kids').each(function() { $(this).replaceWith($(this).contents()); });
    var rows = box.children('.checkbox').toArray(), i = 0;
    var baseOf = function(r) { return window.mtFactorBase[$(r).find('input').val()]; };
    while (i < rows.length) {
      var base = baseOf(rows[i]);
      if (!base) { i++; continue; }
      var j = i;
      while (j < rows.length && baseOf(rows[j]) === base) j++;
      var head = $('<div class=\"mt-fgroup-head\"><span class=\"mt-fcaret\" title=\"Show / hide levels\"></span>' +
                   '<span class=\"mt-fgroup-cb\" role=\"checkbox\" title=\"Tick / untick all levels\"></span>' +
                   '<span class=\"mt-fgroup-name\"></span><span class=\"mt-fgroup-count\"></span></div>').attr('data-base', base);
      head.find('.mt-fgroup-name').text(base);
      var imp = window.mtImp[base];
      if (imp) {
        head.find('.mt-fgroup-name').prepend($('<span class=\"mt-imp-rank\"></span>').text(imp.rank + '.'));
        head.find('.mt-fgroup-count').after($('<span class=\"mt-imp-tag\" title=\"Share of total gain\"></span>').text(imp.pct));
      }
      var kids = $('<div class=\"mt-fgroup-kids\"></div>');
      $(rows[i]).before(head);
      head.after(kids);
      kids.append(rows.slice(i, j));
      head.toggleClass('is-open', !!window.mtExpanded[base]);
      i = j;
    }
    refreshGroups(); applyFactorFilter(); applyViewing();
  }
  function refreshGroups() {
    $('#FactorList .mt-fgroup-head').each(function() {
      var kids = $(this).next('.mt-fgroup-kids').find('input[type=checkbox]');
      var n = kids.length, k = kids.filter(':checked').length;
      $(this).find('.mt-fgroup-cb').toggleClass('is-checked', n > 0 && k === n).toggleClass('is-mixed', k > 0 && k < n);
      $(this).toggleClass('has-checked', k > 0);
      $(this).find('.mt-fgroup-count').text(k + '/' + n);
    });
  }
  function applyFactorFilter() {
    var q = ($('#factor_search').val() || '').toLowerCase();
    $('#FactorList').toggleClass('mt-searching', q.length > 0);
    $('#FactorList .checkbox').each(function() {
      var v = String($(this).find('input').val()), base = window.mtFactorBase[v] || '';
      $(this).toggleClass('mt-filtered', (v + ' ' + base).toLowerCase().indexOf(q) < 0);
    });
    $('#FactorList .mt-fgroup-head').each(function() {
      $(this).toggleClass('mt-filtered', $(this).next('.mt-fgroup-kids').find('.checkbox:not(.mt-filtered)').length === 0);
    });
  }
  // select / clear acts on everything matching the search, including levels inside collapsed groups
  function setVisible(checked) {
    $('#FactorList .checkbox:not(.mt-filtered) input[type=checkbox]').prop('checked', checked);
    $('#FactorList input[type=checkbox]').first().trigger('change');
  }
  // highlight the rows (one-hot levels) that belong to the factor currently shown in the charts
  function applyViewing() {
    $('#FactorList .checkbox').each(function() {
      $(this).toggleClass('mt-viewing', window.mtViewing.indexOf($(this).find('input').val()) > -1);
    });
    $('#FactorList .mt-fgroup-head').each(function() {
      $(this).toggleClass('mt-viewing', $(this).next('.mt-fgroup-kids').find('.checkbox.mt-viewing').length > 0);
    });
  }

  Shiny.addCustomMessageHandler('factor_groups', function(m) {
    window.mtFactorBase = {};
    (m.cols || []).forEach(function(c, i) { if (m.base[i]) window.mtFactorBase[c] = m.base[i]; });
    window.mtImp = m.imp || {};
    setTimeout(buildGroups, 0);
  });
  Shiny.addCustomMessageHandler('factor_viewing', function(vals) {
    window.mtViewing = [].concat(vals || []);
    applyViewing();
  });

  // clicking a factor name views it in the charts; only the tick box ticks / unticks it
  $(document).on('click', '#FactorList .checkbox label', function(e) {
    if ($(e.target).is('input[type=checkbox]')) return;
    e.preventDefault();
    Shiny.setInputValue('factor_clicked', $(this).find('input[type=checkbox]').val(), {priority: 'event'});
  });
  $(document).on('click', '#FactorList .mt-fgroup-head', function(e) {
    var head = $(this), base = head.attr('data-base');
    if ($(e.target).closest('.mt-fcaret, .mt-fgroup-count').length) {
      window.mtExpanded[base] = !head.hasClass('is-open');
      head.toggleClass('is-open', window.mtExpanded[base]);
    } else if ($(e.target).closest('.mt-fgroup-cb').length) {
      var kids = head.next('.mt-fgroup-kids').find('input[type=checkbox]');
      kids.prop('checked', kids.filter(':checked').length < kids.length);
      kids.first().trigger('change');
    } else {
      Shiny.setInputValue('factor_clicked', base, {priority: 'event'});
    }
  });
  $(document).on('change', '#FactorList input[type=checkbox]', refreshGroups);
  $(document).on('input', '#factor_search', applyFactorFilter);
  $(document).on('click', '#factor_select_all', function() { setVisible(true); });
  $(document).on('click', '#factor_clear_all',  function() { setVisible(false); });
  // rebuild after the server re-orders or replaces the list
  $(document).on('shiny:updateinput', function(e) {
    if (e.target && e.target.id === 'FactorList') setTimeout(buildGroups, 0);
  });
});
"

# Model tab: drag the panel's right edge to change its width, and the bar under the factor list to change the
# list's height. Sizes are remembered in this browser; double-click a handle to go back to the default.
resize_js <- "
$(function() {
  var store = {
    get: function(k) { try { return localStorage.getItem(k); } catch (e) { return null; } },
    set: function(k, v) { try { if (v === null) localStorage.removeItem(k); else localStorage.setItem(k, v); } catch (e) {} }
  };
  function nudgeCharts() { window.dispatchEvent(new Event('resize')); }
  // panels whose width can be dragged: Model tab (fixed panel) and Factor mapping tab (factor browser)
  var sides = {
    model: {row: '.mt-model-row', prop: '--mt-side', key: 'mt_side_px', min: 260, handle: '.mt-side-resizer',
            width: function(ev) { return ev.clientX + 12; }},
    map:   {row: '.mt-map-layout', prop: '--mt-map-side', key: 'mt_map_side_px', min: 220, handle: '.mt-map-side-resizer',
            width: function(ev) { return ev.clientX - $('.mt-map-layout').offset().left + 6; }}
  };
  function setSide(cfg, px) {
    if (px === null) { $(cfg.row).css(cfg.prop, ''); return; }
    px = Math.max(cfg.min, Math.min(px, Math.round(window.innerWidth * 0.6)));
    $(cfg.row).css(cfg.prop, px + 'px');
    return px;
  }
  // lists whose height can be dragged (the handle sits right under its list)
  var lists = {
    model: {list: '.mt-model-row .mt-factor-list', key: 'mt_list_px'},
    map:   {list: '#map_factor_list', key: 'mt_map_list_px'},
    glm:   {list: '#glm_factor_list', key: 'mt_glm_list_px'}
  };
  function setList(cfg, px) {
    if (px === null) { $(cfg.list).css({height: '', 'max-height': ''}); return; }
    px = Math.round(Math.max(120, Math.min(px, 2000)));
    $(cfg.list).css({height: px + 'px', 'max-height': 'none'});
    return px;
  }
  function restore() {
    $.each(sides, function(_, c) { var v = parseInt(store.get(c.key), 10); if (v) setSide(c, v); });
    $.each(lists, function(_, c) { var v = parseInt(store.get(c.key), 10); if (v) setList(c, v); });
  }
  restore();
  $(document).on('shiny:connected', restore);

  $.each(sides, function(_, cfg) {
    $(document).on('mousedown', cfg.handle, function(e) {
      e.preventDefault();
      $('body').addClass('mt-resizing');
      var w;
      $(document).on('mousemove.mtside', function(ev) { w = setSide(cfg, cfg.width(ev)); });
      $(document).on('mouseup.mtside', function() {
        $(document).off('.mtside');
        $('body').removeClass('mt-resizing');
        if (w) store.set(cfg.key, w);
        nudgeCharts();
      });
    });
    $(document).on('dblclick', cfg.handle, function() { setSide(cfg, null); store.set(cfg.key, null); nudgeCharts(); });
  });

  $(document).on('mousedown', '.mt-list-resizer', function(e) {
    e.preventDefault();
    var cfg = lists[$(this).attr('data-list') || 'model'];
    $('body').addClass('mt-resizing-list');
    var startY = e.clientY, startH = $(cfg.list).outerHeight(), h;
    $(document).on('mousemove.mtlist', function(ev) { h = setList(cfg, startH + ev.clientY - startY); });
    $(document).on('mouseup.mtlist', function() {
      $(document).off('.mtlist');
      $('body').removeClass('mt-resizing-list');
      if (h) store.set(cfg.key, h);
    });
  });
  $(document).on('dblclick', '.mt-list-resizer', function() {
    var cfg = lists[$(this).attr('data-list') || 'model'];
    setList(cfg, null); store.set(cfg.key, null);
  });
});
"

# Import tab: the file picker only offers files of the chosen data type
import_js <- "
$(function() {
  var types = {
    rds:     {accept: '.rds',         placeholder: 'No .rds file selected'},
    csv:     {accept: '.csv,.txt',    placeholder: 'No .csv file selected'},
    parquet: {accept: '.parquet,.pq', placeholder: 'No .parquet file selected'}
  };
  function textBox() { return $('#action_read_file').closest('.input-group').find('input[type=text]'); }
  function applyType(t) {
    var cfg = types[t] || types.rds;
    $('#action_read_file').attr('accept', cfg.accept);
    if (!textBox().data('picked')) textBox().attr('placeholder', cfg.placeholder);
  }
  $(document).on('change', 'input[name=import_type]', function() { applyType(this.value); });
  $(document).on('change', '#action_read_file', function() { textBox().data('picked', true); });
  $(document).on('shiny:connected', function() { applyType($('input[name=import_type]:checked').val()); });
});
"

# Factor mapping tab: factor browser (click = view, right-click / pencil = map) and the spreadsheet-like mapping table
map_js <- "
$(function() {
  // ---- factor browser ----
  function filterMapList() {
    var q = ($('#map_search').val() || '').toLowerCase();
    $('#map_factor_list .mt-map-row').each(function() {
      $(this).toggle(String($(this).attr('data-f')).toLowerCase().indexOf(q) > -1);
    });
  }
  window.mtMapViewing = null;
  function markMapViewing() {
    $('#map_factor_list .mt-map-row').each(function() {
      $(this).toggleClass('mt-viewing', $(this).attr('data-f') === window.mtMapViewing);
    });
  }
  Shiny.addCustomMessageHandler('map_viewing', function(f) { window.mtMapViewing = f; markMapViewing(); });
  $(document).on('input', '#map_search', filterMapList);
  $(document).on('shiny:value', function(e) {
    if (e.name === 'map_factor_list_ui') setTimeout(function() { filterMapList(); markMapViewing(); }, 0);
  });
  $(document).on('click', '#map_factor_list .mt-map-row', function(e) {
    if ($(e.target).closest('.mt-map-edit').length) return;
    Shiny.setInputValue('map_view', $(this).attr('data-f'), {priority: 'event'});
  });
  $(document).on('contextmenu', '#map_factor_list .mt-map-row', function(e) {
    e.preventDefault();
    Shiny.setInputValue('map_open', $(this).attr('data-f'), {priority: 'event'});
  });
  $(document).on('click', '#map_factor_list .mt-map-edit', function(e) {
    e.stopPropagation();
    Shiny.setInputValue('map_open', $(this).closest('.mt-map-row').attr('data-f'), {priority: 'event'});
  });

  // ---- mapping table: current levels are locked, new levels are editable / pasteable ----
  var sendTimer = null;
  function isCustom() { return $('#map_edit_table').attr('data-mode') === 'custom'; }
  function colVals(col) { return $('#map_edit_table input[data-col=\"' + col + '\"]').map(function() { return this.value; }).get(); }
  function sendCustom(op, extra) {
    var t = $('#map_edit_table');
    var msg = $.extend({token: t.attr('data-token'), op: op, left: colVals('left'), right: colVals('right'),
                        values: colVals('new'), nonce: Math.random()}, extra || {});
    Shiny.setInputValue('map_custom_edit', msg, {priority: 'event'});
  }
  function sendMapLevels() {
    var t = $('#map_edit_table');
    if (!t.length) return;
    if (isCustom()) { sendCustom('edit'); return; }
    var vals = t.find('input.mt-new').map(function() { return this.value; }).get();
    Shiny.setInputValue('map_new_levels', {token: t.attr('data-token'), values: vals});
  }
  $(document).on('click', '#map_add_band', function() { clearTimeout(sendTimer); sendCustom('add'); });
  $(document).on('click', '#map_edit_table .mt-band-del', function() {
    clearTimeout(sendTimer); sendCustom('remove', {i: parseInt($(this).attr('data-i'), 10)});
  });
  Shiny.addCustomMessageHandler('map_expo', function(m) {
    var t = $('#map_edit_table');
    if (String(t.attr('data-token')) !== String(m.token)) return;
    var v = [].concat(m.v), txt = [].concat(m.txt);
    t.find('tbody tr').each(function(i) { $(this).find('td.mt-num').attr('data-v', v[i]).text(txt[i]); });
  });
  function queueSend() { clearTimeout(sendTimer); sendTimer = setTimeout(sendMapLevels, 300); }
  function markRow(inp) {
    var $i = $(inp), changed = $i.val() !== '' && $i.val() !== $i.attr('data-orig');
    $i.toggleClass('mt-edited', changed);
    $i.closest('tr').toggleClass('mt-changed', changed);
  }
  $(document).on('input', '#map_edit_table input.mt-new', function() { markRow(this); queueSend(); });
  // make sure the latest typing reaches the server before apply / download / preview
  $(document).on('mousedown focus', '#map_apply, #map_download_xlsx, #map_view_new', function() { clearTimeout(sendTimer); sendMapLevels(); });
  // pasting several cells from Excel fills the column downwards from the selected cell;
  // if several columns are pasted, the last one is taken as the new level
  $(document).on('paste', '#map_edit_table input.mt-new', function(e) {
    var cd = (e.originalEvent && e.originalEvent.clipboardData) || window.clipboardData;
    if (!cd) return;
    var txt = cd.getData('text');
    if (txt.indexOf('\\n') < 0 && txt.indexOf('\\t') < 0) return;
    e.preventDefault();
    var lines = txt.replace(/\\r/g, '').split('\\n');
    while (lines.length && lines[lines.length - 1] === '') lines.pop();
    if (isCustom()) {
      // custom bands: the pasted columns fill From / To / New level to the right of the cell; extra rows add bands
      var grid = lines.map(function(l) { return l.split('\\t').map(function(s) { return s.trim(); }); });
      if (grid.length && grid[0].some(function(s) { return /from|to|left|right|level|band/i.test(s) && isNaN(parseFloat(s)); })) grid.shift();
      var cols = ['left', 'right', 'new'], c0 = cols.indexOf($(this).attr('data-col'));
      var r0 = $('#map_edit_table input[data-col=\"' + cols[c0] + '\"]').index(this);
      var data = {left: colVals('left'), right: colVals('right'), new: colVals('new')}, n0 = data.left.length;
      grid.forEach(function(row, i) {
        var r = r0 + i;
        cols.forEach(function(c) { while (data[c].length <= r) data[c].push(''); });
        row.forEach(function(v, j) { if (c0 + j < 3) data[cols[c0 + j]][r] = v; });
      });
      clearTimeout(sendTimer);
      var t = $('#map_edit_table');
      if (data.left.length === n0) cols.forEach(function(c) {
        $('#map_edit_table input[data-col=\"' + c + '\"]').each(function(i) { $(this).val(data[c][i]); markRow(this); });
      });
      Shiny.setInputValue('map_custom_edit', {token: t.attr('data-token'), op: data.left.length > n0 ? 'set' : 'edit',
                          left: data.left, right: data.right, values: data.new, nonce: Math.random()}, {priority: 'event'});
      Shiny.setInputValue('map_pasted', {n: grid.length, extra: 0}, {priority: 'event'});
      return;
    }
    var cells = lines.map(function(l) { var p = l.split('\\t'); return p[p.length - 1].trim(); });
    if (cells.length && /new.?(factor.?)?level/i.test(cells[0])) cells.shift();
    var inputs = $('#map_edit_table input.mt-new'), start = inputs.index(this);
    var n = Math.min(cells.length, inputs.length - start);
    for (var i = 0; i < n; i++) { inputs.eq(start + i).val(cells[i]); markRow(inputs[start + i]); }
    Shiny.setInputValue('map_pasted', {n: n, extra: cells.length - n}, {priority: 'event'});
    sendMapLevels();
  });
  // copy the whole table (tab separated, with a header row) so it pastes straight into Excel
  function copyText(txt, done) {
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(txt).then(done, function() { fallbackCopy(txt, done); });
    } else { fallbackCopy(txt, done); }
  }
  function fallbackCopy(txt, done) {
    // the textarea goes inside the modal, otherwise the modal's focus trap blocks the copy
    var ta = $('<textarea style=\"position:fixed;top:0;left:0;opacity:0;\"></textarea>').val(txt)
               .appendTo($('.modal:visible .modal-body').first().length ? $('.modal:visible .modal-body').first() : $('body'));
    ta[0].focus(); ta[0].select();
    var ok = false; try { ok = document.execCommand('copy'); } catch (e) {}
    ta.remove();
    if (ok) done(); else manualCopy(txt, done);
  }
  // last resort when the browser blocks clipboard access: show the text selected, ready for Ctrl+C
  function manualCopy(txt, done) {
    var box = $('#map_copy_fallback');
    if (!box.length) {
      box = $('<div id=\"map_copy_fallback\" class=\"mt-copy-fallback\">' +
              '<div>This browser blocked automatic copying. The table is selected below: press <b>Ctrl+C</b> to copy it.</div>' +
              '<textarea readonly spellcheck=\"false\"></textarea></div>').insertAfter('.mt-map-tools');
      box.find('textarea').on('copy', function() { setTimeout(function() { box.remove(); done(); }, 0); });
    }
    box.find('textarea').val(txt).focus().select();
  }
  $(document).on('click', '#map_copy_table', function() {
    var t = $('#map_edit_table'), btn = $(this);
    if (!t.length) return;
    var lines = [t.find('thead th').map(function() { return $(this).attr('data-col'); }).get().join('\\t')];
    t.find('tbody tr').each(function() {
      lines.push($(this).find('td').map(function() {
        var inp = $(this).find('input');
        if (inp.length) return inp.val();
        var v = $(this).attr('data-v');
        return v !== undefined ? v : $(this).text();
      }).get().join('\\t'));
    });
    copyText(lines.join('\\r\\n') + '\\r\\n', function() {
      var label = btn.find('span');
      label.text('Copied ' + (lines.length - 1) + ' rows');
      btn.addClass('mt-copied');
      setTimeout(function() { label.text('Copy table'); btn.removeClass('mt-copied'); }, 2000);
    });
  });
  // Enter / arrow keys move between cells like a spreadsheet
  $(document).on('keydown', '#map_edit_table input.mt-new', function(e) {
    var col = $(this).attr('data-col');
    var inputs = col ? $('#map_edit_table input[data-col=\"' + col + '\"]') : $('#map_edit_table input.mt-new'), i = inputs.index(this);
    if (e.key === 'Enter' || e.key === 'ArrowDown') { e.preventDefault(); inputs.eq(Math.min(i + 1, inputs.length - 1)).focus().select(); }
    else if (e.key === 'ArrowUp') { e.preventDefault(); if (i > 0) inputs.eq(i - 1).focus().select(); }
  });
});
"

# GLM-specific styling -------------------------------------------------------------------------------------------------------
glm_css <- "
.mt-map-custom-hint { color: var(--mt-muted); font-size: 12px; padding-bottom: 8px; }
table.mt-custom-bands input.mt-edge[data-col='left'], table.mt-custom-bands input.mt-edge[data-col='right'] { font-variant-numeric: tabular-nums; }
table.mt-custom-bands td.mt-num { white-space: nowrap; }
table.mt-map-table th.mt-del, table.mt-map-table td.mt-del { width: 30px; padding: 0 4px; text-align: center; }
.mt-band-del { border: none; background: transparent; color: #94a3b8; width: 24px; height: 24px; border-radius: 4px; cursor: pointer; }
.mt-band-del:hover { background: #fef3f2; color: #b42318; }
.mt-add-band { margin-top: 6px; padding: 4px 10px; font-size: 12px; }
.mt-band-check { margin-top: 8px; font-size: 12px; display: flex; flex-direction: column; gap: 4px; }
.mt-band-check .bad { color: #b42318; background: #fef3f2; border: 1px solid #fecdca; border-radius: 6px; padding: 5px 8px; }
.mt-band-check .warn { color: #b54708; background: #fffaeb; border: 1px solid #fedf89; border-radius: 6px; padding: 5px 8px; }
.mt-band-check.ok { color: #067647; background: #ecfdf3; border: 1px solid #abefc6; border-radius: 6px; padding: 5px 8px; display: block; }
.mt-rename-tools { display: flex; flex-wrap: wrap; gap: 8px; align-items: flex-start; margin-bottom: 8px; }
.mt-rename-tools .form-group { margin: 0; }
.mt-rename-tools .shiny-input-container { width: auto !important; }
.mt-rename-tools .input-group .form-control { display: none; }
.mt-rename-tools .input-group .btn { border-radius: 6px !important; }
.mt-rename-tools .progress { display: none; }
.mt-rename-wrap { max-height: 560px; }
table.mt-map-table td.mt-type { color: var(--mt-muted); font-size: 11px; text-transform: uppercase; letter-spacing: .4px; }
table.mt-map-table tr.mt-bad-name input.mt-new { background: #fef3f2; box-shadow: inset 3px 0 0 #b42318; }
.mt-name-status { margin-top: 8px; font-size: 12px; }
.mt-name-status .mt-bad, .mt-name-status .mt-good { display: inline-block; margin: 2px 4px 2px 0; }
.mt-coming {
  min-height: 260px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 8px;
  border: 1px dashed #cbd5e1; border-radius: 8px; color: var(--mt-muted); background: #fafbfc; text-align: center; padding: 24px;
}
.mt-coming b { color: var(--mt-text); }

/* ---- Model tab: factor list with include box and V / C switches ---- */
details.mt-fold { margin-top: 10px; border-top: 1px solid var(--mt-border); padding-top: 8px; }
details.mt-fold > summary { cursor: pointer; font-weight: 600; font-size: 12px; color: #475569; list-style: none; padding: 4px 0; }
details.mt-fold > summary::-webkit-details-marker { display: none; }
details.mt-fold > summary::after { content: '\\25B8'; float: right; color: #94a3b8; transition: transform .12s ease; }
details.mt-fold[open] > summary::after { transform: rotate(90deg); }
.mt-glm-list { max-height: 360px; min-height: 140px; overflow-y: auto; border: 1px solid var(--mt-border); border-radius: 6px; }
/* Model tab panel: the factor card takes the free height, so the Interactions card sits at the bottom of the screen */
@media (min-width: 768px) {
  .mt-model-row .mt-control-panel { display: flex; flex-direction: column; }
  .mt-model-row .mt-control-panel > .mt-card { flex: 0 0 auto; }
  .mt-model-row .mt-control-panel > .mt-glm-factors { flex: 1 1 auto; display: flex; flex-direction: column; min-height: 320px; }
  .mt-glm-factors > .mt-card-body { flex: 1 1 auto; display: flex; flex-direction: column; min-height: 0; }
  .mt-glm-factors .mt-glm-list { flex: 1 1 auto; max-height: none; min-height: 160px; }
}
.mt-glm-row { display: flex; align-items: center; gap: 6px; padding: 5px 8px; border-bottom: 1px solid #f0f2f6; cursor: pointer; font-size: 12px; color: #64748b; }
.mt-glm-row:last-child { border-bottom: none; }
.mt-glm-row:hover { background: #f5f7fb; }
.mt-glm-row.mt-in { color: var(--mt-text); }
.mt-glm-row.mt-in .mt-map-name { font-weight: 600; }
.mt-glm-row.mt-viewing { background: #e0eaff; box-shadow: inset 3px 0 0 var(--mt-accent); color: #1e3a8a; }
.mt-glm-row:hover .mt-map-edit, .mt-glm-row.mt-viewing .mt-map-edit { visibility: visible; }
.mt-glm-cb { flex: 0 0 15px; width: 15px; height: 15px; border: 1.5px solid #cbd5e1; border-radius: 3px; background: #f8fafc; position: relative; cursor: default; }
.mt-vc.mt-s.on { background: #2563eb; border-color: #2563eb; color: #fff; }
.mt-glm-cb.on { background: var(--mt-accent); border-color: var(--mt-accent); }
.mt-glm-cb.on::after { content: ''; position: absolute; left: 4px; top: 1px; width: 4px; height: 8px; border: solid #fff; border-width: 0 2px 2px 0; transform: rotate(45deg); }
.mt-vc { flex: 0 0 auto; min-width: 22px; padding: 0 4px; height: 18px; line-height: 16px; text-align: center; border-radius: 4px;
         border: 1px solid #d5dbe5; color: #94a3b8; font-size: 10.5px; font-weight: 700; background: #fff; user-select: none; }
.mt-vc:hover { border-color: var(--mt-accent); color: var(--mt-accent); }
.mt-vc.mt-v.on { background: #4f46e5; border-color: #4f46e5; color: #fff; }
.mt-vc.mt-c.on { background: #0d9488; border-color: #0d9488; color: #fff; }
.mt-vc.mt-warn-vc { box-shadow: 0 0 0 2px #fecdca; }
.mt-glm-legend { display: flex; flex-wrap: wrap; gap: 4px 10px; margin-top: 8px; color: var(--mt-muted); font-size: 11.5px; align-items: center; }
.mt-glm-legend .mt-vc { cursor: default; }
.mt-x-badge { flex: 0 0 auto; display: inline-block; min-width: 16px; height: 16px; line-height: 15px; text-align: center; border-radius: 8px;
              background: #fff7ed; color: #c2410c; border: 1px solid #fed7aa; font-size: 11px; font-weight: 700; }
.mt-inter-row { display: flex; align-items: center; gap: 6px; padding: 6px 4px; border-bottom: 1px solid #f0f2f6; font-size: 12px; cursor: pointer; }
.mt-inter-row:last-child { border-bottom: none; }
.mt-inter-row:hover { background: #f5f7fb; }
.mt-inter-name { flex: 1 1 auto; min-width: 0; overflow-wrap: anywhere; }
.mt-inter-name small { display: block; color: var(--mt-muted); font-family: Consolas, monospace; font-size: 10.5px; }
.mt-inter-del { border: none; background: transparent; color: #94a3b8; padding: 2px 6px; border-radius: 4px; }
.mt-inter-del:hover { background: #fef3f2; color: #b42318; }
.mt-inter-list { max-height: 220px; overflow-y: auto; margin-bottom: 8px; }
pre.mt-formula { background: #0f172a; color: #e2e8f0; border: none; border-radius: 6px; padding: 12px 14px; font-size: 12px; white-space: pre-wrap; max-height: 420px; overflow: auto; }
.mt-chip-row { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
.mt-mode-chip { padding: 2px 9px; border-radius: 10px; font-size: 11.5px; font-weight: 600; background: #f1f5f9; color: #475569; }
.mt-mode-chip.var { background: #eef2ff; color: #4338ca; }
.mt-mode-chip.cust { background: #f0fdfa; color: #0f766e; }
.mt-mode-chip.plain { background: #eff6ff; color: #1d4ed8; }
.mt-mode-chip.stale { background: #fffaeb; color: #b54708; }
.modal-dialog:has(.mt-glm-modal) { width: min(1180px, 96vw); }
.mt-glm-modal .nav-tabs { margin-bottom: 10px; }
.mt-glm-modal .mt-map-table-wrap { max-height: 440px; }
.mt-ed-head { display: flex; flex-wrap: wrap; gap: 18px; align-items: flex-end; margin-bottom: 8px; }
.mt-ed-head .form-group { margin-bottom: 0; }
.mt-ed-head .checkbox { margin: 0 0 6px 0; font-weight: 600; }
.mt-ed-head .shiny-input-container { width: auto; }
.mt-ed-preview { padding: 8px 12px; background: #f8fafc; border: 1px solid var(--mt-border); border-radius: 8px; align-items: center; }
.mt-ed-preview .control-label { font-size: 11px; text-transform: uppercase; letter-spacing: .5px; color: var(--mt-muted); margin-bottom: 2px; }
table.mt-map-table tr.mt-missing td.mt-new-cell input { background: #fef3f2; box-shadow: inset 3px 0 0 #b42318; }
.mt-rel-table { max-height: 420px; overflow: auto; }
.mt-rel-table table { font-size: 12px; }
.mt-rel-table td.mt-base-row { font-weight: 700; color: var(--mt-accent); }
.mt-rel-table td { white-space: nowrap; }
.mt-rel-table tbody tr { cursor: pointer; }
.mt-rel-table tbody tr:hover td { background: #f5f7fb; }
.mt-chart-bar { align-items: center; }
.mt-chart-bar .btn-group-toggle .btn, .mt-chart-bar .btn-group .btn { font-size: 12px; }
.mt-chart-bar .radioGroupButtons .btn.active { background: var(--mt-accent); border-color: var(--mt-accent); color: #fff; }
.mt-rel-tools { display: flex; flex-wrap: wrap; gap: 10px; align-items: flex-end; margin-bottom: 10px; }
.mt-rel-tools .form-group { margin-bottom: 0; }
.mt-rel-tools .shiny-input-container { width: auto; min-width: 200px; }
"

# Model tab: factor list switches and the variate / custom editor tables
glm_js <- "
$(function() {
  // ---- factor list ----
  function filterGlm() {
    var q = ($('#glm_search').val() || '').toLowerCase();
    $('#glm_factor_list .mt-glm-row').each(function() { $(this).toggle(String($(this).attr('data-f')).toLowerCase().indexOf(q) > -1); });
  }
  window.mtGlmViewing = null;
  function markGlmViewing() {
    $('#glm_factor_list .mt-glm-row').each(function() { $(this).toggleClass('mt-viewing', $(this).attr('data-f') === window.mtGlmViewing); });
  }
  Shiny.addCustomMessageHandler('glm_viewing', function(f) { window.mtGlmViewing = f; markGlmViewing(); });
  $(document).on('input', '#glm_search', filterGlm);
  $(document).on('shiny:value', function(e) { if (e.name === 'glm_factor_list_ui') setTimeout(function() { filterGlm(); markGlmViewing(); }, 0); });
  // the tick box is an indicator only (set by S / V / C), so it is not clickable
  $(document).on('click', '#glm_factor_list .mt-vc', function(e) {
    e.stopPropagation();
    var k = $(this).attr('data-k');
    $(this).toggleClass('on');
    Shiny.setInputValue('glm_toggle', {f: $(this).closest('.mt-glm-row').attr('data-f'), k: k, nonce: Math.random()}, {priority: 'event'});
  });
  $(document).on('click', '#glm_factor_list .mt-glm-row', function(e) {
    if ($(e.target).closest('.mt-map-edit').length) return;
    Shiny.setInputValue('glm_view', $(this).attr('data-f'), {priority: 'event'});
  });
  $(document).on('contextmenu', '#glm_factor_list .mt-glm-row', function(e) {
    e.preventDefault();
    Shiny.setInputValue('glm_edit', $(this).attr('data-f'), {priority: 'event'});
  });
  $(document).on('click', '#glm_factor_list .mt-map-edit', function(e) {
    e.stopPropagation();
    Shiny.setInputValue('glm_edit', $(this).closest('.mt-glm-row').attr('data-f'), {priority: 'event'});
  });
  // relativity table: click a row to make that level the base
  $(document).on('click', '.mt-rel-table tbody tr[data-l]', function() {
    Shiny.setInputValue('glm_base_row', {f: $(this).attr('data-f'), level: $(this).attr('data-l'), nonce: Math.random()}, {priority: 'event'});
  });
  // interactions list: click a row to view it, the cross removes it
  $(document).on('click', '.mt-inter-del', function(e) {
    e.stopPropagation();
    Shiny.setInputValue('glm_inter_remove', parseInt($(this).attr('data-i'), 10), {priority: 'event'});
  });
  $(document).on('click', '.mt-inter-row', function() {
    Shiny.setInputValue('glm_inter_view', parseInt($(this).attr('data-i'), 10), {priority: 'event'});
  });

  // ---- editor tables (variate values / custom groups): levels locked, last column editable / pasteable ----
  var timers = {};
  function sendTable(t) {
    var vals = t.find('input.mt-new').map(function() { return this.value; }).get();
    Shiny.setInputValue('ed_values', {name: t.attr('data-name'), token: t.attr('data-token'), values: vals, nonce: Math.random()});
  }
  function markCell(inp) {
    var $i = $(inp), changed = $i.val() !== $i.attr('data-orig');
    $i.toggleClass('mt-edited', changed);
    $i.closest('tr').toggleClass('mt-changed', changed).toggleClass('mt-missing', $i.val().trim() === '');
  }
  $(document).on('input', 'table.mt-edit-table input.mt-new', function() {
    markCell(this);
    var t = $(this).closest('table'), n = t.attr('data-name');
    clearTimeout(timers[n]); timers[n] = setTimeout(function() { sendTable(t); }, 300);
  });
  $(document).on('mousedown focus', '#ed_apply, #ed_var_xlsx, #ed_cust_xlsx', function() {
    $('table.mt-edit-table').each(function() { clearTimeout(timers[$(this).attr('data-name')]); sendTable($(this)); });
  });
  $(document).on('keydown', 'table.mt-edit-table input.mt-new', function(e) {
    var inputs = $(this).closest('table').find('input.mt-new'), i = inputs.index(this);
    if (e.key === 'Enter' || e.key === 'ArrowDown') { e.preventDefault(); inputs.eq(Math.min(i + 1, inputs.length - 1)).focus().select(); }
    else if (e.key === 'ArrowUp') { e.preventDefault(); if (i > 0) inputs.eq(i - 1).focus().select(); }
  });
  $(document).on('paste', 'table.mt-edit-table input.mt-new', function(e) {
    var cd = (e.originalEvent && e.originalEvent.clipboardData) || window.clipboardData;
    if (!cd) return;
    var txt = cd.getData('text');
    if (txt.indexOf('\\n') < 0 && txt.indexOf('\\t') < 0) return;
    e.preventDefault();
    var lines = txt.replace(/\\r/g, '').split('\\n');
    while (lines.length && lines[lines.length - 1] === '') lines.pop();
    var cells = lines.map(function(l) { var p = l.split('\\t'); return p[p.length - 1].trim(); });
    if (cells.length && /value|group|variate|custom/i.test(cells[0])) cells.shift();
    var t = $(this).closest('table'), inputs = t.find('input.mt-new'), start = inputs.index(this);
    var n = Math.min(cells.length, inputs.length - start);
    for (var i = 0; i < n; i++) { inputs.eq(start + i).val(cells[i]); markCell(inputs[start + i]); }
    Shiny.setInputValue('map_pasted', {n: n, extra: cells.length - n}, {priority: 'event'});
    sendTable(t);
  });
  $(document).on('click', '.mt-copy-btn', function() {
    var t = $('#' + $(this).attr('data-target')), btn = $(this);
    if (!t.length) return;
    var lines = [t.find('thead th').map(function() { return $(this).attr('data-col'); }).get().join('\\t')];
    t.find('tbody tr').each(function() {
      lines.push($(this).find('td').map(function() {
        var inp = $(this).find('input'); if (inp.length) return inp.val();
        var v = $(this).attr('data-v'); return v !== undefined ? v : $(this).text();
      }).get().join('\\t'));
    });
    var txt = lines.join('\\r\\n') + '\\r\\n';
    var done = function() { var l = btn.find('span'); l.text('Copied ' + (lines.length - 1) + ' rows'); btn.addClass('mt-copied');
                            setTimeout(function() { l.text('Copy table'); btn.removeClass('mt-copied'); }, 2000); };
    window.mtCopyText(txt, done, btn.closest('.mt-map-tools, .mt-rename-tools'));
  });
});

// Copy text to the clipboard, working in normal browsers, RStudio's viewer and inside pop-ups:
//   1. execCommand('copy') on a hidden text box (runs inside the click, so the browser allows it)
//   2. the asynchronous clipboard API
//   3. if both are blocked: show the text selected in a box, ready for Ctrl+C
window.mtCopyText = function(txt, done, anchor) {
  var host = $('.modal:visible .modal-body').first();
  if (!host.length) host = $('body');
  function legacy() {
    var ta = $('<textarea style=\"position:fixed;top:0;left:0;width:1px;height:1px;opacity:0;\"></textarea>').val(txt).appendTo(host);
    ta[0].focus(); ta[0].select();
    var ok = false; try { ok = document.execCommand('copy'); } catch (e) {}
    ta.remove();
    return ok;
  }
  function manual() {
    var where = (anchor && anchor.length) ? anchor : host.children().first();
    var box = where.siblings('.mt-copy-fallback');
    if (!box.length) {
      box = $('<div class=\"mt-copy-fallback\"><div>This browser blocked automatic copying. The table is selected below: press <b>Ctrl+C</b> to copy it.</div>' +
              '<textarea readonly spellcheck=\"false\"></textarea></div>').insertAfter(where);
      box.find('textarea').on('copy', function() { setTimeout(function() { box.remove(); done(); }, 0); });
    }
    box.find('textarea').val(txt).focus().select();
  }
  if (legacy()) { done(); return; }
  if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(txt).then(done, manual);
  else manual();
};
"

# Factor names table (Model structure tab): raw names locked, model names editable / pasteable like the mapping table
rename_js <- "
$(function() {
  var timer = null;
  function sendNames() {
    var t = $('#rename_table');
    if (!t.length) return;
    var raw = [], vals = [];
    t.find('input.mt-new').each(function() { raw.push($(this).attr('data-raw')); vals.push(this.value); });
    Shiny.setInputValue('rename_values', {raw: raw, values: vals, nonce: Math.random()});
  }
  function mark(inp) {
    var $i = $(inp), changed = $i.val() !== '' && $i.val() !== $i.attr('data-raw');
    $i.toggleClass('mt-edited', changed);
    $i.closest('tr').toggleClass('mt-changed', changed);
  }
  // rows whose model name is invalid / duplicated (sent by the server)
  window.mtRenameBad = [];
  function markBad() {
    $('#rename_table input.mt-new').each(function() {
      $(this).closest('tr').toggleClass('mt-bad-name', window.mtRenameBad.indexOf($(this).attr('data-raw')) > -1);
    });
  }
  Shiny.addCustomMessageHandler('rename_bad', function(raws) { window.mtRenameBad = [].concat(raws || []); markBad(); });
  $(document).on('shiny:value', function(e) { if (e.name === 'rename_table_ui') setTimeout(markBad, 0); });
  $(document).on('input', '#rename_table input.mt-new', function() { mark(this); clearTimeout(timer); timer = setTimeout(sendNames, 300); });
  $(document).on('mousedown focus', '#action_prepare_data, #action_save_prep', function() { clearTimeout(timer); sendNames(); });
  $(document).on('keydown', '#rename_table input.mt-new', function(e) {
    var inputs = $('#rename_table input.mt-new'), i = inputs.index(this);
    if (e.key === 'Enter' || e.key === 'ArrowDown') { e.preventDefault(); inputs.eq(Math.min(i + 1, inputs.length - 1)).focus().select(); }
    else if (e.key === 'ArrowUp') { e.preventDefault(); if (i > 0) inputs.eq(i - 1).focus().select(); }
  });
  // pasting a column from Excel fills downwards from the selected cell (the last pasted column is used)
  $(document).on('paste', '#rename_table input.mt-new', function(e) {
    var cd = (e.originalEvent && e.originalEvent.clipboardData) || window.clipboardData;
    if (!cd) return;
    var txt = cd.getData('text');
    if (txt.indexOf('\\n') < 0 && txt.indexOf('\\t') < 0) return;
    e.preventDefault();
    var lines = txt.replace(/\\r/g, '').split('\\n');
    while (lines.length && lines[lines.length - 1] === '') lines.pop();
    var cells = lines.map(function(l) { var p = l.split('\\t'); return p[p.length - 1].trim(); });
    if (cells.length && /model.?name|re.?name/i.test(cells[0])) cells.shift();
    var inputs = $('#rename_table input.mt-new'), start = inputs.index(this);
    var n = Math.min(cells.length, inputs.length - start);
    for (var i = 0; i < n; i++) { inputs.eq(start + i).val(cells[i]); mark(inputs[start + i]); }
    sendNames();
  });
  // copy the table for Excel: raw name, type, levels, model name
  $(document).on('click', '#rename_copy', function() {
    var t = $('#rename_table'), btn = $(this);
    if (!t.length) return;
    var lines = ['raw_name\\ttype\\tlevels\\tmodel_name'];
    t.find('tbody tr').each(function() {
      var td = $(this).find('td');
      lines.push([td.eq(0).text(), td.eq(1).text(), td.eq(2).text(), $(this).find('input').val()].join('\\t'));
    });
    var txt = lines.join('\\r\\n') + '\\r\\n';
    var done = function() {
      var label = btn.find('span'); label.text('Copied ' + (lines.length - 1) + ' rows'); btn.addClass('mt-copied');
      setTimeout(function() { label.text('Copy table'); btn.removeClass('mt-copied'); }, 2000);
    };
    window.mtCopyText(txt, done, btn.closest('.mt-rename-tools'));
  });
});
"

# Small UI helpers -----------------------------------------------------------------------------------------------------------
# pop-up message that keeps the line breaks of its text
mt_alert <- function(title, text = "", ...) {
  shinyalert::shinyalert(title = title, text = gsub("\n", "<br>", htmltools::htmlEscape(text)), html = TRUE, ...)
}
mt_card <- function(title = NULL, ..., icon_name = NULL, subtitle = NULL, class = NULL) {
  div(class = paste(c("mt-card", class), collapse = " "),
      if (!is.null(title))
        div(class = "mt-card-header",
            if (!is.null(icon_name)) icon(icon_name),
            span(class = "mt-card-title", title),
            if (!is.null(subtitle)) span(class = "mt-card-subtitle", subtitle)),
      div(class = "mt-card-body", ...))
}
mt_page_header <- function(title, description) div(class = "mt-page-header", h2(title), p(description))
mt_step_tab    <- function(step, label) tagList(span(class = "mt-step", step), label)
mt_section     <- function(label) div(class = "mt-section-label", label)
mt_status      <- function(id) div(class = "mt-status", htmlOutput(id))


# UI -----------------------------------------------------------------------------------------------------------------------
ui <- navbarPage(
  title = span(span(class = "mt-brand-icon", icon("square-root-variable")),
               "GLM Modelling Studio",
               span(class = "mt-brand-sub", "GLM pricing workbench")),
  windowTitle = "GLM Modelling Studio",
  position = "fixed-top",
  inverse = TRUE,
  collapsible = TRUE,
  header = tagList(
    tags$head(tags$style(HTML(app_css)),
              tags$style(HTML(glm_css)),
              tags$script(HTML(map_js)),
              tags$script(HTML(resize_js)),
              tags$script(HTML(import_js)),
              tags$script(HTML(rename_js)),
              tags$script(HTML(glm_js))),
    useShinyjs()
  ),

  # ~ MAIN TAB 1 - data preparation ----------------------------------------------------------------------------------------
  tabPanel("Data", icon = icon("database"),
           mt_page_header("Data preparation",
                          "Import the dataset, define the model structure and factor names, then band the factors before building the modelling dataset."),
           tabsetPanel(type = "tabs",
                       # ~ ~ SUB-TAB 1a - data import ------------------------------------------------------------------------
                       tabPanel(mt_step_tab(1, "Import"),
                                fluidRow(
                                  column(4,
                                         mt_card("Source data", icon_name = "file-import",
                                                 div(class = "mt-import-step", span(class = "mt-step", "1"), "Choose the data type"),
                                                 radioButtons("import_type", NULL, width = "100%",
                                                              choiceNames = list(
                                                                tagList(icon("r-project"), span(class = "mt-type-name", "R data"), span(class = "mt-type-ext", ".rds")),
                                                                tagList(icon("file-csv"), span(class = "mt-type-name", "CSV"), span(class = "mt-type-ext", ".csv / .txt")),
                                                                tagList(icon("table-cells"), span(class = "mt-type-name", "Parquet"), span(class = "mt-type-ext", ".parquet"))),
                                                              choiceValues = c("rds", "csv", "parquet")),
                                                 conditionalPanel("input.import_type == 'csv'", class = "mt-csv-options",
                                                                  fluidRow(
                                                                    column(7, selectInput("import_csv_sep", "Separator",
                                                                                          choices = c("Detect automatically" = "auto", "Comma ," = ",",
                                                                                                      "Semicolon ;" = ";", "Tab" = "\t", "Pipe |" = "|"))),
                                                                    column(5, div(class = "mt-csv-header",
                                                                                  checkboxInput("import_csv_header", "First row is header", value = TRUE))))),
                                                 div(class = "mt-import-step", span(class = "mt-step", "2"), "Choose the file"),
                                                 fileInput("action_read_file", NULL, width = '100%', accept = ".rds",
                                                           buttonLabel = "Browse…", placeholder = "No .rds file selected"),
                                                 mt_status("output_import_warning"),
                                                 div(class = "mt-kpi-row",
                                                     div(class = "mt-kpi", textOutput("file_info")),
                                                     div(class = "mt-kpi", textOutput("number_rows")),
                                                     div(class = "mt-kpi", textOutput("number_cols")))
                                         )
                                  ),
                                  column(8,
                                         mt_card("Data preview", icon_name = "table",
                                                 div(class = "mt-preview-table", DT::DTOutput('table_raw_data_head')))
                                  )
                                ),
                                mt_card("Column summary", icon_name = "list-ul",
                                        div(class = "mt-table-scroll", tableOutput("data_summary_desc")))
                       ),

                       # ~ ~ SUB-TAB 1b - model structure + factor names ----------------------------------------------------
                       tabPanel(mt_step_tab(2, "Model structure"),
                                fluidRow(
                                  column(3,
                                         mt_card("Model definition", icon_name = "sliders",
                                                 selectInput("select_model_type", "Model type",
                                                             choices = list("Frequency · Poisson, log link"     = 1,
                                                                            "Severity · Gamma, log link"        = 2,
                                                                            "Burning cost · Tweedie, log link"  = 3,
                                                                            "Binomial · logit link"             = 4)),
                                                 selectInput("select_response", "Response", choices = list()),
                                                 selectInput("select_exposure", "Exposure / weight", choices = list()),
                                                 selectInput("select_offset", "Offset (prior expected, optional)", choices = list()),
                                                 mt_section("Partition"),
                                                 selectInput("select_partition_factor", "Partition factor (1 = modelling, 2 = holdout, 3 = validation)",
                                                             choices = list()),
                                                 selectInput("select_policy_keys", "Policy keys (kept for prediction export)",
                                                             choices = list(), multiple = TRUE, selectize = FALSE, size = 4)
                                         ),
                                         mt_card("Saved structures", icon_name = "folder-open",
                                                 subtitle = "Definition + factor names",
                                                 fileInput("action_import_prep", "Load model structure (.rds)", width = '100%', accept = ".rds"),
                                                 downloadButton("action_save_prep", "Save current model structure", class = "btn-default btn-block")
                                         )
                                  ),
                                  column(3,
                                         mt_card("Rating factors", icon_name = "layer-group",
                                                 subtitle = textOutput("rating_count", inline = TRUE),
                                                 selectInput("select_rating_factors", NULL, choices = list(), multiple = TRUE,
                                                             selectize = FALSE, size = 26, width = '100%'),
                                                 p(class = "mt-empty-hint", "Ctrl / Shift + click to multi-select")
                                         )
                                  ),
                                  column(6,
                                         mt_card("Factor names", icon_name = "signature",
                                                 subtitle = "Model names are used everywhere from here on",
                                                 div(class = "mt-rename-tools",
                                                     tags$button(id = "rename_copy", type = "button", class = "btn btn-default",
                                                                 title = "Copy the table, ready to paste into Excel",
                                                                 icon("copy"), span("Copy table")),
                                                     actionButton("rename_reset", "Use raw names", icon = icon("rotate-left"))),
                                                 uiOutput("rename_table_ui"),
                                                 uiOutput("rename_status_ui"),
                                                 div(class = "mt-map-note", icon("lock"),
                                                     " Raw names are locked. Type a model name, or paste a column from Excel (click the first cell, Ctrl+V).")
                                         ),
                                         mt_card("Apply structure", icon_name = "circle-check",
                                                 actionButton("action_prepare_data", "Apply model structure",
                                                              icon = icon("play"), class = 'btn-primary btn-block'),
                                                 mt_status("output_data_prep_warning")
                                         )
                                  )
                                )
                       ),

                       # ~ ~ SUB-TAB 1c - factor mapping (initial banding) --------------------------------------------------
                       tabPanel(mt_step_tab(3, "Factor mapping"),
                                fluidRow(class = "mt-map-layout",
                                  column(3, class = "mt-map-side",
                                         div(class = "mt-map-side-resizer", title = "Drag to resize the panel · double-click to reset"),
                                         mt_card("Factors", icon_name = "list-ul",
                                                 subtitle = textOutput("map_count", inline = TRUE),
                                                 class = "mt-factor-card",
                                                 div(class = "mt-factor-toolbar",
                                                     tags$input(id = "map_search", type = "search", class = "form-control",
                                                                placeholder = "Search factors…", autocomplete = "off"),
                                                     radioButtons("map_sort", NULL, inline = TRUE,
                                                                  choices = c("A–Z" = "alpha", "Mapped first" = "mapped"))),
                                                 div(id = "map_factor_list", class = "mt-map-list",
                                                     uiOutput("map_factor_list_ui")),
                                                 div(class = "mt-list-resizer", `data-list` = "map",
                                                     title = "Drag to resize the list · double-click to reset"),
                                                 div(class = "mt-map-hint",
                                                     icon("computer-mouse"), " Click to view · ",
                                                     tags$b("right-click"), " or ", icon("pen"), " to map")
                                         )
                                  ),
                                  column(9, class = "mt-map-main",
                                         div(class = "mt-card mt-map-header", uiOutput("map_header_ui")),
                                         uiOutput("map_charts_ui"),
                                         fluidRow(
                                           column(6,
                                                  mt_card("Mapping set", icon_name = "layer-group",
                                                          subtitle = textOutput("map_set_count", inline = TRUE),
                                                          p(class = "mt-empty-hint", style = "margin: 0 0 10px 0;",
                                                            "Save all applied mappings to reuse them, or load a saved set (it is applied straight away). ",
                                                            "An Excel set can also be any workbook with one tab per factor, named by raw or model name."),
                                                          div(class = "mt-btn-row",
                                                              downloadButton("action_save_formatted_data", "Save (.rds)", class = "btn-default"),
                                                              downloadButton("action_save_formatted_xlsx", "Save (Excel)", class = "btn-default"),
                                                              actionButton("map_clear_all", "Clear all mappings",
                                                                           icon = icon("trash-can"), class = "btn-danger-outline")),
                                                          div(style = "margin-top: 10px;",
                                                              fileInput("action_import_formatted_data", NULL,
                                                                        buttonLabel = "Load mappings…",
                                                                        placeholder = "Saved mapping file (.rds or .xlsx)",
                                                                        width = '100%', accept = c(".rds", ".xlsx", ".xls")))
                                                  )),
                                           column(6,
                                                  mt_card("Build modelling dataset", icon_name = "cubes",
                                                          p(class = "mt-empty-hint", style = "margin: 0 0 10px 0;",
                                                            "Applies all factor mappings and turns every rating factor into GLM levels (missing values become an 'NA' level). No one-hot encoding is needed."),
                                                          actionButton("Prepare_modelling_data", "Create modelling dataset",
                                                                       icon = icon("play"), class = 'btn-primary btn-block'),
                                                          mt_status("output_modelling_data_warning")
                                                  ))
                                         )
                                  )
                                )
                       )
           )
  ),

  # ~ MAIN TAB 2 - modelling (Stage 2) ---------------------------------------------------------------------------------------
  tabPanel("Model", icon = icon("sliders"),
           fluidRow(class = "mt-model-row",
             column(3, class = "mt-model-side",
                    div(class = "mt-side-resizer", title = "Drag to resize the panel · double-click to reset"),
                    div(class = "mt-control-panel",
                        mt_card("Model run", icon_name = "play",
                                actionButton("glm_fit", "Fit GLM", icon = icon("play"), class = 'btn-primary btn-block'),
                                mt_status("glm_fit_status"),
                                conditionalPanel("input.select_model_type == '3'",
                                                 numericInput("glm_tweedie_p", "Tweedie power", value = 1.5, min = 1.05, max = 1.95, step = 0.05)),
                                div(class = "mt-empty-hint", style = "margin: 6px 0 0 0;", textOutput("glm_ref_info", inline = TRUE)),
                                # reference model and files fold away so the factor list and interactions stay in view
                                tags$details(class = "mt-fold",
                                  tags$summary(icon("folder-open"), " Reference model & files"),
                                  mt_section("Reference model"),
                                  div(class = "mt-btn-row",
                                      actionButton("glm_ref_set", "Set current", icon = icon("thumbtack")),
                                      actionButton("glm_ref_clear", "Clear", icon = icon("xmark"))),
                                  div(style = "margin-top: 8px;",
                                      fileInput("glm_ref_load", NULL, buttonLabel = "Load…", width = "100%",
                                                placeholder = "Fitted model as reference (.rds)", accept = ".rds")),
                                  downloadButton("glm_model_save", "Save fitted model (.rds)", class = "btn-default btn-block"),
                                  mt_section("Model definition"),
                                  downloadButton("glm_def_save", "Save definition (.rds)", class = "btn-default btn-block"),
                                  div(style = "margin-top: 8px;",
                                      fileInput("glm_def_load", NULL, buttonLabel = "Load…", width = "100%",
                                                placeholder = "Saved definition (.rds)", accept = ".rds")))
                        ),
                        mt_card("Simple factors", icon_name = "list-check",
                                subtitle = textOutput("glm_factor_count", inline = TRUE),
                                class = "mt-factor-card mt-glm-factors",
                                div(class = "mt-factor-toolbar",
                                    tags$input(id = "glm_search", type = "search", class = "form-control input-sm",
                                               placeholder = "Search factors…", autocomplete = "off"),
                                    radioButtons("glm_sort", NULL, inline = TRUE,
                                                 choices = c("A–Z" = "alpha", "In model first" = "model"))),
                                div(id = "glm_factor_list", class = "mt-glm-list", uiOutput("glm_factor_list_ui")),
                                div(class = "mt-glm-legend",
                                    span(class = "mt-vc mt-s on", "S"), "own levels",
                                    span(class = "mt-vc mt-v on", "V"), "variate",
                                    span(class = "mt-vc mt-c on", "C"), "custom",
                                    span(class = "mt-x-badge", "×"), "in an interaction"),
                                div(class = "mt-map-hint", icon("circle-info"), " The tick shows the factor is in the model: switch on ",
                                    tags$b("S"), ", ", tags$b("V"), " or ", tags$b("C"), " (V and C can be combined). Click to view · ",
                                    tags$b("right-click"), " or ", icon("pen"), " to edit")
                        ),
                        mt_card("Interactions", icon_name = "shuffle",
                                subtitle = textOutput("glm_inter_count", inline = TRUE),
                                uiOutput("glm_inter_list_ui"),
                                actionButton("glm_inter_add", "Add interaction", icon = icon("plus"), class = "btn-default btn-block")
                        )
                    )
             ),
             column(9, class = "mt-model-main",
                    mt_page_header("Model development",
                                   "Choose how each factor enters the GLM, fit it and review actual vs expected and relativities."),
                    tabsetPanel(type = "tabs", id = "glm_tabs",
                                tabPanel(tagList(icon("chart-line"), " Factor view"), value = "view",
                                         div(class = "mt-card mt-map-header", uiOutput("glm_view_header")),
                                         mt_card("Factor chart", icon_name = "chart-column",
                                                 subtitle = textOutput("glm_chart_subtitle", inline = TRUE),
                                                 div(class = "mt-ed-head mt-chart-bar",
                                                     shinyWidgets::radioGroupButtons("glm_view_mode", NULL, size = "sm",
                                                                                     choices = c("Actual vs expected" = "ave", "Relativity" = "rel"),
                                                                                     selected = "ave"),
                                                     conditionalPanel("input.glm_view_mode == 'ave'",
                                                                      radioButtons("glm_view_part", NULL, inline = TRUE,
                                                                                   choices = c("Modelling" = 1, "Holdout" = 2, "Validation" = 3))),
                                                     checkboxInput("glm_view_ci", "95% confidence band", value = TRUE),
                                                     checkboxInput("glm_view_ref", "Reference model", value = TRUE)),
                                                 plotlyOutput("glm_ave_plot", height = 680)),
                                         mt_card("Relativities", icon_name = "table",
                                                 uiOutput("glm_rel_tools_ui"),
                                                 uiOutput("glm_rel_table_ui")),
                                         uiOutput("glm_inter_view_ui")
                                ),
                                tabPanel(tagList(icon("square-check"), " Summary"), value = "summary",
                                         uiOutput("glm_summary_ui")),
                                tabPanel(tagList(icon("chart-area"), " Validation"), value = "valid",
                                         fluidRow(
                                           column(6, mt_card("Gains curve & Gini", icon_name = "chart-area",
                                                             subtitle = "Normalised Gini · dotted: reference model",
                                                             plotlyOutput("glm_gains_plot", height = 480))),
                                           column(6, mt_card("Lift chart", icon_name = "chart-column",
                                                             subtitle = "Bands of equal exposure by predicted rate",
                                                             div(class = "mt-ed-head",
                                                                 radioButtons("glm_lift_part", NULL, inline = TRUE,
                                                                              choices = c("Modelling" = 1, "Holdout" = 2, "Validation" = 3), selected = 2),
                                                                 numericInput("glm_lift_bands", "Bands", value = 10, min = 2, max = 50, width = "90px")),
                                                             plotlyOutput("glm_lift_plot", height = 420)))
                                         ),
                                         mt_card("Feature importance", icon_name = "ranking-star",
                                                 subtitle = "Which terms matter, measured on the modelling data · purple: interactions",
                                                 uiOutput("glm_imp_ui")),
                                         mt_card("Model comparison", icon_name = "code-compare",
                                                 subtitle = "Current fit against the reference model",
                                                 uiOutput("glm_compare_ui")),
                                         mt_card("Relativity check", icon_name = "scale-balanced",
                                                 subtitle = "Do the relativity tables reproduce the model's predictions?",
                                                 uiOutput("glm_relcheck_ui"))
                                ),
                                tabPanel(tagList(icon("table-list"), " Coefficients"), value = "coef",
                                         mt_card("Coefficients", icon_name = "table-list",
                                                 subtitle = "Estimates on the link (log) scale; exp(estimate) is the multiplicative effect",
                                                 DT::DTOutput("glm_coef_table"))
                                ),
                                tabPanel(tagList(icon("code"), " Formula"), value = "formula",
                                         mt_card("Current formula", icon_name = "code", subtitle = "Built from the factor list",
                                                 tags$pre(class = "mt-formula", textOutput("glm_formula_txt"))),
                                         mt_card("Import a formula", icon_name = "file-import",
                                                 p(class = "mt-empty-hint", style = "margin: 0 0 8px 0;",
                                                   "Paste the right-hand side of a GLM formula. ",
                                                   tags$code("f_var"), " and ", tags$code("I(f_var^2)"), " switch on the variate (with its order), ",
                                                   tags$code("f_custom"), " the custom grouping and a bare ", tags$code("f"), " the factor's own levels. ",
                                                   "Two-way interactions are written ", tags$code("a_var:b_custom"), " (each side plain, _var or _custom). ",
                                                   "Factors not in the formula are taken out of the model."),
                                                 textAreaInput("glm_formula_in", NULL, rows = 9, width = "100%",
                                                               placeholder = "Drv_PH_Age_var + I(Drv_PH_Age_var^2) + Drv_PH_Age_custom + Pol_Cover_Type_custom + ..."),
                                                 actionButton("glm_formula_apply", "Apply formula", icon = icon("check"), class = "btn-primary"))
                                )
                    )
             )
           )
  ),

  # ~ MAIN TAB 3 - investigation: two-way actual vs expected ---------------------------------------------------------------
  tabPanel("Investigation", icon = icon("magnifying-glass-chart"),
           mt_page_header("Investigation",
                          "Look for interactions the model misses: actual (solid) vs expected (dashed) of one factor, split by another."),
           mt_card("Two-way actual vs expected", icon_name = "table-cells",
                   fluidRow(
                     column(3, selectInput("inv_fa", "Factor on the x-axis", choices = list(), width = "100%")),
                     column(3, selectInput("inv_fb", "Split by", choices = list(), width = "100%")),
                     column(4, radioButtons("inv_part", "Partition", inline = TRUE,
                                            choices = c("Modelling" = 1, "Holdout" = 2, "Validation" = 3, "All" = 0))),
                     column(2, div(style = "padding-top: 24px;", checkboxInput("inv_expected", "Show expected", value = TRUE)))),
                   p(class = "mt-empty-hint", style = "margin: 0 0 6px 0;",
                     "If the gap between solid and dashed lines differs between colours, the effect of the x-axis factor depends on the split factor: a candidate interaction."),
                   plotlyOutput("inv_plot", height = 900))
  ),

  # ~ MAIN TAB 4 - export ----------------------------------------------------------------------------------------------------
  tabPanel("Export", icon = icon("download"),
           mt_page_header("Export", "Download the fitted model's outputs."),
           fluidRow(
             column(6,
                    mt_card("Relativity tables", icon_name = "file-excel",
                            subtitle = "Excel workbook",
                            p(class = "mt-empty-hint", style = "margin: 0 0 10px 0;",
                              "One sheet per factor (level, modelling exposure, relativity, 95% interval, base) and one per interaction, ",
                              "plus a Base sheet and an Index of the full names. Prediction = base × factor relativities × interaction relativities × exposure."),
                            uiOutput("exp_rel_status"),
                            downloadButton("glm_rel_all_xlsx", "Download all relativities (Excel)", class = "btn-primary btn-block"))),
             column(6,
                    mt_card("Model report", icon_name = "file-export",
                            subtitle = "Summary, importance, gains, lift, every factor and interaction in one file",
                            div(class = "mt-report-opts",
                                fluidRow(
                                  column(4, radioButtons("glm_report_format", "Format",
                                                         choices = c("HTML (interactive)" = "html", "PDF" = "pdf"))),
                                  column(4, checkboxGroupInput("glm_report_parts", "Partitions",
                                                               choices = c("Modelling" = 1, "Holdout" = 2, "Validation" = 3),
                                                               selected = c(1, 2, 3))),
                                  column(4, radioButtons("glm_report_factors", "Factors",
                                                         choices = c("In the model (by importance)" = "model", "All factors" = "all")))),
                                uiOutput("glm_report_status"),
                                downloadButton("glm_report_dl", "Create report", class = "btn-primary btn-block"),
                                p(class = "mt-empty-hint", style = "margin: 8px 0 0 0;",
                                  "For each factor in the model: relativity chart and table (95% interval) and actual vs expected with the rebased ",
                                  "relativity for each partition. Each interaction is drawn both ways round, plus its heatmap. Run the drop-one check ",
                                  "(Validation tab) first to rank by drop-one deviance; otherwise the report uses Wald χ². The reference model's lines ",
                                  "are included when one is set."))),
                    mt_card("More exports", icon_name = "list-ul",
                            p(class = "mt-empty-hint", style = "margin: 0;",
                              "The fitted model (.rds) and the model definition are saved from Model › Reference model & files. ",
                              "Factor mappings are saved from Data › Factor mapping, and the model structure from Data › Model structure.")))
           )
  )
)


# SERVER ---------------------------------------------------------------------------------------------------------------------
server <- function(input, output, session) {
  # ~ REACTIVE VALUES ------------------------------------------------------------------------------------------------------
  rv <- reactiveValues( data_loaded            = FALSE,
                        model_structure_loaded = FALSE,
                        data_prepared          = FALSE,
                        raw_data               = data.frame(),
                        col_info               = data.frame(),   # type and number of distinct values of every raw column
                        rename                 = character(0),   # raw name -> model name (every raw column)
                        rename_token           = 0,              # bumped when the names table must be redrawn
                        factor_raw             = character(0),   # model name -> raw name, for the applied structure
                        subset_data            = list(),
                        subset_data_orig       = list(),
                        factor_list            = character(0),
                        factor_lookup_tb_saved = list(),
                        actual_summary_lst     = list(),
                        actual_summary_lst_orig = list(),
                        mapping_version        = 0,
                        map_view               = NULL,
                        map_factor             = NULL,
                        map_table              = NULL,
                        map_draft              = NULL,
                        map_token              = 0,
                        map_mode               = "manual",
                        map_custom_start       = NULL,
                        map_method_saved       = list(),
                        map_preview_on         = FALSE,
                        model_type             = 1,
                        offset_factor          = NULL,
                        key_data               = list(),
                        model_data             = list(),
                        factor_levels          = list(),
                        summary_lst            = list(),
                        terms                  = list(),   # how each factor enters the GLM (include / variate / custom)
                        terms_version          = 0,        # bumped on every change to rv$terms or rv$inters
                        inters                 = list(),   # interactions: list(a, ak, b, bk)
                        inter_view             = NULL,     # interaction shown in the factor view
                        fit_version            = -1,       # terms_version the current model was fitted with
                        glm_model              = NULL,
                        fit_error              = NULL,
                        ref                    = NULL,     # reference model: list(model, pred, rel, label)
                        glm_rel                = NULL,
                        glm_pred               = list(),
                        glm_view               = NULL,
                        base_override          = list(),   # factor -> base level chosen on the Relativities card
                        ed_f                   = NULL,     # factor open in the variate / custom editor
                        ed_var                 = NULL,     # editor drafts
                        ed_cust                = NULL,
                        ed_full                = NULL,     # full-model preview of the factor open in the editor
                        ed_token               = 0 )

  # ~ ERROR GUARD -------------------------------------------------------------------------------------------------------
  # Runs an action; if it fails the listed reactive values are put back as they were, a message explains what went
  # wrong and what to change, and the session stays alive (an uncaught error in an observer closes the app).
  mt_guard <- function(title, expr, hints = NULL, restore = character(0), failed = NULL) {
    saved <- isolate(lapply(setNames(restore, restore), function(n) rv[[n]]))
    tryCatch(expr, error = function(e) {
      if (inherits(e, "shiny.silent.error")) stop(e)   # req() / validate(): not a failure
      for (n in restore) rv[[n]] <- saved[[n]]
      gc()
      msg <- conditionMessage(e)
      message("ERROR (", title, "): ", msg)
      if (!length(hints) && grepl("cannot allocate|memory|too large|exhausted", msg, ignore.case = TRUE))
        hints <- "The data ran out of memory: group factors with many levels (Factor mapping tab), take them out of the model, or use fewer rows."
      mt_error_modal(title, msg, c(hints, if (length(restore)) "Your previous state was restored: nothing was changed."))
      invisible(failed)
    })
  }
  # pop-up shown when a fit would be too big: the largest terms, the parameter count and the memory estimate
  glm_fit_blocked <- function(chk, what = "fit") {
    top <- head(chk$params, 8)
    fmt <- function(x) formatC(x, format = "d", big.mark = ",")
    tbl <- tags$table(class = "table table-condensed", style = "font-size: 12.5px; margin-bottom: 12px;",
                      tags$thead(tags$tr(tags$th("Largest terms"), tags$th(style = "text-align:right", "Parameters"))),
                      tags$tbody(lapply(seq_along(top), function(i)
                        tags$tr(tags$td(names(top)[i]), tags$td(style = "text-align:right", fmt(top[[i]]))))))
    mt_error_modal(if (chk$too_many) sprintf("Too many parameters to %s", what) else sprintf("Model too large to %s in memory", what),
                   msg = paste(c(if (chk$too_many) sprintf("The model has about %s parameters; the limit is %s.", fmt(chk$n_params), fmt(MT_MAX_GLM_PARAMS)),
                                 sprintf("%s rows x %s parameters = %.1f GB per copy; the fit needs about %.1f GB%s.",
                                         fmt(chk$n_rows), fmt(chk$n_params), chk$gb, chk$need_gb,
                                         if (is.na(chk$avail_gb)) "" else sprintf(" and %.1f GB is free", chk$avail_gb))), collapse = "\n"),
                   extra = tbl,
                   hints = c("A factor used with its own levels (S) adds one parameter per level: group its levels on the <b>Factor mapping</b> tab, or use it as a <b>Variate</b> (1 to 3 parameters) or <b>Custom</b> groups instead.",
                             "Interactions of two factors with many levels multiply: use variate or custom groups on one side.",
                             "Or take the largest terms out of the model.",
                             "Nothing was fitted: the current model (if any) is kept."))
  }

  # ~ MAIN TAB 1 - data ----------------------------------------------------------------------------------------------------
  # ~ ~ SUB-TAB 1a - import -------------------------------------------------------------------------------------------------
  output$output_import_warning <- renderText({ '<span style=\"color:red\">DATA NOT LOADED</span>' })

  observeEvent(input$action_read_file, {
    loaded <- withProgress(message = "Reading file", value = 0.3,
                           tryCatch(read_data_file(input$action_read_file$datapath, input$action_read_file$name,
                                                   type = input$import_type,
                                                   csv_sep = input$import_csv_sep, csv_header = input$import_csv_header),
                                    error = function(e) e))
    if (inherits(loaded, "error")) {
      output$output_import_warning <- renderText({
        paste0('<span style=\"color:red\">IMPORT FAILED: ', htmltools::htmlEscape(conditionMessage(loaded)), '</span>')
      })
      return()
    }
    rv$raw_data <- loaded
    cols <- colnames(loaded)
    rv$col_info <- data.frame(col     = cols,
                              numeric = vapply(loaded, is.numeric, logical(1)),
                              levels  = vapply(loaded, function(x) length(unique(x)), integer(1)),
                              row.names = cols, stringsAsFactors = FALSE)
    rv$rename       <- setNames(cols, cols)
    rv$rename_token <- rv$rename_token + 1
    num_cols <- cols[rv$col_info$numeric]

    updateSelectInput(session, 'select_response',         choices = num_cols)
    updateSelectInput(session, 'select_exposure',         choices = num_cols)
    updateSelectInput(session, 'select_offset',           choices = c("NONE", num_cols))
    updateSelectInput(session, 'select_partition_factor', choices = cols)
    updateSelectInput(session, 'select_rating_factors',   choices = cols)
    updateSelectInput(session, 'select_policy_keys',      choices = c("NONE", cols))

    output$output_import_warning <- renderText({ '<span style=\"color:green\">DATA LOADED SUCCESSFULLY</span>' })
    rv$data_loaded <- TRUE

    file_mb   <- file.info(input$action_read_file$datapath)$size / 1024^2
    file_type <- toupper(input$import_type)
    output$file_info   <- renderText({ paste0("FILE SIZE: ", formatC(file_mb, format = "f", digits = 1), " MB (", file_type, ")") })
    output$number_rows <- renderText({ paste0("NUMBER OF ROWS: ", formatC(nrow(rv$raw_data), format = "d", big.mark = ",")) })
    output$number_cols <- renderText({ paste0("NUMBER OF COLUMNS: ", ncol(rv$raw_data)) })
    output$data_summary_desc <- renderTable({ unclass(summary(rv$raw_data)) })
    output$table_raw_data_head <- DT::renderDT({
      DT::datatable(rv$raw_data, rownames = FALSE,
                    options = list(pageLength = 25, lengthMenu = c(10, 25, 50, 100),
                                   scrollX = TRUE, scrollY = "600px", scrollCollapse = TRUE, deferRender = TRUE))
    })
  })

  # ~ ~ SUB-TAB 1b - model structure and factor names ----------------------------------------------------------------------
  output$rating_count <- renderText({
    n <- length(input$select_rating_factors)
    if (!rv$data_loaded) "" else paste0(n, " of ", ncol(rv$raw_data), " selected")
  })

  # columns that are not rating factors but are kept in the modelling data (names must not clash with them)
  structure_cols <- reactive({
    unique(setdiff(c(input$select_response, input$select_exposure, input$select_offset), c("NONE", "")))
  })

  # model name of each selected factor (blank = raw name)
  model_names_of <- function(raw) {
    nm <- unname(rv$rename[raw])
    nm[is.na(nm) | trimws(nm) == ""] <- raw[is.na(nm) | trimws(nm) == ""]
    trimws(nm)
  }

  # problems with the model names of the selected factors; returns a named list of row messages (by raw name)
  rename_problems <- reactive({
    raw <- input$select_rating_factors
    if (!length(raw)) return(list())
    nm  <- model_names_of(raw)
    msg <- setNames(rep(NA_character_, length(raw)), raw)
    bad <- make.names(nm) != nm
    msg[bad] <- "not a valid R name (letters, digits, . and _ only; must not start with a digit)"
    dup <- nm %in% nm[duplicated(nm)]
    msg[dup & is.na(msg)] <- "used by more than one factor"
    clash <- nm %in% structure_cols()
    msg[clash & is.na(msg)] <- "same as the response / exposure / offset column"
    sfx <- grepl("_(var|custom)$", nm)
    msg[sfx & is.na(msg)] <- "must not end in _var or _custom (kept for variate / custom versions)"
    as.list(msg[!is.na(msg)])
  })

  output$rename_table_ui <- renderUI({
    rv$rename_token
    raw <- input$select_rating_factors
    if (!rv$data_loaded || !length(raw))
      return(div(class = "mt-map-preview-empty", style = "min-height: 160px;", icon("list-check"),
                 "Select the rating factors to name them."))
    nm   <- isolate(model_names_of(raw))
    info <- isolate(rv$col_info)[raw, ]
    esc  <- function(x) htmltools::htmlEscape(as.character(x), attribute = TRUE)
    rows <- sprintf('<tr%s><td class="mt-locked">%s</td><td class="mt-type">%s</td><td class="mt-num">%s</td><td class="mt-new-cell"><input class="mt-new%s" value="%s" data-raw="%s" placeholder="%s" spellcheck="false"></td></tr>',
                    ifelse(nm != raw, ' class="mt-changed"', ""), esc(raw),
                    ifelse(info$numeric, "num", "cat"), formatC(info$levels, format = "d", big.mark = ","),
                    ifelse(nm != raw, " mt-edited", ""), esc(nm), esc(raw), esc(raw))
    HTML(sprintf('<div class="mt-map-table-wrap mt-rename-wrap"><table id="rename_table" class="mt-map-table"><thead><tr><th>Raw name%s</th><th>Type</th><th style=\"text-align: right;\">Levels</th><th>Model name</th></tr></thead><tbody>%s</tbody></table></div>',
                 as.character(icon("lock")), paste(rows, collapse = "")))
  })
  # highlight rows with a bad name without redrawing the table (keeps the cursor where it is)
  observe({
    session$sendCustomMessage("rename_bad", names(rename_problems()))
  })
  output$rename_status_ui <- renderUI({
    raw <- input$select_rating_factors
    req(rv$data_loaded, length(raw))
    p <- rename_problems()
    n_renamed <- sum(model_names_of(raw) != raw)
    if (!length(p))
      return(div(class = "mt-name-status", span(class = "mt-good", icon("check"),
                                                  sprintf(" %d factor%s · %d renamed · all names valid", length(raw),
                                                          if (length(raw) == 1) "" else "s", n_renamed))))
    div(class = "mt-name-status",
        lapply(names(p), function(r) div(span(class = "mt-bad", icon("triangle-exclamation"), " ", model_names_of(r)),
                                         span(class = "mt-empty-hint", paste0(" (", r, "): ", p[[r]])))))
  })

  observeEvent(input$rename_values, {
    v <- input$rename_values
    raw  <- as.character(unlist(v$raw))
    vals <- trimws(as.character(unlist(v$values)))
    req(length(raw) == length(vals), all(raw %in% names(rv$rename)))
    vals[vals == ""] <- raw[vals == ""]
    r <- rv$rename
    r[raw] <- vals
    rv$rename <- r
  })
  observeEvent(input$rename_reset, {
    req(rv$data_loaded)
    rv$rename <- setNames(names(rv$rename), names(rv$rename))
    rv$rename_token <- rv$rename_token + 1
  })

  # Factor_config.xlsx: raw name, model name (+ optional In_model = Y to select the factor)
  observeEvent(input$rename_config, {
    req(rv$data_loaded)
    path <- input$rename_config$datapath
    cfg <- tryCatch(if (tolower(tools::file_ext(input$rename_config$name)) == "csv") data.table::fread(path, data.table = FALSE)
                    else as.data.frame(readxl::read_excel(path)),
                    error = function(e) NULL)
    if (is.null(cfg) || ncol(cfg) < 2) {
      mt_alert(title = "Could not read the file", text = "It needs at least two columns: raw name and model name.", type = "error")
      return()
    }
    raw_col <- if ("Factor_list" %in% names(cfg)) "Factor_list" else names(cfg)[1]
    new_col <- if ("Factor_re_name" %in% names(cfg)) "Factor_re_name" else names(cfg)[2]
    cfg <- cfg[!is.na(cfg[[raw_col]]), ]
    raw <- trimws(as.character(cfg[[raw_col]]))
    new <- trimws(as.character(cfg[[new_col]]))
    found <- raw %in% names(rv$rename)
    r <- rv$rename
    ok <- found & !is.na(new) & new != ""
    r[raw[ok]] <- new[ok]
    rv$rename <- r
    use <- found
    if ("In_model" %in% names(cfg)) use <- use & toupper(trimws(as.character(cfg$In_model))) %in% c("Y", "YES", "TRUE", "1")
    updateSelectInput(session, "select_rating_factors", selected = raw[use])
    rv$rename_token <- rv$rename_token + 1
    mt_alert(title = sprintf("%d factor name%s loaded", sum(ok), if (sum(ok) == 1) "" else "s"),
               text  = paste0(sum(use), " factor", if (sum(use) == 1) "" else "s", " selected.",
                              if (any(!found)) paste0(" Not in this data, skipped: ", paste(raw[!found], collapse = ", ")) else ""),
               type  = if (any(!found)) "warning" else "success")
  })

  # ---- save / load the structure (definition + factor names) ----
  output$action_save_prep <- downloadHandler(
    filename = "glm_model_structure.rds",
    content = function(file) {
      req(rv$data_loaded)
      raw <- input$select_rating_factors
      saveRDS(list(tool           = "GLM Modelling Studio",
                   model_type     = input$select_model_type,
                   response       = input$select_response,
                   exposure       = input$select_exposure,
                   offset         = input$select_offset,
                   partition      = input$select_partition_factor,
                   rating_factors = raw,
                   model_names    = setNames(model_names_of(raw), raw),
                   policy_keys    = input$select_policy_keys),
              file)
    }
  )
  observeEvent(input$action_import_prep, {
    req(rv$data_loaded)
    s <- tryCatch(readRDS(input$action_import_prep$datapath), error = function(e) NULL)
    if (!is.list(s) || is.null(s$rating_factors)) {
      mt_alert(title = "Not a GLM model structure", text = "Choose a file saved with 'Save current model structure'.", type = "error")
      return()
    }
    cols <- names(rv$rename)
    updateSelectInput(session, 'select_model_type',       selected = s$model_type)
    updateSelectInput(session, 'select_response',         selected = s$response)
    updateSelectInput(session, 'select_exposure',         selected = s$exposure)
    updateSelectInput(session, 'select_offset',           selected = s$offset)
    updateSelectInput(session, 'select_partition_factor', selected = s$partition)
    updateSelectInput(session, 'select_policy_keys',      selected = s$policy_keys)
    updateSelectInput(session, 'select_rating_factors',   selected = intersect(s$rating_factors, cols))
    r <- rv$rename
    keep <- intersect(names(s$model_names), cols)
    r[keep] <- s$model_names[keep]
    rv$rename <- r
    rv$rename_token <- rv$rename_token + 1
    missing <- setdiff(s$rating_factors, cols)
    if (length(missing))
      mt_alert(title = "Structure loaded", type = "warning",
                 text = paste("These factors are not in the data and were skipped:", paste(missing, collapse = ", ")))
  })

  # ---- apply structure ----
  output$output_data_prep_warning <- renderText({ '<span style=\"color:red\">STRUCTURE NOT APPLIED</span>' })
  observeEvent(input$action_prepare_data, {
    fail <- function(msg) {
      output$output_data_prep_warning <- renderText({ paste0('<span style=\"color:red\">', htmltools::htmlEscape(msg), '</span>') })
    }
    if (!rv$data_loaded) return(fail("NO DATA: import a file first"))
    raw <- input$select_rating_factors
    if (!length(raw)) return(fail("SELECT AT LEAST ONE RATING FACTOR"))
    if (length(rename_problems())) return(fail("FIX THE FACTOR NAMES MARKED IN RED"))
    pf <- input$select_partition_factor
    part <- suppressWarnings(as.integer(as.character(rv$raw_data[[pf]])))
    if (!all(unique(part[!is.na(part)]) %in% 1:3) || !any(part == 1, na.rm = TRUE))
      return(fail(paste0("PARTITION '", pf, "' MUST HOLD 1 (MODELLING), 2 (HOLDOUT) AND OPTIONALLY 3 (VALIDATION)")))
    if (input$select_response == input$select_exposure) return(fail("RESPONSE AND EXPOSURE MUST BE DIFFERENT COLUMNS"))

    ok <- mt_guard("Could not apply the model structure", failed = FALSE,
      hints = c("Check the response, exposure, offset and partition choices (step 2).",
                "Factors with a very large number of distinct values (IDs, raw postcodes) are slow and rarely useful: leave them out of the rating factors."),
      restore = c("model_type", "offset_factor", "key_data", "subset_data", "subset_data_orig", "factor_list", "factor_raw",
                  "actual_summary_lst", "actual_summary_lst_orig", "map_view", "model_structure_loaded", "data_prepared",
                  "mapping_version"), {
    withProgress(message = "Applying model structure", value = 0.1, {
      rv$model_type    <- as.numeric(input$select_model_type)
      rv$offset_factor <- if (identical(input$select_offset, "NONE")) NULL else input$select_offset
      new <- model_names_of(raw)

      d    <- rv$raw_data
      keep <- d[[input$select_exposure]] > 0 & !is.na(d[[input$select_exposure]])
      d    <- d[keep, , drop = FALSE]
      sub  <- d[, unique(c(input$select_response, input$select_exposure, rv$offset_factor, raw)), drop = FALSE]
      names(sub)[match(raw, names(sub))] <- new
      sub$.partition <- d[[pf]]
      setProgress(0.4, detail = "Splitting partitions")
      parts <- lapply(partition_data_factor(sub, ".partition"), function(x) { x$.partition <- NULL; x })

      keys <- setdiff(input$select_policy_keys, "NONE")
      rv$key_data <- if (length(keys)) partition_data_factor(cbind(d[, keys, drop = FALSE], .partition = d[[pf]]), ".partition") else list()

      rv$subset_data      <- parts
      rv$subset_data_orig <- parts
      rv$factor_list      <- sort(new)
      rv$factor_raw       <- setNames(raw, new)
      setProgress(0.6, detail = "Summarising factors")
      rv$actual_summary_lst      <- summarise_fun_actual(bind_rows(parts), rv$factor_list, input$select_exposure, input$select_response)
      rv$actual_summary_lst_orig <- rv$actual_summary_lst

      if (is.null(rv$map_view) || !rv$map_view %in% rv$factor_list) rv$map_view <- rv$factor_list[1]
      setProgress(0.8, detail = "Re-applying mappings")
      map_apply_to_data(names(rv$factor_lookup_tb_saved))
      rv$model_structure_loaded <- TRUE
      rv$data_prepared <- FALSE
    })
    TRUE
    })
    if (!isTRUE(ok)) return()

    n <- vapply(parts, nrow, integer(1))
    dropped <- sum(!keep)
    output$output_data_prep_warning <- renderText({
      paste0('<span style=\"color:green\">STRUCTURE APPLIED · ', length(raw), ' FACTORS · ',
             paste(paste(toupper(mt_partition_names), formatC(n, format = "d", big.mark = ",")), collapse = " · "),
             if (dropped) paste0(' · ', formatC(dropped, format = "d", big.mark = ","), ' ROWS WITH ZERO EXPOSURE DROPPED') else '',
             '</span>')
    })
    output$output_modelling_data_warning <- renderText({ '<span style=\"color:red\">MODELLING DATA NOT CREATED</span>' })
  })

  # ~ ~ SUB-TAB 1c - factor mapping (from the GBM app) ------------------------------------------------------------------
  # rv$factor_lookup_tb_saved holds the applied mapping table of every mapped factor (this is what is saved / loaded).
  # The pop-out editor works on a draft (rv$map_draft); the data only changes when "Apply mapping" is pressed.

  map_all_orig   <- reactive({ req(length(rv$subset_data_orig) > 0); bind_rows(rv$subset_data_orig) })
  map_is_numeric <- function(f) is.numeric(rv$subset_data_orig[[1]][[f]])
  map_n_levels   <- function(f, mapped = FALSE) {
    s <- if (mapped) rv$actual_summary_lst[[f]] else rv$actual_summary_lst_orig[[f]]
    if (is.null(s)) NA_integer_ else nrow(s)
  }
  map_mapped     <- function() intersect(names(rv$factor_lookup_tb_saved), rv$factor_list)

  # writes the applied mappings of `facs` into the modelling data (original values if a factor has no mapping)
  map_apply_to_data <- function(facs) {
    facs <- intersect(facs, rv$factor_list)
    if (!length(facs)) return(invisible())
    dat <- rv$subset_data
    for (s in seq_along(dat)) for (f in facs)
      dat[[s]][[f]] <- apply_factor_mapping(rv$subset_data_orig[[s]][[f]], rv$factor_lookup_tb_saved[[f]])
    rv$subset_data <- dat
    sums <- rv$actual_summary_lst
    sums[facs] <- summarise_fun_actual(bind_rows(dat), facs, input$select_exposure, input$select_response)
    rv$actual_summary_lst <- sums
    rv$mapping_version <- rv$mapping_version + 1
  }
  map_clear <- function(facs) {
    saved <- rv$factor_lookup_tb_saved
    saved[facs] <- NULL
    rv$factor_lookup_tb_saved <- saved
    map_apply_to_data(facs)
  }

  map_manual_table <- function(f) {
    lv <- rv$actual_summary_lst_orig[[f]]$factor_name
    data.frame(current_factor_level = lv, new_factor_level = lv)
  }
  # exposure behind each row of a mapping table
  map_table_exposure <- function(f, tb) {
    if (is_band_mapping(tb)) {
      all <- map_all_orig()
      x <- all[[f]]; w <- all[[input$select_exposure]]
      L <- suppressWarnings(as.numeric(tb$current_factor_level_left))
      R <- suppressWarnings(as.numeric(tb$current_factor_level_right))
      vapply(seq_len(nrow(tb)), function(i) {
        if (is.na(L[i]) || is.na(R[i]) || L[i] >= R[i]) return(NA_real_)
        sum(w[!is.na(x) & x >= L[i] & x < R[i]])
      }, 0)
    } else {
      s <- rv$actual_summary_lst_orig[[f]]
      s$exposure[match(tb$current_factor_level, s$factor_name)]
    }
  }
  # puts a new table in the editor (discards edits)
  map_set_draft <- function(tb) {
    rv$map_table <- tb
    rv$map_draft <- tb
    rv$map_token <- rv$map_token + 1
  }

  # ---- factor browser ----
  output$map_factor_list_ui <- renderUI({
    facs <- rv$factor_list
    if (!length(facs)) return(div(class = "mt-map-empty", "Apply the model structure (step 2) to list the factors."))
    mapped <- map_mapped()
    if (identical(input$map_sort, "mapped")) facs <- c(facs[facs %in% mapped], facs[!facs %in% mapped])
    rows <- vapply(facs, function(f) {
      m <- f %in% mapped
      sprintf('<div class="mt-map-row%s" data-f="%s" title="Click to view, right-click to map"><span class="mt-map-name">%s</span>%s<span class="mt-map-tag">%s</span><button type="button" class="mt-map-edit" title="Map this factor">%s</button></div>',
              if (m) " mt-mapped" else "",
              htmltools::htmlEscape(f, attribute = TRUE),
              gsub("([_.])", "\\1<wbr>", htmltools::htmlEscape(f)),
              if (m) sprintf('<span class="mt-map-badge" title="levels: original to mapped">%s &rarr; %s</span>', map_n_levels(f), map_n_levels(f, TRUE)) else "",
              if (map_is_numeric(f)) "num" else "cat",
              as.character(icon("pen")))
    }, character(1))
    HTML(paste(rows, collapse = ""))
  })
  output$map_count <- renderText({
    if (!length(rv$factor_list)) return("")
    paste0(length(map_mapped()), " of ", length(rv$factor_list), " mapped")
  })
  output$map_set_count <- renderText({
    n <- length(map_mapped())
    if (n == 0) "no mappings applied" else paste0(n, " factor", if (n > 1) "s", " mapped")
  })

  observeEvent(input$map_view, {
    req(input$map_view %in% rv$factor_list)
    rv$map_view <- input$map_view
  })
  observe({ session$sendCustomMessage("map_viewing", if (is.null(rv$map_view)) "" else rv$map_view) })

  # ---- workspace: header + charts ----
  output$map_header_ui <- renderUI({
    f <- rv$map_view
    if (is.null(f) || !f %in% rv$factor_list)
      return(div(class = "mt-map-head",
                 span(class = "mt-map-head-meta", icon("circle-info"),
                      " Apply the model structure (step 2), then pick a factor from the list.")))
    tb <- rv$factor_lookup_tb_saved[[f]]
    mapped <- !is.null(tb)
    div(class = "mt-map-head",
        span(class = "mt-map-head-name", f),
        span(class = "mt-map-head-meta",
             paste0(if (map_is_numeric(f)) "Numeric" else "Categorical", " · ", map_n_levels(f), " levels")),
        if (mapped)
          span(class = "mt-map-chip on", icon("check"),
               paste0(" ", if (!is_band_mapping(tb)) "Manual"
                           else if (identical(rv$map_method_saved[[f]], "auto")) "Auto bands" else "Custom bands", " · ",
                      map_n_levels(f), " → ", map_n_levels(f, TRUE), " levels"))
        else span(class = "mt-map-chip off", "Not mapped"),
        div(class = "mt-map-head-actions",
            if (mapped) actionButton("map_clear_view", "Clear mapping", icon = icon("eraser"), class = "btn-danger-outline"),
            actionButton("map_edit_current", if (mapped) "Edit mapping" else "Map factor",
                         icon = icon("pen-to-square"), class = "btn-primary")))
  })

  output$map_charts_ui <- renderUI({
    f <- rv$map_view
    req(f %in% rv$factor_list)
    mapped <- f %in% names(rv$factor_lookup_tb_saved)
    orig_card <- mt_card(if (mapped) "Original banding" else "Banding", icon_name = "chart-column",
                         subtitle = paste(map_n_levels(f), "levels"),
                         plotlyOutput("map_plot_orig", height = 720))
    if (!mapped) return(orig_card)
    fluidRow(column(8, orig_card),
             column(4, mt_card("Mapped banding", icon_name = "shuffle",
                               subtitle = paste(map_n_levels(f, TRUE), "levels"),
                               plotlyOutput("map_plot_new", height = 720))))
  })
  output$map_plot_orig <- renderPlotly({
    f <- rv$map_view
    req(f %in% names(rv$actual_summary_lst_orig))
    mapping_oneway_plot(rv$actual_summary_lst_orig[[f]], f) %>% mt_set_rate_label(rv$model_type)
  })
  output$map_plot_new <- renderPlotly({
    f <- rv$map_view
    req(f %in% names(rv$factor_lookup_tb_saved), f %in% names(rv$actual_summary_lst))
    mapping_oneway_plot(rv$actual_summary_lst[[f]], f, compact = TRUE) %>% mt_set_rate_label(rv$model_type)
  })

  # ---- pop-out mapping editor ----
  map_open_editor <- function(f) {
    req(f %in% rv$factor_list)
    rv$map_view       <- f
    rv$map_factor     <- f
    rv$map_preview_on <- FALSE
    saved  <- rv$factor_lookup_tb_saved[[f]]
    is_num <- map_is_numeric(f)
    n_lv   <- map_n_levels(f)
    # too many levels for the hand-editable table (one input per level would freeze the browser)
    too_many <- !is.na(n_lv) && n_lv > MT_MAX_MAP_LEVELS
    if (too_many && !is_num) {
      mt_error_modal(sprintf("%s has too many levels to map by hand", f),
                     msg = sprintf("%s levels; the mapping table is limited to %s.",
                                   formatC(n_lv, format = "d", big.mark = ","), formatC(MT_MAX_MAP_LEVELS, format = "d", big.mark = ",")),
                     hints = c("Group the levels in the source data (for example postcode to postcode area) and load it again.",
                               "Or leave this factor out of the rating factors (step 2)."))
      return(invisible())
    }
    method <- if (!is.null(saved) && is_band_mapping(saved)) {
      if (identical(rv$map_method_saved[[f]], "auto")) "auto" else "custom"
    } else if (too_many) "auto" else "manual"
    rv$map_mode <- method
    map_set_draft(if (!is.null(saved) && (!too_many || is_band_mapping(saved))) saved
                  else if (too_many) NULL else map_manual_table(f))
    rv$map_custom_start <- if (method == "custom") saved else NULL

    showModal(modalDialog(
      title = div(class = "mt-map-title", icon("shuffle"), span("Map factor"), tags$b(f),
                  span(class = "mt-map-tag", if (is_num) "numeric" else "categorical"),
                  span(class = "mt-map-head-meta", paste(map_n_levels(f), "levels"))),
      size = "l", easyClose = FALSE,
      div(class = "mt-map-modal",
          div(class = "mt-map-method",
              radioButtons("map_method", "Mapping method", inline = TRUE, selected = method,
                           choices = if (too_many) c("Auto banding" = "auto", "Custom bands" = "custom")
                                     else if (is_num) c("Manual" = "manual", "Auto banding" = "auto", "Custom bands" = "custom")
                                     else c("Manual" = "manual")),
              conditionalPanel("input.map_method == 'auto'", class = "mt-map-auto",
                               numericInput("map_n_bands", "Number of bands", min = 2, max = 200,
                                            value = if (method == "auto") nrow(saved) else min(10, map_n_levels(f))),
                               actionButton("map_make_bands", "Create bands", icon = icon("wand-magic-sparkles"),
                                            class = "btn-primary")),
              conditionalPanel("input.map_method == 'custom'", class = "mt-map-auto",
                               span(class = "mt-map-custom-hint", icon("circle-info"),
                                    " Type each band's From (≥), To (<) and new level, or paste the three columns from Excel.")),
              if (!is_num) span(class = "mt-empty-hint", icon("circle-info"), " Auto and custom banding are available for numeric factors only"),
              if (too_many) span(class = "mt-empty-hint", icon("circle-info"),
                                 sprintf(" %s distinct values: too many to map by hand, use Auto or Custom banding",
                                         formatC(n_lv, format = "d", big.mark = ",")))
          ),
          div(class = "mt-divider"),
          fluidRow(
            column(5,
                   mt_section("Mapping table"),
                   div(class = "mt-map-tools",
                       tags$button(id = "map_copy_table", type = "button", class = "btn btn-default",
                                   title = "Copy the table to the clipboard, ready to paste into Excel",
                                   icon("copy"), span("Copy table")),
                       downloadButton("map_download_xlsx", "Download Excel", class = "btn-default"),
                       fileInput("map_upload", NULL, buttonLabel = tagList(icon("file-arrow-up"), "Upload Excel"),
                                 accept = c(".xlsx", ".xls", ".csv")),
                       actionButton("map_reset", "Reset", icon = icon("rotate-left"))),
                   uiOutput("map_edit_table_ui"),
                   uiOutput("map_band_check_ui"),
                   conditionalPanel("input.map_method != 'custom'",
                     div(class = "mt-map-note", icon("lock"),
                         " Current levels are locked. Type new levels, or copy a column from Excel, click the first cell to fill and press Ctrl+V. Levels given the same new value are merged.")),
                   conditionalPanel("input.map_method == 'custom'",
                     div(class = "mt-map-note", icon("circle-info"),
                         " Bands are [From, To). Use Inf for an open top band. Paste From, To and New level from Excel into the From cell of the first band to fill all three columns (extra rows add bands). A blank new level takes the band's From value. Bands given the same new level are merged."))
            ),
            column(7,
                   mt_section("Impact of new banding"),
                   uiOutput("map_preview_ui"))
          )
      ),
      footer = tagList(
        if (!is.null(saved)) actionButton("map_clear_current", "Clear current mapping", icon = icon("eraser"),
                                          class = "btn-danger-outline", style = "float: left;"),
        modalButton("Cancel"),
        actionButton("map_apply", "Apply mapping", icon = icon("check"), class = "btn-success"))
    ))
  }
  observeEvent(input$map_open,         map_open_editor(input$map_open))
  observeEvent(input$map_edit_current, map_open_editor(rv$map_view))

  # switching method: manual starts from the original levels; auto waits for "Create bands"
  observeEvent(input$map_method, ignoreInit = TRUE, {
    f <- rv$map_factor
    req(f)
    cur_auto <- !is.null(rv$map_table) && is_band_mapping(rv$map_table)
    saved    <- rv$factor_lookup_tb_saved[[f]]
    if (input$map_method == "manual" && (is.null(rv$map_table) || cur_auto) && isTRUE(map_n_levels(f) <= MT_MAX_MAP_LEVELS))
      map_set_draft(if (!is.null(saved) && !is_band_mapping(saved)) saved else map_manual_table(f))
    if (input$map_method == "auto" && !cur_auto)
      map_set_draft(if (!is.null(saved) && is_band_mapping(saved)) saved else NULL)
    # custom keeps the current bands (e.g. auto bands to tweak); otherwise starts from the saved bands or 5 auto bands
    if (input$map_method == "custom") {
      start <- if (!is.null(rv$map_draft) && is_band_mapping(rv$map_draft)) rv$map_draft
               else if (!is.null(saved) && is_band_mapping(saved)) saved
               else auto_band_table(map_all_orig()[[f]], min(5, map_n_levels(f)))
      if (is.null(start)) start <- band_table_from(NA, NA, "")
      map_set_draft(start)
      rv$map_custom_start <- start
    }
    rv$map_mode <- input$map_method
  })

  observeEvent(input$map_make_bands, {
    f  <- rv$map_factor
    nb <- input$map_n_bands
    req(f)
    if (!isTruthy(nb) || nb < 2) { showNotification("Number of bands must be at least 2", type = "error"); return() }
    tb <- mt_guard("Could not create the bands", auto_band_table(map_all_orig()[[f]], nb), hints = "Try fewer bands.", failed = FALSE)
    if (isFALSE(tb)) return()
    if (is.null(tb)) { showNotification("Not enough distinct values to create bands for this factor", type = "error"); return() }
    map_set_draft(tb)
    if (nrow(tb) < nb)
      showNotification(sprintf("Created %d bands: fewer than requested because many records share the same values", nrow(tb)), type = "message")
  })

  observeEvent(input$map_reset, {
    req(rv$map_factor)
    if (identical(rv$map_mode, "custom") && !is.null(rv$map_custom_start)) map_set_draft(rv$map_custom_start)
    else if (is.null(rv$map_table)) return()
    else if (!is_band_mapping(rv$map_table)) map_set_draft(map_manual_table(rv$map_factor))
    else map_set_draft(rv$map_table)
  })

  # the editable table (plain HTML: locked current levels + one input per new level)
  output$map_edit_table_ui <- renderUI({
    tb <- rv$map_table
    f  <- isolate(rv$map_factor)
    if (is.null(tb))
      return(div(class = "mt-map-preview-empty", style = "min-height: 220px;", icon("wand-magic-sparkles"),
                 "Choose the number of bands and click Create bands"))
    esc  <- function(x) htmltools::htmlEscape(ifelse(is.na(x), "NA", as.character(x)), attribute = TRUE)
    escv <- function(x) htmltools::htmlEscape(ifelse(is.na(x), "", as.character(x)), attribute = TRUE)
    expo  <- map_table_exposure(f, tb)
    share <- expo / sum(expo, na.rm = TRUE)
    expo_txt <- ifelse(is.na(expo), "", paste0(formatC(expo, format = "f", digits = 0, big.mark = ","),
                                                " · ", formatC(100 * share, format = "f", digits = 1), "%"))
    lock <- as.character(icon("lock"))
    if (is_band_mapping(tb) && identical(rv$map_mode, "custom")) {
      cell <- function(col, v, ph = "") sprintf('<td class="mt-new-cell"><input class="mt-new mt-edge" data-col="%s" value="%s" data-orig="%s" placeholder="%s" spellcheck="false"></td>',
                                               col, v, v, ph)
      L <- mt_edge_txt(tb$current_factor_level_left); R <- mt_edge_txt(tb$current_factor_level_right)
      rows <- paste0('<tr>', cell("left", escv(L), "From"), cell("right", escv(R), "To"),
                     sprintf('<td class="mt-num" data-v="%s">%s</td>', ifelse(is.na(expo), "", format(expo, scientific = FALSE, trim = TRUE)), expo_txt),
                     cell("new", escv(tb$new_factor_level), escv(L)),
                     sprintf('<td class="mt-del"><button type="button" class="mt-band-del" data-i="%d" title="Remove this band">%s</button></td>',
                             seq_len(nrow(tb)) - 1, as.character(icon("xmark"))),
                     '</tr>')
      head <- '<th data-col="current_factor_level_left">From (&ge;)</th><th data-col="current_factor_level_right">To (&lt;)</th><th data-col="exposure">Exposure</th><th data-col="new_factor_level">New level</th><th class="mt-del"></th>'
      return(HTML(sprintf('<div class="mt-map-table-wrap"><table id="map_edit_table" class="mt-map-table mt-custom-bands" data-mode="custom" data-token="%s"><thead><tr>%s</tr></thead><tbody>%s</tbody></table></div><button type="button" id="map_add_band" class="btn btn-default mt-add-band">%s Add band</button>',
                          rv$map_token, head, paste(rows, collapse = ""), as.character(icon("plus")))))
    }
    if (is_band_mapping(tb)) {
      head <- sprintf('<th data-col="current_factor_level_left">From (&ge;)%s</th><th data-col="current_factor_level_right">To (&lt;)%s</th><th data-col="exposure">Exposure</th><th data-col="new_factor_level">New level</th>', lock, lock)
      locked <- sprintf('<td class="mt-locked">%s</td><td class="mt-locked">%s</td>',
                        esc(tb$current_factor_level_left), esc(tb$current_factor_level_right))
      orig_new <- escv(tb$new_factor_level)
      changed  <- rep(FALSE, nrow(tb))
    } else {
      head <- sprintf('<th data-col="current_factor_level">Current level%s</th><th data-col="exposure">Exposure</th><th data-col="new_factor_level">New level</th>', lock)
      locked <- sprintf('<td class="mt-locked">%s</td>', esc(tb$current_factor_level))
      orig_new <- escv(tb$current_factor_level)
      changed  <- as.character(tb$new_factor_level) != as.character(tb$current_factor_level)
      changed[is.na(changed)] <- FALSE
    }
    rows <- sprintf('<tr%s>%s<td class="mt-num" data-v="%s">%s</td><td class="mt-new-cell"><input class="mt-new%s" value="%s" data-orig="%s" placeholder="%s" spellcheck="false"></td></tr>',
                    ifelse(changed, ' class="mt-changed"', ""), locked, ifelse(is.na(expo), "", format(expo, scientific = FALSE, trim = TRUE)), expo_txt,
                    ifelse(changed, " mt-edited", ""), escv(tb$new_factor_level), orig_new, escv(tb$new_factor_level))
    HTML(sprintf('<div class="mt-map-table-wrap"><table id="map_edit_table" class="mt-map-table" data-token="%s"><thead><tr>%s</tr></thead><tbody>%s</tbody></table></div>',
                 rv$map_token, head, paste(rows, collapse = "")))
  })

  # edits / pastes arrive here (debounced in the browser); blank cells keep the value shown when the table was built
  observeEvent(input$map_new_levels, {
    v  <- input$map_new_levels
    tb <- rv$map_table
    req(!is.null(tb), identical(as.character(v$token), as.character(rv$map_token)))
    vals <- as.character(unlist(v$values))
    req(length(vals) == nrow(tb))
    blank <- is.na(vals) | trimws(vals) == ""
    vals[blank] <- as.character(tb$new_factor_level[blank])
    vals <- trimws(vals)
    tb$new_factor_level <- if (map_is_numeric(rv$map_factor)) mt_as_level(vals) else vals
    rv$map_draft <- tb
  })
  # custom bands: every edit sends all three columns; add / remove / a paste that adds rows rebuild the table
  observeEvent(input$map_custom_edit, {
    v  <- input$map_custom_edit
    tb <- rv$map_table
    req(!is.null(tb), is_band_mapping(tb), identical(as.character(v$token), as.character(rv$map_token)))
    col <- function(k) { z <- unlist(lapply(v[[k]], function(s) if (is.null(s)) "" else as.character(s))); if (is.null(z)) character(0) else z }
    L <- col("left"); R <- col("right"); N <- col("values")
    op <- as.character(v$op)
    if (op == "remove") {
      i <- as.integer(v$i) + 1
      if (i >= 1 && i <= length(L)) { L <- L[-i]; R <- R[-i]; N <- N[-i] }
    }
    if (op == "add") {
      n <- length(L)
      L <- c(L, if (n) R[n] else ""); R <- c(R, ""); N <- c(N, "")
    }
    nt <- band_table_from(L, R, N)
    if (op == "edit" && nrow(nt) == nrow(tb)) {
      rv$map_draft <- nt
      expo  <- map_table_exposure(rv$map_factor, nt)
      share <- expo / sum(expo, na.rm = TRUE)
      session$sendCustomMessage("map_expo", list(
        token = rv$map_token,
        v   = ifelse(is.na(expo), "", format(expo, scientific = FALSE, trim = TRUE)),
        txt = ifelse(is.na(expo), "", paste0(formatC(expo, format = "f", digits = 0, big.mark = ","), " · ",
                                              formatC(100 * share, format = "f", digits = 1), "%"))))
    } else {
      map_set_draft(nt)
    }
  })
  map_band_check <- reactive({
    tb <- rv$map_draft
    req(!is.null(tb), is_band_mapping(tb), rv$map_factor %in% rv$factor_list)
    all <- map_all_orig()
    band_mapping_check(all[[rv$map_factor]], all[[input$select_exposure]], tb)
  })
  output$map_band_check_ui <- renderUI({
    req(identical(rv$map_mode, "custom"))
    chk <- map_band_check()
    if (!length(chk$errors) && !length(chk$warnings))
      return(div(class = "mt-band-check ok", icon("circle-check"),
                 sprintf(" %d band%s, every value is in a band", nrow(rv$map_draft), if (nrow(rv$map_draft) == 1) "" else "s")))
    div(class = "mt-band-check",
        lapply(chk$errors,   function(m) div(class = "bad",  icon("circle-xmark"), " ", m)),
        lapply(chk$warnings, function(m) div(class = "warn", icon("triangle-exclamation"), " ", m)))
  })

  observeEvent(input$map_pasted, {
    p <- input$map_pasted
    msg <- sprintf("Pasted %d value%s", p$n, if (p$n == 1) "" else "s")
    if (p$extra > 0) msg <- paste0(msg, sprintf(" · %d more row%s than the table, ignored", p$extra, if (p$extra == 1) "" else "s"))
    showNotification(msg, type = if (p$extra > 0) "warning" else "message", duration = 4)
  })

  output$map_download_xlsx <- downloadHandler(
    filename = function() paste0("mapping_", rv$map_factor, ".xlsx"),
    content  = function(file) {
      tb  <- rv$map_draft
      req(tb)
      out <- cbind(tb[setdiff(names(tb), "new_factor_level")],
                   exposure = map_table_exposure(rv$map_factor, tb),
                   new_factor_level = tb$new_factor_level)
      writexl::write_xlsx(list(mapping = out), file)
    }
  )

  observeEvent(input$map_upload, {
    tb <- rv$map_table
    if (is.null(tb)) { showNotification("Create the bands first, then upload the edited file", type = "error"); return() }
    path <- input$map_upload$datapath
    up <- tryCatch(if (tolower(tools::file_ext(input$map_upload$name)) == "csv") data.table::fread(path, data.table = FALSE)
                   else as.data.frame(readxl::read_excel(path)),
                   error = function(e) NULL)
    if (is.null(up) || !"new_factor_level" %in% names(up)) {
      showNotification("The file needs a 'new_factor_level' column: download the Excel first to get the layout", type = "error")
      return()
    }
    # custom bands: a file with band edges replaces the whole table, whatever its number of rows
    if (identical(rv$map_mode, "custom") && is_band_mapping(up)) {
      map_set_draft(band_table_from(up$current_factor_level_left, up$current_factor_level_right, up$new_factor_level))
      showNotification(sprintf("Loaded %d bands from file", nrow(up)), type = "message")
      return()
    }
    if (nrow(up) != nrow(tb)) {
      showNotification(sprintf("The file has %d rows but the table has %d", nrow(up), nrow(tb)), type = "error")
      return()
    }
    key <- intersect(c("current_factor_level", "current_factor_level_left"), intersect(names(up), names(tb)))
    if (length(key) && !identical(as.character(up[[key[1]]]), as.character(tb[[key[1]]]))) {
      showNotification("The current levels in the file don't match this factor (rows changed or re-ordered)", type = "error")
      return()
    }
    vals <- as.character(up$new_factor_level)
    tb$new_factor_level <- if (map_is_numeric(rv$map_factor)) mt_as_level(vals) else vals
    map_set_draft(tb)
    showNotification("New levels loaded from file", type = "message")
  })

  # ---- impact preview (stays live once opened) ----
  observeEvent(input$map_view_new, { rv$map_preview_on <- TRUE })
  map_preview_data <- reactive({
    req(rv$map_preview_on, !is.null(rv$map_draft), rv$map_factor %in% rv$factor_list)
    f     <- rv$map_factor
    all   <- map_all_orig()
    expo  <- all[[input$select_exposure]]
    new_x <- apply_factor_mapping(all[[f]], rv$map_draft)
    list(orig     = rv$actual_summary_lst_orig[[f]],
         new      = mapping_level_summary(new_x, expo, all[[input$select_response]]),
         unmapped = sum(expo[is.na(new_x) & !is.na(all[[f]])]) / sum(expo))
  })
  output$map_preview_ui <- renderUI({
    if (!rv$map_preview_on)
      return(div(class = "mt-map-preview-empty",
                 icon("chart-column", style = "font-size: 22px;"),
                 div("Compare the new levels with the original banding."),
                 actionButton("map_view_new", "View new banding", icon = icon("eye"), class = "btn-primary")))
    tagList(uiOutput("map_preview_stats"),
            div(class = "mt-map-preview-title", "Original"),
            plotlyOutput("map_prev_orig", height = 205),
            div(class = "mt-map-preview-title", "New banding"),
            plotlyOutput("map_prev_new", height = 205))
  })
  output$map_preview_stats <- renderUI({
    d <- map_preview_data()
    small <- min(d$new$exposure) / sum(d$new$exposure)
    div(class = "mt-map-preview-stats",
        span(class = "mt-sum-chip", "Levels: ", tags$b(paste(nrow(d$orig), "→", nrow(d$new)))),
        span(class = "mt-sum-chip", "Smallest level: ", tags$b(paste0(formatC(100 * small, format = "f", digits = 1), "% of exposure"))),
        if (d$unmapped > 0)
          span(class = "mt-sum-chip mt-bad", icon("triangle-exclamation"),
               paste0(" ", formatC(100 * d$unmapped, format = "f", digits = 1), "% of exposure falls outside the bands (becomes NA)")))
  })
  output$map_prev_orig <- renderPlotly({ d <- map_preview_data(); mapping_oneway_plot(d$orig, rv$map_factor, compact = TRUE) %>% mt_set_rate_label(rv$model_type) })
  output$map_prev_new  <- renderPlotly({ d <- map_preview_data(); mapping_oneway_plot(d$new,  rv$map_factor, compact = TRUE) %>% mt_set_rate_label(rv$model_type) })

  # ---- apply / clear ----
  map_restore <- c("factor_lookup_tb_saved", "map_method_saved", "subset_data", "actual_summary_lst", "mapping_version")
  observeEvent(input$map_apply, {
    f  <- rv$map_factor
    tb <- rv$map_draft
    if (is.null(tb)) { showNotification("Create the bands first", type = "error"); return() }
    if (is_band_mapping(tb)) {
      chk <- map_band_check()
      if (length(chk$errors)) {
        mt_alert(title = "Fix the bands first", text = paste(chk$errors, collapse = "\n"), type = "error")
        return()
      }
    }
    removeModal()
    ok <- mt_guard(sprintf("Could not apply the mapping of %s", f), restore = map_restore, failed = FALSE,
                   hints = "Check the new levels in the mapping table (blank cells, overlapping bands), then try again.", {
      saved <- rv$factor_lookup_tb_saved
      saved[[f]] <- as.data.frame(tb)
      rv$factor_lookup_tb_saved <- saved
      ms <- rv$map_method_saved
      ms[[f]] <- if (is_band_mapping(tb)) rv$map_mode else "manual"
      rv$map_method_saved <- ms
      map_apply_to_data(f)
      TRUE
    })
    if (!isTRUE(ok)) return()
    showNotification(sprintf("Mapping applied to %s: %s → %s levels", f, map_n_levels(f), map_n_levels(f, TRUE)), type = "message")
  })
  observeEvent(input$map_clear_current, {
    f <- rv$map_factor
    removeModal()
    if (!isTRUE(mt_guard(paste("Could not clear the mapping of", f), { map_clear(f); TRUE }, restore = map_restore))) return()
    showNotification(paste("Mapping cleared for", f), type = "message")
  })
  observeEvent(input$map_clear_view, {
    f <- rv$map_view
    if (!isTRUE(mt_guard(paste("Could not clear the mapping of", f), { map_clear(f); TRUE }, restore = map_restore))) return()
    showNotification(paste("Mapping cleared for", f), type = "message")
  })
  observeEvent(input$map_clear_all, {
    n <- length(map_mapped())
    if (n == 0) { showNotification("There are no mappings to clear", type = "message"); return() }
    mt_alert(title = "Clear all mappings?",
               text  = sprintf("This removes the mapping of %d factor%s and restores the original levels.", n, if (n > 1) "s" else ""),
               type  = "warning", showCancelButton = TRUE,
               confirmButtonText = "Clear all", confirmButtonCol = "#b42318", cancelButtonText = "Cancel",
               callbackR = function(ok) {
                 if (isTRUE(ok)) {
                   if (!isTRUE(mt_guard("Could not clear the mappings", { map_clear(names(rv$factor_lookup_tb_saved)); TRUE },
                                        restore = map_restore))) return()
                   showNotification("All mappings cleared", type = "message")
                 }
               })
  })


  # ---- save / load the mapping set (.rds keyed by model name, or Excel with one tab per factor) ----
  output$action_save_formatted_data <- downloadHandler(
    filename = "factor_mappings.rds",
    content = function(file) {
      req(rv$model_structure_loaded)
      saveRDS(rv$factor_lookup_tb_saved, file)
    }
  )
  output$action_save_formatted_xlsx <- downloadHandler(
    filename = "factor_mappings.xlsx",
    content = function(file) {
      req(rv$model_structure_loaded)
      writexl::write_xlsx(mapping_set_to_sheets(rv$factor_lookup_tb_saved), file)
    }
  )
  observeEvent(input$action_import_formatted_data, {
    if (!length(rv$factor_list)) {
      mt_alert(title = "Apply the model structure first", type = "error")
      return()
    }
    path <- input$action_import_formatted_data$datapath
    ext  <- tolower(tools::file_ext(input$action_import_formatted_data$name))
    loaded <- tryCatch(if (ext %in% c("xlsx", "xls")) read_mapping_workbook(path) else readRDS(path),
                       error = function(e) NULL)
    if (!is.list(loaded) || is.data.frame(loaded) || (length(loaded) && is.null(names(loaded)))) {
      mt_alert(title = "Not a mapping file", text = "Choose an .rds or Excel file saved with 'Save', or a Factor_formats_simple workbook.", type = "error")
      return()
    }
    # tabs / entries may be named by model name or by raw name
    to_model <- function(n) {
      if (n %in% rv$factor_list) return(n)
      m <- names(rv$factor_raw)[match(n, rv$factor_raw)]
      if (length(m) && !is.na(m)) m else NA_character_
    }
    target  <- vapply(names(loaded), to_model, character(1))
    bad_tb  <- !vapply(loaded, valid_mapping_table, logical(1))
    use     <- !is.na(target) & !bad_tb
    ok <- mt_guard("Could not apply the loaded mappings", restore = map_restore, failed = FALSE,
                   hints = "The file may come from a different data set: check that its levels match this data.", {
      saved <- rv$factor_lookup_tb_saved
      saved[target[use]] <- loaded[use]
      rv$factor_lookup_tb_saved <- saved
      map_apply_to_data(unname(target[use]))
      TRUE
    })
    if (!isTRUE(ok)) return()
    skipped <- names(loaded)[is.na(target)]
    invalid <- names(loaded)[!is.na(target) & bad_tb]
    mt_alert(title = sprintf("%d mapping%s loaded and applied", sum(use), if (sum(use) == 1) "" else "s"),
               text  = paste(c(if (length(skipped)) paste("Not in this model structure, skipped:", paste(skipped, collapse = ", ")),
                               if (length(invalid)) paste("Not a mapping table, skipped:", paste(invalid, collapse = ", "))),
                             collapse = "\n\n"),
               type  = if (length(skipped) || length(invalid)) "warning" else "success")
  })

  # ---- build the modelling dataset: every rating factor becomes a set of GLM levels ----
  output$output_modelling_data_warning <- renderText({ '<span style=\"color:red\">MODELLING DATA NOT CREATED</span>' })
  observeEvent(input$Prepare_modelling_data, {
    if (!isTRUE(rv$model_structure_loaded)) {
      showNotification("Apply the model structure (step 2) first", type = "error")
      return()
    }
    ok <- mt_guard("Could not create the modelling dataset", failed = FALSE,
      hints = c("Factors with a very large number of levels make the level tables large: group them on the <b>Factor mapping</b> tab or leave them out of the rating factors (step 2)."),
      restore = c("factor_levels", "summary_lst", "model_data", "terms", "inters", "terms_version", "fit_error", "glm_view",
                  "glm_model", "data_prepared", "ref"), {
    withProgress(message = "Creating modelling dataset", value = 0, {
      facs  <- rv$factor_list
      parts <- rv$subset_data
      all   <- bind_rows(parts)
      lv    <- list()
      for (i in seq_along(facs)) {
        f <- facs[i]
        setProgress(0.05 + 0.6 * i / length(facs), detail = sprintf("Levels of %s (%d of %d)", f, i, length(facs)))
        lv[[f]] <- glm_factor_levels(all[[f]])
        for (s in seq_along(parts)) parts[[s]][[f]] <- glm_as_factor(parts[[s]][[f]], lv[[f]])
      }
      setProgress(0.7, detail = "Summarising levels")
      expo <- input$select_exposure; resp <- input$select_response
      rv$factor_levels <- lapply(setNames(facs, facs), function(f) {
        m <- parts[[1]]
        s <- tapply(m[[expo]], m[[f]], sum); s[is.na(s)] <- 0
        data.frame(level = lv[[f]], exposure = as.numeric(s[lv[[f]]]), stringsAsFactors = FALSE)
      })
      setProgress(0.85, detail = "Summarising partitions")
      rv$summary_lst <- lapply(parts, function(p) if (nrow(p)) summarise_fun_actual(p, facs, expo, resp) else list())
      rv$model_data  <- parts
      # term definitions: keep a factor's existing definition while its levels are unchanged
      old <- rv$terms; new_terms <- list(); reset <- character(0)
      for (f in facs) {
        if (!is.null(old[[f]]) && identical(old[[f]]$var_tb$level, lv[[f]])) new_terms[[f]] <- old[[f]]
        else { new_terms[[f]] <- glm_new_term(lv[[f]]); if (!is.null(old[[f]])) reset <- c(reset, f) }
      }
      rv$terms <- new_terms
      rv$inters <- Filter(function(it) all(c(it$a, it$b) %in% facs), rv$inters)   # keep interactions whose factors remain
      rv$terms_version <- rv$terms_version + 1
      rv$fit_error <- NULL
      if (length(reset)) showNotification(paste("Levels changed, variate / custom definitions reset for:", paste(reset, collapse = ", ")),
                                          type = "warning", duration = 10)
      if (is.null(rv$glm_view) || !rv$glm_view %in% facs) rv$glm_view <- facs[1]
      rv$glm_model <- NULL
      rv$data_prepared <- TRUE
      updateSelectInput(session, "inv_fa", choices = facs, selected = if (isTruthy(input$inv_fa) && input$inv_fa %in% facs) input$inv_fa else facs[1])
      updateSelectInput(session, "inv_fb", choices = facs, selected = if (isTruthy(input$inv_fb) && input$inv_fb %in% facs) input$inv_fb else facs[min(2, length(facs))])
      # the reference model is re-scored on the new data (dropped if it no longer fits it)
      if (!is.null(rv$ref)) {
        r <- tryCatch(make_reference(rv$ref$model, rv$ref$label), error = function(e) NULL)
        if (is.null(r)) showNotification("The reference model does not match the new dataset and was cleared", type = "warning", duration = 8)
        rv$ref <- r
      }
      setProgress(1, detail = "Done")
    })
    TRUE
    })
    if (!isTRUE(ok)) return()
    n_lv <- vapply(rv$factor_levels, nrow, integer(1))
    big  <- sort(n_lv[n_lv > MT_MAX_CHART_LEVELS], decreasing = TRUE)
    if (length(big))
      showNotification(paste0("Many levels: ", paste(sprintf("%s (%s)", names(big), formatC(big, format = "d", big.mark = ",")), collapse = ", "),
                              ". Band or group them on the Factor mapping tab before using them with their own levels (S): each level is one parameter."),
                       type = "warning", duration = 15)
    output$output_modelling_data_warning <- renderText({
      sprintf('<span style=\"color:green\">MODELLING DATA CREATED · %d FACTORS · %s LEVELS</span>',
              length(n_lv), formatC(sum(n_lv), format = "d", big.mark = ","))
    })
    showNotification(sprintf("Modelling dataset created: %d factors, %d levels in total", length(n_lv), sum(n_lv)), type = "message")
  })

  # ~ MAIN TAB 2 - model ---------------------------------------------------------------------------------------------------
  fmt_num <- function(x, d = 0) formatC(x, format = "f", digits = d, big.mark = ",")
  fmt_pct <- function(x, d = 1) ifelse(is.na(x), "–", paste0(formatC(100 * x, format = "f", digits = d), "%"))
  # a factor is in the model exactly when one of S / V / C is on: one out of the model has V and C off too
  set_terms <- function(tl) {
    for (f in names(tl)) if (!isTRUE(tl[[f]]$include)) { tl[[f]]$var_on <- FALSE; tl[[f]]$cust_on <- FALSE }
    rv$terms <- tl; rv$terms_version <- rv$terms_version + 1
  }
  # ranking used by the gains curve and Gini: the predicted rate without the offset (as the GBM app ranks on the margin
  # without its base margin), so the Gini measures what the rating factors add
  rank_score <- function(pred, d) {
    s <- pred / d[[input$select_exposure]]
    if (!is.null(rv$offset_factor)) s <- s / d[[rv$offset_factor]]
    s
  }
  tweedie_p <- function() if (isTruthy(input$glm_tweedie_p)) input$glm_tweedie_p else 1.5
  model_name_of <- function(n) {
    if (n %in% names(rv$terms)) return(n)
    m <- names(rv$factor_raw)[match(n, rv$factor_raw)]
    if (length(m) && !is.na(m)) m else NA_character_
  }
  is_in <- function(tl) vapply(tl, function(t) isTRUE(t$include), logical(1))
  mode_chips <- function(t) {
    if (!isTRUE(t$include)) return(span(class = "mt-mode-chip", "Not in model"))
    tagList(
      if (isTRUE(t$var_on)) span(class = "mt-mode-chip var", paste0("Variate · ", c("linear", "quadratic", "cubic")[t$var_order])),
      if (isTRUE(t$cust_on)) span(class = "mt-mode-chip cust", paste0("Custom · ", length(unique(t$cust_tb$group)), " groups")),
      if (!isTRUE(t$var_on) && !isTRUE(t$cust_on)) span(class = "mt-mode-chip plain", paste0("Simple · own ", nrow(t$var_tb), " levels")))
  }

  # ---- factor list ----
  output$glm_factor_list_ui <- renderUI({
    tl <- rv$terms
    if (!length(tl)) return(div(class = "mt-map-empty", style = "padding: 12px;",
                                "Create the modelling dataset (Data › Factor mapping) to list the factors."))
    facs <- sort(names(tl))
    if (identical(input$glm_sort, "model")) { inc <- is_in(tl[facs]); facs <- c(facs[inc], facs[!inc]) }
    in_inter <- glm_inter_factors(rv$inters)
    rows <- vapply(facs, function(f) {
      t <- tl[[f]]
      vlab <- c("V", "V²", "V³")[t$var_order]
      warn <- isTRUE(t$var_on) && anyNA(t$var_tb$value)
      partners <- unlist(lapply(rv$inters, function(it) if (it$a == f) it$b else if (it$b == f) it$a))
      simple <- isTRUE(t$include) && !isTRUE(t$var_on) && !isTRUE(t$cust_on)
      sprintf('<div class="mt-glm-row%s" data-f="%s"><span class="mt-glm-cb%s" title="%s"></span><span class="mt-map-name">%s</span>%s<span class="mt-vc mt-s%s" data-k="s" title="Simple: the factor\'s own levels">S</span><span class="mt-vc mt-v%s%s" data-k="v" title="Variate (fit a curve over the level values)">%s</span><span class="mt-vc mt-c%s" data-k="c" title="Custom grouping of levels">C</span><button type="button" class="mt-map-edit" title="Edit variate / custom">%s</button></div>',
              if (isTRUE(t$include)) " mt-in" else "", htmltools::htmlEscape(f, attribute = TRUE),
              if (isTRUE(t$include)) " on" else "",
              if (isTRUE(t$include)) "In the model" else "Not in the model: switch on S, V or C",
              gsub("([_.])", "\\1<wbr>", htmltools::htmlEscape(f)),
              if (f %in% in_inter) sprintf('<span class="mt-x-badge" title="Interacts with %s">×</span>',
                                           htmltools::htmlEscape(paste(partners, collapse = ", "), attribute = TRUE)) else "",
              if (simple) " on" else "",
              if (isTRUE(t$var_on)) " on" else "", if (warn) " mt-warn-vc" else "", vlab,
              if (isTRUE(t$cust_on)) " on" else "", as.character(icon("pen")))
    }, character(1))
    HTML(paste(rows, collapse = ""))
  })
  output$glm_factor_count <- renderText({
    tl <- rv$terms
    if (!length(tl)) "" else paste0(sum(is_in(tl)), " of ", length(tl), " in model")
  })
  observe({ session$sendCustomMessage("glm_viewing", if (is.null(rv$glm_view)) "" else rv$glm_view) })

  observeEvent(input$glm_toggle, mt_guard("Could not change the factor", restore = c("terms", "inters", "terms_version"), {
    f <- input$glm_toggle$f; k <- input$glm_toggle$k
    tl <- rv$terms
    req(f %in% names(tl))
    t <- tl[[f]]
    simple <- isTRUE(t$include) && !isTRUE(t$var_on) && !isTRUE(t$cust_on)
    # S = the factor's own levels; it cannot be combined with V or C (they describe the same levels twice).
    # The factor is in the model while any of S / V / C is on.
    if (k == "s") {
      if (simple) t$include <- FALSE
      else { t$var_on <- FALSE; t$cust_on <- FALSE; t$include <- TRUE }
    }
    if (k == "v") { t$var_on  <- !isTRUE(t$var_on);  t$include <- t$var_on || isTRUE(t$cust_on) }
    if (k == "c") { t$cust_on <- !isTRUE(t$cust_on); t$include <- t$cust_on || isTRUE(t$var_on) }
    tl[[f]] <- t
    set_terms(tl)
    if (k == "v" && t$var_on && anyNA(t$var_tb$value))
      showNotification(sprintf("%s: some levels have no variate value yet. Right-click the factor to fill them in.", f),
                       type = "warning", duration = 6)
  }))
  observeEvent(input$glm_view, {
    req(input$glm_view %in% names(rv$terms))
    rv$glm_view <- input$glm_view
    if (!identical(input$glm_tabs, "view")) updateTabsetPanel(session, "glm_tabs", selected = "view")
  })

  # ---- interactions ----
  set_inters <- function(x) { rv$inters <- x; rv$terms_version <- rv$terms_version + 1 }
  kind_label <- c(var = "variate", custom = "custom", plain = "levels")
  output$glm_inter_count <- renderText({ n <- length(rv$inters); if (!n) "none" else paste(n, if (n == 1) "interaction" else "interactions") })
  output$glm_inter_list_ui <- renderUI({
    it_list <- rv$inters
    if (!length(it_list)) return(p(class = "mt-empty-hint", style = "margin: 0 0 8px 0;",
                                   "No interactions. Use the Investigation tab to look for candidates."))
    div(class = "mt-inter-list",
        lapply(seq_along(it_list), function(k) {
          it <- it_list[[k]]
          div(class = "mt-inter-row", `data-i` = k, title = "Click to view",
              span(class = "mt-x-badge", "×"),
              div(class = "mt-inter-name", glm_inter_label(it),
                  tags$small(paste0(kind_label[[it$ak]], " × ", kind_label[[it$bk]]))),
              tags$button(type = "button", class = "mt-inter-del", `data-i` = k, title = "Remove", icon("xmark")))
        }))
  })
  observeEvent(input$glm_inter_remove, {
    k <- input$glm_inter_remove
    req(k >= 1, k <= length(rv$inters))
    lab <- glm_inter_label(rv$inters[[k]])
    set_inters(rv$inters[-k])
    showNotification(paste("Interaction removed:", lab), type = "message")
  })
  observeEvent(input$glm_inter_view, {
    k <- input$glm_inter_view
    req(k >= 1, k <= length(rv$inters))
    rv$glm_view <- rv$inters[[k]]$a
    rv$inter_view <- glm_inter_label(rv$inters[[k]])
    updateTabsetPanel(session, "glm_tabs", selected = "view")
  })
  kind_choices <- function(f) {
    t <- rv$terms[[f]]
    ch <- c("Variate values" = "var", "Custom groups" = "custom", "Own levels" = "plain")
    attr(ch, "default") <- if (is.null(t)) "plain" else glm_main_kind(t)
    ch
  }
  observeEvent(input$glm_inter_add, {
    if (!length(rv$terms)) { showNotification("Create the modelling dataset first", type = "error"); return() }
    facs <- sort(names(rv$terms))
    a0 <- if (!is.null(rv$glm_view) && rv$glm_view %in% facs) rv$glm_view else facs[1]
    b0 <- if (identical(input$inv_fb, a0) || !isTruthy(input$inv_fb)) facs[facs != a0][1] else input$inv_fb
    showModal(modalDialog(
      title = div(class = "mt-map-title", icon("shuffle"), span("Add interaction")),
      fluidRow(
        column(6, selectInput("ia_a", "First factor", choices = facs, selected = a0, width = "100%"),
               radioButtons("ia_ak", "Used as", choices = kind_choices(a0), selected = attr(kind_choices(a0), "default"))),
        column(6, selectInput("ia_b", "Second factor", choices = facs, selected = b0, width = "100%"),
               radioButtons("ia_bk", "Used as", choices = kind_choices(b0), selected = attr(kind_choices(b0), "default")))),
      div(class = "mt-formula-preview", style = "margin-top: 6px;", mt_section("Formula term"),
          tags$pre(class = "mt-formula", style = "margin: 0;", textOutput("ia_term", inline = TRUE))),
      p(class = "mt-empty-hint", style = "margin-top: 8px;",
        "Variate × variate fits one coefficient (a slope on the product); custom groups or own levels fit one per combination of levels. ",
        "The variate values and custom groups come from each factor's own editor."),
      footer = tagList(modalButton("Cancel"), actionButton("ia_ok", "Add", icon = icon("check"), class = "btn-success")),
      easyClose = TRUE))
  })
  observeEvent(input$ia_a, { k <- kind_choices(input$ia_a); updateRadioButtons(session, "ia_ak", selected = attr(k, "default")) }, ignoreInit = TRUE)
  observeEvent(input$ia_b, { k <- kind_choices(input$ia_b); updateRadioButtons(session, "ia_bk", selected = attr(k, "default")) }, ignoreInit = TRUE)
  output$ia_term <- renderText({
    req(input$ia_a, input$ia_b, input$ia_ak, input$ia_bk)
    glm_inter_term(glm_new_interaction(input$ia_a, input$ia_ak, input$ia_b, input$ia_bk))
  })
  observeEvent(input$ia_ok, mt_guard("Could not add the interaction", restore = c("terms", "inters", "terms_version"), {
    it <- glm_new_interaction(input$ia_a, input$ia_ak, input$ia_b, input$ia_bk)
    if (it$a == it$b) { showNotification("Choose two different factors", type = "error"); return() }
    dup <- any(vapply(rv$inters, function(x) setequal(c(x$a, x$b), c(it$a, it$b)), logical(1)))
    if (dup) { showNotification("These two factors already interact: remove that interaction first", type = "error"); return() }
    pr <- glm_inter_problem(it, rv$terms)
    if (!is.null(pr)) { showNotification(paste(pr, collapse = "; "), type = "error", duration = 8); return() }
    set_inters(c(rv$inters, list(it)))
    removeModal()
    notin <- setdiff(c(it$a, it$b), names(rv$terms)[is_in(rv$terms)])
    showNotification(paste0("Interaction added: ", glm_inter_label(it),
                            if (length(notin)) paste0(". Note: ", paste(notin, collapse = ", "), " not in the model as a main effect") else ""),
                     type = if (length(notin)) "warning" else "message", duration = 6)
  }))

  # ---- fit ----
  output$glm_fit_status <- renderText({
    if (!is.null(rv$fit_error)) return(paste0('<span style=\"color:red\">', htmltools::htmlEscape(rv$fit_error), '</span>'))
    m <- rv$glm_model
    if (is.null(m)) return('<span style=\"color:red\">MODEL NOT FITTED</span>')
    if (rv$fit_version != rv$terms_version) return('<span style=\"color:orange\">DEFINITION CHANGED SINCE THE LAST FIT</span>')
    sprintf('<span style=\"color:green\">FITTED · %d PARAMETERS · %s S</span>', m$n_params, fmt_num(m$fit_seconds, 1))
  })

  observeEvent(input$glm_fit, {
    rv$fit_error <- NULL
    if (!isTRUE(rv$data_prepared)) { rv$fit_error <- "CREATE THE MODELLING DATASET FIRST"; return() }
    tl  <- rv$terms
    inc <- names(tl)[is_in(tl)]
    probs <- c(unlist(lapply(inc, function(f) glm_term_problem(f, tl[[f]]))),
               unlist(lapply(rv$inters, glm_inter_problem, terms = tl)))
    if (length(probs)) {
      rv$fit_error <- "FIX THE FACTORS LISTED IN THE MESSAGE"
      mt_alert(title = "Fix these factors first", text = paste(probs, collapse = "\n"), type = "error")
      return()
    }
    chk <- tryCatch(glm_fit_check(tl, rv$inters, nrow(rv$model_data[[1]])), error = function(e) NULL)
    if (!is.null(chk) && (chk$too_many || chk$too_big)) {
      rv$fit_error <- "MODEL TOO LARGE: SEE THE MESSAGE"
      glm_fit_blocked(chk)
      return()
    }
    res <- mt_guard("Model fit failed", failed = simpleError("fit failed"),
                    hints = c("Check the variate values and custom groups of the factors in the model.",
                              "Very many parameters can exhaust memory: group factors with many levels, or use them as variate / custom."), {
    withProgress(message = "Fitting GLM", value = 0.1, {
      setProgress(0.15, detail = sprintf("%d factors · %d interactions · %s modelling rows", length(inc), length(rv$inters),
                                         fmt_num(nrow(rv$model_data[[1]]))))
      m <- tryCatch(glm_fit_model(rv$model_data[[1]], tl, input$select_response, input$select_exposure,
                                  rv$offset_factor, rv$model_type, tweedie_p(), inters = rv$inters),
                    error = function(e) e)
      if (inherits(m, "error")) return(m)
      setProgress(0.75, detail = "Predicting every partition")
      pred <- lapply(rv$model_data, function(d) glm_predict(m, d))
      setProgress(0.9, detail = "Relativities")
      list(m = m, pred = pred, rel = glm_add_ci(glm_relativities(m, rv$factor_levels, rv$base_override), m))
    })
    })
    if (inherits(res, "error")) {
      rv$fit_error <- paste("FIT FAILED:", conditionMessage(res))
      if (!identical(conditionMessage(res), "fit failed"))   # the guard has already shown its own message
        mt_error_modal("Model fit failed", conditionMessage(res),
                       c(if (grepl("cannot allocate|memory|too large|exhausted", conditionMessage(res), ignore.case = TRUE))
                           "The fit ran out of memory: group factors with many levels (Factor mapping tab), use them as variate / custom, or take terms out of the model.",
                         "Check the variate values and custom groups of the factors in the model.",
                         "A factor or interaction with levels that have no data can make the fit fail: group those levels.",
                         "Nothing was changed: the current model (if any) is kept."))
      return()
    }
    rv$glm_model <- res$m; rv$glm_pred <- res$pred; rv$glm_rel <- res$rel
    rv$fit_version <- rv$terms_version
    showModal(modalDialog(title = tagList(icon("circle-check", style = "color: #067647;"), " GLM fitted"),
                          glm_summary_tags(), size = "l", easyClose = TRUE,
                          footer = tagList(actionButton("glm_open_summary", "Open summary", icon = icon("square-check")),
                                           modalButton("Close"))))
  })
  observeEvent(input$glm_open_summary, { removeModal(); updateTabsetPanel(session, "glm_tabs", selected = "summary") })

  # ---- summary ----
  glm_partition_stats <- reactive({
    m <- rv$glm_model
    req(m)
    bind_rows(lapply(1:3, function(i) {
      d <- rv$model_data[[i]]
      if (!nrow(d)) return(NULL)
      p <- rv$glm_pred[[i]]
      data.frame(partition = mt_partition_names[i], rows = nrow(d), exposure = sum(d[[m$exposure]]),
                 actual = sum(d[[m$response]]), expected = sum(p), ae = sum(d[[m$response]]) / sum(p),
                 gini = glm_gini(p, d[[m$exposure]], d[[m$response]], score = rank_score(p, d)))
    }))
  })
  glm_summary_tags <- function() {
    m <- rv$glm_model; ps <- glm_partition_stats()
    tile <- function(label, value, sub = NULL) div(class = "mt-sum-tile", div(class = "mt-sum-label", label),
                                                   div(class = "mt-sum-value", value), if (!is.null(sub)) div(class = "mt-sum-sub", sub))
    ae_class <- function(ae) if (is.na(ae)) "" else if (abs(ae - 1) <= 0.02) "mt-good" else if (abs(ae - 1) <= 0.05) "mt-warn" else "mt-bad"
    hold <- ps[ps$partition == "Holdout", ]
    tl <- m$terms
    tagList(
      div(class = "mt-sum-tiles",
          tile("Model", m$family, paste(length(m$included), "factors")),
          tile("Parameters", m$n_params, if (length(m$aliased)) paste(length(m$aliased), "aliased (set to 0)") else
                 paste0(if (m$converged) "converged" else "NOT converged", " · ", m$iterations, " iterations")),
          tile("Deviance explained", fmt_pct(1 - m$deviance / m$null_deviance, 2),
               paste0(fmt_num(m$deviance, 1), " of ", fmt_num(m$null_deviance, 1))),
          tile(if (is.na(m$aic)) "Dispersion" else "AIC", if (is.na(m$aic)) formatC(m$dispersion, format = "g", digits = 4) else fmt_num(m$aic, 1)),
          tile("Holdout Gini", if (nrow(hold)) fmt_pct(hold$gini) else "–", paste0("Modelling ", fmt_pct(ps$gini[1]))),
          tile("Holdout A/E", if (nrow(hold)) formatC(hold$ae, format = "f", digits = 3) else "–", "actual ÷ expected"),
          tile("Fit time", paste0(fmt_num(m$fit_seconds, 1), " s"), format(m$fitted_at, "%H:%M:%S"))),
      fluidRow(
        column(7,
               mt_section("Validation by partition"),
               tags$table(class = "table mt-sum-table",
                          tags$thead(tags$tr(tags$th("Partition"), tags$th("Exposure"), tags$th("Actual"), tags$th("Expected"),
                                             tags$th("A/E"), tags$th("Gini"))),
                          tags$tbody(lapply(seq_len(nrow(ps)), function(i) {
                            p <- ps[i, ]
                            tags$tr(tags$td(p$partition), tags$td(fmt_num(p$exposure)), tags$td(fmt_num(p$actual, 1)),
                                    tags$td(fmt_num(p$expected, 1)),
                                    tags$td(span(class = ae_class(p$ae), formatC(p$ae, format = "f", digits = 3))),
                                    tags$td(fmt_pct(p$gini)))
                          }))),
               mt_section("Base"),
               div(class = "mt-sum-metrics",
                   span(class = "mt-sum-chip", "Base value: ", tags$b(formatC(rv$glm_rel$base, format = "g", digits = 6))),
                   span(class = "mt-sum-chip", "All factors at their highest-exposure level"))),
        column(5,
               mt_section("Factors in the model"),
               div(style = "max-height: 330px; overflow-y: auto;",
                   lapply(m$included, function(f) div(class = "mt-chip-row", style = "margin-bottom: 5px;",
                                                       span(style = "font-weight: 600; font-size: 12px; min-width: 0; overflow-wrap: anywhere;", f),
                                                       mode_chips(tl[[f]]))),
                   if (length(m$interactions)) tagList(
                     mt_section("Interactions"),
                     lapply(m$interactions, function(it) div(class = "mt-chip-row", style = "margin-bottom: 5px;",
                                                             span(class = "mt-x-badge", "×"),
                                                             span(style = "font-weight: 600; font-size: 12px;", glm_inter_label(it)),
                                                             span(class = "mt-mode-chip", paste0(kind_label[[it$ak]], " × ", kind_label[[it$bk]])))))))
      )
    )
  }
  output$glm_summary_ui <- renderUI({
    if (is.null(rv$glm_model))
      return(div(class = "mt-coming", icon("play", style = "font-size: 22px;"), div("Fit the GLM to see its summary.")))
    mt_card("Model summary", icon_name = "square-check",
            subtitle = if (rv$fit_version != rv$terms_version) "Definition changed since this fit" else NULL,
            glm_summary_tags())
  })

  # ---- factor view ----
  output$glm_view_header <- renderUI({
    f <- rv$glm_view
    if (is.null(f) || !f %in% names(rv$terms))
      return(div(class = "mt-map-head", span(class = "mt-map-head-meta", icon("circle-info"),
                                             " Create the modelling dataset, then pick a factor from the list.")))
    t <- rv$terms[[f]]
    m <- rv$glm_model
    stale <- !is.null(m) && rv$fit_version != rv$terms_version
    div(class = "mt-map-head",
        span(class = "mt-map-head-name", f),
        span(class = "mt-map-head-meta", paste0("raw: ", rv$factor_raw[[f]], " · ", nrow(t$var_tb), " levels")),
        div(class = "mt-chip-row", mode_chips(t),
            if (stale) span(class = "mt-mode-chip stale", icon("triangle-exclamation"), " refit to update the chart")),
        div(class = "mt-map-head-actions",
            actionButton("glm_edit_current", "Edit variate / custom", icon = icon("pen-to-square"), class = "btn-primary")))
  })
  output$glm_chart_subtitle <- renderText({
    if (identical(input$glm_view_mode, "rel")) "Relativity to the base level (star) · shaded: 95% confidence band"
    else "Rebased relativity = relativity × average actual rate of the modelling data"
  })
  output$glm_ave_plot <- renderPlotly({
    f <- rv$glm_view
    req(rv$data_prepared, f %in% names(rv$terms))
    if (identical(input$glm_view_mode, "rel")) {
      validate(need(!is.null(rv$glm_model), "Fit the model to see the relativities."),
               need(!is.null(rv$glm_rel$factors[[f]]), "This factor is not in the fitted model."))
      ref <- if (isTRUE(input$glm_view_ref) && !is.null(rv$ref)) rv$ref$rel$factors[[f]] else NULL
      return(plot_glm_relativity(rv$glm_rel$factors[[f]], f, ref, isTRUE(input$glm_view_ci)))
    }
    n_lv <- nrow(rv$factor_levels[[f]])
    if (isTRUE(n_lv > MT_MAX_CHART_LEVELS)) return(mt_too_many_levels_plot(f, n_lv))
    i <- as.integer(input$glm_view_part)
    d <- rv$model_data[[i]]
    validate(need(nrow(d) > 0, "There is no data in this partition."))
    resp <- input$select_response; expo <- input$select_exposure
    m    <- rv$glm_model
    pred <- if (!is.null(m)) rv$glm_pred[[i]] else NULL
    rel  <- if (!is.null(m)) rv$glm_rel$factors[[f]] else NULL
    d1   <- rv$model_data[[1]]
    rate <- sum(d1[[resp]]) / sum(d1[[expo]])
    s <- glm_factor_summary(d, f, resp, expo, pred, rel, rate)
    ref <- if (isTRUE(input$glm_view_ref)) rv$ref else NULL
    if (!is.null(ref)) {
      sr <- glm_factor_summary(d, f, resp, expo, ref$pred[[i]], ref$rel$factors[[f]], rate)
      s$prediction_ref <- sr$prediction[match(as.character(s$factor_name), as.character(sr$factor_name))]
      s$relativity_ref <- sr$relativity_rebased[match(as.character(s$factor_name), as.character(sr$factor_name))]
    }
    lines <- list(list(col = "actual", name = "Actual", colour = mt_chart_colours$actual))
    if (!is.null(pred)) lines <- c(lines, list(list(col = "prediction", name = "Expected", colour = mt_chart_colours$expected)))
    if (!is.null(rel))  lines <- c(lines, list(list(col = "relativity_rebased", name = "Rebased relativity", colour = "#16a34a",
                                                    dash = "dash", symbol = "diamond")))
    if (!is.null(ref)) lines <- c(lines, list(
      list(col = "prediction_ref", name = "Expected (reference)", colour = mt_chart_colours$expected_ref, dash = "dot"),
      list(col = "relativity_ref", name = "Rebased relativity (reference)", colour = "#7c3aed", dash = "dot", symbol = "diamond-open")))
    p <- mt_oneway_plot(s, f, lines) %>% mt_set_rate_label(rv$model_type)
    # 95% confidence band around the rebased relativity (drawn on the right-hand axis)
    if (!is.null(rel) && isTRUE(input$glm_view_ci) && !all(is.na(rel$lower))) {
      lv <- levels(droplevels(factor(s$factor_name)))
      k  <- match(lv, rel$level)
      xs <- factor(rel$level[k], levels = lv)
      p <- p %>%
        add_trace(x = xs, y = rate * rel$lower[k], type = "scatter", mode = "lines", yaxis = "y2", name = "95% band",
                  legendgroup = "ci", showlegend = FALSE, line = list(color = "rgba(22,163,74,0)", width = 0),
                  hovertemplate = "lower %{y:.4f}<extra></extra>") %>%
        add_trace(x = xs, y = rate * rel$upper[k], type = "scatter", mode = "lines", yaxis = "y2", name = "95% band",
                  legendgroup = "ci", fill = "tonexty", fillcolor = "rgba(22,163,74,0.13)",
                  line = list(color = "rgba(22,163,74,0)", width = 0), hovertemplate = "upper %{y:.4f}<extra></extra>")
    }
    # keep the axis in the factor's level order whatever order the traces were added in
    p %>% layout(xaxis = list(categoryorder = "array", categoryarray = levels(droplevels(factor(s$factor_name)))))
  })
  # ---- feature importance: Wald and spread straight after a fit, drop-one deviance on request ----
  glm_imp_quick <- reactive({
    m <- rv$glm_model
    req(m)
    mt_guard("Could not calculate feature importance", glm_importance_quick(m, rv$model_data[[1]]))
  })
  # drop-one results belong to one fitted model: shown only while that model is current
  glm_imp_drop_now <- reactive({
    d <- rv$glm_imp_drop; m <- rv$glm_model
    if (is.null(d) || is.null(m) || !identical(d$stamp, m$fitted_at)) NULL else d$table
  })
  glm_imp_eta <- function(m) {
    n <- length(m$included) + length(m$interactions)
    s <- n * max(1, 0.45 * m$fit_seconds)   # a warm-started refit takes roughly 40-50% of the full fit
    if (s < 90) sprintf("~%d s", ceiling(s / 10) * 10) else sprintf("~%d min", ceiling(s / 60))
  }
  output$glm_imp_ui <- renderUI({
    m <- rv$glm_model
    if (is.null(m)) return(p(class = "mt-empty-hint", "Fit the model to see which terms matter."))
    has_drop <- !is.null(glm_imp_drop_now())
    choices <- c("Wald χ² (share)" = "wald", "Relativity spread" = "spread")
    if (has_drop) choices <- c("Drop-one deviance (share)" = "drop", choices)
    # re-rendered only when the model or the drop-one results change: show the drop-one chart as soon as it exists
    sel <- if (has_drop) "drop" else isolate(input$glm_imp_measure)
    if (is.null(sel) || !sel %in% choices) sel <- choices[[1]]
    n_terms <- length(m$included) + length(m$interactions)
    tagList(
      div(class = "mt-ed-head", style = "align-items: center; gap: 14px; flex-wrap: wrap;",
          radioButtons("glm_imp_measure", NULL, inline = TRUE, choices = choices, selected = sel),
          if (!has_drop)
            actionButton("glm_imp_run", sprintf("Run drop-one check (%d refits, %s)", n_terms, glm_imp_eta(m)),
                         icon = icon("play"), class = "btn-default")
          else span(class = "mt-good", style = "padding: 3px 10px;", icon("circle-check"), " Drop-one check done for this fit")),
      div(class = "mt-empty-hint", style = "margin: 2px 0 8px;", uiOutput("glm_imp_note", inline = TRUE)),
      plotlyOutput("glm_imp_plot", height = paste0(max(260, 26 * n_terms + 70), "px")),
      uiOutput("glm_imp_table_ui"))
  })
  output$glm_imp_note <- renderUI({
    switch(req(input$glm_imp_measure),
           drop   = "Deviance increase when the term is taken out and the model refitted, as a share of the total: the GLM counterpart of the GBM's share of gain. Each term is measured with all the others in the model.",
           wald   = "Wald chi-square of the term's coefficients, from the fitted model (no refit). Usually close to the drop-one check, but it can understate a term with a large effect on a level that has little data: use the drop-one check for the final ranking.",
           spread = "How much the term moves the price: exposure-weighted standard deviation of its effect on log(prediction) over the modelling rows. ±10% means a typical policy's price moves about 10% with this term.")
  })
  output$glm_imp_plot <- renderPlotly({
    qi <- req(glm_imp_quick()); meas <- req(input$glm_imp_measure)
    if (meas == "drop") {
      dr <- req(glm_imp_drop_now())
      x <- merge(qi, dr, by = "key", sort = FALSE)
      plot_glm_importance(x, x$drop_share, "share", "Deviance increase (share of total)")
    } else if (meas == "wald") plot_glm_importance(qi, qi$wald_share, "share", "Wald chi-square (share of total)")
    else plot_glm_importance(qi, qi$spread, "spread", "Spread of the term's effect (log scale)")
  })
  output$glm_imp_table_ui <- renderUI({
    qi <- req(glm_imp_quick()); dr <- glm_imp_drop_now()
    x <- if (is.null(dr)) qi else merge(qi, dr, by = "key", sort = FALSE)
    x <- x[order(-(if (is.null(dr)) x$wald else x$dev_increase)), ]
    pv <- function(p) if (is.na(p)) "" else if (p < 1e-4) "<0.0001" else formatC(p, format = "f", digits = 4)
    sig <- function(p) if (is.na(p)) "" else if (p < 0.01) "mt-good" else if (p < 0.05) "mt-warn" else "mt-bad"
    tags$table(class = "table mt-sum-table", style = "margin-top: 8px;",
               tags$thead(tags$tr(tags$th(style = "text-align: left;", "Term"),
                                  tags$th(title = "Coefficients the term adds", "Parameters"),
                                  if (!is.null(dr)) tagList(tags$th(title = "Deviance increase when the term is dropped (divided by the dispersion)", "Drop-one χ²"),
                                                            tags$th("p-value"), tags$th("Share")),
                                  tags$th("Wald χ²"), tags$th("p-value"), tags$th("Share"),
                                  tags$th(title = "Typical price movement from this term", "Spread"))),
               tags$tbody(lapply(seq_len(nrow(x)), function(i) {
                 k <- x[i, ]
                 tags$tr(tags$td(style = "text-align: left;", k$term, if (k$kind == "interaction") span(class = "mt-empty-hint", " (interaction)")),
                         tags$td(k$params),
                         if (!is.null(dr)) tagList(tags$td(fmt_num(k$chisq, 1)), tags$td(span(class = sig(k$drop_p), pv(k$drop_p))),
                                                   tags$td(sprintf("%.1f%%", 100 * k$drop_share))),
                         tags$td(if (is.na(k$wald)) "" else fmt_num(k$wald, 1)), tags$td(span(class = sig(k$wald_p), pv(k$wald_p))),
                         tags$td(if (is.na(k$wald_share)) "" else sprintf("%.1f%%", 100 * k$wald_share)),
                         tags$td(sprintf("±%.1f%%", 100 * (exp(k$spread) - 1))))
               })))
  })
  observeEvent(input$glm_imp_run, {
    m <- rv$glm_model
    req(m)
    res <- mt_guard("Drop-one check failed", hints = "The full model is unchanged. Terms with levels that have no data can make a refit fail: group those levels.", {
      withProgress(message = "Drop-one check", value = 0, {
        glm_importance_drop_one(m, rv$model_data[[1]], progress = function(i, n, label)
          setProgress((i - 1) / n, detail = sprintf("Refit %d of %d: without %s", i, n, label)))
      })
    })
    if (is.null(res)) return()
    rv$glm_imp_drop <- list(stamp = m$fitted_at, table = res)
    if (!all(res$converged)) showNotification("Some refits did not converge: their drop-one figures are approximate.", type = "warning", duration = 8)
  })

  # ---- relativity check: relativities vs coefficients (every partition) and coefficients vs R's glm (modelling) ----
  relcheck <- reactive({
    m <- rv$glm_model; rel <- rv$glm_rel
    req(m, rel)
    resp <- m$response
    rows <- list()
    for (i in which(vapply(rv$model_data, nrow, integer(1)) > 0)) {
      d <- rv$model_data[[i]]
      p_rel <- glm_predict_from_rel(rel, m, d)
      rows[[length(rows) + 1]] <- cbind(partition = mt_partition_names[i],
                                        glm_check_row("A: relativity tables · B: coefficients", p_rel, rv$glm_pred[[i]], d[[resp]]))
    }
    if (!is.null(m$fitted) && length(m$fitted) == nrow(rv$model_data[[1]]))
      rows[[length(rows) + 1]] <- cbind(partition = "Modelling",
                                        glm_check_row("A: coefficients · B: R glm() fitted values", rv$glm_pred[[1]], m$fitted,
                                                      rv$model_data[[1]][[resp]]))
    do.call(rbind, rows)
  })
  output$glm_relcheck_ui <- renderUI({
    if (is.null(rv$glm_model)) return(p(class = "mt-empty-hint", "Fit the model to run the check."))
    ck <- relcheck()
    all_ok <- all(ck$pass)
    f2 <- function(x) fmt_num(x, 2)
    tagList(
      div(class = "mt-chip-row", style = "margin-bottom: 10px;",
          span(class = if (all_ok) "mt-good" else "mt-bad", style = "font-size: 13px; padding: 4px 12px;",
               icon(if (all_ok) "circle-check" else "triangle-exclamation"),
               if (all_ok) " PASS: the relativity tables reproduce every prediction" else " CHECK FAILED: see the rows marked below"),
          span(class = "mt-empty-hint", "Row-level tolerance 0.0001%. Prediction from relativities = base × factor relativities × interaction relativities × exposure.")),
      tags$table(class = "table mt-sum-table",
                 tags$thead(tags$tr(tags$th("Partition"), tags$th(style = "text-align: left;", "Comparison (A vs B)"),
                                    tags$th(title = "Number of policies compared", "Rows"),
                                    tags$th(title = "Sum of predictions from method A", "Total predicted (A)"),
                                    tags$th(title = "Sum of predictions from method B", "Total predicted (B)"),
                                    tags$th(title = "Sum of the actual response, for reference", "Actual total"),
                                    tags$th(title = "Largest |A / B - 1| over all rows", "Largest row difference"),
                                    tags$th("Result"))),
                 tags$tbody(lapply(seq_len(nrow(ck)), function(i) {
                   k <- ck[i, ]
                   tags$tr(tags$td(k$partition), tags$td(style = "text-align: left;", k$check), tags$td(fmt_num(k$rows)),
                           tags$td(f2(k$total_a)), tags$td(f2(k$total_b)), tags$td(f2(k$actual)),
                           tags$td(formatC(k$max_rel_diff, format = "e", digits = 1)),
                           tags$td(span(class = if (k$pass) "mt-good" else "mt-bad",
                                        if (k$pass) "pass" else paste(fmt_num(k$rows_off), "rows off"))))
                 }))))
  })

  # ---- base level + Excel tools above the relativity table ----
  output$glm_rel_tools_ui <- renderUI({
    f <- rv$glm_view; m <- rv$glm_model
    req(m, f %in% names(rv$glm_rel$factors))
    r <- rv$glm_rel$factors[[f]]
    default_base <- rv$factor_levels[[f]]$level[which.max(rv$factor_levels[[f]]$exposure)]
    div(class = "mt-rel-tools",
        selectInput("glm_base_pick", "Base level", choices = r$level, selected = r$level[r$is_base], width = "220px"),
        if (!identical(r$level[r$is_base], default_base))
          actionButton("glm_base_reset", paste0("Reset to ", default_base, " (most exposure)"), icon = icon("rotate-left")),
        downloadButton("glm_rel_xlsx", "This factor (Excel)", class = "btn-default"),
        span(class = "mt-empty-hint", "Click a row to make it the base. Changing the base only re-expresses the relativities; predictions stay the same."))
  })
  set_base <- function(f, lvl) {
    req(rv$glm_model, f %in% names(rv$glm_rel$factors))
    bo <- rv$base_override; bo[[f]] <- lvl; rv$base_override <- bo
  }
  observeEvent(input$glm_base_pick, {
    f <- rv$glm_view; r <- rv$glm_rel$factors[[f]]
    req(r, input$glm_base_pick %in% r$level, !identical(input$glm_base_pick, r$level[r$is_base]))
    set_base(f, input$glm_base_pick)
  }, ignoreInit = TRUE)
  observeEvent(input$glm_base_row, { req(input$glm_base_row$f == rv$glm_view); set_base(input$glm_base_row$f, input$glm_base_row$level) })
  observeEvent(input$glm_base_reset, { bo <- rv$base_override; bo[[rv$glm_view]] <- NULL; rv$base_override <- bo })
  # re-express the relativities (current and reference) whenever a base changes; the fit itself is untouched
  observeEvent(rv$base_override, {
    m <- isolate(rv$glm_model)
    if (!is.null(m)) rv$glm_rel <- glm_add_ci(glm_relativities(m, isolate(rv$factor_levels), rv$base_override), m)
    r <- isolate(rv$ref)
    if (!is.null(r)) {
      rr <- glm_relativities(r$model, isolate(rv$factor_levels), rv$base_override)
      if (!is.null(r$model$vcov)) rr <- glm_add_ci(rr, r$model)
      r$rel <- rr; rv$ref <- r
    }
  }, ignoreInit = TRUE)
  output$glm_rel_xlsx <- downloadHandler(
    filename = function() paste0("relativities_", rv$glm_view, ".xlsx"),
    content  = function(file) {
      sh <- glm_relativity_sheets(list(base = rv$glm_rel$base, factors = rv$glm_rel$factors[rv$glm_view], interactions = list()),
                                  rv$glm_model)
      writexl::write_xlsx(sh[setdiff(names(sh), "Index")], file)
    })
  output$exp_rel_status <- renderUI({
    m <- rv$glm_model
    if (is.null(m)) return(div(class = "mt-status", span(style = "color:red", "NO FITTED MODEL: fit one on the Model tab first")))
    n_f <- length(rv$glm_rel$factors); n_i <- length(rv$glm_rel$interactions)
    moved <- names(rv$base_override)[vapply(names(rv$base_override), function(f) !is.null(rv$base_override[[f]]), logical(1))]
    div(class = "mt-status", style = "margin-bottom: 10px;",
        span(style = "color:green", sprintf("%d FACTOR%s · %d INTERACTION%s · FITTED %s%s", n_f, if (n_f == 1) "" else "S",
                                            n_i, if (n_i == 1) "" else "S", format(m$fitted_at, "%H:%M:%S"),
                                            if (length(moved)) paste0(" · BASE CHANGED FOR ", paste(moved, collapse = ", ")) else "")))
  })
  output$glm_rel_all_xlsx <- downloadHandler(
    filename = function() paste0("relativities_", format(Sys.time(), "%Y%m%d_%H%M"), ".xlsx"),
    content  = function(file) {
      req(rv$glm_model)
      writexl::write_xlsx(glm_relativity_sheets(rv$glm_rel, rv$glm_model), file)
    })

  # ---- model report (as the GBM app's): HTML or PDF ----
  glm_report_factor_list <- function(which) {
    m <- rv$glm_model
    imp <- tryCatch(glm_imp_quick(), error = function(e) NULL)
    drop <- glm_imp_drop_now()
    ranked <- m$included
    if (!is.null(imp)) {
      v <- if (!is.null(drop)) drop$drop_share[match(imp$key, drop$key)] else imp$wald_share
      k <- imp$kind == "factor"
      ranked <- c(imp$term[k][order(-v[k])], setdiff(m$included, imp$term[k]))
    }
    if (identical(which, "all")) ranked <- c(ranked, stringr::str_sort(setdiff(names(rv$terms), ranked), numeric = TRUE))
    ranked
  }
  output$glm_report_status <- renderUI({
    m <- rv$glm_model
    if (is.null(m)) return(div(class = "mt-status", style = "margin-bottom: 8px;", span(style = "color:red", "NO FITTED MODEL: fit one on the Model tab first")))
    n_f <- length(glm_report_factor_list(input$glm_report_factors)); n_p <- length(input$glm_report_parts)
    div(class = "mt-status", style = "margin-bottom: 8px;",
        span(style = "color:green", sprintf("%d FACTORS · %d INTERACTION%s · %d PARTITION%s · RANKED BY %s%s", n_f, length(m$interactions),
                                            if (length(m$interactions) == 1) "" else "S", n_p, if (n_p == 1) "" else "S",
                                            if (is.null(glm_imp_drop_now())) "WALD χ²" else "DROP-ONE DEVIANCE",
                                            if (!is.null(rv$ref)) " · WITH REFERENCE MODEL" else "")),
        if (rv$fit_version != rv$terms_version) span(style = "color:#b45309; margin-left: 8px;", "(definition changed since this fit)"))
  })
  output$glm_report_dl <- downloadHandler(
    filename = function() paste0("glm_model_report_", format(Sys.time(), "%Y%m%d_%H%M"),
                                 if (identical(input$glm_report_format, "pdf")) ".pdf" else ".html"),
    content = function(file) {
      m <- rv$glm_model
      if (is.null(m)) {
        showNotification("Fit a model before creating the report.", type = "error", duration = 6)
        writeLines("No model fitted.", file); return(invisible())
      }
      parts <- sort(as.integer(input$glm_report_parts))
      if (!length(parts)) parts <- 1:3
      x <- list(model = m, rel = rv$glm_rel, pred = rv$glm_pred, data = rv$model_data, ref = rv$ref,
                imp_quick = tryCatch(glm_imp_quick(), error = function(e) NULL), imp_drop = glm_imp_drop_now(),
                factors = glm_report_factor_list(input$glm_report_factors), partitions = parts,
                model_type = rv$model_type, offset = rv$offset_factor)
      writer <- if (identical(input$glm_report_format, "pdf")) glm_write_report_pdf else glm_write_report_html
      res <- withProgress(message = "Creating model report", value = 0,
                          tryCatch(writer(file, x, function(v, d) setProgress(v, detail = d)), error = function(e) e))
      if (inherits(res, "error")) {
        mt_error_modal("Could not create the report", conditionMessage(res),
                       hints = "Try the other format, or fewer partitions / only the factors in the model.")
        stop(res)
      }
    })

  output$glm_rel_table_ui <- renderUI({
    f <- rv$glm_view; m <- rv$glm_model
    if (is.null(m)) return(p(class = "mt-empty-hint", "Fit the model to see relativities."))
    if (!f %in% names(rv$glm_rel$factors)) return(p(class = "mt-empty-hint", "This factor is not in the fitted model."))
    r <- rv$glm_rel$factors[[f]]; t <- m$terms[[f]]
    if (nrow(r) > MT_MAX_TABLE_LEVELS)
      return(p(class = "mt-empty-hint", icon("triangle-exclamation"),
               sprintf(" %s has %s levels: too many to list here (limit %s). Group its levels on the Factor mapping tab.",
                       f, formatC(nrow(r), format = "d", big.mark = ","), formatC(MT_MAX_TABLE_LEVELS, format = "d", big.mark = ","))))
    partners <- unlist(lapply(m$interactions, function(it) if (it$a == f) it$b else if (it$b == f) it$a))
    cols <- list(Level = r$level, `Exposure (modelling)` = fmt_num(r$exposure))
    if (isTRUE(t$var_on) && f %in% m$included)  cols[["Variate value"]] <- format(t$var_tb$value[match(r$level, t$var_tb$level)], trim = TRUE, drop0trailing = TRUE)
    if (isTRUE(t$cust_on) && f %in% m$included) cols[["Custom group"]]  <- t$cust_tb$group[match(r$level, t$cust_tb$level)]
    cols[["Relativity"]] <- formatC(r$relativity, format = "f", digits = 4)
    # bounds: 3 decimals normally; very large / small values in short scientific form so the table keeps its layout
    fmt_bound <- function(x) ifelse(!is.finite(x), "∞", ifelse(x >= 1000 | (x > 0 & x < 0.001),
                                                                   formatC(x, format = "e", digits = 1), formatC(x, format = "f", digits = 3)))
    if (!is.null(r$lower)) cols[["95% interval"]] <- ifelse(r$is_base, "base",
                                                     # (almost) no data: the level's own estimate is meaningless and its interval explodes
                                                     ifelse(r$exposure <= 0 | !is.finite(r$upper / r$lower) | r$upper / r$lower > 1e4,
                                                            "too little data to estimate",
                                                            paste0(fmt_bound(r$lower), " – ", fmt_bound(r$upper))))
    if (!is.null(rv$ref) && !is.null(rv$ref$rel$factors[[f]])) {
      rr <- rv$ref$rel$factors[[f]]
      cols[["Reference"]] <- formatC(rr$relativity[match(r$level, rr$level)], format = "f", digits = 4)
    }
    div(class = "mt-rel-table",
        tags$table(class = "table mt-sum-table",
                   tags$thead(tags$tr(lapply(names(cols), tags$th))),
                   tags$tbody(lapply(seq_len(nrow(r)), function(i)
                     tags$tr(`data-f` = f, `data-l` = r$level[i], title = if (r$is_base[i]) "Base level" else "Click to make this the base level",
                             lapply(names(cols), function(cn) tags$td(class = if (r$is_base[i]) "mt-base-row", cols[[cn]][i])))))),
        p(class = "mt-empty-hint", "Base level (relativity 1) in blue. By default it is the level with the most modelling exposure.",
          if (length(partners)) paste0(" Includes the interaction with ", paste(partners, collapse = " and "),
                                       " at ", if (length(partners) > 1) "their" else "its", " base level (see Interaction relativities below).")))
  })

  # ---- interaction relativities of the viewed factor ----
  view_inters <- reactive({
    m <- rv$glm_model; f <- rv$glm_view
    if (is.null(m) || is.null(f) || !length(m$interactions)) return(character(0))
    labs <- vapply(m$interactions, glm_inter_label, character(1))
    labs[vapply(m$interactions, function(it) f %in% c(it$a, it$b), logical(1))]
  })
  output$glm_inter_view_ui <- renderUI({
    labs <- view_inters()
    if (!length(labs)) return(NULL)
    sel <- if (!is.null(rv$inter_view) && rv$inter_view %in% labs) rv$inter_view else labs[1]
    mt_card("Interaction relativities", icon_name = "shuffle",
            subtitle = textOutput("glm_inter_subtitle", inline = TRUE),
            div(class = "mt-ed-head mt-chart-bar",
                if (length(labs) > 1) selectInput("glm_inter_pick", NULL, choices = labs, selected = sel, width = "360px")
                else span(class = "mt-map-head-name", style = "font-size: 14px;", labs),
                shinyWidgets::radioGroupButtons("glm_inter_style", NULL, size = "sm",
                                                choices = c("Actual vs rebased" = "ave", "Interaction only" = "lines", "Heatmap" = "heat"),
                                                selected = isolate(if (is.null(input$glm_inter_style)) "ave" else input$glm_inter_style)),
                uiOutput("glm_inter_x_ui", inline = TRUE),
                conditionalPanel("input.glm_inter_style == 'ave'",
                                 radioButtons("glm_inter_part", NULL, inline = TRUE,
                                              choices = c("Modelling" = 1, "Holdout" = 2, "Validation" = 3),
                                              selected = isolate(if (is.null(input$glm_inter_part)) 1 else input$glm_inter_part)),
                                 checkboxInput("glm_inter_actual", "Actual", value = isolate(if (is.null(input$glm_inter_actual)) TRUE else input$glm_inter_actual)))),
            plotlyOutput("glm_inter_plot", height = 520),
            p(class = "mt-empty-hint", style = "margin-top: 6px;",
              "Prediction = base × factor relativities × interaction relativities. The factor tables above already include ",
              "each interaction at the partner factor's base level; \"Interaction only\" and the heatmap show just how the effect ",
              "changes away from it."))
  })
  # the interaction currently shown, and the factor on its x-axis (defaults to the factor being viewed)
  inter_current <- reactive({
    labs <- view_inters()
    req(length(labs))
    lab <- if (length(labs) > 1 && isTruthy(input$glm_inter_pick) && input$glm_inter_pick %in% labs) input$glm_inter_pick else labs[1]
    r <- rv$glm_rel$interactions[[lab]]
    req(r)
    list(lab = lab, r = r, it = rv$glm_model$interactions[[r$it_index[1]]])
  })
  output$glm_inter_x_ui <- renderUI({
    it <- inter_current()$it
    ch <- c(it$a, it$b)
    sel <- isolate(input$glm_inter_x)
    if (is.null(sel) || !sel %in% ch) sel <- if (isTRUE(rv$glm_view %in% ch)) rv$glm_view else it$a
    div(style = "display: inline-flex; align-items: center; gap: 6px;",
        span(class = "mt-map-head-meta", icon("right-left"), " x-axis"),
        shinyWidgets::radioGroupButtons("glm_inter_x", NULL, size = "sm", choices = ch, selected = sel))
  })
  inter_axes <- reactive({
    cur <- inter_current(); it <- cur$it
    flip <- isTruthy(input$glm_inter_x) && identical(input$glm_inter_x, it$b)
    if (flip) list(x = it$b, s = it$a, x_col = "level_b", s_col = "level_a")
    else      list(x = it$a, s = it$b, x_col = "level_a", s_col = "level_b")
  })
  output$glm_inter_subtitle <- renderText({
    switch(if (is.null(input$glm_inter_style)) "ave" else input$glm_inter_style,
           ave   = "Solid: actual · dashed: rebased relativity = both factor relativities × interaction relativity × average actual rate",
           lines = "Pure interaction effect: 1 along each factor's base level",
           heat  = "Pure interaction effect: 1 along each factor's base level")
  })
  output$glm_inter_plot <- renderPlotly({
    cur <- inter_current(); r <- cur$r; it <- cur$it; lab <- cur$lab
    ax <- inter_axes()
    xl <- unique(r[[ax$x_col]]); sl <- unique(r[[ax$s_col]])
    style <- if (is.null(input$glm_inter_style)) "ave" else input$glm_inter_style
    if (length(xl) * length(sl) > 20000 || max(length(xl), length(sl)) > MT_MAX_CHART_LEVELS)
      return(mt_message_plot(sprintf("%s: %s x %s levels, too many to chart", lab, length(xl), length(sl)),
                             "Group the levels on the Factor mapping tab, or use variate / custom groups in the interaction."))
    if (style != "heat" && length(sl) > MT_MAX_TWO_WAY_LINES)
      return(mt_message_plot(sprintf("%s has %d levels: too many lines (limit %d)", ax$s, length(sl), MT_MAX_TWO_WAY_LINES),
                             sprintf("Put %s on the x-axis instead, or switch to the heatmap view.", ax$s)))
    if (style == "ave") {
      i <- as.integer(if (is.null(input$glm_inter_part)) 1 else input$glm_inter_part)
      d1 <- rv$model_data[[1]]; resp <- input$select_response; expo <- input$select_exposure
      rate <- sum(d1[[resp]]) / sum(d1[[expo]])
      s <- mt_guard("Could not build the interaction chart",
                    glm_inter_summary(rv$model_data[[i]], it, resp, expo, rv$glm_rel, rate))
      req(s)
      return(plot_glm_inter_ave(s, ax$x, ax$s, ax$x_col, ax$s_col, rv$model_type,
                                show_actual = !isFALSE(input$glm_inter_actual)))
    }
    ci <- if (!is.null(r$lower)) sprintf("<br>95%%: %.3f – %.3f", r$lower, r$upper) else ""
    if (style == "lines") {
      cols <- rep(mt_series_palette, length.out = length(sl))
      p <- plot_ly()
      for (j in seq_along(sl)) {
        d <- r[r[[ax$s_col]] == sl[j], ]
        p <- p %>% add_trace(x = factor(d[[ax$x_col]], levels = xl), y = d$relativity, type = "scatter", mode = "lines+markers",
                             name = sl[j], line = list(color = cols[j], width = 1.8), marker = list(color = cols[j], size = 4),
                             hovertemplate = paste0(ax$s, " ", sl[j], "<br>", ax$x, " %{x}<br>Relativity %{y:.4f}<extra></extra>"))
      }
      p %>% layout(font = list(family = mt_font_family, size = 12, color = mt_chart_colours$text),
                   xaxis = list(title = ax$x, type = "category", categoryorder = "array", categoryarray = xl),
                   yaxis = list(title = "Interaction relativity", gridcolor = mt_chart_colours$grid, zeroline = FALSE),
                   legend = list(title = list(text = paste0(ax$s, ": "))), hovermode = "closest") %>%
        mt_plotly_config(paste0("interaction_", ax$x, "_by_", ax$s))
    } else {
      # rows of the matrix: the factor on the y-axis (the one not on x)
      ord <- order(match(r[[ax$x_col]], xl), match(r[[ax$s_col]], sl))
      rr  <- r[ord, ]
      z   <- matrix(rr$relativity, nrow = length(sl), ncol = length(xl))
      txt <- matrix(sprintf("%s %s<br>%s %s<br>Relativity %.4f%s", it$a, rr$level_a, it$b, rr$level_b, rr$relativity,
                            if (nzchar(ci[1])) ci[ord] else ""),
                    nrow = length(sl), ncol = length(xl))
      lim <- max(abs(log(range(z, na.rm = TRUE))))
      plot_ly(x = factor(xl, levels = xl), y = factor(sl, levels = sl), z = log(z), type = "heatmap", text = txt, hoverinfo = "text",
              colorscale = list(c(0, "#2563eb"), c(0.5, "#f8fafc"), c(1, "#e11d48")), zmin = -lim, zmax = lim,
              colorbar = list(title = "Relativity", tickvals = log(c(0.8, 0.9, 1, 1.1, 1.25)), ticktext = c("0.8", "0.9", "1", "1.1", "1.25"))) %>%
        layout(font = list(family = mt_font_family, size = 12, color = mt_chart_colours$text),
               xaxis = list(title = ax$x, type = "category"), yaxis = list(title = ax$s, type = "category"),
               margin = list(l = 110, r = 20, t = 20, b = 90)) %>%
        mt_plotly_config(paste0("interaction_", ax$x, "_by_", ax$s))
    }
  })

  # ---- coefficients ----
  output$glm_coef_table <- DT::renderDT({
    m <- rv$glm_model
    req(m)
    ct <- m$coef_table
    ct$exp_estimate <- exp(ct$estimate)
    ct <- ct[, c("term", "estimate", "exp_estimate", "std_error", "statistic", "p_value")]
    names(ct) <- c("Term", "Estimate", "exp(Estimate)", "Std. error", if (m$model_type %in% c(1, 4)) "z value" else "t value", "p-value")
    DT::datatable(ct, rownames = FALSE, options = list(pageLength = 100, dom = "ftip", scrollX = TRUE)) %>%
      DT::formatRound(c("Estimate", "exp(Estimate)", "Std. error", names(ct)[5]), 4) %>%
      DT::formatSignif("p-value", 3) %>%
      DT::formatStyle("p-value", color = DT::styleInterval(c(0.01, 0.05), c("#067647", "#b54708", "#b42318")), fontWeight = "600")
  })

  # ---- formula ----
  output$glm_formula_txt <- renderText({
    if (!length(rv$terms)) "Create the modelling dataset first." else glm_formula_text(rv$terms, rv$inters)
  })
  observeEvent(input$glm_formula_apply, mt_guard("Could not apply the formula", hints = "Check the formula text: factor names must match the names on the Model tab.", restore = c("terms", "inters", "terms_version"), {
    if (!length(rv$terms)) { mt_alert(title = "Create the modelling dataset first", type = "error"); return() }
    txt <- input$glm_formula_in
    req(nzchar(trimws(txt)))
    pf <- glm_parse_formula(txt)
    tl <- rv$terms
    use     <- intersect(names(pf$terms), names(tl))
    unknown <- setdiff(names(pf$terms), names(tl))
    for (f in names(tl)) tl[[f]]$include <- FALSE
    for (f in use) {
      p <- pf$terms[[f]]
      tl[[f]]$include <- TRUE; tl[[f]]$var_on <- p$var; tl[[f]]$var_order <- as.integer(p$order); tl[[f]]$cust_on <- p$cust
    }
    ok_inter  <- Filter(function(it) all(c(it$a, it$b) %in% names(tl)), pf$interactions)
    bad_inter <- Filter(function(it) !all(c(it$a, it$b) %in% names(tl)), pf$interactions)
    rv$inters <- ok_inter
    set_terms(tl)
    probs <- c(unlist(lapply(use, function(f) glm_term_problem(f, tl[[f]]))),
               unlist(lapply(ok_inter, glm_inter_problem, terms = tl)))
    msg <- c(if (length(unknown)) paste("Not a factor in this dataset, skipped:", paste(unknown, collapse = ", ")),
             if (length(bad_inter)) paste("Interactions with a factor not in this dataset, skipped:",
                                          paste(vapply(bad_inter, glm_inter_term, ""), collapse = ", ")),
             if (length(pf$skipped)) paste("Not supported (three-way, or a power inside an interaction), skipped:", paste(pf$skipped, collapse = ", ")),
             if (length(probs)) paste(c("Still to fill in before fitting:", probs), collapse = "\n"))
    mt_alert(title = sprintf("%d factor%s and %d interaction%s set from the formula", length(use), if (length(use) == 1) "" else "s",
                             length(ok_inter), if (length(ok_inter) == 1) "" else "s"),
               text = paste(msg, collapse = "\n\n"), type = if (length(msg)) "warning" else "success")
  }))

  # ---- save / load the model definition ----
  output$glm_def_save <- downloadHandler(
    filename = "glm_model_definition.rds",
    content = function(file) {
      req(length(rv$terms))
      saveRDS(list(tool = "GLM Modelling Studio", type = "model definition", terms = rv$terms, interactions = rv$inters,
                   tweedie_p = tweedie_p(), factor_raw = rv$factor_raw), file)
    }
  )
  observeEvent(input$glm_def_load, mt_guard("Could not load the model definition", hints = "The file may come from a different dataset: its factors or levels may not match.", restore = c("terms", "inters", "terms_version"), {
    if (!length(rv$terms)) { mt_alert(title = "Create the modelling dataset first", type = "error"); return() }
    s <- tryCatch(readRDS(input$glm_def_load$datapath), error = function(e) NULL)
    if (!is.list(s) || is.null(s$terms)) {
      mt_alert(title = "Not a model definition", text = "Choose a file saved with 'Save definition'.", type = "error"); return()
    }
    tl <- rv$terms; partial <- character(0)
    use <- intersect(names(s$terms), names(tl))
    for (f in names(tl)) tl[[f]]$include <- FALSE
    for (f in use) {
      st <- s$terms[[f]]; t <- tl[[f]]
      t$include <- isTRUE(st$include); t$var_on <- isTRUE(st$var_on); t$cust_on <- isTRUE(st$cust_on)
      t$var_order <- if (is.null(st$var_order)) 1L else as.integer(st$var_order)
      iv <- glm_match_levels(st$var_tb$level, t$var_tb$level);  t$var_tb$value[iv[!is.na(iv)]] <- st$var_tb$value[!is.na(iv)]
      ic <- glm_match_levels(st$cust_tb$level, t$cust_tb$level); t$cust_tb$group[ic[!is.na(ic)]] <- st$cust_tb$group[!is.na(ic)]
      if (anyNA(iv) || length(unique(iv)) < nrow(t$var_tb)) partial <- c(partial, f)
      tl[[f]] <- t
    }
    si <- if (is.null(s$interactions)) list() else s$interactions
    rv$inters <- Filter(function(it) all(c(it$a, it$b) %in% names(tl)), si)
    set_terms(tl)
    if (!is.null(s$tweedie_p)) updateNumericInput(session, "glm_tweedie_p", value = s$tweedie_p)
    missing <- setdiff(names(s$terms), names(tl))
    lost <- length(si) - length(rv$inters)
    msg <- c(if (length(missing)) paste("Not in this dataset, skipped:", paste(missing, collapse = ", ")),
             if (lost) paste(lost, "interaction(s) use a factor not in this dataset and were skipped"),
             if (length(partial)) paste("Levels differ from the saved definition (check them):", paste(partial, collapse = ", ")))
    mt_alert(title = sprintf("Definition loaded for %d factors", length(use)), text = paste(msg, collapse = "\n\n"),
               type = if (length(msg)) "warning" else "success")
  }))

  # ---- old variate / custom workbooks (one or several files; tabs named by raw or model name) ----
  observeEvent(input$glm_terms_xlsx, mt_guard("Could not load the variate / custom workbook", hints = "Check the workbook layout: one tab per factor with the level and value / group columns.", restore = c("terms", "inters", "terms_version"), {
    if (!length(rv$terms)) { mt_alert(title = "Create the modelling dataset first", type = "error"); return() }
    files <- input$glm_terms_xlsx
    tl <- rv$terms; n_var <- 0; n_cust <- 0; skipped <- character(0); partial <- character(0)
    for (k in seq_len(nrow(files))) {
      wb <- tryCatch(read_term_workbook(files$datapath[k]), error = function(e) NULL)
      if (is.null(wb)) { skipped <- c(skipped, files$name[k]); next }
      for (s in names(wb)) {
        e <- wb[[s]]
        f <- model_name_of(s)
        if (is.null(e) || is.na(f)) { skipped <- c(skipped, paste0(s, " (", files$name[k], ")")); next }
        if (e$kind == "variate") {
          i <- glm_match_levels(e$level, tl[[f]]$var_tb$level)
          tl[[f]]$var_tb$value[i[!is.na(i)]] <- e$value[!is.na(i)]; n_var <- n_var + 1
        } else {
          i <- glm_match_levels(e$level, tl[[f]]$cust_tb$level)
          tl[[f]]$cust_tb$group[i[!is.na(i)]] <- e$group[!is.na(i)]; n_cust <- n_cust + 1
        }
        n_missing <- nrow(tl[[f]]$var_tb) - length(unique(i[!is.na(i)]))
        if (n_missing > 0) partial <- c(partial, sprintf("%s %s: %d level%s not in the file", f, e$kind, n_missing, if (n_missing > 1) "s" else ""))
      }
    }
    set_terms(tl)
    msg <- c("Switch the tables on with V / C in the factor list, or apply the matching formula on the Formula tab.",
             if (length(partial)) paste(c("Levels kept at their default:", partial), collapse = "\n"),
             if (length(skipped)) paste("Not matched to a factor, skipped:", paste(skipped, collapse = ", ")))
    mt_alert(title = sprintf("%d variate and %d custom table%s loaded", n_var, n_cust, if (n_cust == 1) "" else "s"),
               text = paste(msg, collapse = "\n\n"), type = if (length(skipped) || length(partial)) "warning" else "success")
  }))

  # ---- variate / custom editor ----
  ed_level_stats <- reactive({
    f <- rv$ed_f
    req(f, rv$data_prepared)
    d  <- rv$model_data[[1]]
    lv <- rv$terms[[f]]$var_tb$level
    e  <- tapply(d[[input$select_exposure]], d[[f]], sum); r <- tapply(d[[input$select_response]], d[[f]], sum)
    out <- data.frame(level = lv, exposure = as.numeric(e[lv]), res_sum = as.numeric(r[lv]), stringsAsFactors = FALSE)
    out$exposure[is.na(out$exposure)] <- 0; out$res_sum[is.na(out$res_sum)] <- 0
    out
  })
  ed_tools <- function(kind) {
    div(class = "mt-map-tools",
        tags$button(type = "button", class = "btn btn-default mt-copy-btn", `data-target` = paste0("ed_", kind, "_table"),
                    title = "Copy the table, ready to paste into Excel", icon("copy"), span("Copy table")),
        downloadButton(paste0("ed_", kind, "_xlsx"), "Excel", class = "btn-default"),
        fileInput(paste0("ed_", kind, "_upload"), NULL, buttonLabel = tagList(icon("file-arrow-up"), "Upload"),
                  accept = c(".xlsx", ".xls")),
        if (kind == "var") actionButton("ed_var_reset", "Default values", icon = icon("rotate-left"))
        else tagList(actionButton("ed_cust_reset", "One group per level", icon = icon("rotate-left")),
                     actionButton("ed_cust_other", "All to 'Other'", icon = icon("object-group"))))
  }
  open_editor <- function(f) {
    req(f %in% names(rv$terms))
    t <- rv$terms[[f]]
    if (nrow(t$var_tb) > MT_MAX_MAP_LEVELS) {
      mt_error_modal(sprintf("%s has too many levels to edit", f),
                     msg = sprintf("%s levels; the variate / custom tables are limited to %s.",
                                   formatC(nrow(t$var_tb), format = "d", big.mark = ","), formatC(MT_MAX_MAP_LEVELS, format = "d", big.mark = ",")),
                     hints = c("Band or group the factor on the <b>Factor mapping</b> tab first, then create the modelling dataset again.",
                               "Or leave it out of the model."))
      return(invisible())
    }
    rv$ed_f <- f; rv$ed_var <- t$var_tb; rv$ed_cust <- t$cust_tb; rv$ed_token <- rv$ed_token + 1
    rv$ed_full <- NULL
    rv$glm_view <- f
    note <- div(class = "mt-map-note", icon("lock"),
                " Levels are locked. Type in the last column, or copy a column from Excel, click the first cell to fill and press Ctrl+V.")
    showModal(modalDialog(
      title = div(class = "mt-map-title", icon("sliders"), span("Factor terms"), tags$b(f),
                  span(class = "mt-map-head-meta", paste(nrow(t$var_tb), "levels"))),
      size = "l", easyClose = FALSE,
      div(class = "mt-glm-modal",
          div(class = "mt-ed-head",
              checkboxInput("ed_simple", tagList(span(class = "mt-vc mt-s on", "S"), " Simple: fit the factor's own levels"),
                            isTRUE(t$include) && !isTRUE(t$var_on) && !isTRUE(t$cust_on)),
              uiOutput("ed_mode_ui")),
          div(class = "mt-ed-head mt-ed-preview",
              radioButtons("ed_scale", "Chart scale", inline = TRUE, selected = "rel",
                           choices = c("Relativity (base = 1)" = "rel", "Rate" = "rate")),
              actionButton("ed_full_preview", "Preview in full model", icon = icon("play"), class = "btn-primary"),
              uiOutput("ed_full_info")),
          tabsetPanel(id = "ed_tab", selected = if (isTRUE(t$cust_on) && !isTRUE(t$var_on)) "cust" else "var",
                      tabPanel(tagList(span(class = "mt-vc mt-v on", "V"), " Variate"), value = "var",
                               div(class = "mt-ed-head",
                                   checkboxInput("ed_var_on", "Use variate (fit a curve over the values)", t$var_on),
                                   radioButtons("ed_var_order", "Polynomial order", inline = TRUE, selected = t$var_order,
                                                choices = c("Linear" = 1, "Quadratic" = 2, "Cubic" = 3))),
                               fluidRow(column(5, ed_tools("var"), uiOutput("ed_var_table_ui"), note),
                                        column(7, mt_section("One-way fit on the modelling data"),
                                               plotlyOutput("ed_var_plot", height = 440)))),
                      tabPanel(tagList(span(class = "mt-vc mt-c on", "C"), " Custom"), value = "cust",
                               div(class = "mt-ed-head", checkboxInput("ed_cust_on", "Use custom groups", t$cust_on)),
                               fluidRow(column(5, ed_tools("cust"), uiOutput("ed_cust_table_ui"), note),
                                        column(7, mt_section("One-way fit on the modelling data"),
                                               plotlyOutput("ed_cust_plot", height = 440)))))),
      footer = tagList(modalButton("Cancel"),
                       actionButton("ed_apply", "Apply", icon = icon("check"), class = "btn-success"))
    ))
  }
  # live summary of how the factor will be fitted with the editor's current settings
  output$ed_mode_ui <- renderUI({
    req(rv$ed_f, rv$ed_var)
    n_lv <- nrow(rv$ed_var)
    v <- isTRUE(input$ed_var_on); cu <- isTRUE(input$ed_cust_on)
    if (isTRUE(input$ed_simple))
      return(span(class = "mt-mode-chip plain", sprintf("Fitted as: simple, own %d levels (%d parameters)", n_lv, n_lv - 1)))
    if (!v && !cu)
      return(span(class = "mt-mode-chip", "Not in the model: tick Simple, or use the variate or custom tab"))
    ord <- if (isTruthy(input$ed_var_order)) as.integer(input$ed_var_order) else 1L
    n_grp <- length(unique(rv$ed_cust$group[!is.na(rv$ed_cust$group)]))
    parts <- c(if (v) sprintf("variate, %s (%d parameter%s)", c("linear", "quadratic", "cubic")[ord], ord, if (ord > 1) "s" else ""),
               if (cu) sprintf("custom, %d group%s (%d parameter%s)", n_grp, if (n_grp == 1) "" else "s", n_grp - 1, if (n_grp - 1 == 1) "" else "s"))
    span(class = paste("mt-mode-chip", if (cu && n_grp < 2) "stale" else if (v) "var" else "cust"),
         if (cu && n_grp < 2) icon("triangle-exclamation"),
         paste0(" Fitted as: ", paste(parts, collapse = " + "),
                if (cu && n_grp < 2) ". One custom group adds nothing: switch Custom off or use at least two groups" else ""))
  })
  observeEvent(input$glm_edit,         open_editor(input$glm_edit))
  observeEvent(input$glm_edit_current, open_editor(rv$glm_view))
  # Simple excludes variate and custom (and the other way round)
  observeEvent(input$ed_simple, {
    if (isTRUE(input$ed_simple)) { updateCheckboxInput(session, "ed_var_on", value = FALSE); updateCheckboxInput(session, "ed_cust_on", value = FALSE) }
  }, ignoreInit = TRUE)
  observeEvent(input$ed_var_on,  { if (isTRUE(input$ed_var_on))  updateCheckboxInput(session, "ed_simple", value = FALSE) }, ignoreInit = TRUE)
  observeEvent(input$ed_cust_on, { if (isTRUE(input$ed_cust_on)) updateCheckboxInput(session, "ed_simple", value = FALSE) }, ignoreInit = TRUE)

  ed_table_html <- function(kind, tb, st) {
    col  <- if (kind == "var") "value" else "group"
    vals <- tb[[col]]
    esc  <- function(x) htmltools::htmlEscape(ifelse(is.na(x), "", as.character(x)), attribute = TRUE)
    txt  <- if (kind == "var") ifelse(is.na(vals), "", format(vals, trim = TRUE, drop0trailing = TRUE, scientific = FALSE)) else vals
    expo <- st$exposure[match(tb$level, st$level)]
    share <- expo / sum(expo)
    rows <- sprintf('<tr%s><td class="mt-locked">%s</td><td class="mt-num" data-v="%s">%s</td><td class="mt-new-cell"><input class="mt-new" value="%s" data-orig="%s" spellcheck="false"></td></tr>',
                    ifelse(is.na(vals) | txt == "", ' class="mt-missing"', ""), esc(tb$level),
                    format(expo, scientific = FALSE, trim = TRUE),
                    paste0(fmt_num(expo), " · ", formatC(100 * share, format = "f", digits = 1), "%"),
                    esc(txt), esc(txt))
    HTML(sprintf('<div class="mt-map-table-wrap"><table id="ed_%s_table" class="mt-map-table mt-edit-table" data-name="%s" data-token="%s"><thead><tr><th data-col="level">Level%s</th><th data-col="exposure">Exposure</th><th data-col="%s">%s</th></tr></thead><tbody>%s</tbody></table></div>',
                 kind, kind, rv$ed_token, as.character(icon("lock")), col, if (kind == "var") "Variate value" else "Custom group",
                 paste(rows, collapse = "")))
  }
  output$ed_var_table_ui  <- renderUI({ rv$ed_token; tb <- isolate(rv$ed_var);  req(tb); ed_table_html("var",  tb, isolate(ed_level_stats())) })
  output$ed_cust_table_ui <- renderUI({ rv$ed_token; tb <- isolate(rv$ed_cust); req(tb); ed_table_html("cust", tb, isolate(ed_level_stats())) })

  observeEvent(input$ed_values, {
    v <- input$ed_values
    req(identical(as.character(v$token), as.character(rv$ed_token)))
    vals <- trimws(as.character(unlist(lapply(v$values, function(x) if (is.null(x)) "" else x))))
    if (v$name == "var") {
      tb <- rv$ed_var; req(length(vals) == nrow(tb))
      num <- suppressWarnings(as.numeric(vals))
      bad <- vals != "" & is.na(num)
      if (any(bad)) showNotification(paste("Not a number, left blank:", paste(head(vals[bad], 5), collapse = ", ")), type = "warning")
      tb$value <- num; rv$ed_var <- tb
    } else {
      tb <- rv$ed_cust; req(length(vals) == nrow(tb))
      tb$group <- ifelse(vals == "", NA_character_, vals); rv$ed_cust <- tb
    }
  })
  observeEvent(input$ed_var_reset,  { tb <- rv$ed_var;  tb$value <- glm_default_variate(tb$level); rv$ed_var <- tb;  rv$ed_token <- rv$ed_token + 1 })
  observeEvent(input$ed_cust_reset, { tb <- rv$ed_cust; tb$group <- tb$level;                      rv$ed_cust <- tb; rv$ed_token <- rv$ed_token + 1 })
  observeEvent(input$ed_cust_other, { tb <- rv$ed_cust; tb$group <- "Other";                       rv$ed_cust <- tb; rv$ed_token <- rv$ed_token + 1 })

  ed_download <- function(kind) downloadHandler(
    filename = function() paste0(rv$ed_f, if (kind == "var") "_variate.xlsx" else "_custom.xlsx"),
    content  = function(file) {
      st <- ed_level_stats()
      tb <- if (kind == "var") rv$ed_var else rv$ed_cust
      out <- data.frame(level = tb$level, exposure = st$exposure[match(tb$level, st$level)])
      if (kind == "var") out$value <- tb$value else out$group <- tb$group
      writexl::write_xlsx(setNames(list(out), xl_sheet_names(rv$ed_f)), file)
    })
  output$ed_var_xlsx  <- ed_download("var")
  output$ed_cust_xlsx <- ed_download("cust")
  ed_upload <- function(kind, up) {
    wb <- tryCatch(read_term_workbook(up$datapath), error = function(e) NULL)
    want <- if (kind == "var") "variate" else "custom"
    e <- Filter(function(x) !is.null(x) && x$kind == want, wb)
    if (!length(e)) {
      showNotification(sprintf("No %s table found: the sheet needs a level column and a %s column", want,
                               if (kind == "var") "'value' (or variate_level_all)" else "'group' (or custom_level_all)"), type = "error")
      return()
    }
    e <- if (!is.null(e[[rv$ed_f]])) e[[rv$ed_f]] else e[[1]]
    tb <- if (kind == "var") rv$ed_var else rv$ed_cust
    i  <- glm_match_levels(e$level, tb$level)
    if (kind == "var") { tb$value[i[!is.na(i)]] <- e$value[!is.na(i)]; rv$ed_var <- tb }
    else               { tb$group[i[!is.na(i)]] <- e$group[!is.na(i)]; rv$ed_cust <- tb }
    rv$ed_token <- rv$ed_token + 1
    showNotification(sprintf("%d of %d levels loaded from the file", length(unique(i[!is.na(i)])), nrow(tb)), type = "message")
  }
  observeEvent(input$ed_var_upload,  ed_upload("var",  input$ed_var_upload))
  observeEvent(input$ed_cust_upload, ed_upload("cust", input$ed_cust_upload))

  ed_preview_plot <- function(kind) {
    st <- ed_level_stats()
    f  <- rv$ed_f
    if (nrow(st) > MT_MAX_CHART_LEVELS) return(mt_too_many_levels_plot(f, nrow(st)))
    t  <- rv$terms[[f]]
    t$var_tb <- rv$ed_var; t$cust_tb <- rv$ed_cust
    t$var_order <- if (isTruthy(input$ed_var_order)) as.integer(input$ed_var_order) else t$var_order
    one <- t; one$var_on <- kind == "var"; one$cust_on <- kind == "cust"
    fit1 <- glm_oneway_preview(st, one, rv$model_type, tweedie_p())
    both <- isTRUE(input$ed_var_on) && isTRUE(input$ed_cust_on)
    fit2 <- if (both) { b <- t; b$var_on <- TRUE; b$cust_on <- TRUE; glm_oneway_preview(st, b, rv$model_type, tweedie_p()) } else NA_real_
    s <- data.frame(factor_name = factor(st$level, levels = st$level), exposure = st$exposure,
                    actual = ifelse(st$exposure > 0, st$res_sum / st$exposure, NA_real_), fit = fit1, both = fit2)
    rate   <- sum(st$res_sum) / sum(st$exposure)          # average actual rate of the modelling data
    b_i    <- which.max(st$exposure)                       # base level: most exposure, as in the relativity tables
    as_rel <- identical(input$ed_scale, "rel")
    # relativity scale: every line divided by its own value at the base level
    if (as_rel) for (cn in c("actual", "fit", "both")) s[[cn]] <- s[[cn]] / s[[cn]][b_i]
    # full-model preview (and the current fitted model) are relativities: on the rate scale they are rebased like the factor view
    fp  <- rv$ed_full
    cur <- if (!is.null(rv$glm_model)) rv$glm_rel$factors[[f]] else NULL
    mult <- if (as_rel) 1 else rate
    if (!is.null(fp)) {
      k <- match(st$level, fp$rel$level)
      s$full <- fp$rel$relativity[k] * mult; s$full_lo <- fp$rel$lower[k] * mult; s$full_hi <- fp$rel$upper[k] * mult
    }
    if (!is.null(cur)) s$current <- cur$relativity[match(st$level, cur$level)] * mult
    lab <- if (kind == "var") paste0("One-way variate fit (", c("linear", "quadratic", "cubic")[t$var_order], ")") else "One-way custom fit"
    lines <- list(list(col = "actual", name = "Actual", colour = mt_chart_colours$actual),
                  list(col = "fit", name = lab, colour = if (kind == "var") "#4f46e5" else "#0d9488"))
    if (both) lines <- c(lines, list(list(col = "both", name = "One-way variate + custom", colour = "#16a34a", dash = "dash")))
    if (!is.null(fp))  lines <- c(lines, list(list(col = "full", name = "Full model with these settings", colour = "#0f172a",
                                                   symbol = "diamond")))
    if (!is.null(cur)) lines <- c(lines, list(list(col = "current", name = "Current fitted model", colour = "#94a3b8", dash = "dot")))
    p <- mt_oneway_plot(s, f, lines) %>% mt_set_rate_label(rv$model_type) %>%
      layout(margin = list(l = 50, r = 50, t = 30, b = 50), font = list(size = 10.5),
             xaxis = list(title = list(text = NULL)))
    if (as_rel) p <- p %>% layout(yaxis2 = list(title = list(text = paste0("Relativity (base ", st$level[b_i], " = 1)")), rangemode = "normal"))
    # 95% band of the full-model preview
    if (!is.null(fp) && !all(is.na(s$full_lo))) {
      xs <- factor(st$level, levels = st$level)
      p <- p %>%
        add_trace(x = xs, y = s$full_lo, type = "scatter", mode = "lines", yaxis = "y2", showlegend = FALSE, legendgroup = "fullci",
                  line = list(color = "rgba(15,23,42,0)", width = 0), hovertemplate = "lower %{y:.4f}<extra></extra>") %>%
        add_trace(x = xs, y = s$full_hi, type = "scatter", mode = "lines", yaxis = "y2", name = "95% band (full model)",
                  legendgroup = "fullci", fill = "tonexty", fillcolor = "rgba(15,23,42,0.10)",
                  line = list(color = "rgba(15,23,42,0)", width = 0), hovertemplate = "upper %{y:.4f}<extra></extra>") %>%
        layout(xaxis = list(categoryorder = "array", categoryarray = st$level))
    }
    # say why there is no fit line instead of leaving it out silently
    why <- if (kind == "cust" && length(unique(t$cust_tb$group[!is.na(t$cust_tb$group)])) < 2)
             "All levels are in one group: no custom effect to fit. Give at least two levels different groups."
           else if (kind == "var" && anyNA(t$var_tb$value)) "Fill in a variate value for every level to see the fit."
           else if (all(is.na(fit1))) "The one-way fit could not be estimated with these values."
           else NULL
    if (!is.null(why))
      p <- p %>% layout(annotations = list(list(text = why, xref = "paper", yref = "paper", x = 0.5, y = 0.98, showarrow = FALSE,
                                                font = list(color = "#b54708", size = 12), bgcolor = "#fffaeb",
                                                bordercolor = "#fedf89", borderpad = 6)))
    p
  }
  output$ed_var_plot  <- renderPlotly({ req(rv$ed_f, rv$ed_var);  ed_preview_plot("var") })
  output$ed_cust_plot <- renderPlotly({ req(rv$ed_f, rv$ed_cust); ed_preview_plot("cust") })

  # ---- full-model preview: refit the whole model with the editor's draft for this factor (does not replace the fitted model) ----
  ed_draft_term <- function() {
    t <- rv$terms[[rv$ed_f]]
    t$var_tb <- rv$ed_var; t$cust_tb <- rv$ed_cust
    t$var_on <- isTRUE(input$ed_var_on); t$cust_on <- isTRUE(input$ed_cust_on)
    t$var_order <- as.integer(input$ed_var_order); t$include <- TRUE
    t
  }
  observeEvent(input$ed_full_preview, mt_guard("Full-model preview failed", {
    f <- rv$ed_f
    req(f, isTRUE(rv$data_prepared))
    tl <- rv$terms; tl[[f]] <- ed_draft_term()
    inc <- names(tl)[is_in(tl)]
    probs <- c(unlist(lapply(inc, function(g) glm_term_problem(g, tl[[g]]))), unlist(lapply(rv$inters, glm_inter_problem, terms = tl)))
    if (length(probs)) { showNotification(paste(probs, collapse = " · "), type = "error", duration = 10); return() }
    chk <- tryCatch(glm_fit_check(tl, rv$inters, nrow(rv$model_data[[1]])), error = function(e) NULL)
    if (!is.null(chk) && (chk$too_many || chk$too_big)) { glm_fit_blocked(chk, "preview"); return() }
    res <- withProgress(message = "Full-model preview", value = 0.2, {
      setProgress(0.25, detail = sprintf("Fitting %d factors with the draft for %s", length(inc), f))
      tryCatch({
        m <- glm_fit_model(rv$model_data[[1]], tl, input$select_response, input$select_exposure,
                           rv$offset_factor, rv$model_type, tweedie_p(), inters = rv$inters)
        setProgress(0.9, detail = "Relativities")
        list(rel = glm_add_ci(glm_relativities(m, rv$factor_levels, rv$base_override), m)$factors[[f]], draft = tl[[f]],
             deviance = m$deviance, n_params = m$n_params, at = Sys.time())
      }, error = function(e) e)
    })
    if (inherits(res, "error")) { showNotification(paste("Preview fit failed:", conditionMessage(res)), type = "error", duration = 10); return() }
    rv$ed_full <- res
  }))
  # tells whether the shown full-model preview still matches the draft
  output$ed_full_info <- renderUI({
    fp <- rv$ed_full
    if (is.null(fp)) return(span(class = "mt-empty-hint", "Refit the whole model with these settings to see the real relativity."))
    d <- ed_draft_term()
    same <- identical(d$var_tb, fp$draft$var_tb) && identical(d$cust_tb, fp$draft$cust_tb) && identical(d$var_on, fp$draft$var_on) &&
            identical(d$cust_on, fp$draft$cust_on) && identical(d$var_order, fp$draft$var_order)
    cmp <- if (!is.null(rv$glm_model)) sprintf(" · deviance %s vs %s now", fmt_num(fp$deviance, 1), fmt_num(rv$glm_model$deviance, 1)) else
             sprintf(" · deviance %s", fmt_num(fp$deviance, 1))
    if (same) span(class = "mt-mode-chip var", sprintf("Full-model preview: %d parameters%s", fp$n_params, cmp))
    else span(class = "mt-mode-chip stale", icon("triangle-exclamation"), " Settings changed since the preview: run it again")
  })

  observeEvent(input$ed_apply, mt_guard("Could not apply the factor terms", restore = c("terms", "inters", "terms_version"), {
    f  <- rv$ed_f
    tl <- rv$terms
    req(f %in% names(tl))
    t <- tl[[f]]
    t$var_tb <- rv$ed_var; t$cust_tb <- rv$ed_cust
    simple <- isTRUE(input$ed_simple)
    t$var_on  <- !simple && isTRUE(input$ed_var_on)
    t$cust_on <- !simple && isTRUE(input$ed_cust_on)
    t$var_order <- as.integer(input$ed_var_order)
    t$include <- simple || t$var_on || t$cust_on          # in the model when any of S / V / C is on
    pr <- glm_term_problem(f, t)
    if (!is.null(pr) && t$include) { showNotification(pr, type = "error", duration = 8); return() }
    tl[[f]] <- t
    set_terms(tl)
    removeModal()
    showNotification(sprintf("%s: %s", f, if (!t$include) "not in the model" else
                             switch(glm_term_mode(t), plain = "simple (own levels)", glm_term_mode(t))), type = "message")
  }))

  # ---- reference model ----
  # scores a fitted model on the current modelling dataset (errors if it uses factors the dataset does not have)
  make_reference <- function(model, label) {
    # every factor the model uses, interactions included, must exist in the current dataset
    missing <- setdiff(union(model$included, glm_inter_factors(model$interactions)), names(rv$factor_levels))
    if (length(missing)) stop("factors not in this dataset: ", paste(missing, collapse = ", "))
    pred <- lapply(rv$model_data, function(d) glm_predict(model, d))
    n_na <- sum(vapply(pred, function(p) sum(is.na(p)), numeric(1)))
    if (n_na) stop(n_na, " rows have levels the model does not know (were the factors mapped differently?)")
    rel <- glm_relativities(model, rv$factor_levels, rv$base_override)
    if (!is.null(model$vcov)) rel <- glm_add_ci(rel, model)
    list(model = model, pred = pred, rel = rel, label = label)
  }
  observeEvent(input$glm_ref_set, {
    if (is.null(rv$glm_model)) { showNotification("Fit a model first", type = "error"); return() }
    rv$ref <- list(model = rv$glm_model, pred = rv$glm_pred, rel = rv$glm_rel,
                   label = paste0("fit of ", format(rv$glm_model$fitted_at, "%H:%M:%S")))
    showNotification("Current model set as reference", type = "message")
  })
  observeEvent(input$glm_ref_clear, { rv$ref <- NULL })
  output$glm_ref_info <- renderText({
    r <- rv$ref
    if (is.null(r)) "No reference model" else
      sprintf("Reference: %s · %d factors · %d parameters", r$label, length(r$model$included), r$model$n_params)
  })
  output$glm_model_save <- downloadHandler(
    filename = function() paste0("glm_fitted_model_", format(Sys.time(), "%Y%m%d_%H%M"), ".rds"),
    content = function(file) {
      req(rv$glm_model)
      saveRDS(list(tool = "GLM Modelling Studio", type = "fitted GLM", model = rv$glm_model, relativities = rv$glm_rel,
                   response = input$select_response, exposure = input$select_exposure, model_type = rv$model_type,
                   factor_raw = rv$factor_raw, mappings = rv$factor_lookup_tb_saved, saved_at = Sys.time()), file)
    }
  )
  observeEvent(input$glm_ref_load, {
    if (!isTRUE(rv$data_prepared)) { mt_alert(title = "Create the modelling dataset first", type = "error"); return() }
    s <- tryCatch(readRDS(input$glm_ref_load$datapath), error = function(e) NULL)
    if (!is.list(s) || is.null(s$model$coef)) {
      mt_alert(title = "Not a fitted model", text = "Choose a file saved with 'Save fitted model'.", type = "error"); return()
    }
    if (!identical(as.character(s$model_type), as.character(rv$model_type)) || !identical(s$response, input$select_response))
      showNotification("The reference model was fitted to a different response or model type", type = "warning", duration = 8)
    r <- tryCatch(make_reference(s$model, input$glm_ref_load$name), error = function(e) e)
    if (inherits(r, "error")) { mt_alert(title = "Cannot use this model as reference", text = conditionMessage(r), type = "error"); return() }
    rv$ref <- r
    showNotification(paste("Reference model loaded:", input$glm_ref_load$name), type = "message")
  })

  # ---- validation: gains / Gini, lift, comparison ----
  part_rows <- function(i) rv$model_data[[i]]
  output$glm_gains_plot <- renderPlotly({
    m <- rv$glm_model
    validate(need(!is.null(m), "Fit the model to see the gains curve."))
    resp <- m$response; expo <- m$exposure
    ks <- which(vapply(rv$model_data, nrow, integer(1)) > 0)
    nm <- mt_partition_names[ks]
    gains <- setNames(lapply(ks, function(i) glm_gains(rv$glm_pred[[i]], part_rows(i)[[expo]], part_rows(i)[[resp]], score = rank_score(rv$glm_pred[[i]], part_rows(i)))), nm)
    gini  <- setNames(lapply(ks, function(i) glm_gini(rv$glm_pred[[i]], part_rows(i)[[expo]], part_rows(i)[[resp]], score = rank_score(rv$glm_pred[[i]], part_rows(i)))), nm)
    gr <- NULL; gir <- NULL
    if (!is.null(rv$ref)) {
      gr  <- setNames(lapply(ks, function(i) glm_gains(rv$ref$pred[[i]], part_rows(i)[[expo]], part_rows(i)[[resp]], score = rank_score(rv$ref$pred[[i]], part_rows(i)))), nm)
      gir <- setNames(lapply(ks, function(i) glm_gini(rv$ref$pred[[i]], part_rows(i)[[expo]], part_rows(i)[[resp]], score = rank_score(rv$ref$pred[[i]], part_rows(i)))), nm)
    }
    d1 <- part_rows(1)
    perfect <- glm_gains(d1[[resp]], d1[[expo]], d1[[resp]], score = d1[[resp]])
    plot_glm_gains(gains, gini, gr, gir, perfect)
  })
  output$glm_lift_plot <- renderPlotly({
    m <- rv$glm_model
    validate(need(!is.null(m), "Fit the model to see the lift chart."))
    i <- as.integer(input$glm_lift_part); d <- part_rows(i)
    validate(need(nrow(d) > 0, "There is no data in this partition."))
    nb <- max(2, min(50, as.integer(if (isTruthy(input$glm_lift_bands)) input$glm_lift_bands else 10)))
    lf <- glm_lift(rv$glm_pred[[i]], d[[m$exposure]], d[[m$response]], nb)
    lr <- if (!is.null(rv$ref)) { x <- glm_lift(rv$ref$pred[[i]], d[[m$exposure]], d[[m$response]], nb); x } else NULL
    if (!is.null(lr)) lf$expected_ref <- lr$expected
    p <- plot_glm_lift(lf, NULL, mt_rate_label(rv$model_type))
    if (!is.null(lr))
      p <- p %>% add_trace(x = factor(lf$band), y = lf$expected_ref, type = "scatter", mode = "lines+markers", yaxis = "y2",
                           name = "Expected (reference, own bands)", inherit = FALSE,
                           line = list(color = mt_chart_colours$expected_ref, width = 1.6, dash = "dot"),
                           marker = list(color = mt_chart_colours$expected_ref, size = 5), hovertemplate = "%{y:.4f}")
    p
  })
  output$glm_compare_ui <- renderUI({
    m <- rv$glm_model; r <- rv$ref
    if (is.null(m)) return(p(class = "mt-empty-hint", "Fit the model first."))
    if (is.null(r)) return(p(class = "mt-empty-hint", "Set or load a reference model (Model run panel) to compare it with the current fit."))
    resp <- m$response; expo <- m$exposure
    ks <- which(vapply(rv$model_data, nrow, integer(1)) > 0)
    stat <- function(pred, i) { d <- part_rows(i); c(ae = sum(d[[resp]]) / sum(pred), gini = glm_gini(pred, d[[expo]], d[[resp]], score = rank_score(pred, d))) }
    fmt3 <- function(x) formatC(x, format = "f", digits = 3)
    rows <- lapply(ks, function(i) {
      a <- stat(rv$glm_pred[[i]], i); b <- stat(r$pred[[i]], i)
      tags$tr(tags$td(mt_partition_names[i]), tags$td(fmt3(a[["ae"]])), tags$td(fmt3(b[["ae"]])),
              tags$td(fmt_pct(a[["gini"]])), tags$td(fmt_pct(b[["gini"]])),
              tags$td(span(class = if (a[["gini"]] >= b[["gini"]]) "mt-good" else "mt-bad",
                           sprintf("%+.2f pts", 100 * (a[["gini"]] - b[["gini"]])))))
    })
    added   <- setdiff(m$included, r$model$included)
    removed <- setdiff(r$model$included, m$included)
    changed <- Filter(function(f) !identical(glm_term_formula(f, m$terms[[f]]), glm_term_formula(f, r$model$terms[[f]])) ||
                        !identical(m$terms[[f]]$var_tb, r$model$terms[[f]]$var_tb) ||
                        !identical(m$terms[[f]]$cust_tb, r$model$terms[[f]]$cust_tb),
                      intersect(m$included, r$model$included))
    it_terms <- function(x) vapply(if (is.null(x)) list() else x, glm_inter_term, character(1))
    added   <- c(added,   paste0("× ", setdiff(it_terms(m$interactions), it_terms(r$model$interactions))))
    removed <- c(removed, paste0("× ", setdiff(it_terms(r$model$interactions), it_terms(m$interactions))))
    added <- added[added != "× "]; removed <- removed[removed != "× "]
    tagList(
      fluidRow(
        column(7,
               tags$table(class = "table mt-sum-table",
                          tags$thead(tags$tr(tags$th("Partition"), tags$th("A/E current"), tags$th("A/E reference"),
                                             tags$th("Gini current"), tags$th("Gini reference"), tags$th("Change"))),
                          tags$tbody(rows)),
               div(class = "mt-sum-metrics",
                   span(class = "mt-sum-chip", "Parameters: ", tags$b(m$n_params), " vs ", tags$b(r$model$n_params)),
                   span(class = "mt-sum-chip", "Deviance (modelling): ", tags$b(fmt_num(m$deviance, 1)), " vs ", tags$b(fmt_num(r$model$deviance, 1))),
                   if (!is.na(m$aic) && !is.na(r$model$aic))
                     span(class = "mt-sum-chip", "AIC: ", tags$b(fmt_num(m$aic, 1)), " vs ", tags$b(fmt_num(r$model$aic, 1)))),
               p(class = "mt-empty-hint", style = "margin-top: 8px;",
                 "Deviance and AIC are only comparable when both models were fitted to the same modelling data.")),
        column(5,
               mt_section("Differences in the factors"),
               div(class = "mt-chip-row", style = "margin-bottom: 6px;",
                   span(class = "mt-mode-chip var", paste("Added:", if (length(added)) paste(added, collapse = ", ") else "none"))),
               div(class = "mt-chip-row", style = "margin-bottom: 6px;",
                   span(class = "mt-mode-chip stale", paste("Removed:", if (length(removed)) paste(removed, collapse = ", ") else "none"))),
               div(class = "mt-chip-row",
                   span(class = "mt-mode-chip cust", paste("Changed:", if (length(changed)) paste(changed, collapse = ", ") else "none"))))
      )
    )
  })

  # ---- investigation: two-way actual vs expected ----
  output$inv_plot <- renderPlotly({
    validate(need(isTRUE(rv$data_prepared), "Create the modelling dataset first."))
    fa <- input$inv_fa; fb <- input$inv_fb
    req(fa %in% names(rv$factor_levels), fb %in% names(rv$factor_levels))
    validate(need(fa != fb, "Choose two different factors."))
    i <- as.integer(input$inv_part)
    ks <- if (i == 0) seq_along(rv$model_data) else i
    d <- bind_rows(lapply(ks, function(k) rv$model_data[[k]]))
    validate(need(nrow(d) > 0, "There is no data in this partition."))
    pred <- if (!is.null(rv$glm_model)) unlist(lapply(ks, function(k) rv$glm_pred[[k]])) else rep(NA_real_, nrow(d))
    validate(need(length(unique(d[[fb]])) <= MT_MAX_TWO_WAY_LINES, sprintf("The split factor has more than %d levels: band it first or swap the two factors.", MT_MAX_TWO_WAY_LINES)))
    s <- glm_two_way_summary(d, fa, fb, input$select_response, input$select_exposure, pred)
    s$a <- factor(as.character(s$a), levels = levels(d[[fa]])); s$b <- factor(as.character(s$b), levels = levels(d[[fb]]))
    s <- s[order(s$b, s$a), ]
    plot_glm_two_way(s, fa, fb, mt_rate_label(rv$model_type), show_expected = isTRUE(input$inv_expected) && !is.null(rv$glm_model))
  })
}

shinyApp(ui, server)
