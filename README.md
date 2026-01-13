# Climate Risk and Human Flourishing: Interactive Spatial Analysis

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R Shiny](https://img.shields.io/badge/R-Shiny-blue.svg)](https://shiny.rstudio.com/)

An interactive Shiny application for exploring the spatial relationship between climate risk indicators and Human Flourishing Global Index (HFGI) dimensions across US counties.

![climateRickHFGI Dashboard](climateRickHFGI.png)

**Live Application:** [https://ai-services.dataverse.org/r/climateRiskHFGI](https://ai-services.dataverse.org/r/climateRiskHFGI)

## Overview

This application visualizes county-level data on climate risks and human flourishing dimensions, allowing users to explore potential relationships between environmental stressors and various aspects of human wellbeing. The data is based on a Structural Equation Model (SEM) where climate risk predicts various human flourishing outcomes.

### Key Features

- **Side-by-side map comparison** - Climate Risk (left) vs. Human Flourishing dimensions (right)
- **Complete US coverage** - Includes all 50 states plus territories (Alaska, Hawaii, Puerto Rico displayed as insets)
- **Interactive controls**:
  - 7 climate risk indicators (latent composite + 6 individual components)
  - 9 human flourishing dimensions with 49+ observed variables
  - Missing value interpolation (state-level means)
  - Color scale inversion for alternative visualizations

## Data Sources

- **HFGI Data**: Human Flourishing Global Index measures across US counties
  - Source: [Harvard Dataverse](https://doi.org/10.7910/DVN/T39JBY)
  - Variables: 10 latent constructs, 66 observed indicators
  
- **Climate Risk Data**: County-level climate exposure indicators
  - County-level resilience-adjusted climate risk indicators provided by [AlphaGeo~AI](https://alphageo.ai)
  - Composite latent risk score
  - Heat, Fire, Drought, Coastal, Wind, and Inland Flood Risk

## Installation

### Local Installation (R)

1. **Clone the repository**
   ```bash
   git clone https://github.com/siacus/climateRiskHFGI.git
   cd climateRiskHFGI
   ```

2. **Install required R packages**
   ```r
   install.packages(c(
     "shiny",
     "data.table", 
     "sf",
     "ggplot2",
     "viridis",
     "bslib",
     "shinyWidgets",
     "usmap"
   ))
   ```

3. **Run the application**
   ```r
   shiny::runApp()
   ```

4. **Access the app**  
   Open your browser to: `http://localhost:3838`

### Docker Deployment

#### Prerequisites
- Docker installed on your system
- At least 4GB RAM allocated to Docker

#### Build the Docker image

We provide a Dockerfile for ARM architecture (Apple Silicon). For x86_64 systems, modify the `FROM` statement in the Dockerfile.

```bash
docker build --no-cache -t shiny-server-arm-full .
```

#### Run the Shiny Server container

```bash
docker run -d -p 3838:3838 \
  -v ~/shiny-server/apps:/srv/shiny-server/ \
  -v ~/shiny-server/logs:/var/log/shiny-server/ \
  -v ~/shiny-server/conf:/etc/shiny-server/ \
  --name shiny-server shiny-server-arm-full
```

#### Deploy the app

1. Create the app directory:
   ```bash
   mkdir -p ~/shiny-server/apps/climateRiskHFGI
   ```

2. Copy application files:
   ```bash
   cp app.R ~/shiny-server/apps/climateRiskHFGI/
   cp variable_mapping.R ~/shiny-server/apps/climateRiskHFGI/
   cp -r data ~/shiny-server/apps/climateRiskHFGI/
   cp .shiny_app.conf ~/shiny-server/apps/climateRiskHFGI/
   ```

3. Access the dashboard:  
   Point your browser to: `http://your_host_ip:3838/climateRiskHFGI/`

#### Docker Notes

This is a custom build for ARM hardware (Apple Silicon M-series chips). Shiny Server is not officially built for ARM architecture. We adapted the build process from [hvalev/shiny-server-arm-docker](https://github.com/hvalev/shiny-server-arm-docker).

**For x86_64 systems**: Use the official Rocker Project images by modifying the Dockerfile's `FROM` statement.

## Usage Guide

### Climate Risk Map (Left Panel)

1. **Select Variable**: Choose from climate risk indicators
   - Climate Risk (Latent): Composite measure of all risks
   - Individual components: Heat, Fire, Drought, Coastal, Wind, Inland Flood
   
2. **Interpolate Missing Values**: Toggle to fill gaps using state-level means

### Human Flourishing Map (Right Panel)

1. **Select Dimension**: Choose from 9 HFGI dimensions:
   - Character Virtues (8 indicators)
   - Religious & Spiritual Life (6 indicators)
   - Institutional Trust (3 indicators)
   - Meaning & Purpose (4 indicators)
   - Social Connectedness (5 indicators)
   - Subjective Wellbeing (4 indicators)
   - Psychological Distress (4 indicators)
   - Physical Condition (5 indicators)
   - Economic Stability (4 indicators)

2. **Select Variable**: Choose latent construct or specific observed variable

3. **Interpolate Missing Values**: Toggle to fill gaps using state-level means

4. **Invert Color Scale**: Reverse colors for alternative interpretation

### Interpreting the Maps

- **Gray areas**: Missing data (when interpolation is off)
- **Color scale**: Darker colors indicate higher/lower values (depending on variable)
- **Insets**: Alaska (lower left), Hawaii (lower middle), Puerto Rico (lower right)
- **Title indicator**: Maps show "(interpolated)" when interpolation is active

## Project Structure

```
climateRiskHFGI/
├── app.R                      # Main Shiny application
├── variable_mapping.R         # SEM variable structure definition
├── Dockerfile                 # Docker configuration (ARM)
├── .shiny_app.conf           # Shiny Server configuration
├── README.md                  # This file
├── FlourishingMap.png        # Screenshot
└── data/
    ├── latent_scores.csv     # County-level HFGI and climate data
    ├── counties/             # US county shapefiles
    │   └── cb_2021_us_county_20m.*
    └── states/               # US state shapefiles
        └── cb_2021_us_state_20m.*
```

## Technical Details

### Data Processing

- County FIPS codes used for spatial joins
- Missing values optionally filled using state-level means
- Latent constructs estimated via Structural Equation Modeling
- All spatial data projected to Albers Equal Area Conic (EPSG:5070)

### SEM Model Structure

The Structural Equation Model captures relationships between:
- **Exogenous variable**: Climate Risk (6 indicators)
- **Endogenous variables**: 9 HFGI dimensions (49 indicators total)

See `variable_mapping.R` for complete model specification.

## Citation

If you use this application or data in your research, please cite:

```
Iacus, S. M., Qi, H., & Jain, D. (2026). 
Climate Risk and Human Flourishing: Interactive Spatial Analysis [Software]. 
GitHub. https://github.com/siacus/climateRiskHFGI

HFGI Data Source:
https://doi.org/10.7910/DVN/T39JBY
```

## Authors

© 2026 Stefano M. Iacus, Haodong Qi, Devika Jain

## License

This project is licensed under the MIT License - see the LICENSE section in `app.R` for details.

## Issues & Support

For questions, issues, or feature requests, please open an issue on the [GitHub repository](https://github.com/siacus/climateRiskHFGI/issues).

## Acknowledgments

- HFGI data provided by [Harvard Dataverse](https://doi.org/10.7910/DVN/T39JBY)
- County-level resilience-adjusted climate risk indicators provided by [AlphaGeo~AI](https://alphageo.ai)
- County and state shapefiles from US Census Bureau
- Docker ARM build adapted from [hvalev/shiny-server-arm-docker](https://github.com/hvalev/shiny-server-arm-docker)
- Built with the amazing R Shiny framework

---

**Last Updated**: January 2026
