import os
import tables
import ./types/types
import ./types/ast
import ./utils
import ./program
import ../board/board
import ../gfx/window

const MAX_STACK_HEIGHT = 400

type
  Environment* = ref object
    values: TableRef[LightVariable, LightInt]
    parent: Environment

  ExecFuncs* = TableRef[string, proc(ec: ExecutionContext, args: openarray[LightInt]): LightInt]

  DefFuncs = ref object
    params: seq[LightVariable]
    body: seq[LightExpr]

  ExecutionContext* = ref object
    vars: Environment
    builtin_functions: ExecFuncs
    defined_functions: TableRef[string, DefFuncs]
    running: bool
    break_flag: bool

proc MakeEnvironment*(parent: Environment): Environment =
  let values = newTable[LightVariable, LightInt]()
  Environment(
    values: values,
    parent: parent
  )

proc MakeExecutionContext*(funcs: ExecFuncs): ExecutionContext =
  let env = MakeEnvironment(nil)
  let defined_functions = newTable[string, DefFuncs]()
  ExecutionContext(
    vars: env,
    builtin_functions: funcs,
    defined_functions: defined_functions,
    running: false,
    break_flag: false,
  )

proc ExecuteLines(ec: ExecutionContext, lines: seq[LightExpr]): LightInt

func GetVar(env: Environment, variable: LightVariable): LightInt =
  if hasKey(env.values, variable):
    return env.values[variable]
  
  if env.parent == nil:
    raise newException(ValueError, "Undefined variable: " & variable)
  
  return env.parent.GetVar(variable)

func SetVar(env: Environment, variable: LightVariable, value: LightInt): LightInt =
  if hasKey(env.values, variable):
    env.values[variable] = value
    value

  else:
    if env.parent == nil:
      raise newException(ValueError, "Undefined variable")

    env.parent.SetVar(variable, value)

func NewVar(env: Environment, variable: LightVariable) =
  if hasKey(env.values, variable):
    raise newException(ValueError, "Reclaration of variable: " & variable)
  
  env.values[variable] = 0

proc EvalExpr(ec: ExecutionContext, exp: LightExpr): LightInt =
  case exp.kind:
  of leNull:
    0

  of leVar:
    GetVar(ec.vars, exp.var_name)

  of leVarDef:
    NewVar(ec.vars, exp.var_name)
    0

  of leNumLit:
    exp.value

  of leOp:
    let
      left = EvalExpr(ec, exp.left)
      right = EvalExpr(ec, exp.right)

    EvalOperation(exp.operation, left, right)

  of leAssign:
    let value = EvalExpr(ec, exp.expression)
    SetVar(ec.vars, exp.variable, value)

  of leIf:
    let cond = EvalExpr(ec, exp.condition)
    if cond != 0:
      ExecuteLines(ec, exp.body)
    else:
      ExecuteLines(ec, exp.else_body)

  of leWhile:
    var last: LightInt = 0
    while ec.running:
      let cond = EvalExpr(ec, exp.condition)
      if cond == 0:
        break
      if ec.break_flag:
        ec.break_flag = false
        break

      last = ExecuteLines(ec, exp.body)
    last

  of leBreak:
    ec.break_flag = true
    0

  of leFuncCall:
    if ec.builtin_functions.hasKey(exp.func_name):
      var args = newSeq[LightInt]()
      for param in exp.params:
        args.add(EvalExpr(ec, param))
      ec.builtin_functions[exp.func_name](ec, args)

    elif ec.defined_functions.hasKey(exp.func_name):
      var args = newSeq[LightInt]()
      for param in exp.params:
        args.add(EvalExpr(ec, param))

      var new_env = MakeEnvironment(ec.vars)

      var ind: int = 0
      for par in ec.defined_functions[exp.func_name].params:
        if ind >= args.len:
          raise newException(ValueError, "Too few parameters to function call")
        
        new_env.NewVar(par)
        discard new_env.SetVar(par, args[ind])
        ind += 1

      ec.vars = new_env
      let ret = ExecuteLines(ec, ec.defined_functions[exp.func_name].body)
      ec.vars = new_env.parent
      ret

    else:
      raise newException(ValueError, "Cannot call undefined function: " & exp.func_name)

  of leFuncDef:
    if ec.defined_functions.hasKey(exp.def_func_name):
      raise newException(ValueError, "Cannot redefine function: " & exp.def_func_name)

    else:
      ec.defined_functions[exp.def_func_name] = DefFuncs(
        params: exp.param_vars,
        body: exp.func_body
      )
      0
  else:
    0

proc ExecuteLines(ec: ExecutionContext, lines: seq[LightExpr]): LightInt =
  if not ec.running:
    return 0

  var last: LightInt = 0
  for line in lines:
    let next = EvalExpr(ec, line)
    if ec.break_flag:
      break
    last = next
    if not ec.running:
      break
  last

proc ExecuteProgram*(ec: ExecutionContext, prog: LightProgram): LightInt =
  ec.running = true
  ExecuteLines(ec, prog.code)

proc StopExecution*(ec: ExecutionContext) =
  ec.running = false
