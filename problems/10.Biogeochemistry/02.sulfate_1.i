[TimeDependentReactionSolver]
  model_definition = definition
  geochemistry_reactor_name = reactor
  swap_into_basis = 'HS-'
  swap_out_of_basis = 'O2(aq)'
  charge_balance_species = "Cl-"
  constraint_species = "H2O              Na+              Ca++             Fe++             Cl-              SO4--            HCO3-            HS-              H+            Biomass1"
  constraint_value = "  1.0              501E-3           20E-3            2E-3             500E-3           20E-3            2E-3             0.3E-6           -7.2          1E-4"
  constraint_meaning = "kg_solvent_water bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition log10activity bulk_composition"
  constraint_unit = "   kg               moles            moles            moles            moles            moles            moles            moles            dimensionless moles"
  controlled_activity_name = 'H+'
  controlled_activity_value = 6.30957E-8
  kinetic_species_name = "CH3COO-"
  kinetic_species_initial_value = 1E-3
  kinetic_species_unit = MOLES
  ramp_max_ionic_strength_initial = 0
  stoichiometric_ionic_str_using_Cl_only = true
  execute_console_output_on = ''
  mol_cutoff = 1e-20
  solver_info = true
  evaluate_kinetic_rates_always = true
  prevent_precipitation = 'Pyrite Troilite'
[]

[UserObjects]
  [rate_sulfate_reducer]
    type = GeochemistryKineticRate 
    kinetic_species_name = "CH3COO-"
    intrinsic_rate_constant = 0.0864
    multiply_by_mass = false
    kinetic_molal_index = 1.0
    kinetic_monod_index = 1.0
    kinetic_half_saturation = 70E-6
    promoting_species_names = 'H2O Biomass1'
    promoting_indices = '1 1'
    direction = DISSOLUTION
    non_kinetic_biological_catalyst = Biomass1
    non_kinetic_biological_efficiency = 4.3
    energy_captured = 45E3
    theta = 0.2
    eta = 1
  []
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/moose_geochemdb.json"
    basis_species = "H2O Na+ Ca++ Fe++ Cl- SO4-- HCO3- O2(aq) H+ Biomass1"
    equilibrium_minerals = "Mackinawite"
    kinetic_redox = "CH3COO-"
    kinetic_rate_descriptions = "rate_sulfate_reducer"
    piecewise_linear_interpolation = true
  []
[]

[Functions]
  [timestepper]
    type = PiecewiseLinear
    x = '0    10   18  21'
    y = '1E-2 1E-2 1   1'
  []
[]

[Executioner]
  type = Transient
  [TimeStepper]
    type = FunctionDT
    function = timestepper
  []
  end_time = 21
[]

[AuxVariables]
  [moles_acetate]
  []
  [biomass_mg]
  []
[]

[AuxKernels]
  [moles_acetate]
    type = GeochemistryQuantityAux
    reactor = reactor
    species = 'CH3COO-'
    variable = moles_acetate
    quantity = kinetic_moles
  []
  [biomass_mg]
    type = GeochemistryQuantityAux
    reactor = reactor
    species = 'Biomass1'
    variable = biomass_mg
    quantity = mg_per_kg
  []
[]

[Postprocessors]
  [moles_acetane]
    type = PointValue
    point = '0 0 0'
    variable = moles_acetate
  []
  [biomass_mg]
    type = PointValue
    point = '0 0 0'
    variable = biomass_mg
  []
[]

[Outputs]
  csv = true
[]