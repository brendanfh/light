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
  PContext = object
    p_1, p_2, p_3, p_4: LightInt

  PStack = ref object
    stack: ref array[MAX_STACK_HEIGHT, PContext]
    size: int

  LightWorker = ref object
    mem_1*, mem_2*, mem_3*, mem_4*: LightInt
    mem_5*, mem_6*, mem_7*, mem_8*: LightInt
    pos_x*, pos_y*: LightInt
    param_stack: PStack

  ExecFuncs* = TableRef[string, proc(ec: ExecutionContext, args: openarray[LightInt]): LightInt]

  DefFuncs = ref object
    params: seq[LightVariable]
    body: seq[LightExpr]

  ExecutionContext* = ref object
    worker*: LightWorker
    builtin_functions: ExecFuncs
    defined_functions: TableRef[string, DefFuncs]
    running: bool
    break_flag: bool

proc Top(pstack: PStack): var PContext =
  pstack.stack[pstack.size - 1]

proc Push(pstack: var PStack, ctx: PContext) =
  pstack.stack[pstack.size] = ctx
  pstack.size += 1

proc Pop(pstack: var PStack): PContext =
  pstack.size -= 1

proc MakeEmptyWorker(): LightWorker =
  let worker = LightWorker()
  let param_ctx = new(array[MAX_STACK_HEIGHT, PContext])
  worker.param_stack = PStack(
    stack: param_ctx,
    size: 1
  )
  worker

proc MakeExecutionContext*(funcs: ExecFuncs): ExecutionContext =
  let worker = MakeEmptyWorker()
  let defined_functions = newTable[string, DefFuncs]()
  ExecutionContext(
    worker: worker,
    builtin_functions: funcs,
    defined_functions: defined_functions,
    running: false,
    break_flag: false,
  )

proc ExecuteLines(ec: ExecutionContext, lines: seq[LightExpr]): LightInt

func GetVar(worker: LightWorker, variable: LightVariable): LightInt =
  case variable:
  of var_m1: worker.mem_1
  of var_m2: worker.mem_2
  of var_m3: worker.mem_3
  of var_m4: worker.mem_4
  of var_m5: worker.mem_5
  of var_m6: worker.mem_6
  of var_m7: worker.mem_7
  of var_m8: worker.mem_8
  of var_x: worker.pos_x
  of var_y: worker.pos_y
  of var_p1: worker.param_stack.Top().p_1
  of var_p2: worker.param_stack.Top().p_2
  of var_p3: worker.param_stack.Top().p_3
  of var_p4: worker.param_stack.Top().p_4

func SetVar(worker: LightWorker, variable: LightVariable, value: LightInt): LightInt =
  case variable:
  of var_m1: worker.mem_1 = value
  of var_m2: worker.mem_2 = value
  of var_m3: worker.mem_3 = value
  of var_m4: worker.mem_4 = value
  of var_m5: worker.mem_5 = value
  of var_m6: worker.mem_6 = value
  of var_m7: worker.mem_7 = value
  of var_m8: worker.mem_8 = value
  of var_x: worker.pos_x = value
  of var_y: worker.pos_y = value
  of var_p1: worker.param_stack.Top().p_1 = value
  of var_p2: worker.param_stack.Top().p_2 = value
  of var_p3: worker.param_stack.Top().p_3 = value
  of var_p4: worker.param_stack.Top().p_4 = value

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

    EvalOperation(exp.operation, left, right)

  of leAssign:
    let value = EvalExpr(ec, exp.expression)
    SetVar(ec.worker, exp.variable, value)

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

      var ind: int = 0
      var params: PContext

      for par in ec.defined_functions[exp.func_name].params:
        if ind >= args.len:
          raise newException(ValueError, "Too few parameters to function call")

        if   par == var_p1: params.p_1 = args[ind]
        elif par == var_p2: params.p_2 = args[ind]
        elif par == var_p3: params.p_3 = args[ind]
        elif par == var_p4: params.p_4 = args[ind]

        ind += 1

      ec.worker.param_stack.Push(params)
      let ret = ExecuteLines(ec, ec.defined_functions[exp.func_name].body)
      discard ec.worker.param_stack.Pop()
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
