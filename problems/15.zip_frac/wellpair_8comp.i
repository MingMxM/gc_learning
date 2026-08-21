# ==========================================================================
# 8-component PorousFlow INJECTION-PRODUCTION WELL PAIR (zipper fractures)
# FLOW STAGE: inject ACID at lower well, produce at upper well, both on.
#
# Components (match the geochemistry basis H2O H+ Na+ Cl- Mg++ Fe++ SiO2 O2):
#   f0=H+  f1=Na+  f2=Cl-  f3=Mg++  f4=Fe++  f5=SiO2  f6=O2 ; porepressure=H2O
#
# Injected fluid at the lower well is a dilute HCl acid (pH ~ 1.7):
#   H+ and Cl- at finite mass fractions, other ions at trace, H2O the balance.
# Injection well: inlet held at p_inject AND at the acid composition.
# Production well: outlet held at p_produce; solutes leave via OutflowBC.
#
# save_component_rate_in keeps per-node rates for later geochemistry coupling.
# Mesh sides: "inlet"(inj frac bottom), "outlet"(prod frac top), left/right/bottom/top
# ==========================================================================

# ---- injected acid composition (mass fractions), pH ~ 1.7 dilute HCl ----
h_mf_in   = 2e-5
cl_mf_in  = 7.04e-4
trace_mf  = 1e-10           # Na, Mg, Fe, SiO2, O2 trace in injected acid
# h2o balance = 0.9992759995

# ---- flow stage length (days) ----
flow_days = 30
t_end     = ${fparse flow_days * 86400}

# ---- well pressures ----
p_inject  = 40e6
p_produce = 10e6

# ---- reservoir ----
p_init   = 25e6
phi_mat  = 0.05
phi_frac = 0.35
k_mat    = 1e-17
k_frac   = 5e-14

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = zipper_domain_10m.msh
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 0'
[]

[Variables]
  [f0]                              # H+
    initial_condition = 1e-10
    scaling = 1e5
  []
  [f1]                              # Na+
    initial_condition = 1e-10
  []
  [f2]                              # Cl-
    initial_condition = 1e-10
    scaling = 1e5
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
  # Diffusivity material required by PorousFlowDispersiveFlux: tortuosity per
  # phase and a diffusion coefficient per component (8). Dispersion smooths the
  # steep acid front and prevents mass fractions from overshooting negative.
  [diffusivity]
    type = PorousFlowDiffusivityConst
    diffusion_coeff = '1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9'
    tortuosity = 0.1
  []
[]

# --------------------------------------------------------------------------
# Dispersive flux kernels (the Action does NOT add these). One per component,
# coexisting with the advection kernels the Action generates. Dispersion
# spreads the steep concentration fronts and stabilizes the solve.
# --------------------------------------------------------------------------
[Kernels]
  [disp_H]
    type = PorousFlowDispersiveFlux
    variable = f0
    fluid_component = 0
    disp_long = 0.5
    disp_trans = 0.05
  []
  [disp_Na]
    type = PorousFlowDispersiveFlux
    variable = f1
    fluid_component = 1
    disp_long = 0.5
    disp_trans = 0.05
  []
  [disp_Cl]
    type = PorousFlowDispersiveFlux
    variable = f2
    fluid_component = 2
    disp_long = 0.5
    disp_trans = 0.05
  []
  [disp_Mg]
    type = PorousFlowDispersiveFlux
    variable = f3
    fluid_component = 3
    disp_long = 0.5
    disp_trans = 0.05
  []
  [disp_Fe]
    type = PorousFlowDispersiveFlux
    variable = f4
    fluid_component = 4
    disp_long = 0.5
    disp_trans = 0.05
  []
  [disp_SiO2]
    type = PorousFlowDispersiveFlux
    variable = f5
    fluid_component = 5
    disp_long = 0.5
    disp_trans = 0.05
  []
  [disp_O2]
    type = PorousFlowDispersiveFlux
    variable = f6
    fluid_component = 6
    disp_long = 0.5
    disp_trans = 0.05
  []
  [disp_H2O]
    type = PorousFlowDispersiveFlux
    variable = porepressure
    fluid_component = 7
    disp_long = 0.5
    disp_trans = 0.05
  []
[]

# --------------------------------------------------------------------------
# Well-pair BCs, both ON for the whole flow stage.
#   INJECTION well (inlet): pressure 45 MPa + fixed acid composition.
#   PRODUCTION well (outlet): pressure 25 MPa + free solute outflow.
# Other edges: no BC = no-flow.
# --------------------------------------------------------------------------
[BCs]
  # ---- injection well: pressure + acid composition ----
  [inj_p]
    type = DirichletBC
    variable = porepressure
    boundary = inlet
    value = ${p_inject}
    preset = true
  []
  [inj_H]
    type = DirichletBC
    variable = f0
    boundary = inlet
    value = ${h_mf_in}
    preset = true
  []
  [inj_Na]
    type = DirichletBC
    variable = f1
    boundary = inlet
    value = ${trace_mf}
    preset = true
  []
  [inj_Cl]
    type = DirichletBC
    variable = f2
    boundary = inlet
    value = ${cl_mf_in}
    preset = true
  []
  [inj_Mg]
    type = DirichletBC
    variable = f3
    boundary = inlet
    value = ${trace_mf}
    preset = true
  []
  [inj_Fe]
    type = DirichletBC
    variable = f4
    boundary = inlet
    value = ${trace_mf}
    preset = true
  []
  [inj_SiO2]
    type = DirichletBC
    variable = f5
    boundary = inlet
    value = ${trace_mf}
    preset = true
  []
  [inj_O2]
    type = DirichletBC
    variable = f6
    boundary = inlet
    value = ${trace_mf}
    preset = true
  []

  # ---- production well: pressure + free solute outflow ----
  [prod_p]
    type = DirichletBC
    variable = porepressure
    boundary = outlet
    value = ${p_produce}
    preset = true
  []
  [prod_H]
    type = PorousFlowOutflowBC
    variable = f0
    boundary = outlet
    mass_fraction_component = 0
  []
  [prod_Na]
    type = PorousFlowOutflowBC
    variable = f1
    boundary = outlet
    mass_fraction_component = 1
  []
  [prod_Cl]
    type = PorousFlowOutflowBC
    variable = f2
    boundary = outlet
    mass_fraction_component = 2
  []
  [prod_Mg]
    type = PorousFlowOutflowBC
    variable = f3
    boundary = outlet
    mass_fraction_component = 3
  []
  [prod_Fe]
    type = PorousFlowOutflowBC
    variable = f4
    boundary = outlet
    mass_fraction_component = 4
  []
  [prod_SiO2]
    type = PorousFlowOutflowBC
    variable = f5
    boundary = outlet
    mass_fraction_component = 5
  []
  [prod_O2]
    type = PorousFlowOutflowBC
    variable = f6
    boundary = outlet
    mass_fraction_component = 6
  []
[]

[AuxVariables]
  [temp]
    initial_condition = 200
  []
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
  [smp]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type'
    petsc_options_value = 'asm lu NONZERO'
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
  nl_abs_tol = 1e-7
  nl_max_its = 10
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
  # solute at the production well: breakthrough shows as Cl rising at outlet
  [Cl_outlet]
    type = SideAverageValue
    variable = f2
    boundary = outlet
  []
  [H_outlet]
    type = SideAverageValue
    variable = f0
    boundary = outlet
  []
  [water_mass]
    type = PorousFlowFluidMass
    fluid_component = 7
  []
[]

[Outputs]
  exodus = true
  csv = true
[]

# ==========================================================================
# NEXT: couple geochemistry (serpentinization_geochemistry_field.i)
#   via MultiApps + Transfers, transferring rate_* out and massfrac_* back.
# ==========================================================================
