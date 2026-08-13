[UserObjects]
  [Fo90_rate]
      type = GeochemistryKineticRate
      kinetic_species_name = Fo90
      intrinsic_rate_constant = 2.29087e-11    # 10^-10.64 mol/m^2/s at 25 C
      activation_energy = 79.0E3               # J/mol
      area_quantity = 2.25e-2                  # m^2/g
      multiply_by_mass = true
      one_over_T0 = 0.003354
  []
  [Fo90_acid]
      type = GeochemistryKineticRate
      kinetic_species_name = Fo90
      intrinsic_rate_constant = 1.41425e-7    # 10^-6.85 mol/m^2/s at 25 C
      activation_energy = 67.2E3              # J/mol
      area_quantity = 2.25e-2                 # m^2/g
      multiply_by_mass = true
      promoting_species_names = "H+"
      promoting_indices = "0.470"
      one_over_T0 = 0.003354
  []

  [Liz90_rate]
      type = GeochemistryKineticRate
      kinetic_species_name = Liz90
      intrinsic_rate_constant = 3.981072e-13   # 10^-12.40 mol/m^2/s at 25 C
      activation_energy = 56.6E3               # J/mol
      area_quantity = 2.1e-4                   # m^2/g
      multiply_by_mass = true
      one_over_T0 = 0.003354
  []
  [Liz90_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = Liz90
    intrinsic_rate_constant = 1.99526e-6      # 10^-5.70 mol/m^2/s at 25 C
    activation_energy = 75.5E3                # J/mol
    area_quantity = 2.1e-4                    # m^2/g
    multiply_by_mass = true
    promoting_species_names = "H+"
    promoting_indices = "0.800"
    one_over_T0 = 0.003354
  []

  [En90_rate]
      type = GeochemistryKineticRate
      kinetic_species_name = En90
      intrinsic_rate_constant = 1.905461e-13   # 10^-12.72 mol/m^2/s at 25 C
      activation_energy = 80.0E3               # J/mol
      area_quantity = 8e-3                     # m^2/g
      multiply_by_mass = true
      one_over_T0 = 0.003354
  []
  [En90_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = En90
    intrinsic_rate_constant = 9.549926e-10    # 10^-9.02 mol/m^2/s at 25 C
    activation_energy = 80.0E3                # J/mol
    area_quantity = 8e-3                      # m^2/g
    multiply_by_mass = true
    promoting_species_names = "H+"
    promoting_indices = "0.600"
    one_over_T0 = 0.003354
  []

  [Brucite85_rate]
      type = GeochemistryKineticRate
      kinetic_species_name = Brucite85
      intrinsic_rate_constant = 5.754399e-9    # 10^-8.24 mol/m^2/s at 25 C
      activation_energy = 42.0E3               # J/mol
      area_quantity = 5e-5                     # m^2/g
      multiply_by_mass = true
      one_over_T0 = 0.003354
  []
  [Brucite85_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = Brucite85
    intrinsic_rate_constant = 1.86209e-5     # 10^-4.73 mol/m^2/s at 25 C
    activation_energy = 59.0E3               # J/mol
    area_quantity = 5e-5                     # m^2/g
    multiply_by_mass = true
    promoting_species_names = "H+"
    promoting_indices = "0.500"
    one_over_T0 = 0.003354
  []

  [Magnetite_rate]
      type = GeochemistryKineticRate
      kinetic_species_name = Magnetite
      intrinsic_rate_constant = 1.659587e-11    # 10^-10.78 mol/m^2/s at 25 C
      activation_energy = 18.6E3                # J/mol
      area_quantity = 1e-10                     # m^2/g
      multiply_by_mass = true
      one_over_T0 = 0.003354
  []
  [Magnetite_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = Magnetite
    intrinsic_rate_constant = 2.57039e-9     # 10^-8.59 mol/m^2/s at 25 C
    activation_energy = 18.6E3               # J/mol
    area_quantity = 1e-10                    # m^2/g
    multiply_by_mass = true
    promoting_species_names = "H+"
    promoting_indices = "0.279"
    one_over_T0 = 0.003354
  []

  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/serpentinization_database.json"
    basis_species = "H2O H+ Na+ Cl- Mg++ Fe++ SiO2(aq) O2(aq)"
    # remove_all_extrapolated_secondary_species = true
    kinetic_minerals = "Fo90 Liz90 En90 Brucite85 Magnetite"
    kinetic_rate_descriptions = "Fo90_rate Fo90_acid Liz90_rate Liz90_acid En90_rate En90_acid Brucite85_rate Brucite85_acid Magnetite_rate Magnetite_acid"
  []
[]

[TimeDependentReactionSolver]
    model_definition = definition
    swap_out_of_basis = "O2(aq)"
    swap_into_basis = "H2(aq)"
    charge_balance_species = "Cl-"
    constraint_species = "H2O              H+            Na+              Cl-              Mg++             Fe++             SiO2(aq)         H2(aq)"
    constraint_value = "  1                -7.0          0.001            0.001            1e-8             1e-8             1e-8             1e-8"
    constraint_meaning = "kg_solvent_water log10activity bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition"
    constraint_unit = "   kg               dimensionless moles            moles            moles            moles            moles            moles"
    prevent_precipitation = ""

    remove_fixed_activity_name = 'H+'
    remove_fixed_activity_time = "0"

    initial_temperature = 230
    temperature = 230
    
    kinetic_species_name = "         Fo90    Liz90    En90    Brucite85 Magnetite"
    kinetic_species_initial_value = "42.1995 0.363789 3.06899 1e-3      1e-5"
    kinetic_species_unit = "         moles   moles    moles   moles     moles"
    
    ramp_max_ionic_strength_initial = 0
    stoichiometric_ionic_str_using_Cl_only = true
    evaluate_kinetic_rates_always = true
    max_initial_residual = 1E-2
    abs_tol = 1e-12

    execute_console_output_on = ''
[]

[GlobalParams]
  point = '0 0 0'
[]

[Executioner]
  type = Transient
  [TimeStepper]
    type = FunctionDT
    function = 'min(max(10, 0.1 * t),3600)'
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
