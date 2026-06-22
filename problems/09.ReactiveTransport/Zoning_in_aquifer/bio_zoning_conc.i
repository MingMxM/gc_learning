rate_Ca_diffuse = 6.66667E-9
rate_CH3COO_diffuse = 13.3333E-9

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 1
    nx = 10
    xmin = 0
    xmax = 200000
  []
[]

[GlobalParams]
  point = '100000 0 0'
  reactor = reactor
[]

[SpatialReactionSolver]
  model_definition = definition
  geochemistry_reactor_name = reactor
  swap_into_basis = 'Siderite'
  swap_out_of_basis = 'Fe++'
  prevent_precipitation = 'Pyrite Troilite'
  charge_balance_species = "HCO3-"
  constraint_species = "H2O              Ca++             HCO3-            SO4--            CH3COO-          HS-              CH4(aq)          Siderite     H+"
  constraint_value = "  1.0              1E-3             2E-3             0.04E-3          1E-9             1E-9             1E-9             1            -7.5"
  constraint_meaning = "kg_solvent_water bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition free_mineral log10activity"
  constraint_unit = "   kg               moles            moles            moles            moles            moles            moles            cm3          dimensionless"
  controlled_activity_name = 'H+'
  controlled_activity_value = 3.16227E-8
  kinetic_species_name = "sulfate_reducer methanogen"
  kinetic_species_initial_value = '1E-6 1E-6'
  kinetic_species_unit = 'mg mg'
  source_species_names = "H2O             Ca++                       SO4--           CH3COO-                        HS-            CH4(aq)         Fe++"
  source_species_rates = "rate_H2O_per_1l rate_Ca_per_1l_with_source rate_SO4_per_1l rate_CH3COO_per_1l_with_source rate_HS_per_1l rate_CH4_per_1l rate_Fe_per_1l"
  ramp_max_ionic_strength_initial = 1
  ramp_max_ionic_strength_subsequent = 1
  execute_console_output_on = ''
  solver_info = true
  evaluate_kinetic_rates_always = true
  adaptive_timestepping = true
  abs_tol = 1e-14
  precision = 16
[]

[UserObjects]
  [rate_sulfate_reducer]
    type = GeochemistryKineticRate
    kinetic_species_name = "sulfate_reducer"
    intrinsic_rate_constant = 31.536
    multiply_by_mass = true
    promoting_species_names = 'CH3COO- SO4--'
    promoting_indices = '1 1'
    promoting_monod_indices = '1 1'
    promoting_half_saturation = '70E-6 200E-6'
    direction = DISSOLUTION
    kinetic_biological_efficiency = 4.3E-3
    energy_captured = 45E3
    theta = 0.2
    eta = 1
  []
  [rate_methanogen]
    type = GeochemistryKineticRate
    kinetic_species_name = "methanogen"
    intrinsic_rate_constant = 63.072
    multiply_by_mass = true
    promoting_species_names = 'CH3COO-'
    promoting_indices = '1'
    promoting_monod_indices = '1'
    promoting_half_saturation = '20E-3'
    direction = DISSOLUTION
    kinetic_biological_efficiency = 2.0E-9
    energy_captured = 24E3
    theta = 0.5
    eta = 1
  []
  [death_sulfate_reducer]
    type = GeochemistryKineticRate
    kinetic_species_name = "sulfate_reducer"
    intrinsic_rate_constant = 0.031536E-3
    multiply_by_mass = true
    direction = DEATH
    eta = 0.0
  []
  [death_methanogen]
    type = GeochemistryKineticRate
    kinetic_species_name = "methanogen"
    intrinsic_rate_constant = 0.031536E-9
    multiply_by_mass = true
    direction = DEATH
    eta = 0.0
  []    
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../../database/moose_geochemdb.json"
    basis_species = "H2O H+ CH3COO- CH4(aq) HS- Ca++ HCO3- SO4-- Fe++"
    kinetic_minerals = "sulfate_reducer methanogen"
    equilibrium_minerals = "*"
    kinetic_rate_descriptions = "rate_sulfate_reducer death_sulfate_reducer rate_methanogen death_methanogen"
  []
[]

[Executioner]
  type = Transient
  [TimeStepper]
    type = FunctionDT
    function = 'min(0.1 * (t + 1), 100)'
  []
  end_time = 20000
[]

[AuxVariables]
  [rate_H2O_per_1l]
  []
  [rate_CH3COO_per_1l]
  []
  [rate_CH4_per_1l]
  []
  [rate_HS_per_1l]
  []
  [rate_Ca_per_1l]
  []
  [rate_SO4_per_1l]
  []
  [rate_Fe_per_1l]
  []

  [rate_CH3COO_per_1l_with_source]
  []
  [rate_Ca_per_1l_with_source]
  []

  [transported_H2O]
  []
  [transported_CH3COO]
  []
  [transported_CH4]
  []
  [transported_HS]
  []
  [transported_Ca]
  []
  [transported_SO4]
  []
  [transported_Fe]
  []
[]

[AuxKernels]
  [rate_CH3COO_per_1l_with_source]
    type = ParsedAux
    coupled_variables = 'rate_CH3COO_per_1l'
    variable = rate_CH3COO_per_1l_with_source
    expression = 'rate_CH3COO_per_1l + ${rate_CH3COO_diffuse}'
    execute_on = 'timestep_begin timestep_end'
  []
  [rate_Ca_per_1l_with_source]
    type = ParsedAux
    coupled_variables = 'rate_Ca_per_1l'
    variable = rate_Ca_per_1l_with_source
    expression = 'rate_Ca_per_1l + ${rate_Ca_diffuse}'
    execute_on = 'timestep_begin timestep_end'
  []
  [transported_H2O]
    type = GeochemistryQuantityAux
    species = H2O
    variable = transported_H2O
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_end'
  []
  [transported_CH3COO]
    type = GeochemistryQuantityAux
    species = "CH3COO-"
    variable = transported_CH3COO
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_end'
  []
  [transported_CH4]
    type = GeochemistryQuantityAux
    variable = transported_CH4
    species = "CH4(aq)"
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_end'
  []
  [transported_HS]
    type = GeochemistryQuantityAux
    variable = transported_HS
    species = "HS-"
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_end'
  []
  [transported_Ca]
    type = GeochemistryQuantityAux
    variable = transported_Ca
    species = "Ca++"
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_end'
  []
  [transported_SO4]
    type = GeochemistryQuantityAux
    variable = transported_SO4
    species = "SO4--"
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_end'
  []
  [transported_Fe]
    type = GeochemistryQuantityAux
    variable = transported_Fe
    species = "Fe++"
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_end'
  []
[]

[Postprocessors]
    [time]
        type = TimePostprocessor
    []
[]

[VectorPostprocessors]
  [data]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '200000 0 0'
    num_points = 501
    sort_by = X
    variable = 'transported_CH4 transported_CH3COO transported_SO4 free_mg_sulfate_reducer free_mg_methanogen'
  []
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
    time_step_interval = 10
    execute_on = 'INITIAL TIMESTEP_END FINAL'
  []
[]