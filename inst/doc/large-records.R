## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## ----setup--------------------------------------------------------------------
library(FishDiveR)
example_folder <- system.file("extdata", package = "FishDiveR")
archive_days <- readRDS(file.path(example_folder, "data", "archive_days.rds"))

## ----memory-------------------------------------------------------------------
n_periods <- function(lower_period_mins, upper_period_hours, suboctaves = 12) {
  floor(log2(upper_period_hours * 60 / lower_period_mins) * suboctaves) + 1
}
wavelet_gb <- function(days, sampling_s, lower_period_mins, upper_period_hours = 24, suboctaves = 12) {
  records <- days * 86400 / sampling_s
  records * n_periods(lower_period_mins, upper_period_hours, suboctaves) * 48 / 1024^3
}

# A 5 minute to 24 hour wavelet with 12 sub-octaves has this many periods
n_periods(5, 24)

# Approximate wavelet memory in GB for a few deployments
deployments <- expand.grid(days = c(30, 90, 365), sampling_s = c(1, 5, 15, 60))
deployments$memory_GB <- round(wavelet_gb(deployments$days, deployments$sampling_s, lower_period_mins = 5), 1)
deployments

## ----thin---------------------------------------------------------------------
# The example tag is sampled every 60 seconds: thin it to 5 minutes
thinned <- thin_archive(archive_days, interval_s = 300, verbose = TRUE)
head(thinned[, c("date", "depth", "date_only")])

## ----interval-----------------------------------------------------------------
lower_period_mins <- c(5, 10, 20, 30, 60)
data.frame(lower_period_mins, longest_interval_s = lower_period_mins * 60 / 20)

## ----thin-saving--------------------------------------------------------------
round(c(full = wavelet_gb(30, 1, 5), thinned = wavelet_gb(30, 15, 5)), 1)

## ----thin-workflow, eval = FALSE----------------------------------------------
# archive_days <- readRDS(file.path(project, "237522", "archive_days.rds"))
# 
# # Wavelet from the thinned record
# wavelet <- create_wavelet(
#   archive = thin_archive(archive_days, interval_s = 15),
#   tag_ID = "237522",
#   lower_period_mins = 5,
#   upper_period_hours = 24,
#   output = TRUE,
#   output_folder = project
# )
# create_wavelet_stats(wavelet, tag_ID = "237522", output = TRUE, output_folder = project)
# 
# # Depth statistics from the full record
# create_depth_stats(archive_days, tag_ID = "237522", diel = TRUE, GPS = gps_file, output = TRUE, output_folder = project)

## ----minmax, fig.width = 8, fig.height = 4, out.width = "100%", fig.alt = "Depth record of the example tag plotted with the shallowest and deepest record in each of 500 time slices."----
tdr <- plot_TDR(
  rds_file = "data/archive_days.rds",
  data_folder = example_folder,
  minmax_bins = 500,
  Y_lim = c(0, 300, 50),
  date_breaks = "2 day"
)
nrow(tdr)
attr(tdr, "TDR_plot")

## ----redraw, eval = FALSE-----------------------------------------------------
# create_wavelet(
#   archive = archive_days,
#   tag_ID = "237522",
#   load_existing_wavelet = TRUE,
#   lower_period_mins = 5,
#   upper_period_hours = 24,
#   output = TRUE,
#   output_folder = project
# )

