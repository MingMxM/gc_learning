# ==========================================================================
# 8-component PorousFlow HUFF-AND-PUFF (inject acid -> soak -> produce)
# Unified baseline version for comparison with the injection-production cases.
# Fracture + matrix mesh, closed unit, isothermal 200 C.
#
# COMMON BASELINE PARAMETERS
#   Formation pressure       = 25 MPa
#   Injection BHP            = 40 MPa
#   Production BHP           = 10 MPa
#   Matrix porosity          = 0.05 (constant)
#   Matrix permeability      = 1e-17 m^2 (~0.01 mD)
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
p_inject   = 40e6
p_produce  = 10e6

# ---- HnP schedule (days), total = 360 days ----
inject_days  = 30
soak_days    = 300
produce_days = 30
t_inject_end  = ${fparse inject_days * 86400}
t_soak_end    = ${fparse (inject_days + soak_days) * 86400}
t_produce_end = ${fparse (inject_days + soak_days + produce_days) * 86400}

# ---- reservoir pressure / properties ----
p_init   = 25e6
phi_mat  = 0.05
phi_frac = 0.35
k_mat    = 1e-17           # ~0.01 mD
k_frac   = 5e-14           # ~50 mD

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
    character = -1
    enable = false
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
    character = -1
    enable = false
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
    character = -1
    enable = false
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
    character = -1
    enable = false
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
    character = -1
    enable = false
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
    character = -1
    enable = false
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
    character = -1
    enable = false
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
    character = -1
    enable = false
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
# Injection: acid-composition BCs + injection Peaceman well.
# Soak: all well objects and composition BCs off.
# Production: production Peaceman well only.
# --------------------------------------------------------------------------
[Controls]
  [do_inject]
    type = TimePeriod
    enable_objects = 'BCs::inj_H BCs::inj_Na BCs::inj_Cl BCs::inj_Mg BCs::inj_Fe BCs::inj_SiO2 BCs::inj_O2 DiracKernels::inj_well_H DiracKernels::inj_well_Na DiracKernels::inj_well_Cl DiracKernels::inj_well_Mg DiracKernels::inj_well_Fe DiracKernels::inj_well_SiO2 DiracKernels::inj_well_O2 DiracKernels::inj_well_H2O'
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

  end_time = ${t_produce_end}
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
  [cum_inj_H2O]
    type = PorousFlowPlotQuantity
    uo = injected_H2O
    execute_on = 'initial timestep_end'
  []
  [cum_prod_H2O]
    type = PorousFlowPlotQuantity
    uo = produced_H2O
    execute_on = 'initial timestep_end'
  []
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
[]

[Outputs]
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
    input_files = serpentinization_geochemistry_field.i
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
    source_variable = 'massfrac_H massfrac_Na massfrac_Cl massfrac_Mg massfrac_Fe massfrac_SiO2 massfrac_O2'
    variable        = 'f0 f1 f2 f3 f4 f5 f6'
    from_multi_app = react
  []
[]
