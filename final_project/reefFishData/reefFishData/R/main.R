# reefFishData includes a dataset of red sea reef fish images, their corresponding
# segmentation masks, and functions for displaying these images, as well as splitting
# them into training and testing datasets.

# More information on this dataset can be found here:
# https://www.kaggle.com/metavision/accurate-red-sea-reef-fish-shapessegmentation


remotes::install_github("r-tensorflow/unet", force = TRUE)
install.packages("magick")
library(magick)
library(unet)
library(tfdatasets)
library(tidyverse)
library(rsample)
library(reticulate)


# reads images and masks in from defined directory,
# could be improved by passing filepath

load_image_tibble = function(){

  image_tibble = tibble(
    img = list.files(here::here("720p"), all.files = TRUE, full.names= FALSE),
    mask = list.files(here::here("mask"), all.files = TRUE, full.names= FALSE)
  ) %>%
    sample_n(2) %>%
    map(. %>% magick::image_read() %>% magick::image_resize("128x128"))

  out = magick::image_append(c(
    magick::image_append(image_tibble$img, stack = TRUE),
    magick::image_append(image_tibble$mask, stack = TRUE)
  )
  )

  return (image_tibble)
}

load_image_tibble()

image_tibble = tibble(
  img = list.files(here::here("720p"), all.files = TRUE, full.names= FALSE),
  mask = list.files(here::here("mask"), all.files = TRUE, full.names = FALSE)
)

#splits the input data into training and testing data
data_split = function(image_tibble){
  data = initial_split(image_tibble, prop = 0.8)
  return(data)
}
train = data_split(image_tibble)
