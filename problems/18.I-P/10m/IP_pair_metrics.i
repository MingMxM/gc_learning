# ==========================================================================
# REACTIVE-METRICS VERSION
# Injection-production pair, continuous acid injection/production for 360 d.
# Metrics:
#   I_i(t) = 1 when pH_i <= pH_crit, else 0
#   A_rs_2D = sum(I_i A_i)
#   V_rs    = A_rs_2D * out_of_plane_width
#   V_p_rs  = sum(I_i phi_i A_i) * out_of_plane_width
#   Q_eff   = V_w,inj(t) / t
#   tau_h   = V_p_rs / Q_eff
# The default out-of-plane width is defined in the geochemistry metrics file.
# ==========================================================================
# ==========================================================================
# 8-component PorousFlow INJECTION-PRODUCTION WELL PAIR (zipper fractures)
# FLOW STAGE: inject ACID at lower well, produce at upper well, both on.
#
# Components (match the geochemistry basis H2O H+ Na+ Cl- Mg++ Fe++ SiO2 O2):
#   f0=H+  f1=Na+  f2=Cl-  f3=Mg++  f4=Fe++  f5=SiO2  f6=O2 ; porepressure=H2O
#
# Injected fluid at the lower well is 0.05 M HCl, matching the HnP baseline:
#   H+ and Cl- at finite mass fractions, other ions at trace, H2O the balance.
# Injection well: inlet held at p_inject AND at the acid composition.
# Production well: outlet held at p_produce; solutes leave via OutflowBC.
#
# save_component_rate_in keeps per-node rates for later geochemistry coupling.
# Mesh sides: "inlet"(inj frac bottom), "outlet"(prod frac top), left/right/bottom/top
# ==========================================================================

# ---- injected acid composition: 0.05 M HCl at rho = 865 kg/m3 ----
h_mf_in   = 5.83e-5
cl_mf_in  = 2.05e-3
trace_mf  = 1e-10           # Na, Mg, Fe, SiO2, O2 trace in injected acid
# H2O mass fraction is the balance (~0.9978917)

# ---- continuous injection-production stage length (days) ----
flow_days = 360
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
    diffusion_coeff = '4e-9 4e-9 4e-9 4e-9 4e-9 4e-9 4e-9 4e-9'
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
  dtmax = 86400
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

  # ----------------------------------------------------------------------
  # Injection bookkeeping for Q_eff.
  # PorousFlowPlotQuantity is the H2O mass injected during THIS accepted
  # timestep. Injection is negative in the PorousFlow outflow sign convention,
  # so flip the sign first, then accumulate it explicitly.
  # ----------------------------------------------------------------------
  [inj_H2O_step_signed]
    type = PorousFlowPlotQuantity
    uo = injected_H2O
    execute_on = 'initial timestep_end'
  []
  [inj_H2O_step]
    type = ParsedPostprocessor
    pp_names = 'inj_H2O_step_signed'
    expression = '-inj_H2O_step_signed'
    execute_on = 'initial timestep_end'
  []
  [cum_inj_H2O]
    type = CumulativeValuePostprocessor
    postprocessor = inj_H2O_step
    execute_on = 'initial timestep_end'
  []

  # Reactive-sweep metrics returned from the geochemistry sub-app.
  # A_rs_2D and A_p_rs_2D are native 2-D integrals (m2).
  # V_rs and V_p_rs include the chosen out-of-plane representative width (m3).
  [A_rs_2D]
    type = Receiver
    default = 0
    execute_on = 'initial timestep_end transfer'
  []
  [A_p_rs_2D]
    type = Receiver
    default = 0
    execute_on = 'initial timestep_end transfer'
  []
  [V_rs]
    type = Receiver
    default = 0
    execute_on = 'initial timestep_end transfer'
  []
  [V_p_rs]
    type = Receiver
    default = 0
    execute_on = 'initial timestep_end transfer'
  []
  [V_w_inj]
    type = Receiver
    default = 0
    execute_on = 'initial timestep_end transfer'
  []
  [Q_eff_m3s]
    type = Receiver
    default = 0
    execute_on = 'initial timestep_end transfer'
  []
  [Q_eff_m3day]
    type = Receiver
    default = 0
    execute_on = 'initial timestep_end transfer'
  []
  [tau_h_s]
    type = Receiver
    default = 0
    execute_on = 'initial timestep_end transfer'
  []
  [tau_h_day]
    type = Receiver
    default = 0
    execute_on = 'initial timestep_end transfer'
  []

  # Cumulative in-situ H2 generated (kg), received from the geochemistry sub-app.
  [cum_H2_mass]
    type = Receiver
    default = 0
    execute_on = 'initial timestep_end transfer'
  []

  # ---------------- Cumulative produced species at the well (kg) ----------------
  # PorousFlowPlotQuantity returns the mass produced in THIS timestep, because the
  # PorousFlowSumQuantity UO is reset every step. It is a per-step amount, not a
  # cumulative. Production is positive in the outflow convention (no sign flip).
  # cum_prod_* accumulates each per-step value into a true running total.
  [prod_H2O_step]
    type = PorousFlowPlotQuantity
    uo = produced_H2O
    execute_on = 'initial timestep_end'
  []
  [cum_prod_H2O]
    type = CumulativeValuePostprocessor
    postprocessor = prod_H2O_step
    execute_on = 'initial timestep_end'
  []

  # ---------------- Well-produced H2 (kg) ----------------
  # H2 is not a transported flow component, so there is no Peaceman H2 tally.
  # H2 travels with the aqueous phase, so the H2 mass leaving the well each step
  # equals the produced water mass that step times the H2/H2O mass-fraction ratio
  # at the production boundary:
  #   prod_H2_step = prod_H2O_step * (w_H2 / w_H2O)|_outlet
  # with w_H2O = 1 - sum(f0..f6) the water mass fraction at the outlet.
  [w_H2_outlet]
    type = SideAverageValue
    variable = massfrac_H2
    boundary = outlet
    execute_on = 'initial timestep_end'
  []
  [f0_outlet]
    type = SideAverageValue
    variable = f0
    boundary = outlet
    execute_on = 'initial timestep_end'
  []
  [f1_outlet]
    type = SideAverageValue
    variable = f1
    boundary = outlet
    execute_on = 'initial timestep_end'
  []
  [f2_outlet]
    type = SideAverageValue
    variable = f2
    boundary = outlet
    execute_on = 'initial timestep_end'
  []
  [f3_outlet]
    type = SideAverageValue
    variable = f3
    boundary = outlet
    execute_on = 'initial timestep_end'
  []
  [f4_outlet]
    type = SideAverageValue
    variable = f4
    boundary = outlet
    execute_on = 'initial timestep_end'
  []
  [f5_outlet]
    type = SideAverageValue
    variable = f5
    boundary = outlet
    execute_on = 'initial timestep_end'
  []
  [f6_outlet]
    type = SideAverageValue
    variable = f6
    boundary = outlet
    execute_on = 'initial timestep_end'
  []
  [w_H2O_outlet]
    type = ParsedPostprocessor
    pp_names = 'f0_outlet f1_outlet f2_outlet f3_outlet f4_outlet f5_outlet f6_outlet'
    expression = '1.0 - (f0_outlet + f1_outlet + f2_outlet + f3_outlet + f4_outlet + f5_outlet + f6_outlet)'
    execute_on = 'initial timestep_end'
  []
  [prod_H2_step]
    type = ParsedPostprocessor
    pp_names = 'prod_H2O_step w_H2_outlet w_H2O_outlet'
    expression = 'prod_H2O_step * w_H2_outlet / (w_H2O_outlet + 1e-30)'
    execute_on = 'initial timestep_end'
  []
  [cum_prod_H2]
    type = CumulativeValuePostprocessor
    postprocessor = prod_H2_step
    execute_on = 'initial timestep_end'
  []
[]

[Outputs]
  file_base = IP_pair_metrics
  exodus = true
  csv = true
[]


# ==========================================================================
# GEOCHEMISTRY COUPLING + REACTIVE-SWEEP METRICS
# ==========================================================================
[MultiApps]
  [react]
    type = TransientMultiApp
    input_files = serpentinization_geochemistry_IP_metrics.i
    clone_master_mesh = true
    execute_on = 'timestep_end'
  []
[]

[Transfers]
  # main -> sub: transport-induced component mass-change rates + temperature
  [changes_due_to_flow]
    type = MultiAppCopyTransfer
    source_variable = 'rate_H rate_Na rate_Cl rate_Mg rate_Fe rate_SiO2 rate_O2 rate_H2O temp'
    variable        = 'pf_rate_H pf_rate_Na pf_rate_Cl pf_rate_Mg pf_rate_Fe pf_rate_SiO2 pf_rate_O2 pf_rate_H2O temperature'
    to_multi_app = react
  []

  # sub -> main: geochemistry-updated transported component mass fractions
  [massfrac_from_geochem]
    type = MultiAppCopyTransfer
    source_variable = 'massfrac_H massfrac_Na massfrac_Cl massfrac_Mg massfrac_Fe massfrac_SiO2 massfrac_O2 massfrac_H2'
    variable        = 'f0 f1 f2 f3 f4 f5 f6 massfrac_H2'
    from_multi_app = react
  []

  # cumulative injected H2O mass (kg, positive) -> geochemistry metrics app
  [cum_inj_H2O_to_geochem]
    type = MultiAppPostprocessorTransfer
    to_multi_app = react
    from_postprocessor = cum_inj_H2O
    to_postprocessor = cum_inj_H2O_from_main
    execute_on = 'timestep_end'
  []

  # metrics -> main CSV
  [A_rs_2D_from_geochem]
    type = MultiAppPostprocessorTransfer
    from_multi_app = react
    from_postprocessor = A_rs_2D
    to_postprocessor = A_rs_2D
    reduction_type = average
    execute_on = 'timestep_end'
  []
  [A_p_rs_2D_from_geochem]
    type = MultiAppPostprocessorTransfer
    from_multi_app = react
    from_postprocessor = A_p_rs_2D
    to_postprocessor = A_p_rs_2D
    reduction_type = average
    execute_on = 'timestep_end'
  []
  [V_rs_from_geochem]
    type = MultiAppPostprocessorTransfer
    from_multi_app = react
    from_postprocessor = V_rs
    to_postprocessor = V_rs
    reduction_type = average
    execute_on = 'timestep_end'
  []
  [V_p_rs_from_geochem]
    type = MultiAppPostprocessorTransfer
    from_multi_app = react
    from_postprocessor = V_p_rs
    to_postprocessor = V_p_rs
    reduction_type = average
    execute_on = 'timestep_end'
  []
  [V_w_inj_from_geochem]
    type = MultiAppPostprocessorTransfer
    from_multi_app = react
    from_postprocessor = V_w_inj
    to_postprocessor = V_w_inj
    reduction_type = average
    execute_on = 'timestep_end'
  []
  [Q_eff_m3s_from_geochem]
    type = MultiAppPostprocessorTransfer
    from_multi_app = react
    from_postprocessor = Q_eff_m3s
    to_postprocessor = Q_eff_m3s
    reduction_type = average
    execute_on = 'timestep_end'
  []
  [Q_eff_m3day_from_geochem]
    type = MultiAppPostprocessorTransfer
    from_multi_app = react
    from_postprocessor = Q_eff_m3day
    to_postprocessor = Q_eff_m3day
    reduction_type = average
    execute_on = 'timestep_end'
  []
  [tau_h_s_from_geochem]
    type = MultiAppPostprocessorTransfer
    from_multi_app = react
    from_postprocessor = tau_h_s
    to_postprocessor = tau_h_s
    reduction_type = average
    execute_on = 'timestep_end'
  []
  [tau_h_day_from_geochem]
    type = MultiAppPostprocessorTransfer
    from_multi_app = react
    from_postprocessor = tau_h_day
    to_postprocessor = tau_h_day
    reduction_type = average
    execute_on = 'timestep_end'
  []

  # Cumulative in-situ H2 generated (kg) back to the main app for CSV output.
  [cum_H2_mass_from_geochem]
    type = MultiAppPostprocessorTransfer
    from_multi_app = react
    from_postprocessor = cum_H2_mass
    to_postprocessor = cum_H2_mass
    reduction_type = average
    execute_on = 'timestep_end'
  []
[]
