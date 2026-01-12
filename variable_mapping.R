# Variable Mapping from SEM Model
# This file documents the relationship between observed variables and latent constructs

# =============================================================================
# LATENT VARIABLES (Composite/Derived Dimensions from SEM)
# =============================================================================

variable_mapping <- list(
  
  # 1. Climate Risk (predictor in structural model)
  clim_risk = list(
    label = "Climate Risk",
    description = "Composite measure of various climate-related hazards",
    observed_vars = c("HEAT_RISK", "FIRE_RISK", "DROUGHT_RISK", 
                     "COASTAL_RISK", "WIND_RISK", "INLAND_RISK")
  ),
  
  # 2. Character Virtues (outcome predicted by clim_risk)
  charac_virt = list(
    label = "Character Virtues",
    description = "Prosocial behaviors and moral character traits",
    observed_vars = c("altruism", "charity", "delaygrat", "empathy", 
                     "forgive", "goodpromo", "gratitude", "volunteer")
  ),
  
  # 3. Religious/Spiritual (outcome predicted by clim_risk)
  relig = list(
    label = "Religious & Spiritual Life",
    description = "Religious beliefs, practices, and spiritual experiences",
    observed_vars = c("afterlife", "believegod", "lovedgod", "relcomfort", 
                     "relcrit", "spiritpun")
  ),
  
  # 4. Institutional Trust (outcome predicted by clim_risk)
  inst_trust = list(
    label = "Institutional Trust",
    description = "Trust and engagement with government and civic institutions",
    observed_vars = c("govapprove", "polvoice", "discrim")
  ),
  
  # 5. Meaning & Purpose (outcome predicted by clim_risk)
  meaning = list(
    label = "Meaning & Purpose",
    description = "Sense of purpose, hope, and life balance",
    observed_vars = c("balance", "hope", "purpose", "resilience")
  ),
  
  # 6. Social Connectedness (outcome predicted by clim_risk)
  social = list(
    label = "Social Connectedness",
    description = "Quality of relationships and sense of belonging",
    observed_vars = c("belonging", "loneliness", "relationships", "trust", "trusted")
  ),
  
  # 7. Subjective Wellbeing (outcome predicted by clim_risk)
  subj_welb = list(
    label = "Subjective Wellbeing",
    description = "Positive emotions and life satisfaction",
    observed_vars = c("happiness", "innerpeace", "lifesat", "optimism")
  ),
  
  # 8. Psychological Distress (outcome predicted by clim_risk)
  psy_dstrs = list(
    label = "Psychological Distress",
    description = "Mental health challenges and negative emotions",
    observed_vars = c("anxiety", "depression", "suffering", "selfesteem")
  ),
  
  # 9. Physical Condition (outcome predicted by clim_risk)
  physc_cond = list(
    label = "Physical Condition",
    description = "Physical health, energy levels, and functional capacity",
    observed_vars = c("energy", "posfunct", "vitality", "healthlim", "pain")
  ),
  
  # 10. Economic Stability (outcome predicted by clim_risk)
  econ_stab = list(
    label = "Economic Stability",
    description = "Economic security and job satisfaction",
    observed_vars = c("jobsat", "mastery", "fin_sec", "future_sec")
  )
)

# =============================================================================
# STRUCTURAL MODEL RELATIONSHIPS
# =============================================================================

structural_relationships <- list(
  predictor = "clim_risk",
  outcomes = c("inst_trust", "meaning", "social", "subj_welb", 
               "psy_dstrs", "physc_cond", "econ_stab", 
               "charac_virt", "relig"),
  note = "All latent outcome variables are predicted by climate risk, with zero covariances among outcomes"
)

# =============================================================================
# ADDITIONAL OBSERVED VARIABLES (not in latent constructs)
# =============================================================================

additional_variables <- list(
  climate_vars = c("HEAT_RAJ", "INLAND_RAJ", "FIRE_RAJ", "DROUGHT_RAJ",
                   "COASTAL_RAJ", "WIND_RAJ", "MEAN_RISK", "OVERALL_RISK_PCT",
                   "MEAN_RAJ", "OVERALL_RAJ_PCT"),
  
  flourishing_vars = c("finworry", "fearfuture", "migmood", "corruption", 
                       "ptsd", "smokehealth", "drinkhealth"),
  
  demographic_vars = c("ntweets", "rural", "population"),
  
  geographic_id = c("id", "StateCounty")
)

# =============================================================================
# HELPER FUNCTION: Get all variables for a latent construct
# =============================================================================

get_observed_vars <- function(latent_var) {
  if (latent_var %in% names(variable_mapping)) {
    return(variable_mapping[[latent_var]]$observed_vars)
  } else {
    return(NULL)
  }
}

# =============================================================================
# HELPER FUNCTION: Get latent construct for an observed variable
# =============================================================================

get_latent_construct <- function(observed_var) {
  for (latent_name in names(variable_mapping)) {
    if (observed_var %in% variable_mapping[[latent_name]]$observed_vars) {
      return(latent_name)
    }
  }
  return(NULL)
}

# =============================================================================
# EXPORT: All available variables for map visualization
# =============================================================================

all_latent_vars <- names(variable_mapping)

all_observed_vars <- unique(unlist(c(
  lapply(variable_mapping, function(x) x$observed_vars),
  additional_variables$climate_vars,
  additional_variables$flourishing_vars
)))

cat("=== SEM Variable Mapping Summary ===\n")
cat("Latent Variables:", length(all_latent_vars), "\n")
cat("Observed Variables:", length(all_observed_vars), "\n")
cat("\nLatent Constructs:\n")
for (lv in all_latent_vars) {
  cat(sprintf("  - %s (%s): %d indicators\n", 
              lv, 
              variable_mapping[[lv]]$label,
              length(variable_mapping[[lv]]$observed_vars)))
}
