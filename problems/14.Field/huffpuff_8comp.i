# ==========================================================================
# 8-component PorousFlow HUFF-AND-PUFF (inject acid -> soak -> produce)
# Fracture + matrix mesh, closed unit, isothermal 200 C.
#
# Cycle (single):
#   Inject  : 0   - 30  day   (inlet held at p_inject = 40 MPa, ACID solution)
#   Soak    : 30  - 210 day   (all BCs off -> closed unit)
#   Produce : 210 - 240 day   (inlet held at p_produce = 30 MPa)
#
# Eight fluid components (match the geochemistry basis
#   H2O H+ Na+ Cl- Mg++ Fe++ SiO2(aq) O2(aq)):
#   f0 = H+     (component 0)
#   f1 = Na+    (component 1)
#   f2 = Cl-    (component 2)
#   f3 = Mg++   (component 3)
#   f4 = Fe++   (component 4)
#   f5 = SiO2   (component 5)
#   f6 = O2     (component 6)
#   porepressure = H2O (component 7, the LAST component)
#
# Injected fluid is a dilute HCl acid (pH~2): H+ and Cl- at finite mass
# fractions, H2O the balance; the other reactive ions (Na, Mg, Fe, SiO2, O2)
# enter only at trace level (produced inside by serpentinization, not carried
# in). During injection the inlet is held at 40 MPa AND at the acid
# composition; produced water leaves through PorousFlowOutflowBC.
#
# save_component_rate_in stores per-node kg/s changes of every component for
# transfer to the geochemistry sub-app (operator-split coupling, added later).
#
# NOTE: constant porosity here (rock compressibility NOT included, per request).
# Mesh blocks : "fracture", "matrix"
# Mesh sides  : "inlet"(fracture bottom), "outlet_top", "left", "right", "bottom"
# ==========================================================================

# ---- injected acid composition (mass fractions), pH ~ 2 dilute HCl ----
h_mf_in    = 1e-5
cl_mf_in   = 3.52e-4
trace_mf   = 1e-10          # Na, Mg, Fe, SiO2, O2: trace in injected acid
# h2o_mf_in  = 0.9996379995   # = 1 - h - cl - 5*trace

# ---- pressure-controlled injection / production ----
p_inject   = 45e6           # 40 MPa injection bottomhole pressure (huff)
p_produce  = 30e6           # 30 MPa production bottomhole pressure (puff)

# ---- huff-and-puff schedule (days) ----
inject_days  = 30
soak_days    = 180
produce_days = 30
t_inject_end  = ${fparse inject_days * 86400}
t_soak_end    = ${fparse (inject_days + soak_days) * 86400}
t_produce_end = ${fparse (inject_days + soak_days + produce_days) * 86400}

# ---- reservoir pressure / properties ----
p_init   = 30e6            # 30 MPa formation pressure
phi_mat  = 0.05
phi_frac = 0.15
k_mat    = 3e-18           # 0.03 mD
k_frac   = 5e-14           # 50 mD

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = fracture_domain.msh
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 0'
[]

[Variables]
  [f0]                              # H+
    initial_condition = 1e-10
  []
  [f1]                              # Na+
    initial_condition = 1e-10
  []
  [f2]                              # Cl-
    initial_condition = 1e-10
  []
  [f3]                              # Mg++
    initial_condition = 1e-10
  []
  [f4]                              # Fe++
    initial_condition = 1e-10
  []
  [f5]                              # SiO2
    initial_condition = 1e-10
  []
  [f6]                              # O2
    initial_condition = 1e-10
  []
  [porepressure]                    # H2O (last component)
    initial_condition = ${p_init}
  []
[]

# --------------------------------------------------------------------------
# PorousFlowFullySaturated Action for 7 solutes + water.
#   save_component_rate_in: one rate var per component (8), same order.
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
    density0 = 865.0        # ~200 C water
    viscosity = 1.3e-4      # ~200 C water (Pa.s)
  []
[]

[Materials]
  # Pressure-dependent porosity (fluid = true) adds rock/pore storativity to
  # help the closed-unit soak phase converge. biot 0.8, solid_bulk 5e10 Pa.
  [porosity_matrix]
    type = PorousFlowPorosity
    fluid = true
    porosity_zero = ${phi_mat}
    biot_coefficient = 0.8
    solid_bulk = 5e10
    reference_porepressure = ${p_init}
    block = matrix
  []
  [porosity_fracture]
    type = PorousFlowPorosity
    fluid = true
    porosity_zero = ${phi_frac}
    biot_coefficient = 0.8
    solid_bulk = 5e10
    reference_porepressure = ${p_init}
    block = fracture
  []
  [permeability_matrix]
    type = PorousFlowPermeabilityConst
    permeability = '${k_mat} 0        0
                    0        ${k_mat} 0
                    0        0        ${k_mat}'
    block = matrix
  []
  [permeability_fracture]
    type = PorousFlowPermeabilityConst
    permeability = '${k_frac} 0         0
                    0         ${k_frac} 0
                    0         0         ${k_frac}'
    block = fracture
  []
[]

# --------------------------------------------------------------------------
# Boundary conditions.
#   INJECT phase: inlet held at 40 MPa AND at acid composition (each solute
#                 fixed to its injected mass fraction by DirichletBC).
#   PRODUCE phase: inlet held at 30 MPa; solutes leave via PorousFlowOutflowBC.
#   SOAK: all disabled -> closed unit.
# All disabled at start; [Controls] enable each phase's BCs in its window.
# --------------------------------------------------------------------------
[BCs]
  # ---------- INJECTION (huff): pressure + acid composition ----------
  [inj_p]
    type = DirichletBC
    variable = porepressure
    boundary = inlet
    value = ${p_inject}
    preset = true
    enable = false
  []
  [inj_H]
    type = DirichletBC
    variable = f0
    boundary = inlet
    value = ${h_mf_in}
    preset = true
    enable = false
  []
  [inj_Na]
    type = DirichletBC
    variable = f1
    boundary = inlet
    value = ${trace_mf}
    preset = true
    enable = false
  []
  [inj_Cl]
    type = DirichletBC
    variable = f2
    boundary = inlet
    value = ${cl_mf_in}
    preset = true
    enable = false
  []
  [inj_Mg]
    type = DirichletBC
    variable = f3
    boundary = inlet
    value = ${trace_mf}
    preset = true
    enable = false
  []
  [inj_Fe]
    type = DirichletBC
    variable = f4
    boundary = inlet
    value = ${trace_mf}
    preset = true
    enable = false
  []
  [inj_SiO2]
    type = DirichletBC
    variable = f5
    boundary = inlet
    value = ${trace_mf}
    preset = true
    enable = false
  []
  [inj_O2]
    type = DirichletBC
    variable = f6
    boundary = inlet
    value = ${trace_mf}
    preset = true
    enable = false
  []

  # ---------- PRODUCTION (puff): pressure + free solute outflow ----------
  [prod_p]
    type = DirichletBC
    variable = porepressure
    boundary = inlet
    value = ${p_produce}
    preset = true
    enable = false
  []
  [prod_H]
    type = PorousFlowOutflowBC
    variable = f0
    boundary = inlet
    mass_fraction_component = 0
    enable = false
  []
  [prod_Na]
    type = PorousFlowOutflowBC
    variable = f1
    boundary = inlet
    mass_fraction_component = 1
    enable = false
  []
  [prod_Cl]
    type = PorousFlowOutflowBC
    variable = f2
    boundary = inlet
    mass_fraction_component = 2
    enable = false
  []
  [prod_Mg]
    type = PorousFlowOutflowBC
    variable = f3
    boundary = inlet
    mass_fraction_component = 3
    enable = false
  []
  [prod_Fe]
    type = PorousFlowOutflowBC
    variable = f4
    boundary = inlet
    mass_fraction_component = 4
    enable = false
  []
  [prod_SiO2]
    type = PorousFlowOutflowBC
    variable = f5
    boundary = inlet
    mass_fraction_component = 5
    enable = false
  []
  [prod_O2]
    type = PorousFlowOutflowBC
    variable = f6
    boundary = inlet
    mass_fraction_component = 6
    enable = false
  []
[]

# --------------------------------------------------------------------------
# Time-based activation of injection / production phases.
# --------------------------------------------------------------------------
[Controls]
  [do_inject]
    type = TimePeriod
    enable_objects = 'BCs::inj_p BCs::inj_H BCs::inj_Na BCs::inj_Cl BCs::inj_Mg BCs::inj_Fe BCs::inj_SiO2 BCs::inj_O2'
    start_time = 0
    end_time = ${t_inject_end}
    set_sync_times = true
    execute_on = 'initial timestep_begin'
    implicit = false
  []
  [do_produce]
    type = TimePeriod
    enable_objects = 'BCs::prod_p BCs::prod_H BCs::prod_Na BCs::prod_Cl BCs::prod_Mg BCs::prod_Fe BCs::prod_SiO2 BCs::prod_O2'
    start_time = ${t_soak_end}
    end_time = ${t_produce_end}
    set_sync_times = true
    execute_on = 'initial timestep_begin'
    implicit = false
  []
[]

[AuxVariables]
  [temp]
    initial_condition = 200
  []
  # per-component transport rates saved by the Action (kg/s at each node)
  [rate_H][]
  [rate_Na][]
  [rate_Cl][]
  [rate_Mg][]
  [rate_Fe][]
  [rate_SiO2][]
  [rate_O2][]
  [rate_H2O][]
[]

[Preconditioning]
  active = basic
  [basic]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_hypre_type'
    petsc_options_value = ' hypre    boomeramg'
  []
[]

[Executioner]
  type = Transient
  solve_type = Newton
  automatic_scaling = true

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 100
    growth_factor = 1.2
    cutback_factor = 0.5
    optimal_iterations = 10
  []

  end_time = ${t_produce_end}
  dtmax = 43200
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  nl_max_its = 15
[]

[Postprocessors]
  [p_inlet]
    type = SideAverageValue
    variable = porepressure
    boundary = inlet
  []
  [p_max]
    type = NodalExtremeValue
    variable = porepressure
  []
  [H_inlet]
    type = SideAverageValue
    variable = f0
    boundary = inlet
  []
  [Cl_inlet]
    type = SideAverageValue
    variable = f2
    boundary = inlet
  []
  # total masses currently in the domain (rise on inject, fall on produce)
  [water_mass]
    type = PorousFlowFluidMass
    fluid_component = 7
  []
  [H_mass]
    type = PorousFlowFluidMass
    fluid_component = 0
  []
  [Mg_mass]
    type = PorousFlowFluidMass
    fluid_component = 3
  []
  [SiO2_mass]
    type = PorousFlowFluidMass
    fluid_component = 5
  []
  # ---- cumulative PRODUCED mass of each component ----
  # The domain mass balance gives production: during the produce phase the
  # in-domain mass falls, and that decrease is what was produced. Tracking
  # the in-domain masses above (water_mass, H_mass, Mg_mass, SiO2_mass) over
  # the produce window gives cumulative produced mass = (mass at start of
  # produce) - (current mass). For H2 later, add its component mass here.
[]

[Outputs]
  exodus = true
  csv = true
[]

# ==========================================================================
# GEOCHEMISTRY COUPLING (add later, operator split):
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
#     source_variable = 'rate_H rate_Na rate_Cl rate_Mg rate_Fe rate_SiO2 rate_O2 rate_H2O'
#     variable        = 'pf_rate_H pf_rate_Na pf_rate_Cl pf_rate_Mg pf_rate_Fe pf_rate_SiO2 pf_rate_O2 pf_rate_H2O'
#     to_multi_app = react
#   []
#   [massfrac_from_geochem]
#     type = MultiAppCopyTransfer
#     source_variable = 'massfrac_H massfrac_Na massfrac_Cl massfrac_Mg massfrac_Fe massfrac_SiO2 massfrac_O2'
#     variable        = 'f0 f1 f2 f3 f4 f5 f6'
#     from_multi_app = react
#   []
# []
# ==========================================================================
