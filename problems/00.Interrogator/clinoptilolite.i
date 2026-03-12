[GeochemicalModelInterrogator]
  model_definition = definition
  # swap_out_of_basis = "Al+++     SiO2(aq) H+"
  # swap_into_basis = "  Muscovite Quartz   OH-"
  # swap_out_of_basis = "Al+++     SiO2(aq)"
  # swap_into_basis = "  Muscovite Quartz"
  swap_out_of_basis = "SiO2(aq)"
  swap_into_basis = "  Quartz"
  equilibrium_species =  "Clinoptil-Ca"
[]

[UserObjects]
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/moose_geochemdb.json"
    basis_species = "H2O Ca++ Al+++ SiO2(aq) H+ K+"
    equilibrium_minerals = "Clinoptil-Ca Muscovite Quartz"
    piecewise_linear_interpolation = true
  []
[]