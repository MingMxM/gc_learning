# ==========================================================================
# Single-phase PorousFlow INJECTION-PRODUCTION WELL PAIR (zipper fractures)
# FLOW STAGE ONLY: inject at lower well AND produce at upper well
# simultaneously, sustained gradient sweeps fluid across the matrix.
# (No soak, no later production -- those come after breakthrough is known.)
#
# Wells are the whole fracture-tip edges:
#   inlet  = injection fracture bottom (lower well) -> held at p_inject
#   outlet = production fracture top   (upper well) -> held at p_produce
#
# Mesh blocks : "fracture", "matrix"
# Mesh sides  : "inlet"(inj frac bottom), "outlet"(prod frac top),
#               "left","right","bottom","top"
# ==========================================================================

# ---- flow stage length (days) ----
flow_days  = 120           # run long enough to see breakthrough; adjust as needed
t_end      = ${fparse flow_days * 86400}

# ---- well pressures ----
p_inject  = 45e6           # injection well bottomhole pressure (lower well)
p_produce = 25e6           # production well bottomhole pressure (upper well)

# ---- reservoir ----
p_init   = 30e6
phi_mat  = 0.05
phi_frac = 0.35
k_mat    = 3e-18           # 0.003 mD
k_frac   = 5e-14           # 50 mD

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = zipper_domain_light.msh
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
    density0 = 865.0
    viscosity = 1.3e-4
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
# Well-pair BCs, both ON for the whole flow stage (no time control needed).
#   inject_p : inlet (lower well) held at p_inject = 45 MPa
#   produce_p: outlet (upper well) held at p_produce = 25 MPa
# Other edges: no BC = no-flow.
# --------------------------------------------------------------------------
[BCs]
  [inject_p]
    type = DirichletBC
    variable = porepressure
    boundary = inlet
    value = ${p_inject}
    preset = true
  []
  [produce_p]
    type = DirichletBC
    variable = porepressure
    boundary = outlet
    value = ${p_produce}
    preset = true
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
    growth_factor = 1.2
    cutback_factor = 0.5
    optimal_iterations = 10
  []

  end_time = ${t_end}
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
  [p_outlet]
    type = SideAverageValue
    variable = porepressure
    boundary = outlet
  []
  [p_avg]
    type = ElementAverageValue
    variable = porepressure
  []
  # net water in domain; with inject+produce on, watch it approach steady state
  [water_mass]
    type = PorousFlowFluidMass
    fluid_component = 0
  []
[]

[Outputs]
  exodus = true
  csv = true
[]
