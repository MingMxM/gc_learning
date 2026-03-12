[GeochemicalModelInterrogator]
  model_definition = definition
  # swap_out_of_basis = "SiO2(aq)"
  # swap_into_basis = "  Quartz"
  # equilibrium_species =  "Clinoptil-Ca"
[]

[UserObjects]
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/moose_geochemdb.json"
    basis_species = "H2O H+ Cl-"
    piecewise_linear_interpolation = true
  []
[]