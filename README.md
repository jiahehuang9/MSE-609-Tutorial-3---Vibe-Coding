# MSE-609-Tutorial-3-Vibe-Coding

# Vibe Coding with R: Uber Ride Analytics Tutorial

This repository is designed for a hands-on workshop on **Vibe Coding** — pair programming with an AI assistant.  
The goal: practice the full loop of **Plan → MVP → Debug → Iterate → Deliver** while analyzing a Kaggle dataset of Uber rides.

---
## Project Structure
```
uber-vibe-coding-r/
├─ data/ # Place Kaggle CSV files here (not tracked by git)
├─ R/ # R scripts (MVP, cleaning, EDA, report, model)
├─ tests/ # testthat regression tests
├─ fig/ # Generated figures
├─ report/ # RMarkdown report output
├─ .gitignore
├─ README.md
└─ renv.lock # (optional) reproducible environment file
```

---
## Prerequisites
- R
- RStudio or Cursor / VS Code with R extension  
- Packages:  

```{r}
install.packages(c(
  "tidyverse", "lubridate", "janitor", "forcats",
  "ggplot2", "scales", "glue", "testthat",
  "rsample", "yardstick", "rmarkdown"
))
```

Dataset: 
https://www.kaggle.com/datasets/yashdevladdha/uber-ride-analytics-dashboard


R/10_mvp_read.R – MVP: Read & Inspect
- Goal: The minimum viable product. Just load the dataset and confirm it’s readable.
What it does:
- Checks if data/ncr_ride_bookings.csv exists.
- Reads the CSV using readr::read_csv().
- Prints number of rows and columns.
- Displays the first 5 rows (head() output).
- Stops with an error message if the file is missing.


R/20_clean.R – Cleaning & Feature Engineering
- Goal: Transform raw noisy data into a structured dataset ready for analysis.
What it does:
- Renames/standardizes columns (request_time, pickup_time, dropoff_time, status, vehicle_type, fare, distance_mi).
- Parses timestamps (lubridate::ymd_hms) → extracts date, hour, weekday.
- Normalizes status (e.g. “canceled” vs “cancelled”).
- Ensures numeric types for fare, distance_mi, etc.
- Flags invalid data (negative distances, fares, or negative trip durations).
- Saves the cleaned dataset to data/uber_clean.csv.


R/30_eda.R – Exploratory Data Analysis (EDA)
- Goal: Produce first insights and visualizations.
What it does:
- Loads the cleaned dataset (data/uber_clean.csv).
- Creates hourly ride volume plot (how many rides per hour of day).
- Creates cancel rate plot (by weekday and vehicle type).
- Saves figures into fig/hourly_volume.png and fig/cancel_rate.png.

  How to commit changes:
  in bash:
  -  nano .gitignore
  -  enter the following (using ctrl + o to save and ctrl + x to exit):
    
``` gitignore
# Ignore raw/processed data (but keep placeholder)
data/*
!data/.gitkeep

# Ignore RStudio temp/session files
.Rhistory
.RData
.Rproj.user

# Ignore Mac system files
.DS_Store

# Ignore generated figures/reports
!fig/*.png 
*.html
*.pdf
*.docx

# Ignore cache from R Markdown
*.utf8.md
*.knit.md
cache/

Then:
git add .gitignore README.md R/ fig/*.png
git commit -m "update README, add R scripts and generated figures"
git push origin main
