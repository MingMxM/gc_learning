[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    # radial (r) direction -> x
    nx = 6
    xmin = 0.0
    xmax = 0.0125            # radius = 1.25 cm

    # axial (z) direction -> y
    ny = 60
    ymin = 0.0
    ymax = 0.075             # length = 7.5 cm
  []

  [rename_boundaries]
    type = RenameBoundaryGenerator
    input = gen
    old_boundary = 'left right bottom top' 
    new_boundary = 'axis wall  inlet  outlet'
  []

  coord_type = 'RZ'
  rz_coord_axis = Y
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 0'
[]

[Variables]
  [pp]
    initial_condition = 3.4474e6          # 500 psi everywhere at t = 0
  []
[]

[Kernels]
  [mass_time_derivative]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = pp
  []
  [darcy_flux]
    type = PorousFlowAdvectiveFlux
    fluid_component = 0
    gravity = '0 0 0'
    variable = pp
  []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    number_fluid_components = 1
    number_fluid_phases = 1
    porous_flow_vars = 'pp'
  []
  [pc]
    type = PorousFlowCapillaryPressureVG
    alpha = 1e-6
    m = 0.5
  []
[]

[FluidProperties]
  [simple_fluid]
    type = SimpleFluidProperties
    density0 = 827.0
    viscosity = 1.16e-4
    bulk_modulus = 2e+09
    thermal_expansion = 0.0
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
  []
  [ppss]
    type = PorousFlow1PhaseP
    porepressure = pp
    capillary_pressure = pc
  []
  [massfrac]
    type = PorousFlowMassFraction
  []
  [simple_fluid]
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid
    phase = 0
  []
  [relperm]
    type = PorousFlowRelativePermeabilityCorey
    phase = 0
    n = 1
  []
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

[BCs]
  [inlet_injection]
    type = PorousFlowSink
    boundary = inlet
    variable = pp
    flux_function = -4.2119e-4   #kg/m^2/s, negative = into domain
    fluid_phase = 0
  []
  [outlet_pressure]
    type = DirichletBC
    boundary = outlet
    value = 3.4474e6
    variable = pp
  []
[]

[AuxVariables]
  [darcy_vel_z]
    order = CONSTANT
    family = MONOMIAL
  []
[]
[AuxKernels]
  [darcy_vel_z]
    type = PorousFlowDarcyVelocityComponent
    component = y
    variable = darcy_vel_z
    fluid_phase = 0
  []
[]

[Preconditioning]
  [typically_efficient]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_hypre_type'
    petsc_options_value = ' hypre    boomeramg'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  [TimeStepper]
    type = FunctionDT
    function = 'max(10, 0.1 * t)'
  []

  # dt = 5000
  end_time = 3024000    # 31 days in seconds

  nl_abs_tol = 1e-09
  nl_rel_tol = 1e-08
[]

# [Postprocessors]
#   [p_inlet]
#     type = SideAverageValue
#     boundary = inlet
#     variable = pp
#   []
#   [p_outlet]
#     type = SideAverageValue
#     boundary = outlet
#     variable = pp
#   []    
# []

[Outputs]
  exodus = true
[]