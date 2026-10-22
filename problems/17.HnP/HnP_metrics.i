# ==========================================================================
# 8-component PorousFlow HUFF-AND-PUFF (inject acid -> soak -> produce)
# Unified baseline version for comparison with the injection-production cases.
# Fracture + matrix mesh, closed unit, isothermal 200 C.
#
# COMMON BASELINE PARAMETERS
#   Formation pressure       = 35 MPa
#   Injection BHP            = 45 MPa
#   Production BHP           = 35 MPa
#   Matrix porosity          = 0.05 (constant)
#   Matrix permeability      = 3e-18 m^2 (~0.01 mD)
#   Hydraulic-fracture phi   = 0.35 (constant)
#   Hydraulic-fracture perm  = 5e-14 m^2 (~50 mD)
#   Injected acid            = 0.05 M HCl
#   Molecular diffusion      = 4e-9 m^2/s
#   dtmax                    = 1 day
#   nl_abs_tol               = 1e-7
#   nl_max_its               = 10
#
# HNP BASELINE SCHEDULE (360-day common comparison horizon)
#   Inject  : 0   - 30  day
#   Soak    : 30  - 330 day
#   Produce : 330 - 360 day
# NOTE: only inject_days / soak_days / produce_days need to be changed if a
# different HnP operating schedule is selected later.
#
# Well representation is now consistent with the I-P cases:
#   PorousFlowPeacemanBorehole is used for both injection and production.
#   Because HnP uses a single physical well, both huff and puff use the same
#   point_file = injection.bh / production.bh.  The injection phase uses 40 MPa and the
#   production phase uses 10 MPa.
#
# Eight fluid components (same order as the geochemistry basis):
#   f0 = H+     (component 0)
#   f1 = Na+    (component 1)
#   f2 = Cl-    (component 2)
#   f3 = Mg++   (component 3)
#   f4 = Fe++   (component 4)
#   f5 = SiO2   (component 5)
#   f6 = O2     (component 6)
#   porepressure = H2O (component 7, LAST component)
#
# Mesh blocks : "fracture", "matrix"
# Mesh sides  : "inlet"(fracture bottom), "outlet_top", "left", "right", "bottom"
# ==========================================================================

# ---- injected acid composition: 0.05 M HCl at rho = 865 kg/m3 ----
h_mf_in   = 5.83e-5
cl_mf_in  = 2.05e-3
trace_mf  = 1e-10          # Na, Mg, Fe, SiO2, O2 trace in injected acid
# H2O mass fraction is the balance (~0.9978917)

# ---- pressure-controlled injection / production ----
p_inject   = 45e6
p_produce  = 35e6

# ---- HnP schedule (days), total = 360 days ----
inject_days  = 30
soak_days    = 300
produce_days = 30
t_inject_end  = ${fparse inject_days * 86400}
t_soak_end    = ${fparse (inject_days + soak_days) * 86400}
t_produce_end = ${fparse (inject_days + soak_days + produce_days) * 86400}

# ---- reservoir pressure / properties ----
p_init   = 35e6
phi_mat  = 0.05
phi_frac = 0.35
k_mat    = 3e-18           # ~0.01 mD
k_frac   = 5e-14           # ~50 mD


# --------------------------------------------------------------------------
# Injection-well switch for robust cumulative-injection bookkeeping.
# Keep Peaceman injection kernels active throughout injection + soak so their
# PorousFlowSumQuantity objects are reset every timestep.  Actual injection is
# active only for t < t_inject_end; during soak the well character is zero.
# --------------------------------------------------------------------------
[Functions]
  [inj_character]
    type = ParsedFunction
    expression = 'if(t < ${t_inject_end}, -1, 0)'
  []
[]

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
  # Unified treatment: constant porosity in the PorousFlow model.
  # Reaction-induced porosity change, if calculated in the geochemistry
  # sub-app, is diagnostic only unless a separate feedback transfer is added.
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
  [diffusivity]
    type = PorousFlowDiffusivityConst
    diffusion_coeff = '4e-9 4e-9 4e-9 4e-9 4e-9 4e-9 4e-9 4e-9'
    tortuosity = 0.1
  []
[]

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
# Injection composition BCs only. Pressure drive is handled by the Peaceman
# borehole, exactly as in the I-P cases. These composition BCs are enabled only
# during the huff/injection period.
# --------------------------------------------------------------------------
[BCs]
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
[]

# --------------------------------------------------------------------------
# Single-well HnP represented using the same Peaceman borehole formulation as
# the injection-production cases. Both phases use injection.bh because HnP
# injects and produces through the same physical well.
# --------------------------------------------------------------------------
[DiracKernels]
  # ---------- HUFF / INJECTION, 40 MPa ----------
  [inj_well_H]
    type = PorousFlowPeacemanBorehole
    variable = f0
    SumQuantityUO = injected_H
    mass_fraction_component = 0
    point_file = injection.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = inj_character

  []
  [inj_well_Na]
    type = PorousFlowPeacemanBorehole
    variable = f1
    SumQuantityUO = injected_Na
    mass_fraction_component = 1
    point_file = injection.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = inj_character

  []
  [inj_well_Cl]
    type = PorousFlowPeacemanBorehole
    variable = f2
    SumQuantityUO = injected_Cl
    mass_fraction_component = 2
    point_file = injection.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = inj_character

  []
  [inj_well_Mg]
    type = PorousFlowPeacemanBorehole
    variable = f3
    SumQuantityUO = injected_Mg
    mass_fraction_component = 3
    point_file = injection.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = inj_character

  []
  [inj_well_Fe]
    type = PorousFlowPeacemanBorehole
    variable = f4
    SumQuantityUO = injected_Fe
    mass_fraction_component = 4
    point_file = injection.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = inj_character

  []
  [inj_well_SiO2]
    type = PorousFlowPeacemanBorehole
    variable = f5
    SumQuantityUO = injected_SiO2
    mass_fraction_component = 5
    point_file = injection.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = inj_character

  []
  [inj_well_O2]
    type = PorousFlowPeacemanBorehole
    variable = f6
    SumQuantityUO = injected_O2
    mass_fraction_component = 6
    point_file = injection.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = inj_character

  []
  [inj_well_H2O]
    type = PorousFlowPeacemanBorehole
    variable = porepressure
    SumQuantityUO = injected_H2O
    mass_fraction_component = 7
    point_file = injection.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_inject}
    unit_weight = '0 0 0'
    use_mobility = true
    character = inj_character

  []

  # ---------- PUFF / PRODUCTION, same physical well, 10 MPa ----------
  [prod_well_H]
    type = PorousFlowPeacemanBorehole
    variable = f0
    SumQuantityUO = produced_H
    mass_fraction_component = 0
    point_file = production.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
    enable = false
  []
  [prod_well_Na]
    type = PorousFlowPeacemanBorehole
    variable = f1
    SumQuantityUO = produced_Na
    mass_fraction_component = 1
    point_file = production.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
    enable = false
  []
  [prod_well_Cl]
    type = PorousFlowPeacemanBorehole
    variable = f2
    SumQuantityUO = produced_Cl
    mass_fraction_component = 2
    point_file = production.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
    enable = false
  []
  [prod_well_Mg]
    type = PorousFlowPeacemanBorehole
    variable = f3
    SumQuantityUO = produced_Mg
    mass_fraction_component = 3
    point_file = production.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
    enable = false
  []
  [prod_well_Fe]
    type = PorousFlowPeacemanBorehole
    variable = f4
    SumQuantityUO = produced_Fe
    mass_fraction_component = 4
    point_file = production.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
    enable = false
  []
  [prod_well_SiO2]
    type = PorousFlowPeacemanBorehole
    variable = f5
    SumQuantityUO = produced_SiO2
    mass_fraction_component = 5
    point_file = production.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
    enable = false
  []
  [prod_well_O2]
    type = PorousFlowPeacemanBorehole
    variable = f6
    SumQuantityUO = produced_O2
    mass_fraction_component = 6
    point_file = production.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
    enable = false
  []
  [prod_well_H2O]
    type = PorousFlowPeacemanBorehole
    variable = porepressure
    SumQuantityUO = produced_H2O
    mass_fraction_component = 7
    point_file = production.bh
    line_length = 1
    line_direction = '0 0 1'
    bottom_p_or_t = ${p_produce}
    unit_weight = '0 0 0'
    use_mobility = true
    character = 1
    enable = false
  []
[]

[UserObjects]
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

# --------------------------------------------------------------------------
# Time-based activation.
# Injection: acid-composition BCs on; Peaceman well character = -1.
# Soak: composition BCs off; Peaceman well remains active with character = 0.
# Production: production Peaceman well only.
# --------------------------------------------------------------------------
[Controls]
  [do_inject]
    type = TimePeriod
    enable_objects = 'BCs::inj_H BCs::inj_Na BCs::inj_Cl BCs::inj_Mg BCs::inj_Fe BCs::inj_SiO2 BCs::inj_O2'
    start_time = 0
    end_time = ${t_inject_end}
    set_sync_times = true
    execute_on = 'initial timestep_begin'
    implicit = false
  []
  [do_produce]
    type = TimePeriod
    enable_objects = 'DiracKernels::prod_well_H DiracKernels::prod_well_Na DiracKernels::prod_well_Cl DiracKernels::prod_well_Mg DiracKernels::prod_well_Fe DiracKernels::prod_well_SiO2 DiracKernels::prod_well_O2 DiracKernels::prod_well_H2O'
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
  [rate_H][]
  [rate_Na][]
  [rate_Cl][]
  [rate_Mg][]
  [rate_Fe][]
  [rate_SiO2][]
  [rate_O2][]
  [rate_H2O][]
  # H2 mass fraction received from the geochemistry sub-app, used to convert the
  # Peaceman water-production tally into H2 production at the well.
  # Declared like the other massfrac_* transfer variables (default type) so the
  # MultiAppCopyTransfer matches f0..f6.
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

    # time_t  = '0 28512000 28598400 28771200 29030400'
    # time_dt = '86400 100 1000 10000 86400'
  []

  end_time = ${t_produce_end}   # 330 days: injection + soak only; production excluded
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

  # Cumulative water injected/produced (kg) from the same Peaceman tallies
  # used in the I-P cases. These are needed for the water-use metrics.
  # Injection-water bookkeeping for hydraulic characteristic time.
  # PorousFlowPlotQuantity is the mass injected in THIS timestep (kg), not cumulative.
  # Injection is negative in the PorousFlow outflow sign convention, so first flip the sign,
  # then accumulate the positive injected mass over accepted timesteps.
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
  # Production bookkeeping. PorousFlowPlotQuantity returns the mass produced in
  # THIS timestep (kg), because the PorousFlowSumQuantity UO is reset every step.
  # It is therefore a per-step amount (a rate over the step), NOT cumulative.
  # For each produced species we expose the per-step value (*_step) and the
  # running total (cum_prod_*) accumulated with CumulativeValuePostprocessor.
  # Production is positive in the PorousFlow outflow sign convention, so no sign
  # flip is needed here (unlike the injection tally above).
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
  [prod_H_step]
    type = PorousFlowPlotQuantity
    uo = produced_H
    execute_on = 'initial timestep_end'
  []
  [cum_prod_H]
    type = CumulativeValuePostprocessor
    postprocessor = prod_H_step
    execute_on = 'initial timestep_end'
  []
  [prod_Cl_step]
    type = PorousFlowPlotQuantity
    uo = produced_Cl
    execute_on = 'initial timestep_end'
  []
  [cum_prod_Cl]
    type = CumulativeValuePostprocessor
    postprocessor = prod_Cl_step
    execute_on = 'initial timestep_end'
  []
  [prod_Mg_step]
    type = PorousFlowPlotQuantity
    uo = produced_Mg
    execute_on = 'initial timestep_end'
  []
  [cum_prod_Mg]
    type = CumulativeValuePostprocessor
    postprocessor = prod_Mg_step
    execute_on = 'initial timestep_end'
  []

  # ---------------- Well-produced H2 (kg) ----------------
  # H2 is not a transported flow component, so there is no Peaceman H2 tally.
  # H2 travels with the aqueous phase, so the H2 mass leaving the well each step
  # equals the produced water mass that step times the H2/H2O mass-fraction ratio
  # sampled at the production boundary:
  #   prod_H2_step = prod_H2O_step * (w_H2 / w_H2O)|_outlet
  # where w_H2O = 1 - sum(f0..f6) is the water mass fraction at the outlet.
  # cum_prod_H2 accumulates the per-step produced H2 into the well cumulative.
  [w_H2_outlet]
    type = SideAverageValue
    variable = massfrac_H2
    boundary = outlet_top
    execute_on = 'initial timestep_end'
  []
  # Outlet mass fractions of the seven transported solutes, to form the water
  # mass fraction w_H2O = 1 - sum(f0..f6) at the production boundary.
  [f0_outlet]
    type = SideAverageValue
    variable = f0
    boundary = outlet_top
    execute_on = 'initial timestep_end'
  []
  [f1_outlet]
    type = SideAverageValue
    variable = f1
    boundary = outlet_top
    execute_on = 'initial timestep_end'
  []
  [f2_outlet]
    type = SideAverageValue
    variable = f2
    boundary = outlet_top
    execute_on = 'initial timestep_end'
  []
  [f3_outlet]
    type = SideAverageValue
    variable = f3
    boundary = outlet_top
    execute_on = 'initial timestep_end'
  []
  [f4_outlet]
    type = SideAverageValue
    variable = f4
    boundary = outlet_top
    execute_on = 'initial timestep_end'
  []
  [f5_outlet]
    type = SideAverageValue
    variable = f5
    boundary = outlet_top
    execute_on = 'initial timestep_end'
  []
  [f6_outlet]
    type = SideAverageValue
    variable = f6
    boundary = outlet_top
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

  # Cumulative in-situ H2 generated (kg), received from the geochemistry sub-app.
  [cum_H2_mass]
    type = Receiver
    default = 0
    execute_on = 'initial timestep_end transfer'
  []

  # Reactive-sweep metrics received from the geochemistry sub-app.
  # The sub-app CSV is the authoritative same-timestep record; these receivers
  # also expose the quantities in the main-app CSV for convenience.
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
[]

[Outputs]
  file_base = HnP_metrics
  exodus = true
  csv = true
[]

# ==========================================================================
# GEOCHEMISTRY COUPLING (operator split, sequential non-iterative).
# IMPORTANT: the corresponding geochemistry sub-app must also be extended to
# 360 days before this main file is used for the final 360-day simulations.
# ==========================================================================
[MultiApps]
  [react]
    type = TransientMultiApp
    input_files = serpentinization_geochemistry_field_metrics_fracture_matrix.i
    clone_master_mesh = true
    execute_on = 'timestep_end'
  []
[]

[Transfers]
  [changes_due_to_flow]
    type = MultiAppCopyTransfer
    source_variable = 'rate_H rate_Na rate_Cl rate_Mg rate_Fe rate_SiO2 rate_O2 rate_H2O temp'
    variable        = 'pf_rate_H pf_rate_Na pf_rate_Cl pf_rate_Mg pf_rate_Fe pf_rate_SiO2 pf_rate_O2 pf_rate_H2O temperature'
    to_multi_app = react
  []
  [massfrac_from_geochem]
    type = MultiAppCopyTransfer
    source_variable = 'massfrac_H massfrac_Na massfrac_Cl massfrac_Mg massfrac_Fe massfrac_SiO2 massfrac_O2 massfrac_H2'
    variable        = 'f0 f1 f2 f3 f4 f5 f6 massfrac_H2'
    from_multi_app = react
  []

  # Send cumulative injected-water mass (kg, positive) to the geochemistry app.
  [cum_inj_H2O_to_geochem]
    type = MultiAppPostprocessorTransfer
    to_multi_app = react
    from_postprocessor = cum_inj_H2O
    to_postprocessor = cum_inj_H2O_from_main
    execute_on = 'timestep_end'
  []

  # Bring cumulative in-situ H2 generated (kg) back to the main app for CSV output.
  [cum_H2_mass_from_geochem]
    type = MultiAppPostprocessorTransfer
    from_multi_app = react
    from_postprocessor = cum_H2_mass
    to_postprocessor = cum_H2_mass
    reduction_type = average
    execute_on = 'timestep_end'
  []

  # Bring the reactive-sweep metrics back to the main app for convenient CSV output.
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
[]
