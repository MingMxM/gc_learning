#include "gc_learningApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
gc_learningApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

gc_learningApp::gc_learningApp(const InputParameters & parameters) : MooseApp(parameters)
{
  gc_learningApp::registerAll(_factory, _action_factory, _syntax);
}

gc_learningApp::~gc_learningApp() {}

void
gc_learningApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<gc_learningApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"gc_learningApp"});
  Registry::registerActionsTo(af, {"gc_learningApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
gc_learningApp::registerApps()
{
  registerApp(gc_learningApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
gc_learningApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  gc_learningApp::registerAll(f, af, s);
}
extern "C" void
gc_learningApp__registerApps()
{
  gc_learningApp::registerApps();
}
