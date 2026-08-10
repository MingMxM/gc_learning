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
    # scaling = 1e-6
  []
  [na_mf]
    initial_condition = 0.0               # pure water initially
  []
  [cl_mf]
    initial_condition = 0.0
  []
[]

[Kernels]
## -------- water (component 0) -------
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

## -------- Na+ (component 1) -------
  [mass1_time_derivative]
    type = PorousFlowMassTimeDerivative
    fluid_component = 1
    variable = na_mf
  []
  [flux1_adv]
    type = PorousFlowAdvectiveFlux
    fluid_component = 1
    gravity = '0 0 0'
    variable = na_mf
  []
#   [flux1_disp]
#     type = PorousFlowDispersiveFlux
#     fluid_component = 1
#     disp_long = '1e-3'
#     disp_trans = '1e-4'
#     gravity = '0 0 0'
#     variable = na_mf
#   []

## -------- Cl- (component 2) -------
  [mass2_time_derivative]
    type = PorousFlowMassTimeDerivative
    fluid_component = 2
    variable = cl_mf
  []
  [flux2_adv]
    type = PorousFlowAdvectiveFlux
    fluid_component = 2
    gravity = '0 0 0'
    variable = cl_mf
  []
#   [flux2_disp]
#     type = PorousFlowDispersiveFlux
#     fluid_component = 2
#     disp_long = '1e-3'
#     disp_trans = '1e-4'
#     gravity = '0 0 0'
#     variable = cl_mf
#   []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    number_fluid_components = 3
    number_fluid_phases = 1
    porous_flow_vars = 'pp na_mf cl_mf'
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
    mass_fraction_vars = 'na_mf cl_mf'
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
  [diffusivity]
    type = PorousFlowDiffusivityConst
    diffusion_coeff = '7.5e-9 7.5e-9 7.5e-9'
    tortuosity = '1'
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

  #injected-brine composition
  [inlet_na]
    type = PorousFlowSink
    boundary = inlet
    variable = na_mf
    flux_function = -1.6553e-6         # = -4.2119e-4 * 0.00393
    fluid_phase = 0
  []
  [inlet_cl]
    type = PorousFlowSink
    boundary = inlet
    variable = cl_mf
    flux_function = -2.5566e-6         # = -4.2119e-4 * 0.00607
    fluid_phase = 0
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
  automatic_scaling = true

  [TimeStepper]
    type = FunctionDT
    function = 'max(10, 0.1 * t)'
  []

#   dt = 5000
  end_time = 3024000    # 31 days in seconds

  nl_abs_tol = 1e-09
  nl_rel_tol = 1e-08
[]

[Postprocessors]
  [p_inlet]
    type = SideAverageValue
    boundary = inlet
    variable = pp
  []
  [p_outlet]
    type = SideAverageValue
    boundary = outlet
    variable = pp
  []
  [na_outlet]
    type = SideAverageValue
    boundary = outlet
    variable = na_mf
  []
  [cl_outlet]
    type = SideAverageValue
    boundary = outlet
    variable = cl_mf
  []
[]

[Outputs]
  exodus = true
  csv = true
[]