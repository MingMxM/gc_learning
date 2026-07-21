[UserObjects]
   [Fo91_acid]
      type = GeochemistryKineticRate
      kinetic_species_name = Fo91_IdealMix
      intrinsic_rate_constant = 1.41425e-7   # 10^-6.85 mol/m^2/s at 25 C
      activation_energy = 67.2E3             # J/mol
      area_quantity = 0.0225                 # m^2/g
      multiply_by_mass = true
      promoting_species_names = "H+"
      promoting_indices = "0.470"
      one_over_T0 = 0.003354
  []
  [Fo91_neutral]
      type = GeochemistryKineticRate
      kinetic_species_name = Fo91_IdealMix
      intrinsic_rate_constant = 2.29087e-11   # 10^-10.64 mol/m^2/s at 25 C
      activation_energy = 79.0E3              # J/mol
      area_quantity = 0.0225                  # m^2/g
      multiply_by_mass = true
      one_over_T0 = 0.003354
  []

  [Serpentine_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = Serpentine_230_320C
    intrinsic_rate_constant = 1.99526e-6     # 10^-5.70 mol/m^2/s at 25 C
    activation_energy = 75.5E3               # J/mol
    area_quantity = 0.0225                   # m^2/g
    multiply_by_mass = true
    promoting_species_names = "H+"
    promoting_indices = "0.800"
    one_over_T0 = 0.003354
  []
  [Serpentine_neutral]
      type = GeochemistryKineticRate
      kinetic_species_name = Serpentine_230_320C
      intrinsic_rate_constant = 3.98107e-13   # 10^-12.40 mol/m^2/s at 25 C
      activation_energy = 56.6E3              # J/mol
      area_quantity = 0.0225                  # m^2/g
      multiply_by_mass = true
      one_over_T0 = 0.003354
  []

  [Brucite_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = Brucite_265_300C
    intrinsic_rate_constant = 1.86209e-5     # 10^-4.73 mol/m^2/s at 25 C
    activation_energy = 59.0E3               # J/mol
    area_quantity = 0.0225                   # m^2/g
    multiply_by_mass = true
    promoting_species_names = "H+"
    promoting_indices = "0.500"
    one_over_T0 = 0.003354
  []
  [Brucite_neutral]
      type = GeochemistryKineticRate
      kinetic_species_name = Brucite_265_300C
      intrinsic_rate_constant = 5.754399e-9   # 10^-8.24 mol/m^2/s at 25 C
      activation_energy = 42.0E3              # J/mol
      area_quantity = 0.0225                  # m^2/g
      multiply_by_mass = true
      one_over_T0 = 0.003354
  []

  [Magnetite_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = MAGNETITE
    intrinsic_rate_constant = 2.57039e-9     # 10^-8.59 mol/m^2/s at 25 C
    activation_energy = 18.6E3               # J/mol
    area_quantity = 0.0225                   # m^2/g
    multiply_by_mass = true
    promoting_species_names = "H+"
    promoting_indices = "0.279"
    one_over_T0 = 0.003354
  []
  [Magnetite_neutral]
      type = GeochemistryKineticRate
      kinetic_species_name = MAGNETITE
      intrinsic_rate_constant = 1.659587e-11   # 10^-10.78 mol/m^2/s at 25 C
      activation_energy = 18.6E3               # J/mol
      area_quantity = 0.0225                   # m^2/g
      multiply_by_mass = true
      one_over_T0 = 0.003354
  []

  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/mmc1_geochemdb_updated.json"
    basis_species = "H2O H+ Na+ Cl- Mg++ Fe++ SiO2(aq) O2(aq)"
    # remove_all_extrapolated_secondary_species = true
    kinetic_minerals = "Fo91_IdealMix Serpentine_230_320C Brucite_265_300C MAGNETITE"
    kinetic_rate_descriptions = "Fo91_acid Fo91_neutral Serpentine_acid Serpentine_neutral Brucite_acid Brucite_neutral Magnetite_acid Magnetite_neutral"
  []
[]

[TimeDependentReactionSolver]
    model_definition = definition
    geochemistry_reactor_name = reactor
    swap_out_of_basis = "O2(aq)"
    swap_into_basis = "H2(aq)"
    charge_balance_species = "Cl-"
    constraint_species = "H2O              H+            Na+              Cl-              Mg++             Fe++             SiO2(aq)         H2(aq)"
    constraint_value = "  1.0              -7.0          0.5              0.5              1e-8             1e-8             1e-8             1e-8"
    constraint_meaning = "kg_solvent_water log10activity bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition"
    constraint_unit = "   kg               dimensionless moles            moles            moles            moles            moles            moles"
    prevent_precipitation = ""
    ramp_max_ionic_strength_initial = 0
    remove_fixed_activity_name = 'H+'
    remove_fixed_activity_time = "0"
    initial_temperature = 300
    temperature = 300
    kinetic_species_name = "         Fo91_IdealMix Serpentine_230_320C Brucite_265_300C MAGNETITE"
    kinetic_species_initial_value = "6.8321        1e-6                1e-6          1e-6"
    kinetic_species_unit = "         moles         moles               moles         moles"
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
    function = 'max(10, 0.2 * t)'
  []
  end_time = 8640000        # 100 day
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
  [Water_kg]
    type = PointValue
    point = '0 0 0'
    variable = 'molal_H+'
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
  [mass_change_Fo91]
    type = PointValue
    point = '0 0 0'
    variable = free_mg_Fo91_IdealMix
  []
  [mass_change_Serpentine]
    type = PointValue
    point = '0 0 0'
    variable = free_mg_Serpentine_230_320C
  []
  [mass_change_Brucite]
    type = PointValue
    point = '0 0 0'
    variable = free_mg_Brucite_265_300C
  []
  [mass_change_MAGNETITE]
    type = PointValue
    point = '0 0 0'
    variable = 'free_mg_MAGNETITE'
  []
[]

[Outputs]
  csv = true
[]
