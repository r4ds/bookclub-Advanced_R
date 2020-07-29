# Script to create PDF copy of presentations ----
# per Yihui's guide here: https://github.com/yihui/xaringan/wiki/Export-Slides-to-PDF

library(pagedown)

# setwd() to the presentation folder, or else the knit will not work properly!

old_dir <- setwd(here::here("Presentations", "Week11"))

pagedown::chrome_print("Chapter11.Rmd")

setwd(old_dir)
