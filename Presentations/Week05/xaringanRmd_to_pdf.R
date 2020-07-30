# Script to create PDF copy of presentations ----
# per Yihui's guide here: https://github.com/yihui/xaringan/wiki/Export-Slides-to-PDF

library(pagedown)

# setwd() to the presentation folder, or else the knit will not work properly!

setwd("Presentations/Week2")

pagedown::chrome_print("Chap2slides.Rmd")

