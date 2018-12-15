import os
import tables
import ./types/types
import ./types/ast
import ./program
import ../board/board
import ../gfx/window

type
  LightWorker = ref object
    var_1*, var_2*, var_3*, var_4*: LightInt
    var_5*, var_6*, var_7*, var_8*: LightInt
    pos_x*, pos_y*: LightInt

  ExecFuncs = TableRef[string, proc(ec: ExecutionContext, args: openarray[LightInt]): LightInt]

  ExecutionContext* = ref object
    worker*: LightWorker
    builtin_functions: ExecFuncs
    defined_functions: TableRef[string, seq[LightExpr]]
    running: bool

proc MakeEmptyWorker(): LightWorker =
  LightWorker()

proc MakeExecutionContext*(funcs: ExecFuncs): ExecutionContext =
  let worker = MakeEmptyWorker()
  let defined_functions = newTable[string, seq[LightExpr]]()
  ExecutionContext(
    worker: worker,
    builtin_functions: funcs,
    defined_functions: defined_functions,
    running: false
  )

proc ExecuteLines(ec: ExecutionContext, lines: seq[LightExpr]): LightInt

func GetVar(worker: LightWorker, variable: LightVariable): LightInt =
  case variable:
  of var1: worker.var_1
  of var2: worker.var_2
  of var3: worker.var_3
  of var4: worker.var_4
  of var5: worker.var_5
  of var6: worker.var_6
  of var7: worker.var_7
  of var8: worker.var_8
  of varX: worker.pos_x
  of varY: worker.pos_y

func SetVar(worker: LightWorker, variable: LightVariable, value: LightInt): LightInt =
  case variable:
  of var1: worker.var_1 = value
  of var2: worker.var_2 = value
  of var3: worker.var_3 = value
  of var4: worker.var_4 = value
  of var5: worker.var_5 = value
  of var6: worker.var_6 = value
  of var7: worker.var_7 = value
  of var8: worker.var_8 = value
  of varX: worker.pos_X = value
  of varY: worker.pos_Y = value

  value

proc EvalExpr(ec: ExecutionContext, exp: LightExpr): LightInt =
  case exp.kind:
  of leNull:
    0

  of leVar:
    GetVar(ec.worker, exp.var_name)

  of leNumLit:
    exp.value

  of leOp:
    let
      left = EvalExpr(ec, exp.left)
      right = EvalExpr(ec, exp.right)

    case exp.operation:
    of loAdd: left + right
    of loSub: left - right
    of loMul: left * right
    of loDiv: left div right
    of loMod: left mod right
    of loGt:
      if left > right: 1
      else: 0
    of loGte:
      if left >= right: 1
      else: 0
    of loLt:
      if left < right: 1
      else: 0
    of loLte:
      if left <= right: 1
      else: 0
    of loEq:
      if left == right: 1
      else: 0
    of loNeq:
      if left != right: 1
      else: 0

  of leAssign:
    let value = EvalExpr(ec, exp.expression)
    SetVar(ec.worker, exp.variable, value)

  of leIf:
    let cond = EvalExpr(ec, exp.condition)
    if cond != 0:
      ExecuteLines(ec, exp.body)
    else:
      0

  of leWhile:
    while ec.running:
      let cond = EvalExpr(ec, exp.condition)
      if cond == 0:
        break

      discard ExecuteLines(ec, exp.body)
    0

  of leFuncCall:
    if ec.builtin_functions.hasKey(exp.func_name):
      var args = newSeq[LightInt]()
      for param in exp.params:
        args.add(EvalExpr(ec, param))
      ec.builtin_functions[exp.func_name](ec, args)

    elif ec.defined_functions.hasKey(exp.func_name):
      ExecuteLines(ec, ec.defined_functions[exp.func_name])

    else:
      raise newException(ValueError, "Cannot call undefined function")

  of leFuncDef:
    if ec.defined_functions.hasKey(exp.def_func_name):
      raise newException(ValueError, "Cannot redefine function")

    else:
      ec.defined_functions[exp.def_func_name] = exp.func_body
      1
  else:
    0

proc ExecuteLines(ec: ExecutionContext, lines: seq[LightExpr]): LightInt =
  if not ec.running:
    return 0

  var last: LightInt
  for line in lines:
    last = EvalExpr(ec, line)
    if not ec.running: break
  last

proc ExecuteProgram*(ec: ExecutionContext, prog: LightProgram): LightInt =
  ec.running = true
  ExecuteLines(ec, prog.code)

proc StopExecution*(ec: ExecutionContext) =
  ec.running = false
