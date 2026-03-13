[TimeIndependentReactionSolver]
  model_definition = definition
  geochemistry_reactor_name = reactor
  swap_into_basis = "Quartz"
  swap_out_of_basis = "SiO2(aq)"
  charge_balance_species = "Cl-"
  constraint_species = "H2O              Na+              Cl-              Quartz"
  constraint_value = "  1.0              1E-10            1E-10            0.4"
  constraint_meaning = "kg_solvent_water bulk_composition bulk_composition free_mineral"
  constraint_unit = "   kg               moles            moles            kg"
  temperature = 300
  add_aux_pH = false
  ramp_max_ionic_strength_initial = 0
[]

[UserObjects]
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/moose_geochemdb.json"
    basis_species = "H2O SiO2(aq) Na+ Cl-"
    equilibrium_minerals = "Quartz"
  []
[]