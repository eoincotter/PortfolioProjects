library(shiny)
library(shinythemes)
library(tidyverse)
library(odbc)
library(DBI)
library(plyr)

# # open db connection - local
db_connection <- dbConnect(drv = odbc::odbc(),
                           driver = "SQL Server",
                           server = server,
                           database = dbname,
                           uid = userid,
                           pwd = password)

# import data from database and store as dataframe
habits_and_health_data <- dbGetQuery(db_connection, "SELECT * FROM habits_and_health_data") %>%
  mutate(date = as.Date(date),
         calorie_intake = as.numeric(calorie_intake)) %>%
  arrange(date)

# create dataset for heatmap ####
habit_data <- habits_and_health_data %>%
  mutate(
         weekday = factor(format(date, "%a"), levels = c("Sun", "Sat", "Fri", "Thu", "Wed", "Tue", "Mon")),
         week_number = format(date, "%W"),
         year = format(date, "%Y"),
         resistance_training = case_when(resistance_training_mins >= 60 ~ 1,
                                         resistance_training_mins < 60 ~ 0),
         yoga = case_when(`yoga_mins` >= 30 ~ 1,
                          `yoga_mins` < 30 ~ 0),
         resistance_training_or_yoga = case_when(resistance_training_mins >= 60 | yoga_mins >= 30 ~ 1,
                                                 is.na(resistance_training_mins) | is.na(yoga_mins) ~ NA_real_,
                                                 TRUE ~ 0),
         run = case_when(`run_distance` > 0 ~ 1,
                         `run_distance` == 0 ~ 0),
         meditation = case_when(`meditation_mins` >= 20 ~ 1,
                                `meditation_mins` < 20 ~ 0),
         journal = case_when(journal == 'Yes' ~ 1,
                             journal == 'No' ~ 0),
         cold_shower = case_when(`cold_shower` == 'Yes' ~ 1,
                                 `cold_shower` == 'No' ~ 0),
         book_reading = case_when(`book_reading_mins` >= 30 ~ 1,
                                  `book_reading_mins` < 30 ~ 0),
         meditation_study = case_when(`meditation_study_mins` >= 10 ~ 1,
                                      `meditation_study_mins` < 10 ~ 0),
         read_newsletters = case_when(`read_newsletters` == 'Yes' ~ 1,
                                        `read_newsletters` == 'No' ~ 0),
         analytics_project = case_when(`analytics_project_mins` >= 60 ~ 1,
                                       `analytics_project_mins` < 60 ~ 0),
         ) %>%
  select(
         date,
         weekday,
         week_number,
         year,
         resistance_training,
         yoga,
         resistance_training_or_yoga,
         run,
         meditation,
         journal,
         cold_shower,
         book_reading,
         meditation_study,
         read_newsletters,
         analytics_project
  )

# Define UI ####
ui <- navbarPage(
  # application title
  title = "Habits & Health Insights",
  
  # set the theme
  theme = shinytheme("cosmo"),
  
  # define the UI for the Data Input page ####
  tabPanel("Data Input",
           fluidRow(
             column(
               width = 12,
               align = "center",
               dateInput(
                 "date_input",
                 "Choose a date",
                 format = "d M yyyy",
                 weekstart = 1,
                 value = as.Date(Sys.Date()),
                 max = as.Date(Sys.Date())
               ),
               h3("Health"),
               numericInput("sleep_hrs", "Sleep hours", value = NULL),
               numericInput("protein_intake", "Protein intake %", value = NULL, step = 1, min = 0, max = 100),
               numericInput("calorie_intake", "Calorie intake (kcal)", value = NULL),
               numericInput("weight", "Weight (kg)", value = NULL),
               numericInput("fat", "Fat %", value = NULL),
               numericInput("muscle", "Muscle %", value = NULL),
               numericInput("bone", "Bone %", value = NULL),
               numericInput("hydration", "Hydration", value = NULL),
               h3("Exercise"),
               numericInput("yoga_mins", "Yoga minutes", value = NULL, min = 0, max = 1440),
               numericInput("resistance_training_mins", "Resistance training minutes", value = NULL, min = 0, max = 1440),
               numericInput("run_distance", "Run distance", value = NULL),
               textInput("run_time", "Run time (HH:MM:SS)", placeholder = "HH:MM:SS"),
               h3("Mental Well-Being"),
               selectInput("journal", "Journal?", choices = c("", "Yes", "No")),
               selectInput("cold_shower", "Cold shower?", choices = c("","Yes", "No")),
               numericInput("meditation_mins", "Meditation minutes", value = NULL, min = 0, max = 1440),
               h3("Learning"),
               numericInput("meditation_study_mins", "Meditation study minutes", value = NULL, min = 0, max = 1440),
               numericInput("book_reading_mins", "Book reading minutes", value = NULL, min = 0, max = 1440),
               numericInput("analytics_project_mins", "Analytics project minutes", value = NULL),
               selectInput("read_newsletters", "Read newsletters?", choices = c("", "Yes", "No")),
               h3("Other"),
               selectInput("watch_movie", "Watch movie?", choices = c("", "Yes", "No")),
               selectInput("GTD_weekly_review", "GTD weekly review?", choices = c("", "Yes", "No")),
               h3("Leg Exercises"),
               numericInput("deadlift", "Deadlift", value = NULL, min = 0),
               numericInput("rdl", "RDL", value = NULL, min = 0),
               numericInput("fortyfive_degree_leg_press", "45 degree leg press", value = NULL, min = 0),
               numericInput("horizontal_leg_press", "Horizontal leg press", value = NULL, min = 0),
               numericInput("lying_hamstring_curl", "Lying hamstring curl", value = NULL, min = 0),
               h3("Push Exercises"),
               numericInput("bench_press", "Bench press", value = NULL, min = 0),
               numericInput("seated_barbell_shoulder_press", "Seated barbell shoulder press", value = NULL, min = 0),
               numericInput("seated_dumbbell_shoulder_press", "Seated dumbbell shoulder press", value = NULL, min = 0),
               numericInput("machine_shoulder_press", "Machine shoulder press", value = NULL, min = 0),
               numericInput("rope_tricep_pushdown", "Rope tricep pushdown", value = NULL, min = 0),
               numericInput("bar_tricep_pushdown", "Bar tricep pushdown", value = NULL, min = 0),
               h3("Pull Exercises"),
               numericInput("ez_bar_bicep_curl", "EZ-Bar bicep curl", value = NULL, min = 0),
               numericInput("seated_pulley_row", "Seated pulley row", value = NULL, min = 0),
               numericInput("barbell_row", "Barbell row", value = NULL, min = 0),
               numericInput("lat_pulldown", "Lat pulldown", value = NULL, min = 0),
               numericInput("isolateral_front_lat_pulldown", "Isolateral front lat pulldown", value = NULL, min = 0),
               h3("Ab Exercises"),
               numericInput("pulley_crunch", "Pulley crunch", value = NULL, min = 0),
               numericInput("oblique_twist", "Oblique twist", value = NULL, min = 0),
               numericInput("forearm_leg_raises", "Forearm leg raises", value = NULL, min = 0),
               h3("Submit"),
               textInput("password", "Enter password for data submission"),
               actionButton(
                 "submit_data",
                 "Submit data"
               ),
               textOutput("submission_confirmation") 
             )
           )
  ),

  # define the UI for the "Habits" page ####
  tabPanel("Habits",
           fluidRow(
             column(
               width = 12,
               align = "center",
               selectInput(
                 "habit_selection",
                 "Select a habit",
                 choices = c(
                   "Resistance training",
                   "Yoga",
                   "Resistance training or yoga",
                   "Run",
                   "Meditation",
                   "Journalling",
                   "Cold shower",
                   "Book reading",
                   "Meditation study",
                   "Newsletter reading",
                   "Analytics project"
                 )
               ),
               selectInput(
                 "year_selection",
                 "Select a year",
                 choices = c(
                   "2023"
                 )
               ),
               dateRangeInput(
                 "date_range_selection",
                 "Select a date range",
                 start = "2023-01-01",
                 end = Sys.Date(),
                 format = "d M yyyy",
                 weekstart = 1
               )
             )
           ),
           fluidRow(
             column(
               width = 12,
               plotOutput("habit_plot")
             )
           )
  ),

  # define the UI for the "Health & Exercise" page ####
  tabPanel("Health & Exercise",
           fluidRow(
             column(width = 3,
                    dateRangeInput(
                      "date_range",
                      "Date range",
                      start = "2023-06-19",
                      end = "2023-07-30",
                      format = "d M yyyy",
                      weekstart = 1
                    ),
                    selectInput(
                      "resistance_exercise_selection", 
                      label = "Select resistance exercise to display",
                      choices = c(
                        "RDL" = "rdl",
                        "Leg press" = "horizontal_leg_press",
                        "Bench press" = "bench_press",
                        "Shoulder press" = "seated_barbell_shoulder_press",
                        "Tricep pushdown" = "bar_tricep_pushdown",
                        "Bicep curl" = "ez_bar_bicep_curl",
                        "Lat pulldown" = "isolateral_front_lat_pulldown",
                        "Row" = "barbell_row",
                        "Pulley crunch" = "pulley_crunch",
                        "Leg raise" = "forearm_leg_raises",
                        "Oblique twist" = "oblique_twist"
                      )
                    )
             ),
             column(width = 5,
                    h3("Resistance Training Weight in KG"),
                    plotOutput("resistance_exercise_plot")
             ),
             column(width = 4,
                    h3("Running Distance in KM"),
                    plotOutput("run_plot"))
           ),
           fluidRow(
             column(width = 3,
                    h3("Energy Intake in Kcal"),
                    plotOutput("energy_intake_plot")
             )
             ,
             column(width = 5,
                    h3("Body Weight in KG"),
                    plotOutput("weight_plot")
             ),
             column(width = 4,
                    h3("Sleep Hours"),
                    plotOutput("sleep_plot"))
           )
  )
)

# Define server logic ####
server <- function(input, output) {
  
  # action when the submit_data button is clicked
  observeEvent(input$submit_data, {
    
    if(input$password == password) {
      # SQL statement to execute
      sql_statement <- paste0("UPDATE habits_and_health_data
                               SET ", ifelse(is.na(input$yoga_mins), "", paste0("yoga_mins = ", input$yoga_mins, ", ")),
                              ifelse(is.na(input$resistance_training_mins), "", paste0("resistance_training_mins = ", input$resistance_training_mins, ", ")),
                              ifelse(input$cold_shower == "", "", paste0("cold_shower = ", "'", input$cold_shower, "', ")),
                              ifelse(is.na(input$meditation_mins), "", paste0("meditation_mins = ", input$meditation_mins, ", ")),
                              ifelse(is.na(input$meditation_study_mins), "", paste0("meditation_study_mins = ", input$meditation_study_mins, ", ")),
                              ifelse(is.na(input$book_reading_mins), "", paste0("book_reading_mins = ", input$book_reading_mins, ", ")),
                              ifelse(is.na(input$analytics_project_mins), "", paste0("analytics_project_mins = ", input$analytics_project_mins, ", ")),
                              ifelse(input$read_newsletters == "", "", paste0("read_newsletters = ", "'", input$read_newsletters, "', ")),
                              ifelse(input$journal == "", "", paste0("journal = ", "'", input$journal, "', ")),
                              ifelse(is.na(input$sleep_hrs), "", paste0("sleep_hrs = ", input$sleep_hrs, ", ")),
                              ifelse(is.na(input$protein_intake), "", paste0("protein_intake = ", input$protein_intake, ", ")),
                              ifelse(is.na(input$calorie_intake), "", paste0("calorie_intake = ", input$calorie_intake, ", ")),
                              ifelse(is.na(input$weight), "", paste0("weight = ", input$weight, ", ")),
                              ifelse(is.na(input$run_distance), "", paste0("run_distance = ", input$run_distance, ", ")),
                              ifelse(input$run_time == "", "", paste0("run_time = ", "'", input$run_time, "', ")),
                              ifelse(is.na(input$deadlift), "", paste0("deadlift = ", input$deadlift, ", ")),
                              ifelse(is.na(input$rdl), "", paste0("rdl = ", input$rdl, ", ")),
                              ifelse(is.na(input$forearm_leg_raises), "", paste0("forearm_leg_raises = ", input$forearm_leg_raises, ", ")),
                              ifelse(is.na(input$bench_press), "", paste0("bench_press = ", input$bench_press, ", ")),
                              ifelse(is.na(input$seated_barbell_shoulder_press), "", paste0("seated_barbell_shoulder_press = ", input$seated_barbell_shoulder_press, ", ")),
                              ifelse(is.na(input$seated_dumbbell_shoulder_press), "", paste0("seated_dumbbell_shoulder_press = ", input$seated_dumbbell_shoulder_press, ", ")),
                              ifelse(is.na(input$ez_bar_bicep_curl), "", paste0("ez_bar_bicep_curl = ", input$ez_bar_bicep_curl, ", ")),
                              ifelse(is.na(input$fortyfive_degree_leg_press), "", paste0("fortyfive_degree_leg_press = ", input$fortyfive_degree_leg_press, ", ")),
                              ifelse(is.na(input$horizontal_leg_press), "", paste0("horizontal_leg_press = ", input$horizontal_leg_press, ", ")),
                              ifelse(is.na(input$lying_hamstring_curl), "", paste0("lying_hamstring_curl = ", input$lying_hamstring_curl, ", ")),
                              ifelse(is.na(input$pulley_crunch), "", paste0("pulley_crunch = ", input$pulley_crunch, ", ")),
                              ifelse(is.na(input$seated_pulley_row), "", paste0("seated_pulley_row = ", input$seated_pulley_row, ", ")),
                              ifelse(is.na(input$lat_pulldown), "", paste0("lat_pulldown = ", input$lat_pulldown, ", ")),
                              ifelse(is.na(input$machine_shoulder_press), "", paste0("machine_shoulder_press = ", input$machine_shoulder_press, ", ")),
                              ifelse(is.na(input$rope_tricep_pushdown), "", paste0("rope_tricep_pushdown = ", input$rope_tricep_pushdown, ", ")),
                              ifelse(is.na(input$bar_tricep_pushdown), "", paste0("bar_tricep_pushdown = ", input$bar_tricep_pushdown, ", ")),
                              ifelse(is.na(input$oblique_twist), "", paste0("oblique_twist = ", input$oblique_twist, ", ")),
                              ifelse(input$watch_movie == "", "", paste0("movie = ", "'", input$watch_movie, "', ")),
                              ifelse(input$GTD_weekly_review == "", "", paste0("GTD_weekly_review = ", "'", input$GTD_weekly_review, "', ")),
                              ifelse(is.na(input$barbell_row), "", paste0("barbell_row = ", input$barbell_row, ", ")),
                              ifelse(is.na(input$isolateral_front_lat_pulldown), "", paste0("isolateral_front_lat_pulldown = ", input$isolateral_front_lat_pulldown, ", ")),
                              ifelse(is.na(input$fat), "", paste0("fat = ", input$fat, ", ")),
                              ifelse(is.na(input$hydration), "", paste0("hydration = ", input$hydration, ", ")),
                              ifelse(is.na(input$muscle), "", paste0("muscle = ", input$muscle, ", ")),
                              ifelse(is.na(input$bone), "", paste0("bone = ", input$bone, ", ")),
                              "date = '", input$date_input, "' ",
                              "WHERE date = '", input$date_input, "'")
      
      # Execute the SQL statement
      dbExecute(db_connection, statement = sql_statement)
      
      # display message to user
      output$submission_confirmation <- renderText("Submitted")
    }
    
    else {
      output$submission_confirmation <- renderText("Incorrect password")
    }
    
  })
  
  # Reactive expression to filter the habits_data dataset based on user input
  filtered_habit_data <- reactive({
    # Perform the filtering operation based on the user input
    filtered_data <- habit_data %>% filter(year == input$year_selection, 
                                           between(date, input$date_range_selection[1], input$date_range_selection[2])
                                           )
    
    # Return the filtered dataset
    filtered_data
  })
  
  # Generate heat map
  output$habit_plot <- renderPlot({
    ggplot(filtered_habit_data(), 
           aes(x = week_number, 
               y = weekday, 
               fill = case_when(
                 input$habit_selection == "Resistance training" ~ resistance_training,
                 input$habit_selection == "Yoga" ~ yoga,
                 input$habit_selection == "Resistance training or yoga" ~ resistance_training_or_yoga,
                 input$habit_selection == "Run" ~ run,
                 input$habit_selection == "Meditation" ~ meditation,
                 input$habit_selection == "Journalling" ~ journal,
                 input$habit_selection == "Cold shower" ~ cold_shower,
                 input$habit_selection == "Book reading" ~ book_reading,
                 input$habit_selection == "Meditation study" ~ meditation_study,
                 input$habit_selection == "Newsletter reading" ~ read_newsletters,
                 input$habit_selection == "Analytics project" ~ analytics_project
                      )
           )
    ) +
      geom_tile(color = "white",
                lwd = 1.5,
                linetype = 1) +
      scale_fill_gradient(low = "red", high = "green") +
      coord_fixed() +
      theme(legend.position = "none")
  })  
  
  # Generate "Health & Exercise" page plots ####
  # Define a custom theme
  my_theme <- theme_bw(base_size = 12) +
    theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text = element_text(colour = "black"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major = element_line(colour = "gray90"),
    panel.grid.minor = element_line(colour = "gray90")
  )
  
  # Apply the custom theme to all plots
  theme_set(my_theme)
  
  # Generate weight plot
  output$weight_plot <- renderPlot({
    ggplot(habits_and_health_data, mapping = aes(x = date, y = weight)) +
     geom_point() +
     geom_smooth(se = FALSE) +
     scale_x_date(date_breaks = "2 weeks", date_labels = "%d/%m", minor_breaks = "1 week", limits = input$date_range) +
     scale_y_continuous(breaks = seq(0, round_any(max(habits_and_health_data$weight, na.rm = TRUE), 1, ceiling), by = 1))
  })
  
  # Generate energy intake plot
  output$energy_intake_plot <- renderPlot({
    ggplot(habits_and_health_data) +
      geom_col(mapping = aes(x = date, y = calorie_intake)) +
      scale_x_date(date_breaks = "2 weeks", date_labels = "%d/%m", minor_breaks = "1 week", limits = input$date_range) +
      scale_y_continuous(limits = c(0, max(habits_and_health_data$calorie_intake, na.rm = TRUE) + max(habits_and_health_data$calorie_intake, na.rm = TRUE)*.05), 
                         expand = c(0,0), 
                         breaks = seq(0, round_any(max(habits_and_health_data$calorie_intake, na.rm = TRUE), 500, ceiling), by = 500))
  })
  
  # Generate running plot
  output$run_plot <- renderPlot({
    ggplot(habits_and_health_data) +
      geom_col(mapping = aes(x = date, y = run_distance)) +
      scale_x_date(date_breaks = "2 weeks", date_labels = "%d/%m", minor_breaks = "1 week", limits = input$date_range) +
      scale_y_continuous(limits = c(0, max(habits_and_health_data$run_distance, na.rm = TRUE) + max(habits_and_health_data$run_distance, na.rm = TRUE)*.05), 
                         expand = c(0,0))
  })
  
  
  # Generate sleep plot
  output$sleep_plot <- renderPlot({
    ggplot(habits_and_health_data) +
      geom_col(mapping = aes(x = date, y = sleep_hrs)) +
      scale_x_date(date_breaks = "2 weeks", date_labels = "%d/%m", minor_breaks = "1 week", limits = input$date_range) +
      scale_y_continuous(limits = c(0, max(habits_and_health_data$sleep_hrs, na.rm = TRUE) + max(habits_and_health_data$sleep_hrs, na.rm = TRUE)*.05), 
                         expand = c(0,0),
                         breaks = seq(0, round_any(max(habits_and_health_data$sleep_hrs, na.rm = TRUE), 1, ceiling), by = 1))
  })

  # Generate resistance exercise plot
  output$resistance_exercise_plot <- renderPlot({
    ggplot(habits_and_health_data, mapping = aes(x = date, y = !!sym(input$resistance_exercise_selection))) +
      geom_point() +
      scale_x_date(date_breaks = "2 weeks", date_labels = "%d/%m", minor_breaks = "1 week", limits = input$date_range)
  })
  
}

# Create Shiny App ####
shinyApp(ui = ui, server = server)

