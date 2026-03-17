[TimeDependentReactionSolver]
  model_definition = definition
  geochemistry_reactor_name = reactor
  charge_balance_species = "HCO3-"
  constraint_species = "H2O              HCO3-            CH3COO-          CH4(aq)          H+"
  constraint_value = "  1.0              2E-3             1E-6             1E-6             -6"
  constraint_meaning = "kg_solvent_water bulk_composition bulk_composition bulk_composition log10activity"
  constraint_unit = "   kg               moles            moles            moles            dimensionless"
  kinetic_species_name = methanogen
  kinetic_species_initial_value = 1
  kinetic_species_unit = moles
  ramp_max_ionic_strength_initial = 0
  execute_console_output_on = ''
[]

[UserObjects]
  [rate_biomass_death]
    type = GeochemistryKineticRate
    kinetic_species_name = methanogen
    intrinsic_rate_constant = 0.5E-9
    multiply_by_mass = true
    eta = 0
    direction = DEATH
  []
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/moose_geochemdb.json"
    basis_species = "H2O H+ CH3COO- CH4(aq) HCO3-"
    kinetic_minerals = methanogen
    kinetic_rate_descriptions = rate_biomass_death
  []
[]

[Executioner]
  type = Transient
  dt = 1E-2
  end_time = 10
[]

[AuxVariables]
  [moles_biomass]
  []
  [transported_acetate]
  []
[]

[AuxKernels]
  [moles_biomass]
    type = GeochemistryQuantityAux
    reactor = reactor
    species = methanogen
    variable = moles_biomass
    quantity = kinetic_moles
  []
  [transported_acetate]
    type = GeochemistryQuantityAux
    reactor = reactor
    species = "CH3COO-"
    variable = transported_acetate
    quantity = transported_moles_in_original_basis
  []  
[]

[Postprocessors]
  [moles_biomass]
    type = PointValue
    point = '0 0 0'
    variable = moles_biomass
  []
  [transport_acetate]
    type = PointValue
    point = '0 0 0'
    variable = transported_acetate
  []
[]

[Outputs]
  time_step_interval = 100
  csv = true
[]