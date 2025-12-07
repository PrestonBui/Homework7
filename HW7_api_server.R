## Write your API endpoints in this file
library(plumber)
library(jsonlite)

model <- readRDS("model.rds")

predict_prob_internal <- function(model, newdata) {
  if (inherits(model, "randomForest")) {
    as.numeric(predict(model, newdata = newdata, type = "prob")[, 2])
  } else if (inherits(model, "glm")) {
    as.numeric(predict(model, newdata = newdata, type = "response"))
  } else stop("Unsupported model class")
}

parse_body_to_df <- function(req) {
  body <- jsonlite::fromJSON(req$postBody, simplifyDataFrame = TRUE)
  as.data.frame(body)
}

#* @serializer rds
#* @post /predict_prob
function(req) {
  newdata <- parse_body_to_df(req)
  predict_prob_internal(model, newdata)
}

#* @serializer rds
#* @post /predict_class
function(req, threshold = 0.5) {
  newdata <- parse_body_to_df(req)
  p <- predict_prob_internal(model, newdata)
  as.integer(p >= as.numeric(threshold))
}
