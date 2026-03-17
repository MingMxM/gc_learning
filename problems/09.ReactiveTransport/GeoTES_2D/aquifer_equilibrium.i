[TimeIndependentReactionSolver]
    model_definition = definition
    geochemistry_reactor_name = reactor
    charge_balance_species = "Cl-"
    swap_out_of_basis = "SiO2(aq)"
    swap_into_basis = QuartzLike
    constraint_species = "H2O              Na+              Cl-              QuartzLike"
    constraint_value = "  1.0              0.1              0.1              396.685"
    constraint_meaning = "kg_solvent_water bulk_composition bulk_composition free_mineral"
    constraint_unit = "   kg               moles            moles            moles"
    temperature = 50.0
    ramp_max_ionic_strength_initial = 0
    add_aux_pH = false
    precision = 12
[]

[Postprocessors]
    [free_moles_SiO2]
        type = PointValue
        point = '0 0 0'
        variable = 'molal_SiO2(aq)'
    []
[]

[UserObjects]
    [definition]
        type = GeochemicalModelDefinition
        database_file = "../../../database/small_database.json"
        basis_species = "H2O SiO2(aq) Na+ Cl-"
        equilibrium_minerals = "QuartzLike"
    []
[]

[Outputs]
    csv = true
[]