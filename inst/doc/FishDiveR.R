## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 4,
  out.width = "100%"
)

# Include a figure saved by FishDiveR, copied next to the vignette's own figures
include_saved_figure <- function(file) {
  dest <- file.path(knitr::opts_chunk$get("fig.path"), basename(file))
  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  file.copy(file, dest, overwrite = TRUE)
  knitr::include_graphics(dest)
}

## ----setup--------------------------------------------------------------------
# Use rgl's off-screen device, as k_clustering() can draw a 3D plot
options(rgl.useNULL = TRUE)
library(FishDiveR)

# Example data shipped with the package
example_folder <- system.file("extdata", package = "FishDiveR")

# Project folder for this vignette's results
project <- file.path(tempdir(), "FishDiveR-vignette")
dir.create(project, showWarnings = FALSE)

## ----import-------------------------------------------------------------------
archive_days <- import_tag_data(
  tag_ID = "data",
  tag_deploy_UTC = "2000-01-01 00:00:00",
  tag_release_UTC = "2000-01-11 23:59:00",
  archive = file.path(example_folder, "data", "data-Archive.csv"),
  date_time_col = 1,
  depth_col = 2,
  time_zone = "UTC",
  output = TRUE,
  output_folder = project
)
head(archive_days)

## ----plot-tdr, fig.alt = "Depth record of the example tag over ten days, with depth increasing downwards."----
tdr <- plot_TDR(
  rds_file = "data/archive_days.rds",
  data_folder = project,
  minmax_bins = 2000,
  Y_lim = c(0, 300, 50),
  date_breaks = "2 day"
)
attr(tdr, "TDR_plot")

## ----time-at-depth, fig.height = 5, fig.alt = "Percentage of time the example tag spent in each 25 m depth range."----
time_at_depth <- plot_time_at(archive_days, breaks = seq(0, 275, by = 25))
attr(time_at_depth, "time_at_plot")

## ----wavelet, results = "hide"------------------------------------------------
wavelet <- create_wavelet(
  archive = archive_days,
  tag_ID = "data",
  lower_period_mins = 30,
  upper_period_hours = 24,
  suboctaves = 12,
  output = TRUE,
  output_folder = project,
  plot_wavelet = TRUE,
  interactive_mode = FALSE
)

## ----wavelet-figure, echo = FALSE, fig.alt = "Wavelet power spectrum of the example tag: time in days along the bottom, period from 30 minutes to 24 hours up the side."----
include_saved_figure(file.path(project, "data", "2_Wavelet_Figures", "data_wavelet_spectrum_no.p.png"))

## ----wavelet-stats------------------------------------------------------------
wave_stats <- create_wavelet_stats(wavelet, tag_ID = "data", output = TRUE, output_folder = project)
dim(wave_stats)

## ----depth-stats--------------------------------------------------------------
depth_stats <- create_depth_stats(
  archive = archive_days,
  tag_ID = "data",
  diel = TRUE,
  GPS = file.path(example_folder, "data", "GPS.csv"),
  sunset_type = "civil",
  output = TRUE,
  output_folder = project
)
names(depth_stats)

## ----pca-data-----------------------------------------------------------------
pc_data <- pca_data(
  tag_vector = "data",
  data_folder = project,
  power_mean = TRUE,
  power_variance = TRUE,
  amplitude_mean = TRUE
)

## ----eigenvalues--------------------------------------------------------------
all_pcs <- pca_results(pc_data, No_pcs = 50, plot_eigenvalues = FALSE, interactive_mode = FALSE)
round(head(all_pcs$eig, 8), 2)

## ----pca----------------------------------------------------------------------
pc_results <- pca_results(pc_data, No_pcs = 3, plot_eigenvalues = FALSE, interactive_mode = FALSE)
pc_scores <- pca_scores(pc_results, plot_loadings = FALSE)

## ----combine------------------------------------------------------------------
kmeans_data <- combine_data(tag_vector = "data", data_folder = project, pc_scores = pc_scores)
dim(kmeans_data)

## ----select-k, fig.alt = "Elbow plot of within-cluster sum of squares and plot of silhouette width against the number of clusters, with a dashed line at four clusters."----
set.seed(123)
select_k(kmeans_data, Max.k = 8, v_line = 4)

## ----kmeans-------------------------------------------------------------------
set.seed(123)
kmeans_result <- k_clustering(kmeans_data, k = 4, nstart = 50, output = FALSE)
table(Cluster = kmeans_result$cluster)

## ----cluster-tdr, fig.alt = "Depth record of the example tag with each day coloured by its behaviour cluster."----
plot_cluster_TDR(
  tag_ID = "data",
  data_folder = project,
  kmeans_result = kmeans_result,
  minmax_bins = 2000,
  Y_lim = c(0, 300, 50),
  date_breaks = "2 day"
)

## ----example-days-------------------------------------------------------------
plots <- plot_clusters(
  tag_vector = "data",
  data_folder = project,
  kmeans_result = kmeans_result,
  No_days = 1,
  Y_lim = c(0, 300, 50),
  diel_shade = TRUE,
  dpi = 72,
  output = TRUE,
  output_folder = project
)

## ----example-days-figure, echo = FALSE, out.width = "70%", fig.alt = "The most typical day of each of the four clusters, stacked, with night shaded grey."----
include_saved_figure(file.path(project, "data", "6_Cluster-plots.K=4_shaded", "Cluster_facet.png"))

## ----several-tags, eval = FALSE-----------------------------------------------
# tags <- c("tag_A", "tag_B", "tag_C")
# pc_data <- pca_data(tag_vector = tags, data_folder = project, output = TRUE, output_folder = project)
# # ... pca_results() and pca_scores() as above ...
# kmeans_data <- combine_data(tag_vector = tags, data_folder = project, pc_scores = pc_scores)

## ----citation, echo = FALSE, comment = ""-------------------------------------
print(citation("FishDiveR"), style = "text")

