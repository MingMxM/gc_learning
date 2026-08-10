# ==========================================================================
# Flow-through reactive-transport MAIN APP (transport, 7 solutes + water)
# PorousFlowFullySaturated Action.
#
# Packed olivine tube, 2D axisymmetric (RZ):
#   r in [0, 0.0125] m, z in [0, 0.075] m  (2.5 cm dia x 7.5 cm long)
#   porosity 0.334, permeability 45 D, T = 230 C (isothermal here)
#
# Eight fluid components, matching the geochemistry sub-app basis
#   (H2O H+ Na+ Cl- Mg++ Fe++ SiO2(aq) O2(aq)):
#   f0 = H+     (component 0)
#   f1 = Na+    (component 1)
#   f2 = Cl-    (component 2)
#   f3 = Mg++   (component 3)
#   f4 = Fe++   (component 4)
#   f5 = SiO2   (component 5)
#   f6 = O2     (component 6)
#   porepressure = H2O (component 7, the LAST component)
#
# Injected fluid is a dilute NaCl brine: Na+, Cl- and H2O are injected at
# finite mass fractions; the reactive ions (H+, Mg++, Fe++, SiO2, O2) enter
# only at trace level, since they are produced INSIDE the tube by
# serpentinization, not carried in with the injection.
#
# save_component_rate_in stores per-node kg/s changes of every component for
# transfer to the geochemistry sub-app (GeoTES-style operator-split coupling).
# ==========================================================================

# ---- injected brine composition (mass fractions) ----
h_mf_in   = 0.000844
cl_mf_in   = 0.0297
trace_mf   = 1e-10          # reactive ions: trace in the injected brine
h2o_mf_in  = 0.9694662409  # = 1 - na - cl - 5*trace

# ---- total injected mass flux at the inlet face (kg/m^2/s) ----
# Planar 2D: inlet area = width * unit thickness = 0.025 * 1 = 0.025 m^2.
# To keep the real 0.015 cm3/min injection:
#   flux = (0.015e-6/60 * 827) / 0.025 = 8.27e-6 kg/m^2/s
flux_total = 8.27e-6

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
  # planar 2D (Cartesian): no coord_type=RZ, no axis. A unit-thickness slab.
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 0'
[]

[Variables]
  [f0]                              # H+   (component 0)
    initial_condition = 0.0
  []
  [f1]                              # Na+  (component 1)
    initial_condition = 0.0
  []
  [f2]                              # Cl-  (component 2)
    initial_condition = 0.0
  []
  [f3]                              # Mg++ (component 3)
    initial_condition = 0.0
  []
  [f4]                              # Fe++ (component 4)
    initial_condition = 0.0
  []
  [f5]                              # SiO2 (component 5)
    initial_condition = 0.0
  []
  [f6]                              # O2   (component 6)
    initial_condition = 0.0
  []
  [porepressure]                    # H2O  (component 7, last)
    initial_condition = 3.4474e6    # 500 psi
  []
[]

# --------------------------------------------------------------------------
# PorousFlowFullySaturated Action for all 7 solutes + water.
#   mass_fraction_vars = 'f0 ... f6'  (7 mass-fraction vars = components 0..6)
#   porepressure       = component 7 (water)
#   save_component_rate_in: one rate var per component (8 total), same order.
# --------------------------------------------------------------------------
[PorousFlowFullySaturated]
  coupling_type = Hydro
  porepressure = porepressure
  temperature = temp
  mass_fraction_vars = 'f0 f1 f2 f3 f4 f5 f6'
  save_component_rate_in = 'rate_H rate_Na rate_Cl rate_Mg rate_Fe rate_SiO2 rate_O2 rate_H2O'
  fp = the_simple_fluid
  gravity = '0 0 0'
  temperature_unit = Celsius
  stabilization = Full
[]

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
[]

# --------------------------------------------------------------------------
# Fixed-rate injection at the inlet. Na+, Cl-, H2O at brine composition; the
# reactive ions at trace level. Outlet at fixed pressure, free solute outflow.
# --------------------------------------------------------------------------
[BCs]
  # --- reactive ions: trace injection ---
  [inject_H]
    type = PorousFlowSink
    variable = f0
    boundary = inlet
    flux_function = ${fparse -flux_total * h_mf_in}
    fluid_phase = 0
  []
  [inject_Na]
    type = PorousFlowSink
    variable = f1
    boundary = inlet
    flux_function = ${fparse -flux_total * trace_mf}
    fluid_phase = 0
  []
  [inject_Cl]
    type = PorousFlowSink
    variable = f2
    boundary = inlet
    flux_function = ${fparse -flux_total * cl_mf_in}
    fluid_phase = 0
  []
  [inject_Mg]
    type = PorousFlowSink
    variable = f3
    boundary = inlet
    flux_function = ${fparse -flux_total * trace_mf}
    fluid_phase = 0
  []
  [inject_Fe]
    type = PorousFlowSink
    variable = f4
    boundary = inlet
    flux_function = ${fparse -flux_total * trace_mf}
    fluid_phase = 0
  []
  [inject_SiO2]
    type = PorousFlowSink
    variable = f5
    boundary = inlet
    flux_function = ${fparse -flux_total * trace_mf}
    fluid_phase = 0
  []
  [inject_O2]
    type = PorousFlowSink
    variable = f6
    boundary = inlet
    flux_function = ${fparse -flux_total * trace_mf}
    fluid_phase = 0
  []
  # --- water ---
  [inject_H2O]
    type = PorousFlowSink
    variable = porepressure
    boundary = inlet
    flux_function = ${fparse -flux_total * h2o_mf_in}
    fluid_phase = 0
  []
  # --- outlet: fixed pressure ---
  [outlet_pressure]
    type = DirichletBC
    variable = porepressure
    boundary = outlet
    value = 3.4474e6
  []
  # --- outlet: free outflow of every solute ---
  [outlet_H]
    type = PorousFlowOutflowBC
    variable = f0
    boundary = outlet
    mass_fraction_component = 0
  []
  [outlet_Na]
    type = PorousFlowOutflowBC
    variable = f1
    boundary = outlet
    mass_fraction_component = 1
  []
  [outlet_Cl]
    type = PorousFlowOutflowBC
    variable = f2
    boundary = outlet
    mass_fraction_component = 2
  []
  [outlet_Mg]
    type = PorousFlowOutflowBC
    variable = f3
    boundary = outlet
    mass_fraction_component = 3
  []
  [outlet_Fe]
    type = PorousFlowOutflowBC
    variable = f4
    boundary = outlet
    mass_fraction_component = 4
  []
  [outlet_SiO2]
    type = PorousFlowOutflowBC
    variable = f5
    boundary = outlet
    mass_fraction_component = 5
  []
  [outlet_O2]
    type = PorousFlowOutflowBC
    variable = f6
    boundary = outlet
    mass_fraction_component = 6
  []
[]

[AuxVariables]
  [temp]
    initial_condition = 230        # 230 C (temperature_unit=Celsius)
  []
  # per-component transport rates saved by the Action (kg/s at each node)
  [rate_H]
  []
  [rate_Na]
  []
  [rate_Cl]
  []
  [rate_Mg]
  []
  [rate_Fe]
  []
  [rate_SiO2]
  []
  [rate_O2]
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
[]

[Executioner]
  type = Transient
  solve_type = Newton
  automatic_scaling = true

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
  nl_abs_tol = 1e-8
[]

[Postprocessors]
  [Na_outlet]
    type = SideAverageValue
    variable = f1
    boundary = outlet
  []
  [Cl_outlet]
    type = SideAverageValue
    variable = f2
    boundary = outlet
  []
  [Mg_outlet]
    type = SideAverageValue
    variable = f3
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
# COUPLING TO GEOCHEMISTRY (add when ready, GeoTES-style):

[MultiApps]
  [react]
    type = TransientMultiApp
    input_files = serpentinization_geochemistry.i
    clone_master_mesh = true
    execute_on = 'timestep_end'
  []
[]

[Transfers]
  [changes_due_to_flow]
    type = MultiAppCopyTransfer
    source_variable = 'rate_H rate_Na rate_Cl rate_Mg rate_Fe rate_SiO2 rate_O2 rate_H2O'
    variable        = 'pf_rate_H pf_rate_Na pf_rate_Cl pf_rate_Mg pf_rate_Fe pf_rate_SiO2 pf_rate_O2 pf_rate_H2O'
    to_multi_app = react
  []
  [massfrac_from_geochem]
    type = MultiAppCopyTransfer
    source_variable = 'massfrac_H massfrac_Na massfrac_Cl massfrac_Mg massfrac_Fe massfrac_SiO2 massfrac_O2'
    variable        = 'f0 f1 f2 f3 f4 f5 f6'
    from_multi_app = react
  []
[]
# ==========================================================================
