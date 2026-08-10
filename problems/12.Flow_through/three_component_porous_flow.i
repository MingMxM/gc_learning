# ==========================================================================
# Flow-through reactive-transport MAIN APP (transport only, 2 components)
# Modeled on the GeoTES example porous_flow.i, using the PorousFlowFullySaturated
# Action rather than hand-written kernels.
#
# Packed olivine tube, 2D axisymmetric (RZ):
#   r in [0, 0.0125] m, z in [0, 0.075] m  (2.5 cm dia x 7.5 cm long)
#   porosity 0.334, permeability 45 D, T = 230 C (isothermal here)
#
# Two transported solutes injected with a 1 wt% NaCl brine at 0.015 cm3/min:
#   f0 = Na+   (fluid component 0)
#   f1 = Cl-   (fluid component 1)
#   porepressure = H2O (fluid component 2, the LAST component)
#
# Coupling type is Hydro (isothermal): temperature is fixed, so no energy
# equation is solved. The GeoTES file used ThermoHydro because it has a heat
# exchanger; the packed tube is held at constant 230 C.
#
# save_component_rate_in is kept so this file can later be coupled to a
# geochemistry sub-app exactly as in GeoTES (MultiApp + Transfers), without
# restructuring. The MultiApp/Transfer blocks are left commented at the end.
# ==========================================================================

# ---- injected brine composition (mass fractions) ----
na_mf_in  = 0.00393
cl_mf_in  = 0.00607
h2o_mf_in = 0.99000

# ---- total injected mass flux at the inlet face (kg/m^2/s) ----
# 0.015 cm3/min * 827 kg/m3 / (pi*0.0125^2 m2) = 4.2119e-4
flux_total = 4.2119e-4

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim  = 2
    nx   = 6
    xmin = 0.0
    xmax = 0.0125
    ny   = 60
    ymin = 0.0
    ymax = 0.075
  []
  [rename_boundaries]
    type = RenameBoundaryGenerator
    input = gen
    old_boundary = 'left right bottom top'
    new_boundary = 'axis wall inlet outlet'
  []
  coord_type = RZ
  rz_coord_axis = Y
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 0'
[]

[Variables]
  [f0]                              # Na+  (component 0)
    initial_condition = 0.0
  []
  [f1]                              # Cl-  (component 1)
    initial_condition = 0.0
  []
  [porepressure]                    # H2O  (component 2, last)
    initial_condition = 3.4474e6    # 500 psi
  []
[]

# --------------------------------------------------------------------------
# PorousFlowFullySaturated Action: builds the mass-time-derivative, Darcy
# advection and dispersion kernels for all components automatically.
#   mass_fraction_vars = 'f0 f1' -> f0=comp0, f1=comp1, porepressure=comp2
#   save_component_rate_in stores per-node kg/s changes for later coupling.
# --------------------------------------------------------------------------
[PorousFlowFullySaturated]
  coupling_type = Hydro
  porepressure = porepressure
  temperature = temp
  mass_fraction_vars = 'f0 f1'
  save_component_rate_in = 'rate_Na rate_Cl rate_H2O' # kg/node/dt, for geochem coupling later
  fp = the_simple_fluid
  gravity = '0 0 0'
  temperature_unit = Celsius
  stabilization = Full
[]
# NOTE: the PorousFlowFullySaturated Action does NOT add diffusion/dispersion
# kernels. KT stabilization controls numerical dispersion at the sharp front.
# To include PHYSICAL molecular diffusion/mechanical dispersion, add explicit
# PorousFlowDispersiveFlux kernels per component (as in solute_tracer_transport),
# together with the PorousFlowDiffusivityConst material below. For now transport
# is advection-only with KT keeping the front clean.

[FluidProperties]
  [the_simple_fluid]
    type = SimpleFluidProperties
    thermal_expansion = 0.0
    bulk_modulus = 2.2e9
    density0 = 827.0
    viscosity = 0.0005
  []
[]

[Materials]
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 0.334
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '4.5e-11 0       0   
                    0       4.5e-11 0
                    0       0       4.5e-11'
  []
  # NOTE: no [temperature] material here. The PorousFlowFullySaturated Action
  # builds the temperature material itself; declaring one here collides with it
  # (the "declared by multiple materials" error). The fixed 230 C is supplied
  # to the Action via the temperature AuxVariable below (temperature_unit=Celsius).
[]

# --------------------------------------------------------------------------
# Fixed-rate injection at the inlet, split by component so the injected
# brine has the correct Na+/Cl- concentrations. Outlet held at fixed
# pressure with free outflow of each solute.
# --------------------------------------------------------------------------
[BCs]
  [inject_Na]
    type = PorousFlowSink
    variable = f0
    boundary = inlet
    flux_function = ${fparse -flux_total * na_mf_in}
    fluid_phase = 0
  []
  [inject_Cl]
    type = PorousFlowSink
    variable = f1
    boundary = inlet
    flux_function = ${fparse -flux_total * cl_mf_in}
    fluid_phase = 0
  []
  [inject_H2O]
    type = PorousFlowSink
    variable = porepressure
    boundary = inlet
    flux_function = ${fparse -flux_total * h2o_mf_in}
    fluid_phase = 0
  []
  [outlet_pressure]
    type = DirichletBC
    variable = porepressure
    boundary = outlet
    value = 3.4474e6
  []
  [outlet_Na]
    type = PorousFlowOutflowBC
    variable = f0
    boundary = outlet
    mass_fraction_component = 0
  []
  [outlet_Cl]
    type = PorousFlowOutflowBC
    variable = f1
    boundary = outlet
    mass_fraction_component = 1
  []
[]

[AuxVariables]
  [temp]
    initial_condition = 230        # 230 C (temperature_unit=Celsius in the Action)
  []
  [rate_Na]
  []
  [rate_Cl]
  []
  [rate_H2O]
  []
  [Darcy_vel_z]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [Darcy_vel_z]
    type = PorousFlowDarcyVelocityComponent
    variable = Darcy_vel_z
    component = y
    fluid_phase = 0
  []
[]

[Preconditioning]
  active = typically_efficient
  [typically_efficient]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_hypre_type'
    petsc_options_value = ' hypre    boomeramg'
  []
  [strong]
    type = SMP
    full = true
    petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix'
    petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
    petsc_options_value = ' asm      ilu           NONZERO                   2'
  []
  [probably_too_strong]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
[]

[Executioner]
  type = Transient
  solve_type = Newton

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1000
    growth_factor = 1.5
    cutback_factor = 0.5
    optimal_iterations = 10
  []

  end_time = 3024000              # 35 days
  dtmax = 86400
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-10
[]

[Postprocessors]
  [Na_inlet]
    type = SideAverageValue
    variable = f0
    boundary = inlet
  []
  [Na_outlet]
    type = SideAverageValue
    variable = f0
    boundary = outlet
  []
  [Cl_outlet]
    type = SideAverageValue
    variable = f1
    boundary = outlet
  []
  [vel_z]
    type = ElementAverageValue
    variable = Darcy_vel_z
  []
[]

[Outputs]
  exodus = true
  csv = true
[]

# ==========================================================================
# COUPLING TO GEOCHEMISTRY (add later, exactly as in GeoTES):
#
# [MultiApps]
#   [react]
#     type = TransientMultiApp
#     input_files = serpentinization_geochemistry.i
#     clone_master_mesh = true
#     execute_on = 'timestep_end'
#   []
# []
# [Transfers]
#   [changes_due_to_flow]
#     type = MultiAppCopyTransfer
#     source_variable = 'rate_H2O rate_Na rate_Cl'
#     variable = 'pf_rate_H2O pf_rate_Na pf_rate_Cl'
#     to_multi_app = react
#   []
#   [massfrac_from_geochem]
#     type = MultiAppCopyTransfer
#     source_variable = 'massfrac_Na massfrac_Cl'
#     variable = 'f0 f1'
#     from_multi_app = react
#   []
# []
# ==========================================================================
