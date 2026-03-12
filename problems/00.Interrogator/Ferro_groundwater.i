[GeochemicalModelInterrogator]
  model_definition = definition
[]

[UserObjects]
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/moose_geochemdb.json"
    basis_species = "H2O H+ Cl- O2(aq) HCO3- Ca++ Mg++ Na+ K+ Fe++ Fe+++ Mn++ Zn++ SO4--"
  []
[]