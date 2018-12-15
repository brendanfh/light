import ./types
import ./tokens

type
  LightExprType* = enum
    leNull     = 0,
    leVar      = 1,
    leNumLit   = 2,
    leOp       = 3,
    leAssign   = 4,
    leLabel    = 5,
    leGoto     = 6,
    leIf       = 7,
    leWhile    = 8,
    leBreak    = 9,
    leFuncCall = 10,
    leFuncDef  = 11,

  LightExpr* = ref object
    case kind*: LightExprType
    of leVar:
      var_name*: LightVariable
    of leNumLit:
      value*: LightInt
    of leOp:
      left*: LightExpr
      right*: LightExpr
      operation*: LightOperation
    of leAssign:
      variable*: LightVariable
      expression*: LightExpr
    of leLabel, leGoto:
      label*: string
    of leIf, leWhile:
      condition*: LightExpr
      body*: seq[LightExpr]
    of leFuncCall:
      func_name*: string
      params*: seq[LightExpr]
    of leFuncDef:
      def_func_name*: string
      func_body*: seq[LightExpr]
    else: 
      discard

proc `$`*(exp: LightExpr): string =
  case exp.kind:
  of leVar: "Var[" & $exp.var_name & "]"
  of leNumLit: "Num[" & $exp.value & "]"
  of leOp: "Operation[" & $exp.operation & ", " & $exp.left & ", " & $exp.right & "]"
  of leAssign: "Assignment[" & $exp.variable & ", " & $exp.expression & "]"
  of leLabel: "Label[" & $exp.label & "]"
  of leGoto: "Goto[" & $exp.label & "]"
  of leIf: "If[" & $exp.condition & " -> " & $exp.body & "]"
  of leWhile: "While[" & $exp.condition & " -> " & $exp.body & "]"
  of leBreak: "Break"
  of leFuncCall: "FuncCall[" & exp.func_name & ", " & $exp.params & "]"
  of leFuncDef: "FuncDef[" & exp.def_func_name & ", " & $exp.func_body & "]"
  else: ""