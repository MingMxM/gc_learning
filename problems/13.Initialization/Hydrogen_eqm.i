[UserObjects]
  [definition]
    type = GeochemicalModelDefinition
    database_file = "../../database/serpentinization_database.json"
    basis_species = "H2O H+ Na+ Cl- Mg++ Fe++ SiO2(aq) O2(aq)"
    # remove_all_extrapolated_secondary_species = true
    equilibrium_minerals = "Fo90 Liz90 En90 Brucite85 Magnetite"
  []
[]

[TimeIndependentReactionSolver]
    model_definition = definition

    swap_out_of_basis = "SiO2(aq)   Mg++      O2(aq)"
    swap_into_basis = "  Liz90      Brucite85 Magnetite"

    charge_balance_species = "Cl-"

    constraint_species = "H2O              H+               Na+              Cl-              Brucite85        Fe++         Liz90        Magnetite"
    constraint_value = "  1                1e-7             0.001            0.001            30.08            1e-4         20.84        0.01"
    constraint_meaning = "kg_solvent_water bulk_composition bulk_composition bulk_composition free_mineral bulk_composition free_mineral free_mineral"
    constraint_unit = "   kg               moles            moles            moles            moles            moles        moles        moles"
    
    prevent_precipitation = "Fo90 En90"

    temperature = 200

    stoichiometric_ionic_str_using_Cl_only = true
    ramp_max_ionic_strength_initial = 0
    abs_tol = 1e-12
    mol_cutoff = 1e-7
[]

