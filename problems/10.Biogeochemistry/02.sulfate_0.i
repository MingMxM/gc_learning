
[GeochemicalModelInterrogator]
  model_definition = definition
  swap_out_of_basis = 'O2(aq) HS-'
  swap_into_basis = 'HS- CH4(aq)'
  temperature = 300.0  
[]

[UserObjects]
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/moose_geochemdb.json"
    basis_species = "H2O HCO3- SO4-- H+ O2(aq)"
    piecewise_linear_interpolation = true
  []
[]