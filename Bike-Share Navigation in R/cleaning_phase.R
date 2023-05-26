library(tidyverse)
library(lubridate)
library(janitor)
library(ggplot2)
library(scales)


        # Setting the directory and importing the data: 



getwd()
setwd("/Users/Seth/Desktop/Data analysis/Case Study/bike_share/scnd_pro/data_cleaning")
q2_2019 = read.csv("Divvy_Trips_2019_Q2.csv")
q3_2019 = read.csv("Divvy_trips_2019_Q3.csv")
q4_2019 = read.csv("Divvy_trips_2019_Q4.csv")
q1_2020 = read.csv("Divvy_trips_2020_Q1.csv")



        # DATA EXPLORATION



# Looking at column names

colnames(q2_2019)
colnames(q3_2019)
colnames(q4_2019)
colnames(q1_2020)

# Renaming cols to be consistent with q1_2020;

q3_2019 = rename(q3_2019,
                 ride_id = trip_id,
                 rideable_type = bikeid,
                 started_at = start_time, 
                 ended_at = end_time,
                 start_station_name = from_station_name,
                 start_station_id = from_station_id,
                 end_station_name = to_station_name,
                 end_station_id = to_station_id,
                 member_casual = usertype)

q4_2019 = rename(q4_2019, 
                 ride_id = trip_id,
                 rideable_type = bikeid,
                 started_at = start_time, 
                 ended_at = end_time,
                 start_station_name = from_station_name,
                 start_station_id = from_station_id,
                 end_station_name = to_station_name,
                 end_station_id = to_station_id,
                 member_casual = usertype)

q2_2019 = rename(q2_2019,
                 ride_id = X01...Rental.Details.Rental.ID,
                 rideable_type = X01...Rental.Details.Bike.ID,
                 started_at = X01...Rental.Details.Local.Start.Time, 
                 ended_at = X01...Rental.Details.Local.End.Time,
                 start_station_name = X03...Rental.Start.Station.Name,
                 start_station_id = X03...Rental.Start.Station.ID,
                 end_station_name = X02...Rental.End.Station.Name,
                 end_station_id = X02...Rental.End.Station.ID,
                 member_casual = User.Type)


# Inspecting the dataframes: 
str(q2_2019)
str(q3_2019)
str(q4_2019)
str(q1_2020)

# Converting the ride_id & ride_type to chr; to be stacked correctly
q4_2019 = mutate(q4_2019, ride_id = as.character(ride_id),
                 rideable_type = as.character(rideable_type))
q3_2019 = mutate(q3_2019, ride_id = as.character(ride_id),
                 rideable_type = as.character(rideable_type))               
q2_2019 = mutate(q2_2019, ride_id = as.character(ride_id), 
                 rideable_type = as.character(rideable_type))                 
                 
                
# Combining all the data into one dataframe:

all_trips = bind_rows(q2_2019, q3_2019, q4_2019, q1_2020)


# Removing dispensable columns

all_trips = all_trips %>%
  select(-c(start_lat, start_lng, end_lat, end_lng, birthyear, gender,
            "X01...Rental.Details.Duration.In.Seconds.Uncapped",
            "X05...Member.Details.Member.Birthday.Year",
            "Member.Gender", "tripduration"))



          # CLEAN UP DATA FOR ANALYSIS



# Inspecting data once more

colnames(all_trips) # List of col names
nrow(all_trips) # How many rows in the data frame
dim(all_trips) # Dimensions of the data frame
head(all_trips) # See the first 6 rows of the data frame. 
tail(all_trips) # See the last 6 rows of the data frame
str(all_trips) # See list of cols and data types(numeric, character, etc.)
summary(all_trips) # Statistical summary of data. Mainly for numeric data types.





# There are a few problems we will need to fix:
# (1) In the "member_casual" column, there are two names for members 
# ("member" and "Subscriber") and two names for casual riders 
# ("Customer" and "casual"). We will need to consolidate that from four
# to two labels.


# (2) The data can only be aggregated at the ride-level, which is too granular.
# We will want to add some additional columns of data -- such as day,
# month, year -- that provide additional opportunities to aggregate the data.

# (3) We will want to add a calculated field for length of ride since the
# 2020Q1 data did not have the "tripduration" column. We will add "ride_length"
# to the entire dataframe for consistency.

# (4) There are some rides where tripduration shows up as negative, including 
# several hundred rides where Divvy took bikes out of circulation for Quality
# Control reasons. We will want to delete these rides.


# See how many observations fall under each usertype

table(all_trips$member_casual)


# The abbreviation NB comes from the Latin phrase “nota bene,” which means “mark well.”
# N.B.: "Level" is a special property of a column that is retained even 
# if a subset does not contain any values from a specific level

# Reassigning values to the 2020 labels:

all_trips = all_trips %>%
  mutate(member_casual = recode(member_casual,
                                "Subscriber" = "member",
                                "Customer" = "casual"))



# Adding cols to aggregate the data.
# https://www.statmethods.net/input/dates.html  This website will help you with formats

all_trips$date = as.Date(all_trips$started_at) # The default format is yyyy-mm-dd
all_trips$month = format(as.Date(all_trips$date), "%m") # Fromats months.
all_trips$day = format(as.Date(all_trips$date), "%d") # Formats day
all_trips$year = format(as.Date(all_trips$date), "%Y") # Formats as year for digits
all_trips$day_of_week = format(as.Date(all_trips$date), "%A") # unabbreviated weekday

# Converting started_at & ended_at to int
all_trips$started_at = ymd_hms(all_trips$started_at) # Coming from lubridate
all_trips$ended_at = ymd_hms(all_trips$ended_at) # Coming From lubridateall_trips


# Adding "ride_length" col in seconds
all_trips$ride_length = difftime(all_trips$ended_at, all_trips$started_at)


# Convert "ride_length" from Factor to numeric so we can run calculations on the data
is.factor(all_trips$ride_length)
all_trips$ride_length = as.numeric(all_trips$ride_length)
is.numeric(all_trips$ride_length)

# Checking the data: 
glimpse(all_trips)


# Removing Bad Data, because there are data in the "ride_length" col that are negative
# These need to be removed. Created another dataframe.

# check this website: https://www.datasciencemadesimple.com/delete-or-drop-rows-in-r-with-conditions-2/

all_trips_v2 = all_trips[!(all_trips$start_station_name == "HQ QR" | all_trips$ride_length < 0),]



          # CONDUCTING DESCRIPTIVE ANALYSIS



# You can use the summary() to find the mean, median, max, and min.
summary(all_trips_v2)


# You can use the aggregate function to compare members and casual users.
# Aggregate() Function in R Splits the data into subsets, computes summary 
# statistics for each subsets and returns the result in a group by form
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = min)

# Make the weekdays in order for a better understanding.
all_trips_v2$day_of_week = ordered(all_trips_v2$day_of_week,
                                   levels = c("Sunday",
                                              "Monday",
                                              "Tuesday",
                                              "Wednesday",
                                              "Thursday",
                                              "Friday",
                                              "Saturday"))


# The Average ride tibe by each day for members vs casuals:
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual +
            all_trips_v2$day_of_week, FUN = mean)




all_trips_v2 %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>% # Creates weekday field
  group_by(member_casual, weekday) %>% # Group by usertype and weekdays
      # The function n() returns the number of observations in a current group. 
  summarise(number_of_rides = n(),
            average_duration = mean(ride_length)) %>% # Calculates the avg
  arrange(member_casual, weekday) # For Sorting




          # Visualizations:



# Visualization for number of rides for each user type
all_trips_v2 %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>%
  group_by(member_casual, weekday) %>%
  summarise(number_of_rides = n(),
            avg_duration = mean(ride_length)) %>%
  arrange(member_casual, weekday) %>%
  ggplot() + geom_col(mapping = aes(x = weekday, y = number_of_rides,
                                    fill = member_casual), position = "dodge") +
  scale_y_continuous(labels = comma)


# Visualization for the duration of each user type
all_trips_v2 %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>%
  group_by(member_casual, weekday) %>%
  summarise(number_of_rides = n(),
            avg_duration = mean(ride_length)) %>%
  arrange(member_casual, weekday) %>%
  ggplot() + geom_col(mapping = aes(x = weekday, y = avg_duration,
                                    fill = member_casual), position = "dodge") +
  scale_y_continuous(labels = comma)



          # Exporting the summary file for further analysis



counts = aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual +
                     all_trips_v2$day_of_week, FUN = mean)
# https://datatofish.com/export-dataframe-to-csv-in-r/
write.csv(counts, file = "/Users/Seth/Desktop/Data analysis/Case Study/bike_share/scnd_pro/avg_ride_length.csv")


          # My Further Analysis

# To get the number of rides and save them into a spreadsheet

member_casual_info = all_trips_v2 %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>%
  group_by(member_casual, weekday) %>%
  summarise(number_of_rides = n(),
            avg_duration = mean(ride_length))


# Finally, we export the dataset to do some further visualization and analyses.
write.csv(member_casual_info, file = "/Users/Seth/Desktop/Data analysis/Case Study/bike_share/scnd_pro/member_casual_info.csv")
      
                 