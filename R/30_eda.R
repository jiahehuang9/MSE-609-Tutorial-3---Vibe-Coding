# MSE-609 Tutorial 3: Exploratory Data Analysis Script
# This script creates visualizations for the cleaned Uber ride bookings dataset

# Load required libraries
library(tidyverse)
library(ggplot2)
library(scales)

# Define file paths
input_file <- "data/uber_clean.csv"
fig_dir <- "fig"

# Check if input file exists
if (!file.exists(input_file)) {
  stop("Error: File '", input_file, "' not found. Please run the cleaning script first.")
}

# Check if fig directory exists, create if not
if (!dir.exists(fig_dir)) {
  dir.create(fig_dir, recursive = TRUE)
  cat("Created directory:", fig_dir, "\n")
}

cat("Starting exploratory data analysis...\n")
cat("Reading cleaned data from:", input_file, "\n")

# Read the cleaned data
data <- read_csv(input_file, show_col_types = FALSE)

cat("Dataset dimensions:", nrow(data), "rows,", ncol(data), "columns\n")

# =============================================================================
# 1. HOURLY RIDE COUNTS PLOT
# =============================================================================

cat("\nCreating hourly ride counts plot...\n")

# Calculate hourly ride counts
hourly_counts <- data %>%
  count(hour, name = "ride_count") %>%
  arrange(hour)

# Create hourly ride counts plot
p1 <- ggplot(hourly_counts, aes(x = hour, y = ride_count)) +
  geom_line(color = "#1f77b4", size = 1.2) +
  geom_point(color = "#1f77b4", size = 2) +
  scale_x_continuous(breaks = seq(0, 23, 2), labels = paste0(seq(0, 23, 2), ":00")) +
  scale_y_continuous(labels = comma_format()) +
  labs(
    title = "Hourly Ride Counts",
    subtitle = "Distribution of Uber rides throughout the day",
    x = "Hour of Day",
    y = "Number of Rides",
    caption = "Data: Uber Ride Analytics Dataset"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray60"),
    plot.caption = element_text(size = 10, color = "gray60", hjust = 1),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_line(color = "gray90", size = 0.5),
    panel.grid.major.y = element_line(color = "gray90", size = 0.5)
  )

# Save hourly plot
hourly_file <- file.path(fig_dir, "hourly.png")
ggsave(hourly_file, plot = p1, width = 10, height = 6, dpi = 300, bg = "white")
cat("Hourly plot saved to:", hourly_file, "\n")

# =============================================================================
# 2. CANCEL RATE BY WEEKDAY AND VEHICLE TYPE PLOT
# =============================================================================

cat("Creating cancel rate by weekday and vehicle type plot...\n")

# Calculate cancel rates by weekday and vehicle type
cancel_rates <- data %>%
  # Create cancellation indicator (anything that's not "Completed")
  mutate(is_cancelled = !is_successful) %>%
  group_by(weekday, vehicle_type) %>%
  summarise(
    total_rides = n(),
    cancelled_rides = sum(is_cancelled, na.rm = TRUE),
    cancel_rate = cancelled_rides / total_rides * 100,
    .groups = "drop"
  ) %>%
  # Reorder weekdays properly
  mutate(weekday = factor(weekday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")))

# Create cancel rate heatmap
p2 <- ggplot(cancel_rates, aes(x = weekday, y = vehicle_type, fill = cancel_rate)) +
  geom_tile(color = "white", size = 0.5) +
  geom_text(aes(label = paste0(round(cancel_rate, 1), "%")), 
            color = "white", size = 3, fontface = "bold") +
  scale_fill_gradient2(
    low = "#2E8B57",      # Sea green for low cancel rates
    mid = "#FFD700",      # Gold for medium cancel rates  
    high = "#DC143C",     # Crimson for high cancel rates
    midpoint = 50,
    name = "Cancel Rate (%)",
    guide = guide_colorbar(title.position = "top", title.hjust = 0.5)
  ) +
  labs(
    title = "Cancel Rate by Weekday and Vehicle Type",
    subtitle = "Percentage of cancelled rides across different days and vehicle types",
    x = "Day of Week",
    y = "Vehicle Type",
    caption = "Data: Uber Ride Analytics Dataset"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray60"),
    plot.caption = element_text(size = 10, color = "gray60", hjust = 1),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom",
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10),
    panel.grid = element_blank()
  )

# Save cancel rate plot
cancel_file <- file.path(fig_dir, "cancel_rate.png")
ggsave(cancel_file, plot = p2, width = 12, height = 8, dpi = 300, bg = "white")
cat("Cancel rate plot saved to:", cancel_file, "\n")

# =============================================================================
# SUMMARY STATISTICS
# =============================================================================

cat("\nExploratory Data Analysis Summary:\n")
cat("=====================================\n")

# Hourly statistics
cat("\nHourly Ride Statistics:\n")
cat("Peak hour:", hourly_counts$hour[which.max(hourly_counts$ride_count)], 
    "with", max(hourly_counts$ride_count), "rides\n")
cat("Lowest hour:", hourly_counts$hour[which.min(hourly_counts$ride_count)], 
    "with", min(hourly_counts$ride_count), "rides\n")

# Cancel rate statistics
cat("\nCancel Rate Statistics:\n")
overall_cancel_rate <- mean(!data$is_successful, na.rm = TRUE) * 100
cat("Overall cancel rate:", round(overall_cancel_rate, 2), "%\n")

# Highest cancel rate by vehicle type
highest_cancel_vehicle <- cancel_rates %>%
  group_by(vehicle_type) %>%
  summarise(avg_cancel_rate = mean(cancel_rate), .groups = "drop") %>%
  arrange(desc(avg_cancel_rate)) %>%
  slice(1)

cat("Vehicle type with highest cancel rate:", highest_cancel_vehicle$vehicle_type, 
    "(", round(highest_cancel_vehicle$avg_cancel_rate, 2), "%)\n")

# Highest cancel rate by weekday
highest_cancel_day <- cancel_rates %>%
  group_by(weekday) %>%
  summarise(avg_cancel_rate = mean(cancel_rate), .groups = "drop") %>%
  arrange(desc(avg_cancel_rate)) %>%
  slice(1)

cat("Day with highest cancel rate:", highest_cancel_day$weekday, 
    "(", round(highest_cancel_day$avg_cancel_rate, 2), "%)\n")

cat("\nEDA completed successfully!\n")
cat("Plots saved to:", fig_dir, "directory\n")

