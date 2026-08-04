[UserObjects]
  [Fo90_rate]
      type = GeochemistryKineticRate
      kinetic_species_name = Fo90
      intrinsic_rate_constant = 3.019952e-6    # 10^-5.52 mol/m^2/s at 200 C
      # activation_energy = 79.0E3              # J/mol
      area_quantity = 6e-2                    # m^2/g
      multiply_by_mass = true
      # one_over_T0 = 0.003354
  []
  [Liz90_rate]
      type = GeochemistryKineticRate
      kinetic_species_name = Liz90
      intrinsic_rate_constant = 1.862087e-9   # 10^-8.73 mol/m^2/s at 200 C
      # activation_energy = 56.6E3              # J/mol
      area_quantity = 3.89e-4                 # m^2/g
      multiply_by_mass = true
      # one_over_T0 = 0.003354
  []
  [En90_rate]
      type = GeochemistryKineticRate
      kinetic_species_name = En90
      intrinsic_rate_constant = 2.8840315e-8   # 10^-7.54 mol/m^2/s at 200 C
      # activation_energy = 80.0E3              # J/mol
      area_quantity = 6e-2                    # m^2/g
      multiply_by_mass = true
      # one_over_T0 = 0.003354
  []
  [Brucite85_rate]
      type = GeochemistryKineticRate
      kinetic_species_name = Brucite85
      intrinsic_rate_constant = 3.019952e-6     # 10^-5.52 mol/m^2/s at 200 C
      # activation_energy = 42.0E3              # J/mol
      area_quantity = 1e-10                   # m^2/g
      multiply_by_mass = true
      # one_over_T0 = 0.003354
  []
  [Magnetite_rate]
      type = GeochemistryKineticRate
      kinetic_species_name = Magnetite
      intrinsic_rate_constant = 2.630268e-10    # 10^-9.58 mol/m^2/s at 200 C
      # activation_energy = 18.6E3               # J/mol
      area_quantity = 1e-10                    # m^2/g
      multiply_by_mass = true
      # one_over_T0 = 0.003354
  []

  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/serpentinization_database.json"
    basis_species = "H2O H+ Na+ Cl- Mg++ Fe++ SiO2(aq) O2(aq)"
    # remove_all_extrapolated_secondary_species = true
    kinetic_minerals = "Fo90 Liz90 En90 Brucite85 Magnetite"
    kinetic_rate_descriptions = "Fo90_rate Liz90_rate En90_rate Brucite85_rate Magnetite_rate"
  []
[]

[TimeDependentReactionSolver]
    model_definition = definition
    swap_out_of_basis = "O2(aq)"
    swap_into_basis = "H2(aq)"
    charge_balance_species = "Cl-"
    constraint_species = "H2O              H+            Na+              Cl-              Mg++             Fe++             SiO2(aq)         H2(aq)"
    constraint_value = "  0.366            -7.0          0.001            0.001            1e-8             1e-8             1e-8             1e-8"
    constraint_meaning = "kg_solvent_water log10activity bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition"
    constraint_unit = "   kg               dimensionless moles            moles            moles            moles            moles            moles"
    prevent_precipitation = ""
    ramp_max_ionic_strength_initial = 0
    remove_fixed_activity_name = 'H+'
    remove_fixed_activity_time = "0"
    initial_temperature = 200
    temperature = 200
    kinetic_species_name = "         Fo90   Liz90  En90   Brucite85 Magnetite"
    kinetic_species_initial_value = "0.1095 0.0118 0.0345 1e-10     1e-10"
    kinetic_species_unit = "         moles  moles  moles  moles     moles"
    max_initial_residual = 1E-2
    abs_tol = 1e-12
    stoichiometric_ionic_str_using_Cl_only = true
    evaluate_kinetic_rates_always = true # implicit time-marching used for stability
    execute_console_output_on = ''
[]

[GlobalParams]
  point = '0 0 0'
[]

[Executioner]
  type = Transient
  [TimeStepper]
    type = FunctionDT
    function = 'min(max(10, 0.1 * t),7200)'
  []
  end_time = 2592000        # 30 day
[]

[Postprocessors]
  [time]
      type = TimePostprocessor
  []
  [kg_solvent_water]
    type = PointValue
    variable = kg_solvent_H2O
  []
  [pH]
    type = PointValue
    point = '0 0 0'
    variable = pH
  []
  [molal_H]
    type = PointValue
    point = '0 0 0'
    variable = 'molal_H+'
  []
  [molal_Na]
    type = PointValue
    point = '0 0 0'
    variable = 'molal_Na+'
  []
  [molal_Cl]
    type = PointValue
    point = '0 0 0'
    variable = 'molal_Cl-'
  []
  [molal_Mg]
    type = PointValue
    point = '0 0 0'
    variable = 'molal_Mg++'
  []
  [molal_Fe]
    type = PointValue
    point = '0 0 0'
    variable = 'molal_Fe++'
  []
  [molal_SiO2]
    type = PointValue
    point = '0 0 0'
    variable = 'molal_SiO2(aq)'
  []
  [molal_H2aq]
    type = PointValue
    point = '0 0 0'
    variable = 'molal_H2(aq)'
  []
  [mass_change_Fo90]
    type = PointValue
    point = '0 0 0'
    variable = free_mg_Fo90
  []
  [mass_change_Liz90]
    type = PointValue
    point = '0 0 0'
    variable = free_mg_Liz90
  []
  [mass_change_En90]
    type = PointValue
    point = '0 0 0'
    variable = free_mg_En90
  []
  [mass_change_Brucite85]
    type = PointValue
    point = '0 0 0'
    variable = free_mg_Brucite85
  []
  [mass_change_Magnetite]
    type = PointValue
    point = '0 0 0'
    variable = 'free_mg_Magnetite'
  []
[]

[Outputs]
  csv = true
[]
