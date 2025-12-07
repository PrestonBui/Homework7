## Write your client test code here
library(httr)
library(readr)
library(dplyr)
library(lubridate)

base_url <- "http://127.0.0.1:8000"

fe <- function(df) {
  df %>%
    mutate(
      days_wait = as.numeric(difftime(appt_time, appt_made, units = "days")),
      hour      = lubridate::hour(appt_time),
      weekday   = lubridate::wday(appt_time, label = TRUE),
      month     = lubridate::month(appt_time, label = TRUE)
    )
}

test <- readr::read_csv("test_dataset.csv.gz", show_col_types = FALSE)
test <- fe(test)

new_patients <- test[1:5, c("age","address","specialty","provider_id",
                            "days_wait","hour","weekday","month")]

resp_prob <- POST(
  url   = paste0(base_url, "/predict_prob"),
  body  = new_patients,
  encode = "json"
)

prob_vec <- unserialize(content(resp_prob, as = "raw"))
print(prob_vec)

resp_class <- POST(
  url   = paste0(base_url, "/predict_class"),
  body  = new_patients,
  encode = "json"
)

class_vec <- unserialize(content(resp_class, as = "raw"))
print(class_vec)
