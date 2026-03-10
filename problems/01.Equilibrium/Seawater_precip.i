[TimeIndependentReactionSolver]
  model_definition = definition
  swap_out_of_basis = "H+"
  swap_into_basis = "  MgCO3"
  charge_balance_species = "Cl-"
  constraint_species = "H2O              MgCO3            O2(aq)             Cl-              Na+              SO4--            Mg++             Ca++             K+               HCO3-            SiO2(aq)"
  constraint_value = "  1.0              0.0001959        0.2151E-3          0.566            0.485            0.0292           0.055            0.0106           0.0106           0.00241          0.000103"
  constraint_meaning = "kg_solvent_water bulk_composition free_concentration bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition"
  constraint_unit = "  kg                moles            molal              moles            moles            moles            moles            moles            moles            moles            moles"
  prevent_precipitation = "Dolomite-ord Dolomite-dis"
  ramp_max_ionic_strength_initial = 0
  stoichiometric_ionic_str_using_Cl_only = true
  mol_cutoff = 1E-5
  abs_tol = 1E-15
[]

[UserObjects]
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/moose_geochemdb.json"
    basis_species = "H2O H+ Cl- Na+ SO4-- Mg++ Ca++ K+ HCO3- SiO2(aq) O2(aq)"
    equilibrium_minerals = "Antigorite Tremolite Talc Chrysotile Sepiolite Anthophyllite Dolomite Dolomite-ord Huntite Dolomite-dis Magnesite Calcite Aragonite Quartz"
    piecewise_linear_interpolation = true
  []
[]
