[UserObjects]
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/moose_geochemdb.json"
    basis_species = "H2O H+ Na+ Cl- Mg++ Fe++ SiO2(aq) O2(aq)"
    remove_all_extrapolated_secondary_species = true
    equilibrium_minerals = "Forsterite Fayalite Magnetite Greenalite Chrysotile Brucite"
  []
[]

[TimeDependentReactionSolver]
    model_definition = definition
    # swap_out_of_basis = "O2(aq)"
    # swap_into_basis = "  O2(g)"
    charge_balance_species = "Cl-"
    constraint_species = "H2O              H+            Na+              Cl-              Mg++             Fe++             SiO2(aq)         O2(aq)"
    constraint_value = "  1.0              -7.0          0.565            0.565            1e-6             1e-6             1e-6             1e-20"
    constraint_meaning = "kg_solvent_water log10activity bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition"
    constraint_unit = "   kg               dimensionless moles            moles            moles            moles            moles            moles"
    # prevent_precipitation = "Magnetite Greenalite Chrysotile Brucite"
    ramp_max_ionic_strength_initial = 10
    remove_fixed_activity_name = 'H+'
    remove_fixed_activity_time = "0"
    initial_temperature = 50
    temperature = 50
    execute_console_output_on = 'initial timestep_end'
    source_species_names = "Forsterite Fayalite"
    source_species_rates = " 16.3074   1.613"
    max_initial_residual = 1E-2
    stoichiometric_ionic_str_using_Cl_only = true
    mol_cutoff = 1E-6
    abs_tol = 1e-12
[]

[Executioner]
  type = Transient
  dt = 0.1
  end_time = 1
[]

