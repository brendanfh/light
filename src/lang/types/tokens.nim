import ./types

type
  LightTokenType* = enum
    ltNull,
    ltVar, ltNum, ltVarDef,
    ltExprDelim,
    ltLeftParen, ltRightParen,
    ltIf, ltElse, ltWhile,
    ltBlockStart, ltBlockEnd,
    ltBreak,
    ltFunc,
    ltParamDelim,
    ltFuncDef,
    ltOp, ltEq

  LightToken* = ref object
    case kind*: LightTokenType
    of ltVar:
      var_name*: LightVariable
    of ltNum:
      value*: LightInt
    of ltFunc, ltFuncDef:
      func_name*: string
    of ltOp:
      operation*: LightOperation
    else:
      discard

proc `$`*(token: LightToken): string =
  return
    case token.kind:
    of ltNull: "NullToken"
    of ltVar: "VarToken[" & $token.var_name & "]"
    of ltVarDef: "VarDefToken"
    of ltEq: "EqualsToken"
    of ltNum: "NumberToken[" & $token.value & "]"
    of ltExprDelim: "ExprDelimToken"
    of ltLeftParen: "LeftParenToken"
    of ltRightParen: "RightParenToken"
    of ltIf: "IfToken"
    of ltWhile: "WhileToken"
    of ltBreak: "BreakToken"
    of ltBlockStart: "BlockStartToken"
    of ltBlockEnd: "BlockEndToken"
    of ltFunc: "FunctionToken[" & token.func_name & "]"
    of ltParamDelim: "ParamDelimToken"
    of ltFuncDef: "FuncDefToken[" & token.func_name & "]"
    of ltOp: "OpeartionToken[" & $token.operation & "]"
    else: "UndefinedToken"