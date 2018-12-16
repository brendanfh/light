import sequtils
import strutils
import ./types
import ./tokens

type
  LightExprType* = enum
    leNull     = 0,
    leVar      = 1,
    leNumLit   = 2,
    leOp       = 3,
    leAssign   = 4,
    leIf       = 5,
    leWhile    = 6,
    leBreak    = 7,
    leFuncCall = 8,
    leFuncDef  = 9,

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
    of leIf, leWhile:
      condition*: LightExpr
      body*: seq[LightExpr]
      else_body*: seq[LightExpr]
    of leFuncCall:
      func_name*: string
      params*: seq[LightExpr]
    of leFuncDef:
      def_func_name*: string
      func_body*: seq[LightExpr]
    else: 
      discard

func `$`*(exp: LightExpr): string
func printExpr(exp: LightExpr, ind: int): string

func multiline(things: seq[LightExpr], ind: int): string =
  return things.foldl(a & printExpr(b, ind) & "\n", "")[0..^2]

func printExpr(exp: LightExpr, ind: int): string =
  let ts = strutils.repeat("    ", ind)
  ts & (
    case exp.kind:
      of leVar: "var[" & $exp.var_name & "]"
      of leNumLit: "num[" & $exp.value & "]"
      of leOp: "op[" & $exp.operation & ", " & printExpr(exp.left, 0) & ", " & printExpr(exp.right, 0) & "]"
      of leAssign: "assignment[" & $exp.variable & ", " & printExpr(exp.expression, 0) & "]"
      of leIf: "if [" & printExpr(exp.condition, 0) & "] {\n" & multiline(exp.body, ind + 1) & "\n" & ts & "} else {\n" & multiline(exp.else_body, ind + 1) & "\n" & ts & "}"
      of leWhile: "while [" & printExpr(exp.condition, 0) & "] {\n" & multiline(exp.body, ind + 1) & "\n" & ts & "}"
      of leBreak: "break"
      of leFuncCall: "funcCall[" & exp.func_name & ", " & $exp.params & "]"
      of leFuncDef: "funcDef[" & exp.def_func_name & "] {\n" & multiline(exp.func_body, ind + 1) & "\n" & ts & "}"
      of leNull: "NullExpr[]"
      else: "UNDEFINED[]"
  )

func `$`*(exp: LightExpr): string =
  printExpr(exp, 0)
