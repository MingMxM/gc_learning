//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "gc_learningTestApp.h"
#include "gc_learningApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
gc_learningTestApp::validParams()
{
  InputParameters params = gc_learningApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

gc_learningTestApp::gc_learningTestApp(const InputParameters & parameters) : MooseApp(parameters)
{
  gc_learningTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

gc_learningTestApp::~gc_learningTestApp() {}

void
gc_learningTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  gc_learningApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"gc_learningTestApp"});
    Registry::registerActionsTo(af, {"gc_learningTestApp"});
  }
}

void
gc_learningTestApp::registerApps()
{
  registerApp(gc_learningApp);
  registerApp(gc_learningTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
gc_learningTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  gc_learningTestApp::registerAll(f, af, s);
}
extern "C" void
gc_learningTestApp__registerApps()
{
  gc_learningTestApp::registerApps();
}
