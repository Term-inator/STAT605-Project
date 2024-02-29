library(ggplot2)

my_data <- read.csv("./data/airquality.csv")

calculate_AQI_O3_8hour <- function(c) {
  Linear <- function(Ih, Il, Ch, Cl, C) {
    return(((Ih - Il) / (Ch - Cl)) * (C - Cl) + Il)
  }
  
  if (c >= 0 && c < .055) {
    AQI <- Linear(50, 0, 0.054, 0, c)
  } else if (c >= .055 && c < .071) {
    AQI <- Linear(100, 51, .070, .055, c)
  } else if (c >= .071 && c < .086) {
    AQI <- Linear(150, 101, .085, .071, c)
  } else if (c >= .086 && c < .106) {
    AQI <- Linear(200, 151, .105, .086, c)
  } else if (c >= .106 && c < .201) {
    AQI <- Linear(300, 201, .200, .106, c)
  } else if (c >= .201 && c < .605) {
    AQI <- "O3message"
  } else {
    AQI <- "Out of Range"
  }
  
  return(AQI)
}


o3_values <- seq(0, max(my_data$X1st.Max.Value), by = 0.0001)

aqi_values <- sapply(o3_values, calculate_AQI_O3_8hour)
aqi_data <- data.frame(O3 = o3_values, AQI = aqi_values)

ggplot(my_data, aes(x = X1st.Max.Value, y = AQI)) +
  geom_point(aes(color = as.factor(Event.Type))) +
  # geom_line(data = aqi_data, aes(x = O3, y = AQI), color = "blue", size = 1) +
  labs(color = 'Event Type')


abnormal <- my_data[which(abs(sapply(my_data$X1st.Max.Value, calculate_AQI_O3_8hour) - my_data$AQI) > 2),]