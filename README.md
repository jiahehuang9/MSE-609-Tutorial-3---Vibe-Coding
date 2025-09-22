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
