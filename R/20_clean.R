# MSE-609 Tutorial 3: Data Cleaning Script
# This script cleans the Uber ride bookings dataset and creates new features

# Load required libraries
library(tidyverse)
library(lubridate)

# Define file paths
input_file <- "data/ncr_ride_bookings.csv"
output_file <- "data/uber_clean.csv"

# Check if input file exists
if (!file.exists(input_file)) {
  stop("Error: File '", input_file, "' not found. Please ensure the file exists.")
}

cat("Starting data cleaning process...\n")
cat("Reading data from:", input_file, "\n")

# Read the raw data
raw_data <- read_csv(input_file, show_col_types = FALSE)

cat("Original dataset dimensions:", nrow(raw_data), "rows,", ncol(raw_data), "columns\n")

# Create cleaned dataset
clean_data <- raw_data %>%
  # 1. Clean and standardize timestamps
  mutate(
    # Combine Date and Time into a proper datetime
    datetime = as.POSIXct(paste(Date, Time), format = "%Y-%m-%d %H:%M:%S"),
    
    # Create date, hour, and weekday features
    date = as.Date(datetime),
    hour = hour(datetime),
    weekday = wday(datetime, label = TRUE, abbr = FALSE),
    weekday_num = wday(datetime)
  ) %>%
  
  # 2. Clean and standardize vehicle types
  mutate(
    vehicle_type_clean = case_when(
      `Vehicle Type` == "eBike" ~ "eBike",
      `Vehicle Type` == "Bike" ~ "Bike", 
      `Vehicle Type` == "Auto" ~ "Auto",
      `Vehicle Type` == "Go Sedan" ~ "Go Sedan",
      `Vehicle Type` == "Go Mini" ~ "Go Mini",
      `Vehicle Type` == "Premier Sedan" ~ "Premier Sedan",
      `Vehicle Type` == "Uber XL" ~ "Uber XL",
      TRUE ~ "Other"
    ),
    
    # Create vehicle category
    vehicle_category = case_when(
      vehicle_type_clean %in% c("eBike", "Bike") ~ "Two-Wheeler",
      vehicle_type_clean %in% c("Auto") ~ "Three-Wheeler", 
      vehicle_type_clean %in% c("Go Mini", "Go Sedan") ~ "Standard Car",
      vehicle_type_clean %in% c("Premier Sedan", "Uber XL") ~ "Premium Car",
      TRUE ~ "Other"
    )
  ) %>%
  
  # 3. Clean and standardize booking status
  mutate(
    booking_status_clean = case_when(
      `Booking Status` == "Completed" ~ "Completed",
      `Booking Status` == "Incomplete" ~ "Incomplete",
      `Booking Status` == "Cancelled by Customer" ~ "Cancelled by Customer",
      `Booking Status` == "Cancelled by Driver" ~ "Cancelled by Driver", 
      `Booking Status` == "No Driver Found" ~ "No Driver Found",
      TRUE ~ "Other"
    ),
    
    # Create success indicator
    is_successful = booking_status_clean == "Completed"
  ) %>%
  
  # 4. Clean numeric columns (convert "null" to NA and parse numbers)
  mutate(
    booking_value = case_when(
      `Booking Value` == "null" ~ NA_real_,
      TRUE ~ as.numeric(`Booking Value`)
    ),
    
    ride_distance = case_when(
      `Ride Distance` == "null" ~ NA_real_,
      TRUE ~ as.numeric(`Ride Distance`)
    ),
    
    driver_rating = case_when(
      `Driver Ratings` == "null" ~ NA_real_,
      TRUE ~ as.numeric(`Driver Ratings`)
    ),
    
    customer_rating = case_when(
      `Customer Rating` == "null" ~ NA_real_,
      TRUE ~ as.numeric(`Customer Rating`)
    )
  ) %>%
  
  # 5. Clean text columns (remove quotes and standardize)
  mutate(
    booking_id_clean = str_remove_all(`Booking ID`, '"'),
    customer_id_clean = str_remove_all(`Customer ID`, '"'),
    payment_method_clean = case_when(
      `Payment Method` == "null" ~ NA_character_,
      TRUE ~ `Payment Method`
    )
  ) %>%
  
  # 6. Select and reorder columns for the cleaned dataset
  select(
    # Identifiers
    booking_id = booking_id_clean,
    customer_id = customer_id_clean,
    
    # Timestamps and time features
    datetime,
    date,
    hour,
    weekday,
    weekday_num,
    
    # Vehicle information
    vehicle_type = vehicle_type_clean,
    vehicle_category,
    
    # Booking information
    booking_status = booking_status_clean,
    is_successful,
    
    # Location information
    pickup_location = `Pickup Location`,
    drop_location = `Drop Location`,
    
    # Financial and performance metrics
    booking_value,
    ride_distance,
    driver_rating,
    customer_rating,
    payment_method = payment_method_clean
  )

# Display cleaning summary
cat("\nData cleaning summary:\n")
cat("Cleaned dataset dimensions:", nrow(clean_data), "rows,", ncol(clean_data), "columns\n")

cat("\nVehicle type distribution:\n")
print(table(clean_data$vehicle_type, useNA = "ifany"))

cat("\nBooking status distribution:\n")
print(table(clean_data$booking_status, useNA = "ifany"))

cat("\nDate range:", as.character(min(clean_data$date)), "to", as.character(max(clean_data$date)), "\n")

cat("\nSuccess rate:", round(mean(clean_data$is_successful, na.rm = TRUE) * 100, 2), "%\n")

# Save cleaned data
cat("\nSaving cleaned data to:", output_file, "\n")
write_csv(clean_data, output_file)

cat("Data cleaning completed successfully!\n")
cat("Cleaned dataset saved as:", output_file, "\n")

# Display first few rows of cleaned data
cat("\nFirst 5 rows of cleaned dataset:\n")
print(head(clean_data, 5))

