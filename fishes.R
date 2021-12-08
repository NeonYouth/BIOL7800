model <- unet(input_shape = c(128, 128, 3))


data <- tibble(
  img = list.files(here::here("images"), full.names = TRUE),
  mask = list.files(here::here("mask"), full.names = TRUE)
)

data <- initial_split(data, prop = 0.8)

training_dataset <- training(data) %>%
  tensor_slices_dataset() %>%
  dataset_map(~.x %>% list_modify(
    # decode_jpeg yields a 3d tensor of shape (1280, 1918, 3)
    img = tf$image$decode_jpeg(tf$io$read_file(.x$img)),
    # decode_gif yields a 4d tensor of shape (1, 1280, 1918, 3),
    # so we remove the unneeded batch dimension and all but one
    # of the 3 (identical) channels
    mask = tf$image$decode_jpeg(tf$io$read_file(.x$mask))
  ))

example <- training_dataset %>% as_iterator() %>% iter_next()
example

training_dataset <- training_dataset %>%
  dataset_map(~.x %>% list_modify(
    img = tf$image$convert_image_dtype(.x$img, dtype = tf$float32),
    mask = tf$image$convert_image_dtype(.x$mask, dtype = tf$float32)
  ))

training_dataset <- training_dataset %>%
  dataset_map(~.x %>% list_modify(
    img = tf$image$resize(.x$img, size = shape(128, 128)),
    mask = tf$image$resize(.x$mask, size = shape(128, 128))
  ))


##Data augmentation function
random_bsh <- function(img) {
  img %>%
    tf$image$random_brightness(max_delta = 0.3) %>%
    tf$image$random_contrast(lower = 0.5, upper = 0.7) %>%
    tf$image$random_saturation(lower = 0.5, upper = 0.7) %>%
    tf$clip_by_value(0, 1)
}

training_dataset <- training_dataset %>%
  dataset_map(~.x %>% list_modify(
    img = random_bsh(.x$img)
  ))

example <- training_dataset %>% as_iterator() %>% iter_next()
example$img %>% as.array() %>% as.raster() %>% plot()


#create_dataset function
create_dataset <- function(data, train, batch_size = 32L) {

  dataset <- data %>%
    tensor_slices_dataset() %>%
    dataset_map(~.x %>% list_modify(
      img = tf$image$decode_jpeg(tf$io$read_file(.x$img)),
      mask = tf$image$decode_jpeg(tf$io$read_file(.x$mask))
    )) %>%
    dataset_map(~.x %>% list_modify(
      img = tf$image$convert_image_dtype(.x$img, dtype = tf$float32),
      mask = tf$image$convert_image_dtype(.x$mask, dtype = tf$float32)
    )) %>%
    dataset_map(~.x %>% list_modify(
      img = tf$image$resize(.x$img, size = shape(128, 128)),
      mask = tf$image$resize(.x$mask, size = shape(128, 128))
    ))

  # data augmentation performed on training set only
  if (train) {
    dataset <- dataset %>%
      dataset_map(~.x %>% list_modify(
        img = random_bsh(.x$img)
      ))
  }

  # shuffling on training set only
  if (train) {
    dataset <- dataset %>%
      dataset_shuffle(buffer_size = batch_size*128)
  }

  # train in batches; batch size might need to be adapted depending on
  # available memory
  dataset <- dataset %>%
    dataset_batch(batch_size)

  dataset %>%
    # output needs to be unnamed
    dataset_map(unname)
}

training_dataset <- create_dataset(training(data), train = TRUE)
validation_dataset <- create_dataset(testing(data), train = FALSE)



dice <- custom_metric("dice", function(y_true, y_pred, smooth = 1.0) {
  y_true_f <- k_flatten(y_true)
  y_pred_f <- k_flatten(y_pred)
  intersection <- k_sum(y_true_f * y_pred_f)
  (2 * intersection + smooth) / (k_sum(y_true_f) + k_sum(y_pred_f) + smooth)
})

model %>% compile(
  optimizer = optimizer_rmsprop(learning_rate = 1e5),
  loss = "binary_crossentropy",
)

model %>% fit(
  training_dataset,
  epochs = 1,
  validation_data = validation_dataset
)

batch <- validation_dataset %>% as_iterator() %>% iter_next()
predictions <- predict(model, batch[2])

images <- tibble(
  image = batch[[1]] %>% array_branch(1),
  predicted_mask = predictions[,,,1] %>% array_branch(1),
  mask = batch[[2]][,,,1]  %>% array_branch(1)
) %>%
  sample_n(2) %>%
  map_depth(2, function(x) {
    as.raster(x) %>% magick::image_read()
  }) %>%
  map(~do.call(c, .x))


out <- magick::image_append(c(
  magick::image_append(images$mask, stack = TRUE),
  magick::image_append(images$image, stack = TRUE),
  magick::image_append(images$predicted_mask, stack = FALSE)
)
)

plot(out)
