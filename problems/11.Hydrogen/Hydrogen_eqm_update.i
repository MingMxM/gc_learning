[UserObjects]
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/mmc1_geochemdb_updated.json"
    basis_species = "H2O H+ Na+ Cl- Mg++ Fe++ SiO2(aq) O2(aq)"
    # remove_all_extrapolated_secondary_species = true
    equilibrium_minerals = "Fo91_IdealMix Serpentine_230_320C Brucite_265_300C MAGNETITE"
  []
[]

[TimeDependentReactionSolver]
    model_definition = definition
    swap_out_of_basis = "SiO2(aq) Mg++ Fe++ O2(aq)"
    swap_into_basis = "Serpentine_230_320C Brucite_265_300C MAGNETITE H2(aq)"
    charge_balance_species = "Cl-"
    constraint_species = "H2O              H+            Na+              Cl-              Brucite_265_300C MAGNETITE    Serpentine_230_320C H2(aq)"
    constraint_value = "  1.0              -7.0          0.5              0.5              1e-6             1e-6         1e-6                1e-6"
    constraint_meaning = "kg_solvent_water log10activity bulk_composition bulk_composition free_mineral     free_mineral free_mineral        bulk_composition"
    constraint_unit = "   kg               dimensionless moles            moles            moles            moles        moles               moles"
    prevent_precipitation = ""
    ramp_max_ionic_strength_initial = 0
    remove_fixed_activity_name = 'H+'
    remove_fixed_activity_time = "0"
    initial_temperature = 300
    temperature = 300
    execute_console_output_on = 'initial timestep_end'
    source_species_names = "Fo91_IdealMix"
    source_species_rates = "6.8321"
    max_initial_residual = 1E-2
    stoichiometric_ionic_str_using_Cl_only = true
    abs_tol = 1e-12
[]

[Executioner]
  type = Transient
  dt = 1
  end_time = 1
[]

