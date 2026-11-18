# Closed, time-dependent serpentinization batch using the matrix inventory.
# Run directly with a MOOSE executable built with the Geochemistry module.
# The generated one-element mesh only hosts the zero-dimensional reactor.
# Keep the database at the configured path or override UserObjects/definition/database_file.

temperature_c = 200
batch_days = 360
batch_end_time_s = ${fparse batch_days * 86400}
h2_molar_mass_kg = 0.002016

# Initial mineral moles per reactor, on the original 1 kg solvent-water basis.
Fo90_matrix = 464.851
Liz90_matrix = 4.00733
En90_matrix = 33.8066
Brucite85_matrix = 1e-3
Magnetite_matrix = 1e-5

[GlobalParams]
  point = '0 0 0'
[]

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1
[]

[Problem]
  solve = false
[]

[UserObjects]
  # ----- kinetic rate laws (copied from your batch calibration) -----
  [Fo90_rate]
    type = GeochemistryKineticRate
    kinetic_species_name = Fo90
    intrinsic_rate_constant = 2.29087e-11
    activation_energy = 79.0E3
    area_quantity = 2.25e-3
    multiply_by_mass = true
    one_over_T0 = 0.003354
  []
  [Fo90_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = Fo90
    intrinsic_rate_constant = 1.41425e-7
    activation_energy = 67.2E3
    area_quantity = 2.25e-3
    multiply_by_mass = true
    promoting_species_names = "H+"
    promoting_indices = "0.470"
    one_over_T0 = 0.003354
  []
  [Liz90_rate]
    type = GeochemistryKineticRate
    kinetic_species_name = Liz90
    intrinsic_rate_constant = 3.981072e-13
    activation_energy = 56.6E3
    area_quantity = 2.1e-5
    multiply_by_mass = true
    one_over_T0 = 0.003354
  []
  [Liz90_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = Liz90
    intrinsic_rate_constant = 1.99526e-6
    activation_energy = 75.5E3
    area_quantity = 2.1e-5
    multiply_by_mass = true
    promoting_species_names = "H+"
    promoting_indices = "0.800"
    one_over_T0 = 0.003354
  []
  [En90_rate]
    type = GeochemistryKineticRate
    kinetic_species_name = En90
    intrinsic_rate_constant = 1.905461e-13
    activation_energy = 80.0E3
    area_quantity = 8e-4
    multiply_by_mass = true
    one_over_T0 = 0.003354
  []
  [En90_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = En90
    intrinsic_rate_constant = 9.549926e-10
    activation_energy = 80.0E3
    area_quantity = 8e-4
    multiply_by_mass = true
    promoting_species_names = "H+"
    promoting_indices = "0.600"
    one_over_T0 = 0.003354
  []
  [Brucite85_rate]
    type = GeochemistryKineticRate
    kinetic_species_name = Brucite85
    intrinsic_rate_constant = 5.754399e-9
    activation_energy = 42.0E3
    area_quantity = 5e-6
    multiply_by_mass = true
    one_over_T0 = 0.003354
  []
  [Brucite85_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = Brucite85
    intrinsic_rate_constant = 1.86209e-5
    activation_energy = 59.0E3
    area_quantity = 5e-6
    multiply_by_mass = true
    promoting_species_names = "H+"
    promoting_indices = "0.500"
    one_over_T0 = 0.003354
  []
  [Magnetite_rate]
    type = GeochemistryKineticRate
    kinetic_species_name = Magnetite
    intrinsic_rate_constant = 1.659587e-11
    activation_energy = 18.6E3
    area_quantity = 1e-11
    multiply_by_mass = true
    one_over_T0 = 0.003354
  []
  [Magnetite_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = Magnetite
    intrinsic_rate_constant = 2.57039e-9
    activation_energy = 18.6E3
    area_quantity = 1e-11
    multiply_by_mass = true
    promoting_species_names = "H+"
    promoting_indices = "0.279"
    one_over_T0 = 0.003354
  []

  # ----- chemical system definition (your database + basis + kinetics) -----
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/serpentinization_database.json"
    basis_species = "H2O H+ Na+ Cl- Mg++ Fe++ SiO2(aq) O2(aq)"
    kinetic_minerals = "Fo90 Liz90 En90 Brucite85 Magnetite"
    kinetic_rate_descriptions = "Fo90_rate Fo90_acid Liz90_rate Liz90_acid En90_rate En90_acid Brucite85_rate Brucite85_acid Magnetite_rate Magnetite_acid"
  []

  [reactor]
    type = GeochemistryTimeDependentReactor
    model_definition = definition
    swap_out_of_basis = "O2(aq)"
    swap_into_basis = "H2(aq)"
    charge_balance_species = "Cl-"

    constraint_species = "H2O               H+            Na+              Cl-              Mg++             Fe++             SiO2(aq)         H2(aq)"
    constraint_value    = "1                -6.3          0.001            0.001            1e-5             1e-5             1e-5             1e-5"
    constraint_meaning  = "kg_solvent_water log10activity bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition"
    constraint_unit     = "kg               dimensionless moles            moles            moles            moles            moles            moles"

    # Initialize at pH 7, then release the H+ constraint and conserve water.
    close_system_at_time = 0
    # remove_fixed_activity_name = 'H+'
    # remove_fixed_activity_time = '0'

    initial_temperature = ${temperature_c}
    temperature = temperature

    kinetic_species_name = "Fo90 Liz90 En90 Brucite85 Magnetite"
    kinetic_species_unit = "moles moles moles moles moles"
    kinetic_species_initial_value = "${Fo90_matrix} ${Liz90_matrix} ${En90_matrix} ${Brucite85_matrix} ${Magnetite_matrix}"

    ramp_max_ionic_strength_initial = 0
    stoichiometric_ionic_str_using_Cl_only = true
    evaluate_kinetic_rates_always = true
    max_initial_residual = 1E-2
    abs_tol = 1e-10
    execute_on = 'timestep_end'
  []
[]

[Executioner]
  type = Transient
  end_time = ${batch_end_time_s}
  [TimeStepper]
    type = FunctionDT
    # Increase the time step from 100 s to 3600 s over the first day.
    time_t = '0 86400'
    time_dt = '100 3600'
  []
[]

[AuxVariables]
  [temperature]
    initial_condition = ${temperature_c}
  []
  [pH]
  []
  [h2_molal]
  []
  [solvent_water_kg]
  []
  [free_cm3_Fo90]
  []
  [free_cm3_Liz90]
  []
  [free_cm3_En90]
  []
  [free_cm3_Brucite85]
  []
  [free_cm3_Magnetite]
  []
[]

[AuxKernels]
  [pH_aux]
    type = GeochemistryQuantityAux
    reactor = reactor
    variable = pH
    species = 'H+'
    quantity = neglog10a
    execute_on = 'initial timestep_end'
  []
  [h2_molal_aux]
    type = GeochemistryQuantityAux
    reactor = reactor
    variable = h2_molal
    species = 'H2(aq)'
    quantity = molal
    execute_on = 'initial timestep_end'
  []
  # For the H2O basis species, quantity = molal returns kg of solvent water.
  [solvent_water_kg_aux]
    type = GeochemistryQuantityAux
    reactor = reactor
    variable = solvent_water_kg
    species = 'H2O'
    quantity = molal
    execute_on = 'initial timestep_end'
  []
  [free_cm3_Fo90_aux]
    type = GeochemistryQuantityAux
    reactor = reactor
    variable = free_cm3_Fo90
    species = 'Fo90'
    quantity = free_cm3
    execute_on = 'initial timestep_end'
  []
  [free_cm3_Liz90_aux]
    type = GeochemistryQuantityAux
    reactor = reactor
    variable = free_cm3_Liz90
    species = 'Liz90'
    quantity = free_cm3
    execute_on = 'initial timestep_end'
  []
  [free_cm3_En90_aux]
    type = GeochemistryQuantityAux
    reactor = reactor
    variable = free_cm3_En90
    species = 'En90'
    quantity = free_cm3
    execute_on = 'initial timestep_end'
  []
  [free_cm3_Brucite85_aux]
    type = GeochemistryQuantityAux
    reactor = reactor
    variable = free_cm3_Brucite85
    species = 'Brucite85'
    quantity = free_cm3
    execute_on = 'initial timestep_end'
  []
  [free_cm3_Magnetite_aux]
    type = GeochemistryQuantityAux
    reactor = reactor
    variable = free_cm3_Magnetite
    species = 'Magnetite'
    quantity = free_cm3
    execute_on = 'initial timestep_end'
  []
[]

[Postprocessors]
  [pH]
    type = PointValue
    variable = pH
    execute_on = 'initial timestep_end'
  []
  [h2_molal]
    type = PointValue
    variable = h2_molal
    execute_on = 'initial timestep_end'
  []
  [solvent_water_kg]
    type = PointValue
    variable = solvent_water_kg
    execute_on = 'initial timestep_end'
  []
  [free_cm3_Fo90]
    type = PointValue
    variable = free_cm3_Fo90
    execute_on = 'initial timestep_end'
  []
  [free_cm3_Liz90]
    type = PointValue
    variable = free_cm3_Liz90
    execute_on = 'initial timestep_end'
  []
  [free_cm3_En90]
    type = PointValue
    variable = free_cm3_En90
    execute_on = 'initial timestep_end'
  []
  [free_cm3_Brucite85]
    type = PointValue
    variable = free_cm3_Brucite85
    execute_on = 'initial timestep_end'
  []
  [free_cm3_Magnetite]
    type = PointValue
    variable = free_cm3_Magnetite
    execute_on = 'initial timestep_end'
  []
  [time_days]
    type = ParsedPostprocessor
    expression = 't / 86400.0'
    use_t = true
    execute_on = 'initial timestep_end'
  []
  [h2_aqueous_mol]
    type = ParsedPostprocessor
    pp_names = 'h2_molal solvent_water_kg'
    expression = 'h2_molal * solvent_water_kg'
    execute_on = 'initial timestep_end'
  []
  [h2_aqueous_kg]
    type = ParsedPostprocessor
    pp_names = 'h2_aqueous_mol'
    expression = 'h2_aqueous_mol * ${h2_molar_mass_kg}'
    execute_on = 'initial timestep_end'
  []
  [h2_net_generated_kg]
    type = ChangeOverTimePostprocessor
    postprocessor = h2_aqueous_kg
    change_with_respect_to_initial = true
    execute_on = 'initial timestep_end'
  []
[]

[Outputs]
  csv = true
  file_base = serpentinization_matrix_batch_acid_pH63
[]
