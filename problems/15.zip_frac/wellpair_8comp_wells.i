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
flow_days = 60
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
  # Injection-well fluid COMPOSITION is fixed at the injection well node so the
  # borehole draws in acid-composition fluid. Pressure drive is via the
  # Peaceman boreholes in [DiracKernels]. Production solutes leave through the
  # production Peaceman boreholes (no OutflowBC needed).
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
[]

# --------------------------------------------------------------------------
# Peaceman wells (injection at 0,0 ; production at 10,150 -> .bh files).
#   Injection: character=-1, bottom_p_or_t = p_inject.
#   Production: character=+1, bottom_p_or_t = p_produce, each paired with a
#   PorousFlowSumQuantity to tally cumulative produced mass of each component.
# line_length=1 (2D unit thickness), unit_weight=0 (no gravity), use_mobility.
# --------------------------------------------------------------------------
[DiracKernels]
  # ---------- INJECTION borehole (all 8 components) ----------
  [inj_well_H]
    type = PorousFlowPeacemanBorehole
    variable = f0
    SumQuantityUO = injected_H
    mass_fraction_component = 0
    point_file = injection.bh
    line_length = 1
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = -1
  []
  [inj_well_Na]
    type = PorousFlowPeacemanBorehole
    variable = f1
    SumQuantityUO = injected_Na
    mass_fraction_component = 1
    point_file = injection.bh
    line_length = 1
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = -1
  []
  [inj_well_Cl]
    type = PorousFlowPeacemanBorehole
    variable = f2
    SumQuantityUO = injected_Cl
    mass_fraction_component = 2
    point_file = injection.bh
    line_length = 1
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = -1
  []
  [inj_well_Mg]
    type = PorousFlowPeacemanBorehole
    variable = f3
    SumQuantityUO = injected_Mg
    mass_fraction_component = 3
    point_file = injection.bh
    line_length = 1
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = -1
  []
  [inj_well_Fe]
    type = PorousFlowPeacemanBorehole
    variable = f4
    SumQuantityUO = injected_Fe
    mass_fraction_component = 4
    point_file = injection.bh
    line_length = 1
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = -1
  []
  [inj_well_SiO2]
    type = PorousFlowPeacemanBorehole
    variable = f5
    SumQuantityUO = injected_SiO2
    mass_fraction_component = 5
    point_file = injection.bh
    line_length = 1
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = -1
  []
  [inj_well_O2]
    type = PorousFlowPeacemanBorehole
    variable = f6
    SumQuantityUO = injected_O2
    mass_fraction_component = 6
    point_file = injection.bh
    line_length = 1
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = -1
  []
  [inj_well_H2O]
    type = PorousFlowPeacemanBorehole
    variable = porepressure
    SumQuantityUO = injected_H2O
    mass_fraction_component = 7
    point_file = injection.bh
    line_length = 1
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = -1
  []

  # ---------- PRODUCTION borehole (all 8 components, with tally) ----------
  [prod_well_H]
    type = PorousFlowPeacemanBorehole
    variable = f0
    SumQuantityUO = produced_H
    mass_fraction_component = 0
    point_file = production.bh
    line_length = 1
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
  []
  [prod_well_Na]
    type = PorousFlowPeacemanBorehole
    variable = f1
    SumQuantityUO = produced_Na
    mass_fraction_component = 1
    point_file = production.bh
    line_length = 1
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
  []
  [prod_well_Cl]
    type = PorousFlowPeacemanBorehole
    variable = f2
    SumQuantityUO = produced_Cl
    mass_fraction_component = 2
    point_file = production.bh
    line_length = 1
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
  []
  [prod_well_Mg]
    type = PorousFlowPeacemanBorehole
    variable = f3
    SumQuantityUO = produced_Mg
    mass_fraction_component = 3
    point_file = production.bh
    line_length = 1
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
  []
  [prod_well_Fe]
    type = PorousFlowPeacemanBorehole
    variable = f4
    SumQuantityUO = produced_Fe
    mass_fraction_component = 4
    point_file = production.bh
    line_length = 1
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
  []
  [prod_well_SiO2]
    type = PorousFlowPeacemanBorehole
    variable = f5
    SumQuantityUO = produced_SiO2
    mass_fraction_component = 5
    point_file = production.bh
    line_length = 1
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
  []
  [prod_well_O2]
    type = PorousFlowPeacemanBorehole
    variable = f6
    SumQuantityUO = produced_O2
    mass_fraction_component = 6
    point_file = production.bh
    line_length = 1
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
  []
  [prod_well_H2O]
    type = PorousFlowPeacemanBorehole
    variable = porepressure
    SumQuantityUO = produced_H2O
    mass_fraction_component = 7
    point_file = production.bh
    line_length = 1
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
  []
[]

[UserObjects]
  # injection tallies (SumQuantityUO is required by every Peaceman borehole)
  [injected_H]
    type = PorousFlowSumQuantity
  []
  [injected_Na]
    type = PorousFlowSumQuantity
  []
  [injected_Cl]
    type = PorousFlowSumQuantity
  []
  [injected_Mg]
    type = PorousFlowSumQuantity
  []
  [injected_Fe]
    type = PorousFlowSumQuantity
  []
  [injected_SiO2]
    type = PorousFlowSumQuantity
  []
  [injected_O2]
    type = PorousFlowSumQuantity
  []
  [injected_H2O]
    type = PorousFlowSumQuantity
  []
  # production tallies
  [produced_H]
    type = PorousFlowSumQuantity
  []
  [produced_Na]
    type = PorousFlowSumQuantity
  []
  [produced_Cl]
    type = PorousFlowSumQuantity
  []
  [produced_Mg]
    type = PorousFlowSumQuantity
  []
  [produced_Fe]
    type = PorousFlowSumQuantity
  []
  [produced_SiO2]
    type = PorousFlowSumQuantity
  []
  [produced_O2]
    type = PorousFlowSumQuantity
  []
  [produced_H2O]
    type = PorousFlowSumQuantity
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
  # H2 mass fraction received from the geochemistry sub-app (production metric).
  # Not a transport variable; just carried here so it can be produced/tracked.
  [massfrac_H2][]
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

  # ---- cumulative produced mass of each component (kg) ----
  # PorousFlowPlotQuantity reads the SumQuantity UO. This is the running total
  # since the run start. Sign: production (character=+1) accumulates outflow.
  [cum_prod_H]
    type = PorousFlowPlotQuantity
    uo = produced_H
    execute_on = 'initial timestep_end'
  []
  [cum_prod_Cl]
    type = PorousFlowPlotQuantity
    uo = produced_Cl
    execute_on = 'initial timestep_end'
  []
  [cum_prod_Mg]
    type = PorousFlowPlotQuantity
    uo = produced_Mg
    execute_on = 'initial timestep_end'
  []
  [cum_prod_H2O]
    type = PorousFlowPlotQuantity
    uo = produced_H2O
    execute_on = 'initial timestep_end'
  []

  # ---- daily production rate of each component (kg/day) ----
  # = (change in cumulative produced mass) / dt, scaled to per-day.
  # ChangeOverTimePostprocessor gives the increment over the step; dividing by
  # the step in days is done via a ParsedPostprocessor below.
  [dt_pp]
    type = TimestepSize
  []
  [dH_step]
    type = ChangeOverTimePostprocessor
    postprocessor = cum_prod_H
    execute_on = 'initial timestep_end'
  []
  [daily_prod_H]
    type = ParsedPostprocessor
    pp_names = 'dH_step dt_pp'
    expression = 'dH_step / dt_pp * 86400'   # kg per day
    execute_on = 'initial timestep_end'
  []
  [dCl_step]
    type = ChangeOverTimePostprocessor
    postprocessor = cum_prod_Cl
    execute_on = 'initial timestep_end'
  []
  [daily_prod_Cl]
    type = ParsedPostprocessor
    pp_names = 'dCl_step dt_pp'
    expression = 'dCl_step / dt_pp * 86400'  # kg per day
    execute_on = 'initial timestep_end'
  []

  # ---- hydrogen production tracking ----
  # H2 mass fraction at the production well (from geochem, carried in massfrac_H2)
  [H2_massfrac_outlet]
    type = SideAverageValue
    variable = massfrac_H2
    boundary = outlet
    execute_on = 'initial timestep_end'
  []
  # cumulative produced H2 (kg) = produced water mass x outlet H2 mass fraction.
  # produced_H2O is the borehole water tally; multiply by the produced-stream
  # H2 mass fraction for an estimate of cumulative H2 produced.
  [cum_prod_H2]
    type = ParsedPostprocessor
    pp_names = 'cum_prod_H2O H2_massfrac_outlet'
    expression = 'cum_prod_H2O * H2_massfrac_outlet'
    execute_on = 'initial timestep_end'
  []
  [dH2_step]
    type = ChangeOverTimePostprocessor
    postprocessor = cum_prod_H2
    execute_on = 'initial timestep_end'
  []
  [daily_prod_H2]
    type = ParsedPostprocessor
    pp_names = 'dH2_step dt_pp'
    expression = 'dH2_step / dt_pp * 86400'   # kg H2 per day
    execute_on = 'initial timestep_end'
  []
[]

[Outputs]
  exodus = true
  csv = true
[]

# ==========================================================================
# GEOCHEMISTRY COUPLING (operator split). Main app sends transport rates and
# temperature to the react sub-app; sub-app returns updated mass fractions
# f0..f6 AND the H2 mass fraction (massfrac_H2) for hydrogen-production tracking.
# ==========================================================================
[MultiApps]
  [react]
    type = TransientMultiApp
    input_files = serpentinization_geochemistry.i
    clone_master_mesh = true
    execute_on = 'timestep_end'
  []
[]

[Transfers]
  # main -> sub : transport-induced mass-change rates + temperature
  [changes_due_to_flow]
    type = MultiAppCopyTransfer
    source_variable = 'rate_H rate_Na rate_Cl rate_Mg rate_Fe rate_SiO2 rate_O2 rate_H2O temp'
    variable        = 'pf_rate_H pf_rate_Na pf_rate_Cl pf_rate_Mg pf_rate_Fe pf_rate_SiO2 pf_rate_O2 pf_rate_H2O temperature'
    to_multi_app = react
  []
  # sub -> main : updated mass fractions (f0..f6) AND H2 mass fraction
  [massfrac_from_geochem]
    type = MultiAppCopyTransfer
    source_variable = 'massfrac_H massfrac_Na massfrac_Cl massfrac_Mg massfrac_Fe massfrac_SiO2 massfrac_O2 massfrac_H2'
    variable        = 'f0 f1 f2 f3 f4 f5 f6 massfrac_H2'
    from_multi_app = react
  []
[]
