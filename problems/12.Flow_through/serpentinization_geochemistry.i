#########################################################################
# Serpentinization geochemistry SUB-APP (spatial reactive geochemistry).
#
# Modeled on the GeoTES aquifer_geochemistry.i, but using YOUR calibrated
# serpentinization system (kinetic olivine/serpentine/brucite/magnetite).
#
# This file receives, as AuxVariables from the porous-flow MAIN APP, the
# transport-induced mass-change rates of each aqueous component:
#   pf_rate_H pf_rate_Na pf_rate_Cl pf_rate_Mg pf_rate_Fe pf_rate_SiO2
#   pf_rate_O2 pf_rate_H2O   (kg/s at each node)   + temperature.
#
# The geochemistry module needs mol/s per litre of aqueous solution, so
# each pf_rate_X is converted with:
#   rate_X_per_1l = pf_rate_X / MW_X / nodal_void_volume
#
# It sends back massfrac_X (mass fractions) to the main app, computed from
# the transported_* moles.
#
# Kinetic system is copied verbatim from your batch file
# Hydrogen_new_kinetic_nutral_acid.i (10 rate laws, 5 kinetic minerals).
#########################################################################

[UserObjects]
  # ----- kinetic rate laws (copied from your batch calibration) -----
  [Fo90_rate]
    type = GeochemistryKineticRate
    kinetic_species_name = Fo90
    intrinsic_rate_constant = 2.29087e-11
    activation_energy = 79.0E3
    area_quantity = 2.25e-2
    multiply_by_mass = true
    one_over_T0 = 0.003354
  []
  [Fo90_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = Fo90
    intrinsic_rate_constant = 1.41425e-7
    activation_energy = 67.2E3
    area_quantity = 2.25e-2
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
    area_quantity = 2.1e-4
    multiply_by_mass = true
    one_over_T0 = 0.003354
  []
  [Liz90_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = Liz90
    intrinsic_rate_constant = 1.99526e-6
    activation_energy = 75.5E3
    area_quantity = 2.1e-4
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
    area_quantity = 8e-3
    multiply_by_mass = true
    one_over_T0 = 0.003354
  []
  [En90_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = En90
    intrinsic_rate_constant = 9.549926e-10
    activation_energy = 80.0E3
    area_quantity = 8e-3
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
    area_quantity = 5e-5
    multiply_by_mass = true
    one_over_T0 = 0.003354
  []
  [Brucite85_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = Brucite85
    intrinsic_rate_constant = 1.86209e-5
    activation_energy = 59.0E3
    area_quantity = 5e-5
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
    area_quantity = 1e-10
    multiply_by_mass = true
    one_over_T0 = 0.003354
  []
  [Magnetite_acid]
    type = GeochemistryKineticRate
    kinetic_species_name = Magnetite
    intrinsic_rate_constant = 2.57039e-9
    activation_energy = 18.6E3
    area_quantity = 1e-10
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

  # ----- nodal void volume: converts per-node -> per-litre-of-solution -----
  [nodal_void_volume_uo]
    type = NodalVoidVolume
    porosity = porosity
    execute_on = 'initial timestep_end'
  []
[]

# --------------------------------------------------------------------------
# SpatialReactionSolver: the spatial version of your batch reaction solver.
# Same swaps/constraints/kinetics as your batch file, but now it also takes
# transport source rates (rate_*_per_1l) from the main app at every node.
# --------------------------------------------------------------------------
[SpatialReactionSolver]
  model_definition = definition
  geochemistry_reactor_name = reactor
  swap_out_of_basis = "O2(aq)"
  swap_into_basis = "H2(aq)"
  charge_balance_species = "Cl-"

  # initial solution composition (per your batch file), assumed at each node
  constraint_species = "H2O               H+            Na+              Cl-              Mg++             Fe++             SiO2(aq)         H2(aq)"
  constraint_value    = "1                -7.0          0.001            0.001            1e-5             1e-5             1e-5             1e-5"
  constraint_meaning  = "kg_solvent_water log10activity bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition bulk_composition"
  constraint_unit     = "kg               dimensionless moles            moles            moles            moles            moles            moles"

  remove_fixed_activity_name = 'H+'
  remove_fixed_activity_time = '0'

  initial_temperature = 230
  temperature = temperature

  # kinetic minerals initial amounts (per your batch file)
  kinetic_species_name          = "Fo90    Liz90    En90    Brucite85 Magnetite"
  kinetic_species_initial_value = "42.1995 0.363789 3.06899 1e-3      1e-5"
  kinetic_species_unit          = "moles   moles    moles   moles     moles"

  # transport source terms from the main app (mol/s per litre of solution)
  source_species_names = 'H+            Na+            Cl-            Mg++           Fe++           SiO2(aq)         O2(aq)         H2O'
  source_species_rates = 'rate_H_per_1l rate_Na_per_1l rate_Cl_per_1l rate_Mg_per_1l rate_Fe_per_1l rate_SiO2_per_1l rate_O2_per_1l rate_H2O_per_1l'

  ramp_max_ionic_strength_initial = 0
  stoichiometric_ionic_str_using_Cl_only = true
  evaluate_kinetic_rates_always = true
  max_initial_residual = 1E-2
  abs_tol = 1e-12

  execute_console_output_on = ''
  # add_aux_molal = false
  add_aux_mg_per_kg = false
  add_aux_free_mg = false
  add_aux_activity = false
  add_aux_bulk_moles = false
  adaptive_timestepping = true
[]

# --------------------------------------------------------------------------
# Mesh: matches the main-app packed-tube RZ mesh. With clone_master_mesh=true
# in the main app's MultiApp block, this is cloned automatically; it is kept
# here so the sub-app can also be run standalone for testing.
# --------------------------------------------------------------------------
[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim  = 2
    nx   = 10
    xmin = 0.0
    xmax = 0.025             # width = 2.5 cm (full width, planar 2D)
    ny   = 60
    ymin = 0.0
    ymax = 0.075             # length = 7.5 cm
  []
  [rename_boundaries]
    type = RenameBoundaryGenerator
    input = gen
    old_boundary = 'left right bottom top'
    new_boundary = 'side1 side2 inlet outlet'
  []
  # planar 2D (Cartesian), matches the main app. With clone_master_mesh=true
  # in the main app the mesh is cloned from there; kept here for standalone runs.
[]

[GlobalParams]
  point = '0 0 0'
  reactor = reactor
[]

[Executioner]
  type = Transient
  solve_type = Newton
  end_time = 3024000        # 35 days (matches main app)
  [TimeStepper]
    type = FunctionDT
    function = 'min(max(100, 0.1 * t),3600)'
  []
[]

[AuxVariables]
  [temperature]
    initial_condition = 230
  []
  [porosity]
    initial_condition = 0.334
  []
  [nodal_void_volume]
  []

  # ---- transport rates received from main app (kg/s at each node) ----
  [pf_rate_H]
  []
  [pf_rate_Na]
  []
  [pf_rate_Cl]
  []
  [pf_rate_Mg]
  []
  [pf_rate_Fe]
  []
  [pf_rate_SiO2]
  []
  [pf_rate_O2]
  []
  [pf_rate_H2O]
  []

  # ---- converted rates (mol/s per litre of solution) ----
  [rate_H_per_1l]
  []
  [rate_Na_per_1l]
  []
  [rate_Cl_per_1l]
  []
  [rate_Mg_per_1l]
  []
  [rate_Fe_per_1l]
  []
  [rate_SiO2_per_1l]
  []
  [rate_O2_per_1l]
  []
  [rate_H2O_per_1l]
  []

  # ---- transported moles (from geochem) ----
  [transported_H]
  []
  [transported_Na]
  []
  [transported_Cl]
  []
  [transported_Mg]
  []
  [transported_Fe]
  []
  [transported_SiO2]
  []
  [transported_O2]
  []
  [transported_H2O]
  []
  [transported_mass]
  []

  # ---- mass fractions sent back to main app ----
  [massfrac_H]
  []
  [massfrac_Na]
  []
  [massfrac_Cl]
  []
  [massfrac_Mg]
  []
  [massfrac_Fe]
  []
  [massfrac_SiO2]
  []
  [massfrac_O2]
  []
  [massfrac_H2O]
  []

  # ---- mineral volumes percentage ----
  [volpct_Fo90]
  []
  [volpct_Liz90]
  []
  [volpct_En90]
  []
  [volpct_Brucite85]
  []
  [volpct_Magnetite]
  []
  [total_solid_cm3]
  []
[]

[AuxKernels]
  # nodal void volume
  [nodal_void_volume_auxk]
    type = NodalVoidVolumeAux
    variable = nodal_void_volume
    nodal_void_volume_uo = nodal_void_volume_uo
    execute_on = 'initial timestep_end'
  []

  # porosity from kinetic mineral volumes (volume expansion -> porosity drop)
  [porosity_auxk]
    type = ParsedAux
    coupled_variables = 'free_cm3_Fo90 free_cm3_Liz90 free_cm3_En90 free_cm3_Brucite85 free_cm3_Magnetite'
    expression = '1000.0 / (1000.0 + free_cm3_Fo90 + free_cm3_Liz90 + free_cm3_En90 + free_cm3_Brucite85 + free_cm3_Magnetite)'
    variable = porosity
    execute_on = 'timestep_end'
  []

  # ---- unit conversion: kg/s -> mol/s/litre (divide by MW and void volume) ----
  [rate_H_per_1l_auxk]
    type = ParsedAux
    coupled_variables = 'pf_rate_H nodal_void_volume'
    variable = rate_H_per_1l
    expression = 'pf_rate_H / 1.0079 / nodal_void_volume'
    execute_on = 'timestep_begin'
  []
  [rate_Na_per_1l_auxk]
    type = ParsedAux
    coupled_variables = 'pf_rate_Na nodal_void_volume'
    variable = rate_Na_per_1l
    expression = 'pf_rate_Na / 22.9898 / nodal_void_volume'
    execute_on = 'timestep_begin'
  []
  [rate_Cl_per_1l_auxk]
    type = ParsedAux
    coupled_variables = 'pf_rate_Cl nodal_void_volume'
    variable = rate_Cl_per_1l
    expression = 'pf_rate_Cl / 35.453 / nodal_void_volume'
    execute_on = 'timestep_begin'
  []
  [rate_Mg_per_1l_auxk]
    type = ParsedAux
    coupled_variables = 'pf_rate_Mg nodal_void_volume'
    variable = rate_Mg_per_1l
    expression = 'pf_rate_Mg / 24.305 / nodal_void_volume'
    execute_on = 'timestep_begin'
  []
  [rate_Fe_per_1l_auxk]
    type = ParsedAux
    coupled_variables = 'pf_rate_Fe nodal_void_volume'
    variable = rate_Fe_per_1l
    expression = 'pf_rate_Fe / 55.847 / nodal_void_volume'
    execute_on = 'timestep_begin'
  []
  [rate_SiO2_per_1l_auxk]
    type = ParsedAux
    coupled_variables = 'pf_rate_SiO2 nodal_void_volume'
    variable = rate_SiO2_per_1l
    expression = 'pf_rate_SiO2 / 60.0843 / nodal_void_volume'
    execute_on = 'timestep_begin'
  []
  [rate_O2_per_1l_auxk]
    type = ParsedAux
    coupled_variables = 'pf_rate_O2 nodal_void_volume'
    variable = rate_O2_per_1l
    expression = 'pf_rate_O2 / 31.9988 / nodal_void_volume'
    execute_on = 'timestep_begin'
  []
  [rate_H2O_per_1l_auxk]
    type = ParsedAux
    coupled_variables = 'pf_rate_H2O nodal_void_volume'
    variable = rate_H2O_per_1l
    expression = 'pf_rate_H2O / 18.01801802 / nodal_void_volume'
    execute_on = 'timestep_begin'
  []

  # ---- transported moles of each component (from geochem reactor) ----
  [transported_H_auxk]
    type = GeochemistryQuantityAux
    variable = transported_H
    species = 'H+'
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_begin'
  []
  [transported_Na_auxk]
    type = GeochemistryQuantityAux
    variable = transported_Na
    species = 'Na+'
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_begin'
  []
  [transported_Cl_auxk]
    type = GeochemistryQuantityAux
    variable = transported_Cl
    species = 'Cl-'
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_begin'
  []
  [transported_Mg_auxk]
    type = GeochemistryQuantityAux
    variable = transported_Mg
    species = 'Mg++'
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_begin'
  []
  [transported_Fe_auxk]
    type = GeochemistryQuantityAux
    variable = transported_Fe
    species = 'Fe++'
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_begin'
  []
  [transported_SiO2_auxk]
    type = GeochemistryQuantityAux
    variable = transported_SiO2
    species = 'SiO2(aq)'
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_begin'
  []
  [transported_O2_auxk]
    type = GeochemistryQuantityAux
    variable = transported_O2
    species = 'O2(aq)'
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_begin'
  []
  [transported_H2O_auxk]
    type = GeochemistryQuantityAux
    variable = transported_H2O
    species = 'H2O'
    quantity = transported_moles_in_original_basis
    execute_on = 'timestep_begin'
  []

  # ---- total transported mass (sum of moles * MW) ----
  [transported_mass_auxk]
    type = ParsedAux
    coupled_variables = 'transported_H transported_Na transported_Cl transported_Mg transported_Fe transported_SiO2 transported_O2 transported_H2O'
    variable = transported_mass
    expression = 'transported_H * 1.0079 + transported_Na * 22.9898 + transported_Cl * 35.453 + transported_Mg * 24.305 + transported_Fe * 55.847 + transported_SiO2 * 60.0843 + transported_O2 * 31.9988 + transported_H2O * 18.01801802'
    execute_on = 'timestep_end'
  []

  # ---- mass fractions to send back to the main app ----
  [massfrac_H_auxk]
    type = ParsedAux
    coupled_variables = 'transported_H transported_mass'
    variable = massfrac_H
    expression = 'transported_H * 1.0079 / transported_mass'
    execute_on = 'timestep_end'
  []
  [massfrac_Na_auxk]
    type = ParsedAux
    coupled_variables = 'transported_Na transported_mass'
    variable = massfrac_Na
    expression = 'transported_Na * 22.9898 / transported_mass'
    execute_on = 'timestep_end'
  []
  [massfrac_Cl_auxk]
    type = ParsedAux
    coupled_variables = 'transported_Cl transported_mass'
    variable = massfrac_Cl
    expression = 'transported_Cl * 35.453 / transported_mass'
    execute_on = 'timestep_end'
  []
  [massfrac_Mg_auxk]
    type = ParsedAux
    coupled_variables = 'transported_Mg transported_mass'
    variable = massfrac_Mg
    expression = 'transported_Mg * 24.305 / transported_mass'
    execute_on = 'timestep_end'
  []
  [massfrac_Fe_auxk]
    type = ParsedAux
    coupled_variables = 'transported_Fe transported_mass'
    variable = massfrac_Fe
    expression = 'transported_Fe * 55.847 / transported_mass'
    execute_on = 'timestep_end'
  []
  [massfrac_SiO2_auxk]
    type = ParsedAux
    coupled_variables = 'transported_SiO2 transported_mass'
    variable = massfrac_SiO2
    expression = 'transported_SiO2 * 60.0843 / transported_mass'
    execute_on = 'timestep_end'
  []
  [massfrac_O2_auxk]
    type = ParsedAux
    coupled_variables = 'transported_O2 transported_mass'
    variable = massfrac_O2
    expression = 'transported_O2 * 31.9988 / transported_mass'
    execute_on = 'timestep_end'
  []
  [massfrac_H2O_auxk]
    type = ParsedAux
    coupled_variables = 'transported_H2O transported_mass'
    variable = massfrac_H2O
    expression = 'transported_H2O * 18.01801802 / transported_mass'
    execute_on = 'timestep_end'
  []

# ---- total solid volume (cm3 per 1000 cm3 = per litre of solution basis) ----
  [total_solid_cm3_auxk]
    type = ParsedAux
    coupled_variables = 'free_cm3_Fo90 free_cm3_Liz90 free_cm3_En90 free_cm3_Brucite85 free_cm3_Magnetite'
    expression = 'free_cm3_Fo90 + free_cm3_Liz90 + free_cm3_En90 + free_cm3_Brucite85 + free_cm3_Magnetite'
    variable = total_solid_cm3
    execute_on = 'timestep_end'
  []

  # ---- each mineral volume as percent of solid volume (solids + 1000 cm3 solution) ----
  [volpct_Fo90_auxk]
    type = ParsedAux
    coupled_variables = 'free_cm3_Fo90 total_solid_cm3'
    expression = '100.0 * free_cm3_Fo90 / (total_solid_cm3)'
    variable = volpct_Fo90
    execute_on = 'timestep_end'
  []
  [volpct_Liz90_auxk]
    type = ParsedAux
    coupled_variables = 'free_cm3_Liz90 total_solid_cm3'
    expression = '100.0 * free_cm3_Liz90 / (total_solid_cm3)'
    variable = volpct_Liz90
    execute_on = 'timestep_end'
  []
  [volpct_En90_auxk]
    type = ParsedAux
    coupled_variables = 'free_cm3_En90 total_solid_cm3'
    expression = '100.0 * free_cm3_En90 / (total_solid_cm3)'
    variable = volpct_En90
    execute_on = 'timestep_end'
  []
  [volpct_Brucite85_auxk]
    type = ParsedAux
    coupled_variables = 'free_cm3_Brucite85 total_solid_cm3'
    expression = '100.0 * free_cm3_Brucite85 / (total_solid_cm3)'
    variable = volpct_Brucite85
    execute_on = 'timestep_end'
  []
  [volpct_Magnetite_auxk]
    type = ParsedAux
    coupled_variables = 'free_cm3_Magnetite total_solid_cm3'
    expression = '100.0 * free_cm3_Magnetite / (total_solid_cm3)'
    variable = volpct_Magnetite
    execute_on = 'timestep_end'
  []
[]

[Postprocessors]
  [porosity]
    type = PointValue
    variable = porosity
  []
  [free_cm3_Fo90]
    type = PointValue
    variable = free_cm3_Fo90
  []
  [free_cm3_Liz90]
    type = PointValue
    variable = free_cm3_Liz90
  []
  [free_cm3_En90]
    type = PointValue
    variable = free_cm3_En90
  []
  [free_cm3_Brucite85]
    type = PointValue
    variable = free_cm3_Brucite85
  []
  [free_cm3_Magnetite]
    type = PointValue
    variable = free_cm3_Magnetite
  []
  # [molal_H2aq]
  #   type = PointValue
  #   variable = 'molal_H2(aq)'
  # []
  [H2_outlet]
    type = SideAverageValue
    variable = molal_H2(aq)
    boundary = outlet
  []
  [Mg_outlet]
    type = SideAverageValue
    variable = molal_Mg++
    boundary = outlet
  []
  [Fe_outlet]
    type = SideAverageValue
    variable = molal_Fe++
    boundary = outlet
  []
  [SiO2_outlet]
    type = SideAverageValue
    variable = molal_SiO2(aq)
    boundary = outlet
  []
[]

[Outputs]
  exodus = true
  csv = true
[]
