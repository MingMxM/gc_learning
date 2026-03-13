[TimeDependentReactionSolver]
  model_definition = definition
  geochemistry_reactor_name = reactor
  swap_out_of_basis = "Al+++  K+      H+        SiO2(aq)"
  swap_into_basis = "  Albite Maximum Muscovite Quartz"
  charge_balance_species = "Cl-"
  constraint_species = "H2O              Muscovite    Na+              Cl-              Albite       Maximum      Quartz"
  constraint_value = "  1.0              5            1.14093          1.14093          20           10           2"
  constraint_meaning = "kg_solvent_water free_mineral bulk_composition bulk_composition free_mineral free_mineral free_mineral"
  constraint_unit = "   kg               cm3          moles            moles            cm3          cm3          cm3"
  initial_temperature = 300
  temperature = temperature
  ramp_max_ionic_strength_initial = 0
  stoichiometric_ionic_str_using_Cl_only = true
  abs_tol = 1E-14
  execute_console_output_on = ''
[]

[AuxVariables]
  [temperature]
  []
[]

[AuxKernels]
  [temperature]
    type = FunctionAux
    variable = temperature
    function = '300 - t'
    execute_on = 'timestep_begin'
  []
[]

[Postprocessors]
  [solution_temperature]
    type = PointValue
    point = '0 0 0'
    variable = 'temperature'
  []
  [cm3_Max_Micro]
    type = PointValue
    point = '0 0 0'
    variable = 'free_cm3_Maximum'
  []
  [cm3_Albite]
    type = PointValue
    point = '0 0 0'
    variable = 'free_cm3_Albite'
  []
  [cm3_Muscovite]
    type = PointValue
    point = '0 0 0'
    variable = 'free_cm3_Muscovite'
  []
  [cm3_Quartz]
    type = PointValue
    point = '0 0 0'
    variable = 'free_cm3_Quartz'
  []
[]

[Executioner]
  type = Transient
  start_time = -10
  dt = 10
  end_time = 275
[]

[UserObjects]
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/moose_geochemdb.json"
    basis_species = "H2O H+ Na+ Cl- Al+++ K+ SiO2(aq)"
    equilibrium_minerals = "Albite Maximum Muscovite Quartz"
    remove_all_extrapolated_secondary_species = true
  []
[]

[Outputs]
  csv = true
[]