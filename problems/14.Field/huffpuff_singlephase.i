# ==========================================================================
# Single-phase PorousFlow water injection MAIN APP
# Fracture + matrix mesh (Gmsh), stimulated GeoH2 huff-and-puff setup.
#
# STEP 1 (this file): water-only single-phase flow.
#   - Bottom edge "inlet" horizontal wellbore, water injected here.
#   - Fracture and matrix have different porosity / permeability (by block).
#   - Isothermal at 200 C.
#
# Injection: 1.5 m3/day per metre thickness (2D unit-thickness model).
#   inlet = fracture bottom (0.1 m wide), flux_total = 0.15 kg/m2/s.
#
# COUPLING HOOKS (for later geochemistry, GeoTES-style operator split):
#   - solute mass-fraction vars f0..f6 and save_component_rate_in are left
#     commented but pre-structured, so the 8-component version drops in.
#   - MultiApps / Transfers block stubbed at the bottom.
# Mesh blocks : "fracture", "matrix"
# Mesh sides  : "inlet"(bottom), "outlet_top", "left", "right", "bottom"
#   NOTE: the Gmsh file names the wellbore/injection edge "inlet"
#         (fracture bottom). "bottom" is the matrix part of the bottom edge.
# ==========================================================================

# ---- injection at the wellbore (fracture bottom) ----
# 1.5 m3/day/m -> 0.15 kg/m2/s over the 0.1 m fracture inlet
flux_total = 0.15          # kg/m2/s (water), per unit thickness

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
  # gravity = '0 0 0'
[]

[Variables]
  [porepressure]
    initial_condition = ${p_init}
  []
[]

# --------------------------------------------------------------------------
# Single-phase, fully saturated water flow.
# save_component_rate_in kept (single component = water) so the coupling
# machinery is already wired; extend to 8 rates when geochemistry is added.
# --------------------------------------------------------------------------
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

# --------------------------------------------------------------------------
# Block-wise properties: fracture vs matrix.
# --------------------------------------------------------------------------
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
# Boundary conditions.
#   inlet (fracture bottom, the wellbore): fixed-rate water injection.
#   outlet_top: fixed pressure (far boundary held at formation pressure).
#   left: symmetry (no-flux, natural) ; right/bottom: no-flux (natural).
# --------------------------------------------------------------------------
[BCs]
  [inject_water]
    type = PorousFlowSink
    variable = porepressure
    boundary = inlet
    flux_function = ${fparse -flux_total}
    fluid_phase = 0
  []
#  [outlet_pressure]
#    type = DirichletBC
#    variable = porepressure
#    boundary = outlet_top
#    value = ${p_init}
#  []
[]

[AuxVariables]
  [temp]
    initial_condition = 200        # 200 C isothermal
  []
  # transport rate saved by the Action (kg/s at each node) -> geochem later
  [rate_H2O]
  []
[]

[AuxKernels]
[]

[Preconditioning]
  active = basic
  [basic]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_hypre_type'
    petsc_options_value = ' hypre    boomeramg'
  []
  [strong]
    type = SMP
    full = true
    petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix'
    petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
    petsc_options_value = ' asm      ilu           NONZERO                   2'
  []
[]

[Executioner]
  type = Transient
  solve_type = Newton
  automatic_scaling = true

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 100
    growth_factor = 1.5
    cutback_factor = 0.5
    optimal_iterations = 10
  []

  end_time = 2592000            # 30 days (1 month injection, single phase test)
  dtmax = 86400
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
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
[]

[Outputs]
  exodus = true
  csv = true
[]

# ==========================================================================
# GEOCHEMISTRY COUPLING (add later, GeoTES-style operator split)
# When ready, extend to 8 components:
#   - add Variables f0..f6 (H+ Na+ Cl- Mg++ Fe++ SiO2 O2), keep porepressure.
#   - mass_fraction_vars = 'f0 f1 f2 f3 f4 f5 f6' in the Action.
#   - save_component_rate_in = 'rate_H rate_Na ... rate_H2O' (8 rates).
#   - per-solute injection + PorousFlowOutflowBC as in the flow-through file.
#
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
