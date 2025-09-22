# MSE-609 Tutorial 3: MVP Data Reading Script
# This script reads the Uber ride bookings dataset and provides basic information

# Load required libraries
library(tidyverse)

# Define file path
data_file <- "data/ncr_ride_bookings.csv"

# Check if file exists, stop with error if missing
if (!file.exists(data_file)) {
  stop("Error: File '", data_file, "' not found. Please ensure the file exists in the data/ directory.")
}

# Read the CSV file
cat("Reading data from:", data_file, "\n")
ride_data <- read_csv(data_file)

# Print number of rows and columns
cat("Dataset dimensions:\n")
cat("  Rows:", nrow(ride_data), "\n")
cat("  Columns:", ncol(ride_data), "\n")

# Show first 5 rows
cat("\nFirst 5 rows of the dataset:\n")
print(head(ride_data, 5))

cat("\nData reading completed successfully!\n")

