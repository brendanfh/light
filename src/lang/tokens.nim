import ./types

type
  LightTokenType* = enum
    ltNull,
    ltVar, ltNum,
    ltExprDelim,
    ltLabel, ltGoto,
    ltIf, ltWhile,
    ltBlockStart, ltBlockEnd,
    ltBreak,
    ltFunc,
    ltParamStart, ltParamEnd,
    ltParamDelim,
    ltOp, ltEq

  LightToken* = ref object
    case kind*: LightTokenType
    of ltVar:
      var_name*: LightVariable
    of ltNum:
      value*: LightInt
    of ltLabel:
      label_name*: string
    of ltFunc:
      func_name*: string
    of ltOp:
      operation*: LightOperation
    else:
      discard

func `$`*(variable: LightVariable): string =
  case variable:
  of var1: "MEM_1"
  of var2: "MEM_2"
  of var3: "MEM_3"
  of var4: "MEM_4"
  of var5: "MEM_5"
  of var6: "MEM_6"
  of var7: "MEM_7"
  of var8: "MEM_8"
  of var9: "POS_X"
  of var10: "POS_Y"

proc `$`*(token: LightToken): string =
  return
    case token.kind:
    of ltNull: "NullToken"
    of ltVar: "VarToken[" & $token.var_name & "]"
    of ltEq: "EqualsToken"
    of ltNum: "NumberToken[" & $token.value & "]"
    of ltExprDelim: "ExprDelimToken"
    of ltLabel: "LabelToken[" & token.label_name & "]"
    of ltGoto: "GotoToken"
    of ltIf: "IfToken"
    of ltWhile: "WhileToken"
    of ltBreak: "BreakToken"
    of ltBlockStart: "BlockStartToken"
    of ltBlockEnd: "BlockEndToken"
    of ltFunc: "FunctionToken[" & token.func_name & "]"
    of ltParamStart: "ParamStartToken"
    of ltParamEnd: "ParamEndToken"
    of ltParamDelim: "ParamDelimToken"
    of ltOp: "OpeartionToken[" & $token.operation & "]"
    else: "UndefinedToken"