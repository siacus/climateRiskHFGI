# MIT License
#
# Copyright (c) Stefano M. Iacus
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

library(shiny)
library(data.table)
library(sf)
library(ggplot2)
library(viridis)
library(bslib)
library(shinyWidgets)
library(usmap)

# Load variable mapping
source("variable_mapping.R")

# Load latent scores data
latent_data <- fread("data/latent_scores.csv")
latent_data <- latent_data[, .(fips = sprintf("%05s", StateCounty), clim_risk, HEAT_RISK, FIRE_RISK, 
                               DROUGHT_RISK, COASTAL_RISK, WIND_RISK, INLAND_RISK,
                               charac_virt, altruism, charity, delaygrat, empathy, forgive, goodpromo, gratitude, volunteer,
                               relig, afterlife, believegod, lovedgod, relcomfort, relcrit, spiritpun,
                               inst_trust, govapprove, polvoice, discrim,
                               meaning, balance, hope, purpose, resilience,
                               social, belonging, loneliness, relationships, trust, trusted,
                               subj_welb, happiness, innerpeace, lifesat, optimism,
                               psy_dstrs, anxiety, depression, suffering, selfesteem,
                               physc_cond, energy, posfunct, vitality, healthlim, pain,
                               econ_stab, jobsat, mastery, fin_sec, future_sec)]

# Convert to regular dataframe
map_data <- as.data.frame(latent_data)

# Define variable choices for climate risk
climate_choices <- c(
  "Climate Risk (Latent)" = "clim_risk",
  "Heat Risk" = "HEAT_RISK",
  "Fire Risk" = "FIRE_RISK",
  "Drought Risk" = "DROUGHT_RISK",
  "Coastal Risk" = "COASTAL_RISK",
  "Wind Risk" = "WIND_RISK",
  "Inland Flood Risk" = "INLAND_RISK"
)

# Define HFGI latent variables with labels
hfgi_latents <- list(
  charac_virt = list(
    label = "Character Virtues",
    vars = c("Character Virtues (Latent)" = "charac_virt",
             "Altruism" = "altruism", "Charity" = "charity", 
             "Delayed Gratification" = "delaygrat", "Empathy" = "empathy",
             "Forgiveness" = "forgive", "Good Promotion" = "goodpromo",
             "Gratitude" = "gratitude", "Volunteering" = "volunteer")
  ),
  relig = list(
    label = "Religious & Spiritual",
    vars = c("Religious & Spiritual (Latent)" = "relig",
             "Afterlife Belief" = "afterlife", "Belief in God" = "believegod",
             "Loved by God" = "lovedgod", "Religious Comfort" = "relcomfort",
             "Religious Criticism" = "relcrit", "Spiritual Punishment" = "spiritpun")
  ),
  inst_trust = list(
    label = "Institutional Trust",
    vars = c("Institutional Trust (Latent)" = "inst_trust",
             "Government Approval" = "govapprove", "Political Voice" = "polvoice",
             "Discrimination" = "discrim")
  ),
  meaning = list(
    label = "Meaning & Purpose",
    vars = c("Meaning & Purpose (Latent)" = "meaning",
             "Balance" = "balance", "Hope" = "hope",
             "Purpose" = "purpose", "Resilience" = "resilience")
  ),
  social = list(
    label = "Social Connectedness",
    vars = c("Social Connectedness (Latent)" = "social",
             "Belonging" = "belonging", "Loneliness" = "loneliness",
             "Relationships" = "relationships", "Trust Others" = "trust",
             "Feel Trusted" = "trusted")
  ),
  subj_welb = list(
    label = "Subjective Wellbeing",
    vars = c("Subjective Wellbeing (Latent)" = "subj_welb",
             "Happiness" = "happiness", "Inner Peace" = "innerpeace",
             "Life Satisfaction" = "lifesat", "Optimism" = "optimism")
  ),
  psy_dstrs = list(
    label = "Psychological Distress",
    vars = c("Psychological Distress (Latent)" = "psy_dstrs",
             "Anxiety" = "anxiety", "Depression" = "depression",
             "Suffering" = "suffering", "Self-esteem" = "selfesteem")
  ),
  physc_cond = list(
    label = "Physical Condition",
    vars = c("Physical Condition (Latent)" = "physc_cond",
             "Energy" = "energy", "Positive Function" = "posfunct",
             "Vitality" = "vitality", "Health Limitations" = "healthlim",
             "Pain" = "pain")
  ),
  econ_stab = list(
    label = "Economic Stability",
    vars = c("Economic Stability (Latent)" = "econ_stab",
             "Job Satisfaction" = "jobsat", "Mastery" = "mastery",
             "Financial Security" = "fin_sec", "Future Security" = "future_sec")
  )
)

# UI
ui <- fluidPage(
  theme = bs_theme(bootswatch = "flatly"),
  titlePanel("Climate Risk & Human Flourishing: Spatial Comparison"),
  
  # Maps row - aligned at top
  fluidRow(
    column(6,
           h4("Climate Risk"),
           plotOutput("map_climate", height = "500px")
    ),
    column(6,
           h4("Human Flourishing Dimensions"),
           plotOutput("map_hfgi", height = "500px")
    )
  ),
  
  # Controls row - below maps
  fluidRow(
    column(6,
           fluidRow(
             column(6,
                    materialSwitch("interpolate_climate", "Interpolate Missing Values", 
                                 value = TRUE, status = "info")
             )
           ),
           selectInput("climate_var", "Select Variable:",
                      choices = climate_choices,
                      selected = "clim_risk")
    ),
    column(6,
           fluidRow(
             column(6,
                    materialSwitch("interpolate_hfgi", "Interpolate Missing Values", 
                                 value = TRUE, status = "info")
             ),
             column(6,
                    materialSwitch("invert_colors", "Invert Color Scale", 
                                 value = FALSE, status = "primary")
             )
           ),
           fluidRow(
             column(6,
                    radioGroupButtons(
                      inputId = "hfgi_latent",
                      label = "Select Dimension:",
                      choices = setNames(names(hfgi_latents), 
                                       sapply(hfgi_latents, function(x) x$label)),
                      selected = "charac_virt",
                      justified = FALSE,
                      size = "sm",
                      direction = "vertical"
                    )
             ),
             column(6,
                    selectInput("hfgi_var", "Select Variable:",
                               choices = hfgi_latents$charac_virt$vars,
                               selected = "charac_virt")
             )
           )
    )
  ),
  
  fluidRow(
    column(12,
           hr(),
           h5("About this Application"),
           p(
    "This application visualizes the relationship between climate risk indicators and ",
    "Human Flourishing Global Index (HFGI) dimensions across US counties. The data is based ",
    "on a Structural Equation Model (SEM) where climate risk predicts various human flourishing outcomes.",
    br(),
    "Source HFGI data: ",
    tags$a(
      href = "https://doi.org/10.7910/DVN/T39JBY",
      target = "_blank",
      "https://doi.org/10.7910/DVN/T39JBY"
    ), ".",
    "Thanks to ", tags$a(
      href = "https://alphageo.ai",
      target = "_blank",
      "AlphaGeo~AI"
    ), " for providing county-level resilience-adjusted climate risk indicators",
    br(),
    "Left map: Select climate risk measures (composite or individual components). ",
    "Right map: Select HFGI dimensions (latent constructs or observed indicators)."
  ),
  p("\u00A9  2026 Stefano M. Iacus - Haodong Qi - Devika Jain.")
)
  )
)

# Server
server <- function(input, output, session) {
  
  # Update HFGI variable choices when latent dimension changes
  observeEvent(input$hfgi_latent, {
    choices <- hfgi_latents[[input$hfgi_latent]]$vars
    updateSelectInput(session, "hfgi_var",
                     choices = choices,
                     selected = choices[1])
  })
  
  # Helper function to create map using plot_usmap
  create_map <- function(data, var_name, title, invert = FALSE, interpolate = FALSE) {
    # Apply interpolation if requested (simple state-level mean)
    if (interpolate) {
      # Get state from fips
      data$state <- substr(data$fips, 1, 2)
      var_values <- data[[var_name]]
      missing_idx <- which(is.na(var_values))
      
      if (length(missing_idx) > 0) {
        for (idx in missing_idx) {
          state_code <- data$state[idx]
          state_values <- data[[var_name]][data$state == state_code]
          state_mean <- mean(state_values, na.rm = TRUE)
          if (!is.na(state_mean)) {
            data[[var_name]][idx] <- state_mean
          }
        }
      }
      title <- paste0(title, " (interpolated)")
    }
    
    # Get variable values for scale limits
    var_values <- data[[var_name]]
    stat_range <- range(var_values, na.rm = TRUE)
    padding <- 0.1 * diff(stat_range)
    lower_limit <- stat_range[1] - padding
    upper_limit <- stat_range[2] + padding
    
    # Determine color direction and legend title
    color_direction <- if (invert) -1 else 1
    legend_title <- if (invert) paste0(title, " (inverted)") else title
    
    # Create map using plot_usmap
    p <- plot_usmap(regions = "counties", data = data, values = var_name, color = "gray30", linewidth = 0.1) +
      scale_fill_viridis_c(
        option = "plasma",
        direction = color_direction,
        na.value = "grey90",
        limits = c(lower_limit, upper_limit),
        name = legend_title
      ) +
      theme(
        legend.position = "bottom",
        legend.key.width = unit(2, "cm"),
        plot.title = element_text(hjust = 0.5, face = "bold", size = 14)
      ) +
      labs(title = title)
    
    return(p)
  }
  
  # Render climate risk map
  output$map_climate <- renderPlot({
    req(input$climate_var)
    
    var_label <- names(climate_choices)[climate_choices == input$climate_var]
    create_map(map_data, input$climate_var, var_label, 
               interpolate = input$interpolate_climate)
  })
  
  # Render HFGI map
  output$map_hfgi <- renderPlot({
    req(input$hfgi_var)
    
    latent_info <- hfgi_latents[[input$hfgi_latent]]
    var_label <- names(latent_info$vars)[latent_info$vars == input$hfgi_var]
    create_map(map_data, input$hfgi_var, var_label, 
               invert = input$invert_colors,
               interpolate = input$interpolate_hfgi)
  })
}

# Run app
shinyApp(ui, server)
