# ==========================================================================
# Single-phase PorousFlow HUFF-AND-PUFF cycle (inject -> soak -> produce)
# Fracture + matrix mesh, closed reservoir unit, isothermal 200 C.
#
# Cycle (single):
#   Inject  : 0   - 30  day   (inlet held at p_inject = 40 MPa)
#   Soak    : 30  - 210 day   (all BCs off -> fully closed, pressure holds)
#   Produce : 210 - 240 day   (inlet held at p_produce = 30 MPa)
#
# Mechanism (follows the standard MOOSE huff-and-puff pattern):
#   - inject and produce BCs are BOTH written, both start disabled.
#   - [Controls] TimePeriod enables each BC only during its phase.
#   - Soak needs no control: with both BCs off, the closed unit just holds.
#
# Both phases are PRESSURE-controlled Dirichlet BCs at the inlet:
#   inject 40 MPa pushes water in; produce 30 MPa lets it flow back.
#   Rates are computed by the model from the reservoir response.
#
# COUPLING HOOKS for geochemistry kept at the bottom (extend to 8 comps).
# Mesh blocks : "fracture", "matrix"
# Mesh sides  : "inlet"(fracture bottom), "outlet_top", "left", "right", "bottom"
# ==========================================================================

# ---- huff-and-puff schedule (days) ----
inject_days  = 30
soak_days    = 180          # 6 months
produce_days = 30

# derived phase times in seconds
t_inject_end   = ${fparse inject_days * 86400}
t_soak_end     = ${fparse (inject_days + soak_days) * 86400}
t_produce_end  = ${fparse (inject_days + soak_days + produce_days) * 86400}

# ---- pressure-controlled injection / production at the wellbore ----
p_inject  = 40e6           # 40 MPa injection bottomhole pressure (huff)
p_produce = 30e6           # 30 MPa production bottomhole pressure (puff)

# ---- reservoir pressure / properties ----
p_init   = 30e6            # 30 MPa formation pressure
phi_mat  = 0.05            # matrix porosity
phi_frac = 0.15            # fracture porosity
k_mat    = 3e-18           # 0.003 mD in m^2
k_frac   = 5e-14           # 50 mD    in m^2

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = fracture_domain.msh
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
[]

[Variables]
  [porepressure]
    initial_condition = ${p_init}
  []
[]

[PorousFlowFullySaturated]
  coupling_type = Hydro
  porepressure = porepressure
  temperature = temp
  fp = the_simple_fluid
  gravity = '0 0 0'
  temperature_unit = Celsius
  stabilization = Full
  save_component_rate_in = 'rate_H2O'
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
  [porosity_matrix]
    type = PorousFlowPorosityConst
    porosity = ${phi_mat}
    block = matrix
  []
  [porosity_fracture]
    type = PorousFlowPorosityConst
    porosity = ${phi_frac}
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
# Boundary conditions. Both inject and produce written; both start disabled.
# [Controls] enables each only during its phase. Soak = both off = closed.
#   inject_water : inlet held at 40 MPa (huff)
#   produce_water: inlet held at 30 MPa (puff)
# All other edges: no BC = no-flow (closed unit). left is symmetry.
# --------------------------------------------------------------------------
[BCs]
  [inject_water]
    type = DirichletBC
    variable = porepressure
    boundary = inlet
    value = ${p_inject}
    preset = true
    enable = false
  []
  [produce_water]
    type = DirichletBC
    variable = porepressure
    boundary = inlet
    value = ${p_produce}
    preset = true
    enable = false
  []
[]

# --------------------------------------------------------------------------
# Time-based activation of injection / production phases.
# --------------------------------------------------------------------------
[Controls]
  [do_inject]
    type = TimePeriod
    enable_objects = 'BCs::inject_water'
    start_time = 0
    end_time = ${t_inject_end}
    set_sync_times = true
    execute_on = 'initial timestep_begin'
    implicit = false
  []
  [do_produce]
    type = TimePeriod
    enable_objects = 'BCs::produce_water'
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
  [rate_H2O]
  []
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
    growth_factor = 1.2       # gentler growth (was 1.5) so dt does not jump large
    cutback_factor = 0.5
    optimal_iterations = 10
  []

  end_time = ${t_produce_end}      # 240 days total
  dtmax = 43200                    # 12 h cap (was 1 day): keeps soak-phase dt bounded
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  nl_max_its = 15                  # a few more Newton its to ride out stiff steps
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
  [p_min]
    type = NodalExtremeValue
    variable = porepressure
    value_type = min
  []
  [p_avg]
    type = ElementAverageValue
    variable = porepressure
  []
  # net water mass in the domain (rises during inject, falls during produce)
  [water_mass]
    type = PorousFlowFluidMass
    fluid_component = 0
  []
[]

[Outputs]
  exodus = true
  csv = true
[]

# ==========================================================================
# GEOCHEMISTRY COUPLING (add later, GeoTES-style operator split)
#   - extend to 8 components (f0..f6 + porepressure)
#   - save_component_rate_in = 'rate_H rate_Na ... rate_H2O'
#   - MultiApps + Transfers to serpentinization_geochemistry.i
# ==========================================================================
